import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gooey/gooey.dart';

class GooeyAnimatedFab extends StatelessWidget {
  const GooeyAnimatedFab({super.key});

  @override
  Widget build(BuildContext context) {
    return CueModalTransition(
      alignment: .bottomCenter,
      motion: .bouncy(),
      hideTriggerOnTransition: true,
      triggerBuilder: (_, showModal) {
        return FloatingActionButton(
          onPressed: showModal,
          child: const Icon(Iconsax.add),
        );
      },
      builder: (context, rect) {
        return GooeyZone(
          color: Colors.black,
          threshold: .6,
          blurRadius: 6,
          sharpness: .5,
          overpaintFactor: 0,
          shouldSnapshot: false,
          child: Column(
            mainAxisSize: .min,
            spacing: 8,
            children: [
              for (var index = 0; index < 3; index++)
                Actor(
                  acts: [
                    .translateFromGlobalRect(rect),
                    .slideX(from: index.isEven ? .1 : -.15, motion: .bouncy()),
                    .scale(from: .3 * index),
                    StretchAct.keyframed(
                      frames: .fractional(
                        [
                          .key(Stretch(y: 1.2), at: 0.5),
                          .key(Stretch.none, at: 1.0),
                        ],
                        duration: 250.ms,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                  child: GooeyBlob(
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.transparent,
                      heroTag: 'icon_$index',
                      child: Actor(
                        acts: [
                          .zoomIn(),
                          .fadeIn(),
                          .focus(),
                        ],
                        child: Icon([Iconsax.edit, Iconsax.layer, Iconsax.filter][index], size: 20),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              Actor(
                acts: [
                  // stretch a bit for better gooey effect
                  StretchAct.keyframed(
                    alignment: .bottomCenter,
                    frames: .fractional(
                      [
                        .key(Stretch(y: 1.2, x: .9), at: 0.5),
                        .key(Stretch.none, at: 1.0),
                      ],
                      duration: 250.ms,
                      curve: Curves.easeInOut,
                    ),
                  ),
                ],
                child: GooeyBlob(
                  child: FloatingActionButton(
                    onPressed: () => Navigator.pop(context),
                    child: Actor(
                      acts: [
                        .scale(to: 1.2),
                        .rotate(to: 45),
                      ],
                      child: const Icon(Iconsax.add),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
