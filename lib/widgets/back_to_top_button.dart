import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackToTopButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisible;

  const BackToTopButton({
    super.key,
    required this.onPressed,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: isVisible ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: isVisible
            ? Container(
                margin: const EdgeInsets.only(bottom: 20, right: 16),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xFF2D3748),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onPressed();
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Back to top',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
