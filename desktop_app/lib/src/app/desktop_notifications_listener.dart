import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class DesktopNotificationsListener extends StatelessWidget {
  const DesktopNotificationsListener({
    super.key,
    required this.scaffoldMessengerKey,
    required this.child,
  });

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Selector<DesktopAppState, int>(
      selector: (_, state) => state.notificationNonce,
      builder: (context, _, __) {
        final message = context
            .read<DesktopAppState>()
            .consumePendingNotification();
        if (message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(content: Text(message)),
            );
          });
        }
        return child;
      },
    );
  }
}
