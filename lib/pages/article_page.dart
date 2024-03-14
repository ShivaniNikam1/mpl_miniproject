import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArtilcePage extends StatelessWidget {
  final String url;
  const ArtilcePage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      body: SizedBox(
        height: h,
        child: ClipRRect(child: WebViewWidget(controller: controller)),
      ),
    );
  }
}
