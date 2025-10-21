import 'package:flutter/material.dart';
import 'package:flutter_llama/flutter_llama.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Llama Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Llama Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterLlama _llama = FlutterLlama.instance;
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _modelPath = '';
  bool _isModelLoaded = false;
  bool _isLoading = false;
  String _response = '';
  String _statusMessage = 'No model loaded';
  Map<String, dynamic>? _modelInfo;

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickModel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gguf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _modelPath = result.files.single.path!;
          _statusMessage = 'Model selected: $_modelPath';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _loadModel() async {
    if (_modelPath.isEmpty) {
      setState(() {
        _statusMessage = 'Please select a model first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading model...';
    });

    try {
      final config = LlamaConfig(
        modelPath: _modelPath,
        nThreads: 4,
        nGpuLayers: -1, // All layers on GPU
        contextSize: 2048,
        batchSize: 512,
        useGpu: true,
        verbose: true,
      );

      final success = await _llama.loadModel(config);

      if (success) {
        final info = await _llama.getModelInfo();
        setState(() {
          _isModelLoaded = true;
          _modelInfo = info;
          _statusMessage = 'Model loaded successfully!';
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to load model';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _unloadModel() async {
    try {
      await _llama.unloadModel();
      setState(() {
        _isModelLoaded = false;
        _modelInfo = null;
        _statusMessage = 'Model unloaded';
        _response = '';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error unloading: $e';
      });
    }
  }

  Future<void> _generate() async {
    if (!_isModelLoaded) {
      setState(() {
        _statusMessage = 'Please load a model first';
      });
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a prompt';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _response = 'Generating...';
      _statusMessage = 'Generating response...';
    });

    try {
      final params = GenerationParams(
        prompt: prompt,
        temperature: 0.8,
        topP: 0.95,
        topK: 40,
        maxTokens: 512,
        repeatPenalty: 1.1,
      );

      final result = await _llama.generate(params);

      setState(() {
        _response = result.text;
        _statusMessage =
            'Generated ${result.tokensGenerated} tokens in ${result.generationTimeMs}ms '
            '(${result.tokensPerSecond.toStringAsFixed(2)} tok/s)';
      });

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _response = '';
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateStream() async {
    if (!_isModelLoaded) {
      setState(() {
        _statusMessage = 'Please load a model first';
      });
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a prompt';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
      _statusMessage = 'Streaming response...';
    });

    try {
      final params = GenerationParams(
        prompt: prompt,
        temperature: 0.8,
        topP: 0.95,
        topK: 40,
        maxTokens: 512,
        repeatPenalty: 1.1,
      );

      await for (final token in _llama.generateStream(params)) {
        setState(() {
          _response += token;
        });

        // Auto-scroll as we receive tokens
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeOut,
          );
        }
      }

      setState(() {
        _statusMessage = 'Streaming complete!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Model info section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    if (_modelInfo != null) ...[
                      const SizedBox(height: 8),
                      Text('Parameters: ${_modelInfo!['nParams']}'),
                      Text('Layers: ${_modelInfo!['nLayers']}'),
                      Text('Context: ${_modelInfo!['contextSize']}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Model controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickModel,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Pick Model'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : (_isModelLoaded ? _unloadModel : _loadModel),
                    icon: Icon(_isModelLoaded ? Icons.close : Icons.download),
                    label: Text(_isModelLoaded ? 'Unload' : 'Load'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Prompt input
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Enter your prompt',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Generate buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || !_isModelLoaded ? null : _generate,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Generate'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading || !_isModelLoaded ? null : _generateStream,
                    icon: const Icon(Icons.stream),
                    label: const Text('Stream'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Response section
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Response',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Text(
                            _response.isEmpty ? 'No response yet' : _response,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
