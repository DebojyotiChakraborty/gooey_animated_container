import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gooey/gooey.dart';

class GooeyMenu extends StatefulWidget {
  const GooeyMenu({super.key});

  @override
  State<GooeyMenu> createState() => _GooeyMenuState();
}

class _GooeyMenuState extends State<GooeyMenu> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Cue.onToggle(
      toggled: _open,
      skipFirstAnimation: false,
      motion: .smooth(),
      acts: [.slideY(to: .1)],
      child: GooeyZone(
        color: Colors.black,
        blurRadius: 14,
        threshold: .5,
        shouldSnapshot: false,
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          spacing: 8,
          children: [
            Padding(
              padding: const .only(left: 32),
              child: Actor(
                acts: [
                  .slideY(to: 1),
                  .scale(to: 0, alignment: .bottomCenter, motion: .bouncy()),
                  .unfocus(),
                ],
                child: GooeyBlob(
                  child: IconButton(
                    style: IconButton.styleFrom(
                      padding: .all(8),
                      tapTargetSize: .shrinkWrap,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Iconsax.more),
                    onPressed: () {
                      setState(() {
                        _open = !_open;
                      });
                    },
                  ),
                ),
              ),
            ),
            GooeyBlob(
              shape: .superEllipse(.circular(32)),
              child: Actor(
                acts: [
                  .sizedClip(from: .zero, alignment: .bottomCenter),
                  .fadeIn(),
                  .focus(from: 6),
                  .zoomIn(),
                ],
                child: _MenuItems(
                  onItemTap: () {
                    setState(() {
                      _open = false;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItems extends StatelessWidget {
  const _MenuItems({required this.onItemTap});
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const .symmetric(vertical: 8, horizontal: 4),
        child: Material(
          type: .transparency,
          shape: RoundedSuperellipseBorder(
            borderRadius: .circular(24),
          ),
          clipBehavior: .hardEdge,
          child: Column(
            children: [
              for (var index = 0; index < 3; index++)
                ListTile(
                  visualDensity: const VisualDensity(vertical: -2),
                  leading: Icon(
                    [Iconsax.edit, Iconsax.layer, Iconsax.filter][index],
                    color: colors.onPrimary,
                    size: 20,
                  ),
                  title: Text(
                    ['Edit', 'Layers', 'Filter'][index],
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onPrimary),
                  ),
                  onTap: onItemTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
