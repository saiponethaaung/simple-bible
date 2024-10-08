import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_bible/models/base_model.dart';

// ignore: must_be_immutable
class ZoomWidget extends StatelessWidget {
  Widget child;

  ZoomWidget(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    BaseModel baseModel = Provider.of<BaseModel>(context);

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: child,
          ),
          Positioned(
            bottom: 15,
            right: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      if (baseModel.fontScale > 1) {
                        baseModel.fontScale -= 0.1;
                      }
                    },
                    child: const Icon(Icons.remove),
                  ),
                  Container(
                    width: 1,
                    decoration: const BoxDecoration(color: Colors.grey),
                    height: 30,
                  ),
                  TextButton(
                    onPressed: () {
                      baseModel.fontScale += 0.1;
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
