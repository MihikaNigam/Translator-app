import 'package:flutter/material.dart';

class Outputs extends StatelessWidget {
  static const routeName = '/outputs';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Center(
        child: Card(),
      ),
    );
  }
}
