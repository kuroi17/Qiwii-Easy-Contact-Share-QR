import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SetPinModal extends StatefulWidget {
  const SetPinModal({
    super.key,
    required this.onPinConfirmed,
  });

  final ValueChanged<String> onPinConfirmed;

  @override
  State<SetPinModal> createState() => _SetPinModalState();
}

class _SetPinModalState extends State<SetPinModal> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += digit;
          if (_pin.length == 4) {
            // Move to confirmation step automatically
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  _isConfirming = true;
                });
              }
            });
          }
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
          if (_confirmPin.length == 4) {
            if (_pin == _confirmPin) {
              Navigator.pop(context);
              widget.onPinConfirmed(_pin);
            } else {
              _errorMessage = 'PINs do not match. Please try again.';
              _confirmPin = '';
              _isConfirming = false;
              _pin = '';
            }
          }
        }
      }
    });
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = _isConfirming ? _confirmPin : _pin;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 24),
          ),
          const SizedBox(height: 14),

          // Title & Subtitle
          Text(
            _isConfirming ? 'Confirm 4-Digit PIN' : 'Create 4-Digit PIN',
            style: AppTextStyles.display(fontSize: 22, color: AppColors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            _isConfirming
                ? 'Re-enter your 4-digit PIN for confirmation.'
                : 'The receiver will need this PIN to unlock your contacts.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.ink2, fontSize: 13.5),
          ),
          const SizedBox(height: 24),

          // PIN Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < currentCode.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.accent : Colors.transparent,
                  border: Border.all(
                    color: isFilled ? AppColors.accent : AppColors.ink3,
                    width: 2,
                  ),
                ),
              );
            }),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Keypad
          _NumericKeypad(
            onDigit: _onDigitPressed,
            onBackspace: _onBackspace,
          ),
        ],
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) {
                  return const SizedBox(width: 72, height: 60);
                }
                if (key == '⌫') {
                  return InkWell(
                    onTap: onBackspace,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 72,
                      height: 60,
                      alignment: Alignment.center,
                      child: const Icon(Icons.backspace_outlined, color: AppColors.ink, size: 22),
                    ),
                  );
                }
                return InkWell(
                  onTap: () => onDigit(key),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 72,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      key,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
