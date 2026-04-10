import 'package:flutter/material.dart';

import 'screens/mail_command_center_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MailApp());
}

class MailApp extends StatelessWidget {
  const MailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mail Command Center',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: appBackgroundDecoration()),
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.1,
                  colors: [
                    Color(0x2915766E),
                    Colors.transparent,
                  ],
                  stops: [0, 0.45],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 0.95,
                  colors: [
                    Color(0x24C75B39),
                    Colors.transparent,
                  ],
                  stops: [0, 0.4],
                ),
              ),
            ),
            const SafeArea(
              child: Center(
                child: MailCommandCenterScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
