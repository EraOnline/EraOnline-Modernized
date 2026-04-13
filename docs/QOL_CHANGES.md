# Quality of Life Changes

Intentional deviations from the original VB6 game behavior. These are improvements to the player experience that go beyond what Erling's original code did.

## Implemented

### Alpha reveal radius around player character
The original game renders trees, buildings, and other fringe/layer2 sprites fully opaque, meaning your character disappears behind them. A soft circular radius (~3 tiles) around the player renders fringe sprites with partial transparency, revealing the player underneath. Uses an offscreen canvas with `destination-out` radial gradient compositing. Only affects layer2/layer3 — ground objects and characters are always fully opaque.

## Planned

### Keep item equipped when dropping from a stack
In the original, dropping an equipped item unequips it even if you have multiple. If the player has >1 of an equipped item and drops one, keep the item equipped and just reduce the count.

### Arrow key movement while chat input is focused
In the original VB6 client, keyboard input went to the form-level KeyDown handler regardless of focus. In our web client, focusing the chat input box captures arrow keys. Arrow keys should always control movement, even when the chat box is focused (typing text still works — only arrow keys are intercepted).
