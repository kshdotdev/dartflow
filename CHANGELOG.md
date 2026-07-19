# Changelog

## 0.1.0

Initial release.

- `NodeFlow<T, E>` canvas widget: infinite pan/zoom viewport, dotted background
  grid, app-defined node visuals via `nodeBuilder`.
- `FlowController<T, E>`: nodes, edges, selection, marquee, viewport operations
  (`fitView`, `zoomTo`, `centerOnNode`), and callback seams for app-owned
  undo/persistence (`onMoveCommitted`, `onDeleted`, `onEdgesDeleted`).
- Node dragging with multi-selection, locked nodes, grid snap on commit, and
  Figma-style alignment snap guides.
- Ports and drag-to-connect with compatible-port detection, connection preview,
  and normalized `onConnect` requests.
- Edge styles: bezier, smoothstep, and straight, with optional animated
  flowing-dash rendering, hit-testing, and selection.
- Pannable minimap overlay with viewport indicator.
- Zero-dependency theming: explicit `FlowTheme`, `ThemeData` extension lookup,
  or built-in dark defaults.
