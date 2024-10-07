import 'package:flutter/material.dart';

class MainScreenWidget extends StatelessWidget {
  final Widget child;
  const MainScreenWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [Colors.blue, Colors.green],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        color: Color.fromRGBO(246, 239, 209, 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: child,
          ),
          Container(
            margin: const EdgeInsets.all(30),
            child: const Text(
              'by Place in Heart',
              style: TextStyle(color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }
}
