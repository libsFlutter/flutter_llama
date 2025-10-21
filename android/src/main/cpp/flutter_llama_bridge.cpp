/*
 * Flutter Llama - JNI Bridge for Android
 * 
 * This file provides JNI bindings between Kotlin and llama.cpp
 */

#include <jni.h>
#include <string>
#include <vector>
#include <mutex>
#include <android/log.h>

#define LOG_TAG "FlutterLlamaBridge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Include llama.cpp headers
#include "llama.h"
#include "common.h"
#include "sampling.h"

// Global state
static llama_model* g_model = nullptr;
static llama_context* g_context = nullptr;
static llama_sampling_context* g_sampling = nullptr;
static std::mutex g_mutex;
static bool g_should_stop = false;
static std::vector<llama_token> g_stream_tokens;
static size_t g_stream_pos = 0;
static llama_batch g_batch;
static bool g_batch_initialized = false;

extern "C" {

// Initialize and load model
JNIEXPORT jboolean JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeInitModel(
    JNIEnv* env,
    jobject thiz,
    jstring model_path,
    jint n_threads,
    jint n_gpu_layers,
    jint context_size,
    jint batch_size,
    jboolean use_gpu,
    jboolean verbose
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    const char* path = env->GetStringUTFChars(model_path, nullptr);
    
    LOGI("Initializing model: %s", path);
    LOGI("Threads: %d, GPU layers: %d, Context: %d", n_threads, n_gpu_layers, context_size);
    
    // Free existing model if any
    if (g_context) {
        llama_free(g_context);
        g_context = nullptr;
    }
    if (g_model) {
        llama_free_model(g_model);
        g_model = nullptr;
    }
    if (g_batch_initialized) {
        llama_batch_free(g_batch);
        g_batch_initialized = false;
    }
    
    // Initialize backend
    llama_backend_init();
    
    // Set up model parameters
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = use_gpu ? n_gpu_layers : 0;
    model_params.use_mmap = true;
    model_params.use_mlock = false;
    
    // Load model
    g_model = llama_load_model_from_file(path, model_params);
    if (!g_model) {
        LOGE("Failed to load model from: %s", path);
        env->ReleaseStringUTFChars(model_path, path);
        return JNI_FALSE;
    }
    
    // Create context
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = context_size;
    ctx_params.n_batch = batch_size;
    ctx_params.n_threads = n_threads;
    ctx_params.n_threads_batch = n_threads;
    
    g_context = llama_new_context_with_model(g_model, ctx_params);
    if (!g_context) {
        LOGE("Failed to create context");
        llama_free_model(g_model);
        g_model = nullptr;
        env->ReleaseStringUTFChars(model_path, path);
        return JNI_FALSE;
    }
    
    // Initialize batch
    g_batch = llama_batch_init(batch_size, 0, 1);
    g_batch_initialized = true;
    
    LOGI("Model loaded successfully");
    LOGI("Vocab size: %d", llama_n_vocab(g_model));
    LOGI("Context size: %d", llama_n_ctx(g_context));
    
    env->ReleaseStringUTFChars(model_path, path);
    return JNI_TRUE;
}

// Generate text
JNIEXPORT jobject JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeGenerate(
    JNIEnv* env,
    jobject thiz,
    jstring prompt,
    jfloat temperature,
    jfloat top_p,
    jint top_k,
    jint max_tokens,
    jfloat repeat_penalty
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (!g_model || !g_context) {
        LOGE("Model not loaded");
        return nullptr;
    }
    
    const char* prompt_str = env->GetStringUTFChars(prompt, nullptr);
    LOGI("Generating with prompt: %.50s...", prompt_str);
    
    std::string prompt_text(prompt_str);
    env->ReleaseStringUTFChars(prompt, prompt_str);
    
    // Tokenize prompt
    std::vector<llama_token> tokens_list;
    tokens_list.resize(prompt_text.length() + 256);
    
    int n_tokens = llama_tokenize(
        g_model,
        prompt_text.c_str(),
        prompt_text.length(),
        tokens_list.data(),
        tokens_list.size(),
        true,   // add_bos
        false   // special
    );
    
    if (n_tokens < 0) {
        LOGE("Failed to tokenize prompt");
        return nullptr;
    }
    
    tokens_list.resize(n_tokens);
    
    // Clear KV cache
    llama_kv_cache_clear(g_context);
    
    // Evaluate prompt
    llama_batch_clear(g_batch);
    for (size_t i = 0; i < tokens_list.size(); i++) {
        llama_batch_add(g_batch, tokens_list[i], i, {0}, false);
    }
    g_batch.logits[g_batch.n_tokens - 1] = true;
    
    if (llama_decode(g_context, g_batch) != 0) {
        LOGE("Failed to decode prompt");
        return nullptr;
    }
    
    // Prepare sampling params
    llama_sampling_params sparams;
    sparams.temp = temperature;
    sparams.top_p = top_p;
    sparams.top_k = top_k;
    sparams.penalty_repeat = repeat_penalty;
    sparams.penalty_last_n = 64;
    
    // Create sampling context
    llama_sampling_context* sampling = llama_sampling_init(sparams);
    if (!sampling) {
        LOGE("Failed to create sampling context");
        return nullptr;
    }
    
    // Generate tokens
    std::string result;
    int n_generated = 0;
    int n_cur = tokens_list.size();
    
    g_should_stop = false;
    
    for (int i = 0; i < max_tokens; i++) {
        if (g_should_stop) {
            LOGI("Generation stopped by user");
            break;
        }
        
        // Sample next token
        llama_token new_token = llama_sampling_sample(sampling, g_context, nullptr);
        
        // Accept token
        llama_sampling_accept(sampling, g_context, new_token, true);
        
        // Check for EOS
        if (llama_token_is_eog(g_model, new_token)) {
            LOGI("EOS token reached");
            break;
        }
        
        // Convert token to text
        char token_str[256] = {0};
        int n = llama_token_to_piece(g_model, new_token, token_str, sizeof(token_str) - 1, 0, false);
        if (n > 0) {
            token_str[n] = '\0';
            result.append(token_str);
        }
        
        // Prepare for next iteration
        llama_batch_clear(g_batch);
        llama_batch_add(g_batch, new_token, n_cur, {0}, true);
        n_cur++;
        
        if (llama_decode(g_context, g_batch) != 0) {
            LOGE("Failed to decode token");
            break;
        }
        
        n_generated++;
    }
    
    llama_sampling_free(sampling);
    
    LOGI("Generated %d tokens", n_generated);
    
    // Create GenerationResult object
    jclass result_class = env->FindClass("net/nativemind/flutter_llama/FlutterLlamaPlugin$GenerationResult");
    if (!result_class) {
        LOGE("Failed to find GenerationResult class");
        return nullptr;
    }
    
    jmethodID constructor = env->GetMethodID(result_class, "<init>", "(Ljava/lang/String;I)V");
    if (!constructor) {
        LOGE("Failed to find GenerationResult constructor");
        return nullptr;
    }
    
    jstring j_result = env->NewStringUTF(result.c_str());
    jobject generation_result = env->NewObject(result_class, constructor, j_result, n_generated);
    
    return generation_result;
}

// Initialize streaming generation
JNIEXPORT void JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeGenerateStreamInit(
    JNIEnv* env,
    jobject thiz,
    jstring prompt,
    jfloat temperature,
    jfloat top_p,
    jint top_k,
    jint max_tokens,
    jfloat repeat_penalty
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    LOGI("Initializing stream generation");
    
    if (!g_model || !g_context) {
        LOGE("Model not loaded");
        return;
    }
    
    g_should_stop = false;
    g_stream_tokens.clear();
    g_stream_pos = 0;
    
    const char* prompt_str = env->GetStringUTFChars(prompt, nullptr);
    std::string prompt_text(prompt_str);
    env->ReleaseStringUTFChars(prompt, prompt_str);
    
    // Tokenize prompt
    std::vector<llama_token> prompt_tokens;
    prompt_tokens.resize(prompt_text.length() + 256);
    
    int n_tokens = llama_tokenize(
        g_model,
        prompt_text.c_str(),
        prompt_text.length(),
        prompt_tokens.data(),
        prompt_tokens.size(),
        true,   // add_bos
        false   // special
    );
    
    if (n_tokens < 0) {
        LOGE("Failed to tokenize prompt for streaming");
        return;
    }
    
    prompt_tokens.resize(n_tokens);
    
    // Clear KV cache
    llama_kv_cache_clear(g_context);
    
    // Evaluate prompt
    llama_batch_clear(g_batch);
    for (size_t i = 0; i < prompt_tokens.size(); i++) {
        llama_batch_add(g_batch, prompt_tokens[i], i, {0}, false);
    }
    g_batch.logits[g_batch.n_tokens - 1] = true;
    
    if (llama_decode(g_context, g_batch) != 0) {
        LOGE("Failed to decode prompt for streaming");
        return;
    }
    
    // Prepare sampling
    llama_sampling_params sparams;
    sparams.temp = temperature;
    sparams.top_p = top_p;
    sparams.top_k = top_k;
    sparams.penalty_repeat = repeat_penalty;
    sparams.penalty_last_n = 64;
    
    if (g_sampling) {
        llama_sampling_free(g_sampling);
    }
    g_sampling = llama_sampling_init(sparams);
    
    // Pre-generate all tokens
    int n_cur = prompt_tokens.size();
    for (int i = 0; i < max_tokens; i++) {
        if (g_should_stop) break;
        
        llama_token new_token = llama_sampling_sample(g_sampling, g_context, nullptr);
        llama_sampling_accept(g_sampling, g_context, new_token, true);
        
        if (llama_token_is_eog(g_model, new_token)) {
            break;
        }
        
        g_stream_tokens.push_back(new_token);
        
        llama_batch_clear(g_batch);
        llama_batch_add(g_batch, new_token, n_cur, {0}, true);
        n_cur++;
        
        if (llama_decode(g_context, g_batch) != 0) {
            break;
        }
    }
    
    LOGI("Pre-generated %zu tokens for streaming", g_stream_tokens.size());
}

// Get next token in stream
JNIEXPORT jstring JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeGenerateStreamNext(
    JNIEnv* env,
    jobject thiz
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (g_should_stop || g_stream_pos >= g_stream_tokens.size()) {
        return nullptr;
    }
    
    llama_token token = g_stream_tokens[g_stream_pos++];
    
    // Convert token to text
    char token_str[256] = {0};
    int n = llama_token_to_piece(g_model, token, token_str, sizeof(token_str) - 1, 0, false);
    
    if (n > 0) {
        token_str[n] = '\0';
        return env->NewStringUTF(token_str);
    }
    
    return nullptr;
}

// End streaming generation
JNIEXPORT void JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeGenerateStreamEnd(
    JNIEnv* env,
    jobject thiz
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    LOGI("Ending stream generation");
    g_stream_tokens.clear();
    g_stream_pos = 0;
    
    if (g_sampling) {
        llama_sampling_free(g_sampling);
        g_sampling = nullptr;
    }
}

// Get model information
JNIEXPORT jobject JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeGetModelInfo(
    JNIEnv* env,
    jobject thiz
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (!g_model || !g_context) {
        return nullptr;
    }
    
    jlong n_params = llama_model_n_params(g_model);
    jint n_layers = llama_model_n_layer(g_model);
    jint context_size = llama_n_ctx(g_context);
    
    LOGI("Model info: params=%lld, layers=%d, context=%d", 
         (long long)n_params, n_layers, context_size);
    
    // Create ModelInfo object
    jclass info_class = env->FindClass("net/nativemind/flutter_llama/FlutterLlamaPlugin$ModelInfo");
    if (!info_class) {
        LOGE("Failed to find ModelInfo class");
        return nullptr;
    }
    
    jmethodID constructor = env->GetMethodID(info_class, "<init>", "(JII)V");
    if (!constructor) {
        LOGE("Failed to find ModelInfo constructor");
        return nullptr;
    }
    
    jobject model_info = env->NewObject(info_class, constructor, n_params, n_layers, context_size);
    return model_info;
}

// Free model
JNIEXPORT void JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeFreeModel(
    JNIEnv* env,
    jobject thiz
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    LOGI("Freeing model");
    
    if (g_sampling) {
        llama_sampling_free(g_sampling);
        g_sampling = nullptr;
    }
    
    if (g_batch_initialized) {
        llama_batch_free(g_batch);
        g_batch_initialized = false;
    }
    
    if (g_context) {
        llama_free(g_context);
        g_context = nullptr;
    }
    
    if (g_model) {
        llama_free_model(g_model);
        g_model = nullptr;
    }
    
    llama_backend_free();
    
    LOGI("Model freed successfully");
}

// Stop generation
JNIEXPORT void JNICALL
Java_net_nativemind_flutter_1llama_FlutterLlamaPlugin_nativeStopGeneration(
    JNIEnv* env,
    jobject thiz
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    LOGI("Stopping generation");
    g_should_stop = true;
}

} // extern "C"
