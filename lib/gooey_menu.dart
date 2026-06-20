import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gooey/gooey.dart';

/// A draggable, direction-aware gooey context menu.
///
/// Keeps the original single-`GooeyZone` morph (so the button and menu merge
/// gooily, driven by `Cue.onToggle`) but adds three things:
///  1. the collapsed button can be dragged anywhere on the surface;
///  2. the menu expands away from the nearest screen edge — a button in the
///     top-right opens toward the bottom-left, etc.;
///  3. tapping outside the menu closes it.
///
/// The button is always a fixed [_buttonSize] box at [_offset]; only the menu's
/// growth direction changes with position, so dragging never makes it jump.
class GooeyMenu extends StatefulWidget {
  const GooeyMenu({super.key});

  @override
  State<GooeyMenu> createState() => _GooeyMenuState();
}

class _GooeyMenuState extends State<GooeyMenu> {
  static const double _buttonSize = 56;

  bool _open = false;

  /// Top-left of the button within the surface. Null until first laid out
  /// (defaults to centered).
  Offset? _offset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final surface = constraints.biggest;
        final defaultOffset = Offset(
          (surface.width - _buttonSize) / 2,
          (surface.height - _buttonSize) / 2,
        );
        final offset = _offset ?? defaultOffset;
        final center = offset + const Offset(_buttonSize / 2, _buttonSize / 2);

        // Grow toward the open space: down when the button is in the top half,
        // right when it is in the left half.
        final growDown = center.dy < surface.height / 2;
        final growRight = center.dx < surface.width / 2;
        final vAnchor = growDown ? Alignment.bottomCenter : Alignment.topCenter;

        void onDrag(DragUpdateDetails details) {
          setState(() {
            final next = (_offset ?? defaultOffset) + details.delta;
            _offset = Offset(
              next.dx.clamp(0.0, surface.width - _buttonSize),
              next.dy.clamp(0.0, surface.height - _buttonSize),
            );
          });
        }

        // The collapsed button: draggable when closed, and the morph anchor.
        final button = Actor(
          acts: [
            Act.slideY(to: growDown ? 1 : -1),
            Act.scale(to: 0, alignment: vAnchor, motion: .bouncy()),
            .unfocus(),
          ],
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _open = !_open),
            onPanUpdate: _open ? null : onDrag,
            child: const GooeyBlob(child: _TriggerIcon()),
          ),
        );

        // The expanding menu card, revealed from the edge nearest the button.
        final menu = GooeyBlob(
          shape: BlobShape.superEllipse(BorderRadius.circular(32)),
          child: Actor(
            acts: [
              Act.sizedClip(from: NSize.zero, alignment: vAnchor),
              .fadeIn(),
              .focus(from: 6),
              .zoomIn(),
            ],
            // Absorb taps on the card so only taps *outside* it close the menu.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: _MenuItems(onItemTap: () => setState(() => _open = false)),
            ),
          ),
        );

        final unit = Cue.onToggle(
          toggled: _open,
          motion: .smooth(),
          // The original's subtle settle, in the growth direction.
          acts: [Act.slideY(to: growDown ? 0.1 : -0.1)],
          child: GooeyZone(
            color: Colors.black,
            blurRadius: 14,
            threshold: 0.5,
            shouldSnapshot: false,
            child: Column(
              mainAxisSize: .min,
              // verticalDirection.up puts the first child (button) at the
              // bottom, so the menu grows upward above it.
              verticalDirection:
                  growDown ? VerticalDirection.down : VerticalDirection.up,
              crossAxisAlignment:
                  growRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              spacing: 8,
              children: [button, menu],
            ),
          ),
        );

        return Stack(
          children: [
            const Positioned.fill(child: _DragHint()),
            // Tap-outside-to-close catcher. Kept ALWAYS present (only absorbing
            // taps while open) so the children list never reshuffles — otherwise
            // inserting/removing it would re-key the menu's Cue.onToggle element
            // by index, destroying its animation controller and snapping the
            // morph instead of animating it.
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_open,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _open = false),
                ),
              ),
            ),
            // Anchor the button's edge so it stays put while the menu grows.
            Positioned(
              key: const ValueKey('gooey-menu-unit'),
              left: growRight ? offset.dx : null,
              right: growRight ? null : surface.width - (offset.dx + _buttonSize),
              top: growDown ? offset.dy : null,
              bottom: growDown ? null : surface.height - (offset.dy + _buttonSize),
              child: unit,
            ),
          ],
        );
      },
    );
  }
}

/// The blob content of the collapsed button: a "more" icon sized to a circle.
class _TriggerIcon extends StatelessWidget {
  const _TriggerIcon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Icon(Iconsax.more, color: Colors.white, size: 24),
    );
  }
}

/// A faint instruction shown behind the button on the drag surface.
class _DragHint extends StatelessWidget {
  const _DragHint();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Text(
          'Drag the button, then tap to open.\n'
          'The menu expands toward the open space.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black.withValues(alpha: 0.35)),
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
            mainAxisSize: .min,
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
