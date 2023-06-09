import 'package:flutter/material.dart';

class NotifPage extends StatelessWidget {
  const NotifPage({super.key});
  static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(185, 187, 223, 1),
                Color.fromRGBO(223, 244, 243, 1),
                Color.fromRGBO(185, 187, 223, 1),
              ],

            ),
          ),
        ),
      ),
    );
  }
}
