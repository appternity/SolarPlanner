# Canvas Gestures (`roof_canvas.dart`)

## Mouse-wheel zoom

A `Listener.onPointerSignal` wrapping the `GestureDetector` catches `PointerScrollEvent` (import from `package:flutter/gestures.dart`, NOT rendering/material) and calls `_zoomAt`. The zoom anchors at the **cursor position** (not screen center). Scroll up = zoom in.

## Whitespace panning (select mode only)

In select mode, `onScaleStart` hit-tests the focal point:
- If it hits an object → record `_dragStart`, defer to `_dragUpdate`.
- If whitespace → record `_panStart` (focal point) + `_panStartOffset` (current pan), and `onScaleUpdate` pans by the screen-space delta.

**Gotcha:** Store the focal point at start, not the pan offset — computing `d.focalPoint - d.focalPoint` is always zero and the pan silently does nothing.

## World painter must stay clipped

The canvas uses `CustomPaint(size: Size.infinite)` so the painter can draw the whole world; it is wrapped in a `ClipRect` (inside the `RepaintBoundary`). Without the clip, roof/module paint leaks onto sibling widgets — e.g., through the transparent control panel. Regression-tested: 'world painter is clipped to the canvas bounds' in `roof_canvas_test.dart`.

## Resizable right pane (`editor_screen.dart`, wide layout only)

An 8 px `_PanelResizeHandle` between canvas and panel (1 px visible line, `SystemMouseCursors.resizeLeftRight` on hover via MouseRegion). Panel width starts at `_minPanelWidth = 340` (also the minimum); build clamps it to `window − _handleWidth(8) − _minCanvasWidth(200)` so dragging wider than the window can never overflow. Width is session state, not persisted. Regression-tested in `test/editor_screen_resize_test.dart`.

## Move semantics

- All objects (roofs, obstacles, modules) are moveable via drag.
- Moving a roof moves its assigned `placedModules` (by `roofId`) along with it.
- Moving a module does NOT affect its roof.

## Gesture wiring gotcha (Windows/desktop)

The canvas uses a single `onScaleStart/Update/End` recognizer for pan+move. In `onScaleUpdate`, a drag that started on an object (`_dragStart != null && _panStart == null`) MUST route the world delta to `controller.updateMove(from, to)` — an early `return` there silently disables all object moving (pan still works, so it's easy to miss). Controller unit tests call `beginMove/updateMove/endMove` directly and do NOT catch this; a widget test that performs `tester.startGesture(...).moveBy()` on the canvas is required. See 'dragging a roof' in `roof_canvas_test.dart`.

## Roof-move module drift (critical)

When a roof is dragged, its modules must be repositioned from their **fixed start positions** (captured in `beginMove` into `_moveStartModulePos`), NOT by adding the cumulative delta to each module's *current* position. The gesture reports a growing `to - from` delta every update; re-applying it to an already-moved position makes panels drift away quadratically. The roof itself is safe because it's recomputed from the fixed `_moveStartPoly`. Regression-tested with multiple incremental updates in `editor_controller_test.dart` (group 'move').
