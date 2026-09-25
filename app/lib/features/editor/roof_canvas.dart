import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerScrollEvent;

import '../../core/geo.dart';
import 'editor_controller.dart';

/// Interactive plan-view canvas: roofs, obstacles, placed modules.
///
/// Supports panning (drag), zooming (pinch / buttons) and context-dependent
/// taps (select / place module / add obstacle). In select mode, dragging a
/// roof or obstacle moves it (roofs cannot be rotated – the compass
/// orientation is only set via its input field); dragging empty space pans.
class RoofCanvas extends StatefulWidget {
  final EditorController controller;

  const RoofCanvas({super.key, required this.controller});

  @override
  State<RoofCanvas> createState() => _RoofCanvasState();
}

class _RoofCanvasState extends State<RoofCanvas> {
  static const double minZoom = 5; // pixels per meter
  static const double maxZoom = 200;

  double zoom = 40; // pixels per meter
  Offset pan = const Offset(80, 80);
  Size? _size;

  /// Whether the view has been fitted to all objects once.
  bool _fitted = false;

  /// Fits the view so all objects are visible with a margin.
  void _fitView() {
    final c = widget.controller;
    if (_size == null) return;

    var minX = double.infinity, minY = double.infinity,
        maxX = -double.infinity, maxY = -double.infinity;
    void include(List<Pt> poly) {
      for (final p in poly) {
        minX = math.min(minX, p.x);
        minY = math.min(minY, p.y);
        maxX = math.max(maxX, p.x);
        maxY = math.max(maxY, p.y);
      }
    }

    for (final r in c.roofs) {
      final poly = Pt.decode(r.polygon);
      if (poly.isNotEmpty) include(poly);
    }
    for (final o in c.obstacles) {
      final poly = Pt.decode(o.polygon);
      if (poly.isNotEmpty) include(poly);
    }

    const marginPx = 60.0;
    if (minX > maxX) {
      // No objects yet: center the origin.
      zoom = 40;
      pan = Offset(_size!.width / 2, _size!.height / 2);
      return;
    }

    // Solve for a zoom that fits the bounding box with [marginPx] padding.
    final worldW = maxX - minX;
    final worldH = maxY - minY;
    final z = math.min(
      (_size!.width - 2 * marginPx) / (worldW + 1),
      (_size!.height - 2 * marginPx) / (worldH + 1),
    );
    zoom = z.clamp(minZoom, maxZoom);

    final cx = (minX + maxX) / 2;
    final cy = (minY + maxY) / 2;
    pan = Offset(
      _size!.width / 2 - cx * zoom,
      _size!.height / 2 - cy * zoom,
    );
  }

  /// Focal point at the start of a pinch (used to derive pan deltas, since
  /// [ScaleUpdateDetails] has no `delta`).
  Offset? _focalStart;

  /// Screen-space pan origin while a single pointer is down.
  Offset? _panStart;

  /// The world-space pan offset at the start of a single-pointer drag.
  Offset _panStartOffset = Offset.zero;



  /// Live drag state while moving a selected object (select mode).
  Offset? _dragStart;

  void setZoom(double z) {
    final clamped = z.clamp(minZoom, maxZoom);
    if (clamped == zoom) return;
    // Keep the world point under the screen center fixed while zooming.
    final size = _size ?? const Size(800, 600);
    final centerWorld = _toWorld(size.center(Offset.zero));
    setState(() {
      final c = size.center(Offset.zero);
      zoom = clamped;
      pan = Offset(c.dx - centerWorld.x * clamped, c.dy - centerWorld.y * clamped);
    });
  }

  /// Zooms by [factor] keeping the world point under [anchorScreen] fixed.
  /// Used for mouse-wheel zoom so the view stays centered on the cursor.
  void _zoomAt(Offset anchorScreen, double factor) {
    final newZoom = (zoom * factor).clamp(minZoom, maxZoom);
    if (newZoom == zoom) return;
    final worldAnchor = _toWorld(anchorScreen);
    setState(() {
      zoom = newZoom;
      pan = Offset(
        anchorScreen.dx - worldAnchor.x * zoom,
        anchorScreen.dy - worldAnchor.y * zoom,
      );
    });
  }

  Pt _toWorld(Offset screen) =>
      Pt((screen.dx - pan.dx) / zoom, (screen.dy - pan.dy) / zoom);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(builder: (context, constraints) {
                _size = constraints.biggest;
                if (!_fitted && widget.controller.roofs.isNotEmpty) {
                  _fitted = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(_fitView);
                  });
                }
                return Listener(
                  // Mouse-wheel zoom, anchored at the cursor position.
                  onPointerSignal: (e) {
                    if (e is PointerScrollEvent &&
                        e.buttons == 0) { // no other button held
                      final dy = e.scrollDelta.dy;
                      if (dy == 0) return;
                      // Scroll up = zoom in. Scale factor per notch.
                      final factor = dy > 0 ? 1 / 1.1 : 1.1;
                      _zoomAt(e.localPosition, factor);
                    }
                  },
                  child: GestureDetector(
                  // One recognizer handles both: a single pointer pans or
                  // moves an object, two pointers pinch-zoom.
                  onScaleStart: (d) {
                    final c = widget.controller;
                    // In select mode a drag on an object moves it instead of
                    // panning (only when the gesture starts with one pointer).
                    if (d.pointerCount == 1 &&
                        c.mode == EditorMode.select &&
                        c.canEdit) {
                      final hit = c.hitAt(_toWorld(d.localFocalPoint));
                      if (hit != null) {
                        _dragStart = d.localFocalPoint;
                        c.beginMove(hit);
                        return;
                      }
                    }
                    // Single pointer on whitespace: record the focal point and
                    // current pan so we can compute a screen-space delta.
                    _panStart = d.localFocalPoint;
                    _panStartOffset = pan;
                  },
                  onScaleUpdate: (d) {
                    // A single-pointer drag that started on an object moves
                    // it (not the canvas). Route the world-space delta to the
                    // controller; ignore any second pointer (pinch) while a
                    // move is in progress.
                    if (_dragStart != null && _panStart == null) {
                      final c = widget.controller;
                      if (d.pointerCount >= 2) return; // pinch cancels the move
                      final from = _toWorld(_dragStart!);
                      final to = _toWorld(d.localFocalPoint);
                      c.updateMove(from, to);
                      return;
                    }
                    if (d.pointerCount >= 2) {
                      // Pinch zoom: keep the world point under the focal
                      // point fixed while changing the scale.
                      _focalStart ??= d.focalPoint;
                      // d.scale is relative to the start of this gesture.
                      final factor = d.scale;
                      if ((factor - 1).abs() < 0.01) return;
                      final newZoom = (zoom * factor).clamp(minZoom, maxZoom);
                      if (newZoom == zoom) return;
                      final focal = d.focalPoint;
                      final worldFocal = _toWorld(focal);
                      setState(() {
                        zoom = newZoom;
                        pan = Offset(
                          focal.dx - worldFocal.x * zoom,
                          focal.dy - worldFocal.y * zoom,
                        );
                      });
                    } else if (_panStart != null) {
                      // One pointer on whitespace: pan by the screen-space
                      // delta from where the drag started.
                      final delta = d.localFocalPoint - _panStart!;
                      setState(() => pan = Offset(
                            _panStartOffset.dx + delta.dx,
                            _panStartOffset.dy + delta.dy,
                          ));
                    }
                  },
                  onScaleEnd: (_) {
                    _panStart = null;
                    _focalStart = null;
                    if (_dragStart != null) {
                      _dragStart = null;
                      widget.controller.endMove();
                    }
                  },

                  onTapUp: (d) {
                    final world = _toWorld(d.localPosition);
                    final c = widget.controller;
                    if (c.placing) {
                      c.placeModuleAt(world);
                    } else if (c.addingObstacle) {
                      c.addObstacleAt(world);
                    } else {
                      c.selectAt(world);
                    }
                  },

                  child: RepaintBoundary(
                    // The painter draws the whole world (Size.infinite), so it
                    // must be clipped to this widget's bounds — otherwise paint
                    // leaks onto sibling widgets (e.g. the control panel next to
                    // the canvas).
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _CanvasPainter(
                          c: widget.controller,
                          zoom: zoom,
                          pan: pan,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              }),
            ),

            // Compass rose, fixed in the bottom border (bottom right).
            Positioned(
              right: 12,
              bottom: 12,
              child: const _CompassRose(),
            ),

            // Zoom controls, top right corner.
            Positioned(
              right: 12,
              top: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _zoomButton(Icons.add, () => setZoom(zoom * 1.4), 'Hineinzoomen'),
                  const SizedBox(height: 6),
                  _zoomButton(Icons.remove, () => setZoom(zoom / 1.4), 'Herauszoomen'),
                  const SizedBox(height: 6),
                  _zoomButton(Icons.fit_screen, () => setState(_fitView), 'Ansicht anpassen'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Fixed compass rose (north always on top).
class _CompassRose extends StatelessWidget {
  const _CompassRose();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(64, 64),
      painter: _CompassRosePainter(),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    // Background circle.
    canvas.drawCircle(
      center,
      r - 1,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      center,
      r - 1,
      Paint()
        ..color = const Color(0xFF546E7A)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Needle: north (red) / south (grey).
    final tipN = Offset(center.dx, center.dy - (r - 8));
    final tipS = Offset(center.dx, center.dy + r - 14);
    canvas.drawPath(
      Path()
        ..moveTo(tipN.dx, tipN.dy)
        ..lineTo(center.dx - 4, center.dy)
        ..lineTo(center.dx + 4, center.dy)
        ..close(),
      Paint()..color = const Color(0xFFD32F2F),
    );
    canvas.drawPath(
      Path()
        ..moveTo(tipS.dx, tipS.dy)
        ..lineTo(center.dx - 4, center.dy)
        ..lineTo(center.dx + 4, center.dy)
        ..close(),
      Paint()..color = const Color(0xFF78909C),
    );

    // Cardinal labels.
    void label(String text, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    label('N', center + Offset(0, -(r - 12)));
    label('S', center + Offset(0, r - 12));
    label('O', center + Offset(r - 10, 0));
    label('W', center + Offset(-(r - 10), 0));

    // Center dot.
    canvas.drawCircle(center, 2, Paint()..color = const Color(0xFF37474F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CanvasPainter extends CustomPainter {
  final EditorController c;
  final double zoom;
  final Offset pan;

  static const _stringColors = [
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF00897B),
    Color(0xFFE53935),
    Color(0xFF3949AB),
    Color(0xFFC0CA33),
  ];

  _CanvasPainter({
    required this.c,
    required this.zoom,
    required this.pan,
  });

  Color _roofColor(double azimuthDeg) {
    final a = azimuthDeg % 360;
    if (a >= 135 && a <= 225) return const Color(0xFF2E7D32); // south
    if (a >= 45 && a < 135) return const Color(0xFF7CB342); // east
    if (a > 225 && a < 315) return const Color(0xFF00838F); // west
    return const Color(0xFF757575); // north
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Roof labels are collected here and drawn last so they stay in the
    // foreground, on top of obstacles and placed modules.
    final labels = <(Pt, String, Color)>[];

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFECEFF1),
    );

    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(zoom);

    _drawGrid(canvas, size);

    for (final roof in c.roofs) {
      final poly = Pt.decode(roof.polygon);
      if (poly.length < 3) continue;
      final path = _pathOf(poly);
      final selected = roof.id == c.selectedRoofId;
      canvas.drawPath(
        path,
        Paint()
          ..color = _roofColor(roof.azimuthDeg).withValues(alpha: 0.35)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = selected ? const Color(0xFFD32F2F) : const Color(0xFF37474F)
          ..strokeWidth = (selected ? 3 : 2) / zoom
          ..style = PaintingStyle.stroke,
      );

      // Collect labels to draw in a final foreground pass (after obstacles
      // and modules) so they are never hidden behind other objects.
      final area = polygonArea(poly);
      labels.add((polygonCentroid(poly),
          '${roof.name}\n${area.toStringAsFixed(1)} m²',
          const Color(0xFF263238)));

      // For a rectangle the long edges are (0,1) and (2,3); short ones
      // (1,2) and (3,0). Label the first long edge with the length and
      // the first short edge with the width.
      if (poly.length == 4) {
        final longEdge = _edgeMidpoint(poly[0], poly[1]);
        final shortEdge = _edgeMidpoint(poly[1], poly[2]);
        // Offset the edge labels slightly outward from the centroid.
        final centroid = polygonCentroid(poly);
        labels.add((
            longEdge.translate(_outward(longEdge, centroid).x * 0.4,
                _outward(longEdge, centroid).y * 0.4),
            '${roof.lengthM.toStringAsFixed(1)} m',
            const Color(0xFF455A64)));
        labels.add((
            shortEdge.translate(_outward(shortEdge, centroid).x * 0.4,
                _outward(shortEdge, centroid).y * 0.4),
            '${roof.widthM.toStringAsFixed(1)} m',
            const Color(0xFF455A64)));
      }
    }

    for (final o in c.obstacles) {
      final poly = Pt.decode(o.polygon);
      if (poly.length < 3) continue;
      final path = _pathOf(poly);
      final selected = o.id == c.selectedObstacleId;
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF455A64).withValues(alpha: 0.8)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = selected ? const Color(0xFFD32F2F) : const Color(0xFF263238)
          ..strokeWidth = (selected ? 3 : 1) / zoom
          ..style = PaintingStyle.stroke,
      );
    }

    final moduleLabels = c.moduleLabels;

    for (final pm in c.placed) {
      final type = c.moduleTypeOf(pm.moduleId);
      if (type == null) continue;
      final w = type.widthMm / 1000;
      final h = type.heightMm / 1000;
      final stringId = c.placedToString[pm.id];
      final color = stringId == null
          ? const Color(0xFF90A4AE)
          : _stringColors[stringId % _stringColors.length];
      final selected = pm.id == c.selectedPlacedId;

      canvas.save();
      canvas.translate(pm.x, pm.y);
      canvas.rotate(pm.rotationDeg * math.pi / 180);
      final rect = Rect.fromCenter(
          center: Offset.zero, width: w, height: h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(0.02)),
        Paint()..color = color.withValues(alpha: 0.85),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(0.02)),
        Paint()
          ..color = selected ? const Color(0xFFD32F2F) : const Color(0xFF263238)
          ..strokeWidth = (selected ? 3 : 1) / zoom
          ..style = PaintingStyle.stroke,
      );
      final label = moduleLabels[pm.id];
      if (label != null && math.min(w, h) * zoom >= 14) {
        _drawModuleLabel(canvas, label, w, h);
      }
      canvas.restore();
    }

    // Foreground pass: roof labels on top of everything.
    for (final (pos, text, color) in labels) {
      _drawLabel(canvas, pos, text, color);
    }

    canvas.restore();
  }

  static Pt _edgeMidpoint(Pt a, Pt b) => Pt((a.x + b.x) / 2, (a.y + b.y) / 2);

  /// Unit vector from [from] pointing away from [toward].
  static Pt _outward(Pt from, Pt toward) {
    final dx = from.x - toward.x;
    final dy = from.y - toward.y;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-9) return const Pt(0, -1);
    return Pt(dx / len, dy / len);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final worldLeft = -pan.dx / zoom;
    final worldTop = -pan.dy / zoom;
    final worldRight = (size.width - pan.dx) / zoom;
    final worldBottom = (size.height - pan.dy) / zoom;

    final minor = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..strokeWidth = 1 / zoom;
    final major = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1.5 / zoom;

    for (var x = worldLeft.floorToDouble();
        x <= worldRight.ceilToDouble();
        x++) {
      final paint = x % 5 == 0 ? major : minor;
      canvas.drawLine(Offset(x, worldTop), Offset(x, worldBottom), paint);
    }
    for (var y = worldTop.floorToDouble();
        y <= worldBottom.ceilToDouble();
        y++) {
      final paint = y % 5 == 0 ? major : minor;
      canvas.drawLine(Offset(worldLeft, y), Offset(worldRight, y), paint);
    }
  }

  /// Draws a small black band with the module's `{roofId}.{stringId}.{moduleId}`
  /// label along its top edge, in the module's local (rotated) frame. Text keeps
  /// a constant screen size at any zoom and shrinks to fit narrow modules.
  void _drawModuleLabel(Canvas canvas, String label, double w, double h) {
    final bandH = math.min(h * 0.9, 13 / zoom);
    canvas.drawRect(
      Rect.fromLTWH(-w / 2, -h / 2, w, bandH),
      Paint()..color = const Color(0xCC000000),
    );
    var fontSize = 12 / zoom; // ~12px on screen at any zoom
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final maxW = w - 0.02;
    if (tp.width > maxW && tp.width > 0) {
      fontSize *= maxW / tp.width; // shrink to fit the module width
      tp.text = TextSpan(
        text: label,
        style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: fontSize),
      );
      tp.layout();
    }
    tp.paint(
        canvas,
        Offset(-w / 2 + (w - tp.width) / 2, -h / 2 + (bandH - tp.height) / 2));
  }

  void _drawLabel(Canvas canvas, Pt pos, String text, Color color) {
    // Text is drawn in screen space so it keeps a constant size at any zoom.
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    // The canvas is currently transformed by (translate(pan) + scale(zoom)).
    // Reset to identity so the text is painted at a fixed screen size, then
    // position it centered on `pos` converted to screen coordinates.
    canvas.save();
    canvas.transform(Matrix4.identity().storage);
    final screen = Offset(pos.x * zoom + pan.dx, pos.y * zoom + pan.dy);
    tp.paint(canvas, screen - Offset(tp.width / 2, tp.height / 2));
    canvas.restore();
  }

  Path _pathOf(List<Pt> poly) {
    final path = Path();
    if (poly.isEmpty) return path;
    path.moveTo(poly.first.x, poly.first.y);
    for (final p in poly.skip(1)) {
      path.lineTo(p.x, p.y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}
