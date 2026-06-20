import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:gooey/gooey.dart';
import 'package:iconsax/iconsax.dart';

class GooeyPillButton extends StatelessWidget {
  final bool toggled;
  final Widget icon;
  final String text;

  final Widget expandedChild;
  final double expandedWidth;
  final double expandedHeight;
  final double expandedBorderRadius;

  final Color gooeyColor;
  final Spring motion;

  const GooeyPillButton({
    super.key,
    required this.toggled,
    required this.icon,
    required this.text,
    required this.expandedChild,
    this.expandedWidth = 240,
    this.expandedHeight = 200,
    this.expandedBorderRadius = 32,
    this.gooeyColor = Colors.black,
    this.motion = const Spring.smooth(),
  });

  @override
  Widget build(BuildContext context) {
    return Cue.onToggle(
      toggled: toggled,
      skipFirstAnimation: false,
      motion: motion,
      // We apply standard slide if you want similar to gooey_menu, 
      // but omitting acts on parent to act like an AnimatedContainer.
      child: GooeyZone(
        color: gooeyColor,
        blurRadius: 14,
        threshold: 0.5,
        shouldSnapshot: false,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. The Expanded Card (The "Animated Container" Target)
            GooeyBlob(
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(expandedBorderRadius),
              ),
              child: Actor(
                acts: [
                  // SizedClip from center to give the AnimatedContainer expanding feel
                  SizedClipAct(from: Size.zero, alignment: Alignment.center),
                  FadeInAct(),
                  FocusAct(from: 6),
                  ZoomInAct(),
                ],
                child: SizedBox(
                  width: expandedWidth,
                  height: expandedHeight,
                  child: expandedChild,
                ),
              ),
            ),

            // 2. The Initial Pill Shaped Button
            Actor(
              acts: [
                ScaleAct(to: 0, alignment: Alignment.center, motion: motion),
                UnfocusAct(),
              ],
              child: GooeyBlob(
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(100), // Pill Shape
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
