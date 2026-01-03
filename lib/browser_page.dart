import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserPage extends StatefulWidget {
  final String url;
  final String title;
  final Color themeColor;

  const BrowserPage({
    super.key,
    required this.url,
    required this.title,
    required this.themeColor,
  });

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // To show a spinner while loading

  @override
  void initState() {
    super.initState();

    // Initialize the Web View Controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          // RELOAD BUTTON
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. THE WEB VIEW
          WebViewWidget(controller: _controller),
          
          // 2. LOADING SPINNER (Shows on top while loading)
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: widget.themeColor),
            ),
        ],
      ),
    );
  }
}