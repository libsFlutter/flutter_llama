# CMake generated Testfile for 
# Source directory: /Users/anton/proj/ai.nativemind.net/flutter_llama/llama.cpp/examples/eval-callback
# Build directory: /Users/anton/proj/ai.nativemind.net/flutter_llama/macos/llama_build_macos/examples/eval-callback
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(test-eval-callback "/Users/anton/proj/ai.nativemind.net/flutter_llama/macos/llama_build_macos/bin/llama-eval-callback" "--hf-repo" "ggml-org/models" "--hf-file" "tinyllamas/stories260K.gguf" "--model" "stories260K.gguf" "--prompt" "hello" "--seed" "42" "-ngl" "0")
set_tests_properties(test-eval-callback PROPERTIES  LABELS "eval-callback;curl" _BACKTRACE_TRIPLES "/Users/anton/proj/ai.nativemind.net/flutter_llama/llama.cpp/examples/eval-callback/CMakeLists.txt;9;add_test;/Users/anton/proj/ai.nativemind.net/flutter_llama/llama.cpp/examples/eval-callback/CMakeLists.txt;0;")
