import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Simple bible is a simple bible application for reading scripture on different language or version of the books without any distractions. Perfect for personal devotion and worship, the app is easy to use.'),
              const SizedBox(
                height: 15,
              ),
              const Text('- Minimalist design for focused reading'),
              const Text('- Clear scripture text for easy reading'),
              const Text('- Simple navigation for quick book selection'),
              const Text(
                  '- Supports multiple versions and languages (Work in progress)'),
              const SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(children: [
                  const TextSpan(
                      text: 'Visit ', style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: 'www.placeinheart.com',
                      recognizer: TapGestureRecognizer.new()
                        ..onTap = () async {
                          await launchUrl(
                              Uri.parse('https://placeinheart.com'));
                        },
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      )),
                  const TextSpan(
                      text: ' to learn more about us.',
                      style: TextStyle(color: Colors.black)),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
