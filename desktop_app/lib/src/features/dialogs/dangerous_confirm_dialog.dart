import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/design_tokens.dart';
import '../../i18n.dart';

class DangerousConfirmDialog extends StatefulWidget {
  const DangerousConfirmDialog({
    super.key,
    required this.title,
    required this.details,
  });

  final String title;
  final String details;

  @override
  State<DangerousConfirmDialog> createState() => _DangerousConfirmDialogState();
}

class _DangerousConfirmDialogState extends State<DangerousConfirmDialog>
    with SingleTickerProviderStateMixin {
  static const int _initialSeconds = 10;
  int _secondsLeft = _initialSeconds;
  bool _acknowledged = false;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
      } else {
        setState(() {
          _secondsLeft -= 1;
        });
      }
    });

    // Setup pulse animation for warning icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final canConfirm = _acknowledged && _secondsLeft == 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Danger Banner
            _DangerBanner(brightness: brightness),

            Padding(
              padding: const EdgeInsets.all(AppTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Icon
                  Center(
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTokens.danger.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: AppTokens.danger,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTokens.spacingMd),

                  // Title
                  Text(
                    widget.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTokens.getTextPrimary(brightness),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTokens.spacingMd),

                  // Details
                  Container(
                    padding: const EdgeInsets.all(AppTokens.spacingMd),
                    decoration: BoxDecoration(
                      color: brightness == Brightness.dark
                          ? AppTokens.dangerContainerDark.withOpacity(0.3)
                          : AppTokens.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(
                        color: AppTokens.danger.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.details,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTokens.getTextPrimary(brightness),
                        fontWeight: AppTokens.weightMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: AppTokens.spacingMd),

                  // Warning message
                  Text(
                    t.text(
                      'Continue only if you fully trust this environment and understand the execution risk.',
                      'Продолжайте только если полностью доверяете окружению и понимаете риск выполнения команд.',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTokens.getTextSecondary(brightness),
                    ),
                  ),
                  SizedBox(height: AppTokens.spacingMd),

                  // Checkbox
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _acknowledged,
                    onChanged: (value) {
                      setState(() {
                        _acknowledged = value ?? false;
                      });
                    },
                    title: Text(
                      t.text(
                        'I understand and accept the risk',
                        'Я понимаю и принимаю риск',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTokens.getTextPrimary(brightness),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(height: AppTokens.spacingMd),

                  // Countdown/Status
                  _CountdownStatus(
                    secondsLeft: _secondsLeft,
                    canConfirm: canConfirm,
                  ),
                  SizedBox(height: AppTokens.spacingLg),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(t.text('Cancel', 'Отмена')),
                        ),
                      ),
                      SizedBox(width: AppTokens.spacingMd),
                      Expanded(
                        child: FilledButton(
                          onPressed: canConfirm
                              ? () => Navigator.pop(context, true)
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTokens.danger,
                            disabledBackgroundColor: AppTokens.danger.withOpacity(0.3),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(t.text('Enable', 'Включить')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Danger banner with gradient at the top of the dialog
class _DangerBanner extends StatelessWidget {
  const _DangerBanner({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTokens.danger,
            Color(0xFFDC2626),
            Color(0xFFB91C1C),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTokens.radiusLg),
          topRight: Radius.circular(AppTokens.radiusLg),
        ),
      ),
    );
  }
}

/// Countdown status indicator
class _CountdownStatus extends StatelessWidget {
  const _CountdownStatus({
    required this.secondsLeft,
    required this.canConfirm,
  });

  final int secondsLeft;
  final bool canConfirm;

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context);
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    if (secondsLeft > 0) {
      // Countdown in progress
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_clock_rounded,
                size: 18,
                color: AppTokens.warning,
              ),
              SizedBox(width: AppTokens.spacingSm),
              Text(
                t.text(
                  'Confirmation unlocks in $secondsLeft seconds...',
                  'Подтверждение станет доступно через $secondsLeft сек...',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTokens.warning,
                  fontWeight: AppTokens.weightMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTokens.spacingSm),
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTokens.getSurfaceVariant(brightness),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            ),
            child: FractionallySizedBox(
              widthFactor: 1 - (secondsLeft / 10),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTokens.warning,
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Ready to confirm
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacingMd,
          vertical: AppTokens.spacingSm,
        ),
        decoration: BoxDecoration(
          color: canConfirm
              ? AppTokens.success.withOpacity(0.1)
              : AppTokens.getSurfaceVariant(brightness),
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              canConfirm ? Icons.check_circle_rounded : Icons.lock_rounded,
              size: 18,
              color: canConfirm
                  ? AppTokens.success
                  : AppTokens.getTextTertiary(brightness),
            ),
            SizedBox(width: AppTokens.spacingSm),
            Text(
              canConfirm
                  ? t.text(
                      'Countdown complete. You can confirm now.',
                      'Отсчет завершен. Теперь можно подтвердить.',
                    )
                  : t.text(
                      'Check the box above to confirm.',
                      'Отметьте галочку выше для подтверждения.',
                    ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: canConfirm
                    ? AppTokens.success
                    : AppTokens.getTextSecondary(brightness),
                fontWeight: AppTokens.weightMedium,
              ),
            ),
          ],
        ),
      );
    }
  }
}
