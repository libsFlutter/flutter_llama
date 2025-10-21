/*
 * Flutter Llama - llama.cpp Bridge for iOS
 * 
 * This file provides a C++ bridge between Swift and llama.cpp
 */

#import <Foundation/Foundation.h>
#include <string>
#include <vector>
#include <mutex>

// Include llama.cpp headers
#include "../../llama.cpp/llama.h"
#include "../../llama.cpp/common/common.h"
#include "../../llama.cpp/common/sampling.h"

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
bool llama_init_model(
    const char* model_path,
    int32_t n_threads,
    int32_t n_gpu_layers,
    int32_t context_size,
    int32_t batch_size,
    bool use_gpu,
    bool verbose
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    NSLog(@"[llama_cpp_bridge] Initializing model: %s", model_path);
    NSLog(@"[llama_cpp_bridge] Threads: %d, GPU layers: %d, Context: %d", 
          n_threads, n_gpu_layers, context_size);
    
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
    g_model = llama_load_model_from_file(model_path, model_params);
    if (!g_model) {
        NSLog(@"[llama_cpp_bridge] Failed to load model from: %s", model_path);
        return false;
    }
    
    // Create context
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = context_size;
    ctx_params.n_batch = batch_size;
    ctx_params.n_threads = n_threads;
    ctx_params.n_threads_batch = n_threads;
    
    g_context = llama_new_context_with_model(g_model, ctx_params);
    if (!g_context) {
        NSLog(@"[llama_cpp_bridge] Failed to create context");
        llama_free_model(g_model);
        g_model = nullptr;
        return false;
    }
    
    // Initialize batch
    g_batch = llama_batch_init(batch_size, 0, 1);
    g_batch_initialized = true;
    
    NSLog(@"[llama_cpp_bridge] Model loaded successfully");
    NSLog(@"[llama_cpp_bridge] Vocab size: %d", llama_n_vocab(g_model));
    NSLog(@"[llama_cpp_bridge] Context size: %d", llama_n_ctx(g_context));
    
    return true;
}

// Generate text
bool llama_generate(
    const char* prompt,
    float temperature,
    float top_p,
    int32_t top_k,
    int32_t max_tokens,
    float repeat_penalty,
    char* output,
    int32_t output_size,
    int32_t* tokens_generated
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (!g_model || !g_context) {
        NSLog(@"[llama_cpp_bridge] Model not loaded");
        return false;
    }
    
    NSLog(@"[llama_cpp_bridge] Generating with prompt: %.50s...", prompt);
    
    std::string prompt_str(prompt);
    
    // Tokenize prompt
    std::vector<llama_token> tokens_list;
    tokens_list.resize(prompt_str.length() + 256);
    
    int n_tokens = llama_tokenize(
        g_model,
        prompt_str.c_str(),
        prompt_str.length(),
        tokens_list.data(),
        tokens_list.size(),
        true,   // add_bos
        false   // special
    );
    
    if (n_tokens < 0) {
        NSLog(@"[llama_cpp_bridge] Failed to tokenize prompt");
        return false;
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
        NSLog(@"[llama_cpp_bridge] Failed to decode prompt");
        return false;
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
        NSLog(@"[llama_cpp_bridge] Failed to create sampling context");
        return false;
    }
    
    // Generate tokens
    std::string result;
    int n_generated = 0;
    int n_cur = tokens_list.size();
    
    g_should_stop = false;
    
    for (int i = 0; i < max_tokens; i++) {
        if (g_should_stop) {
            NSLog(@"[llama_cpp_bridge] Generation stopped by user");
            break;
        }
        
        // Sample next token
        llama_token new_token = llama_sampling_sample(sampling, g_context, nullptr);
        
        // Accept token
        llama_sampling_accept(sampling, g_context, new_token, true);
        
        // Check for EOS
        if (llama_token_is_eog(g_model, new_token)) {
            NSLog(@"[llama_cpp_bridge] EOS token reached");
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
            NSLog(@"[llama_cpp_bridge] Failed to decode token");
            break;
        }
        
        n_generated++;
    }
    
    llama_sampling_free(sampling);
    
    // Copy result
    size_t copy_len = std::min(result.length(), (size_t)(output_size - 1));
    memcpy(output, result.c_str(), copy_len);
    output[copy_len] = '\0';
    *tokens_generated = n_generated;
    
    NSLog(@"[llama_cpp_bridge] Generated %d tokens", n_generated);
    return true;
}

// Initialize streaming generation
void llama_generate_stream_init(
    const char* prompt,
    float temperature,
    float top_p,
    int32_t top_k,
    int32_t max_tokens,
    float repeat_penalty
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    NSLog(@"[llama_cpp_bridge] Initializing stream generation");
    
    if (!g_model || !g_context) {
        NSLog(@"[llama_cpp_bridge] Model not loaded");
        return;
    }
    
    g_should_stop = false;
    g_stream_tokens.clear();
    g_stream_pos = 0;
    
    std::string prompt_str(prompt);
    
    // Tokenize prompt
    std::vector<llama_token> prompt_tokens;
    prompt_tokens.resize(prompt_str.length() + 256);
    
    int n_tokens = llama_tokenize(
        g_model,
        prompt_str.c_str(),
        prompt_str.length(),
        prompt_tokens.data(),
        prompt_tokens.size(),
        true,   // add_bos
        false   // special
    );
    
    if (n_tokens < 0) {
        NSLog(@"[llama_cpp_bridge] Failed to tokenize prompt for streaming");
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
        NSLog(@"[llama_cpp_bridge] Failed to decode prompt for streaming");
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
    
    NSLog(@"[llama_cpp_bridge] Pre-generated %zu tokens for streaming", g_stream_tokens.size());
}

// Get next token in stream
bool llama_generate_stream_next(
    char* output,
    int32_t output_size
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (g_should_stop || g_stream_pos >= g_stream_tokens.size()) {
        return false;
    }
    
    llama_token token = g_stream_tokens[g_stream_pos++];
    
    // Convert token to text
    char token_str[256] = {0};
    int n = llama_token_to_piece(g_model, token, token_str, sizeof(token_str) - 1, 0, false);
    
    if (n > 0) {
        token_str[n] = '\0';
        size_t copy_len = std::min((size_t)n, (size_t)(output_size - 1));
        memcpy(output, token_str, copy_len);
        output[copy_len] = '\0';
        return true;
    }
    
    return false;
}

// End streaming generation
void llama_generate_stream_end() {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    NSLog(@"[llama_cpp_bridge] Ending stream generation");
    g_stream_tokens.clear();
    g_stream_pos = 0;
    
    if (g_sampling) {
        llama_sampling_free(g_sampling);
        g_sampling = nullptr;
    }
}

// Get model information
void llama_get_model_info(
    int64_t* n_params,
    int32_t* n_layers,
    int32_t* context_size
) {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    if (!g_model || !g_context) {
        *n_params = 0;
        *n_layers = 0;
        *context_size = 0;
        return;
    }
    
    *n_params = llama_model_n_params(g_model);
    *n_layers = llama_model_n_layer(g_model);
    *context_size = llama_n_ctx(g_context);
}

// Free model
void llama_free_model() {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    NSLog(@"[llama_cpp_bridge] Freeing model");
    
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
    
    NSLog(@"[llama_cpp_bridge] Model freed successfully");
}

// Stop generation
void llama_stop_generation() {
    std::lock_guard<std::mutex> lock(g_mutex);
    
    NSLog(@"[llama_cpp_bridge] Stopping generation");
    g_should_stop = true;
}

} // extern "C"
