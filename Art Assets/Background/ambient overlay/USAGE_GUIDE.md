# Usage Guide

## Playback

Play `frame_000.png` through `frame_023.png` at 12 frames per second, then return to frame 000. All frames share one registered origin and canvas.

## Layering

- Alpha: ordinary transparency compositing
- Add / Screen: useful for embers, spores, fireflies, dust, and arcane wisps
- Multiply / Alpha: useful for Shadow Veil

Blend recommendations are starting points. Test the renderer, color space, HDR settings, premultiplied-alpha behavior, and background contrast in the actual project.

## Recommended backgrounds

`CATALOG.csv` and `ANIMATION_METADATA.json` identify the recommended background range for every effect. Pale fog, mist, ash, snow, dust, glow, and bubbles are primarily intended for dark or mid-tone scenes. Shadow Veil is primarily intended for light or mid-tone scenes. Effects are not promised to remain equally visible on every background.

## Sprite sheets

Each sprite sheet uses six columns and four rows. Frames are ordered left-to-right, top-to-bottom. Every cell is 640 x 360.

## Scale

Use the 1280 x 720 sequence as the supplied master. The 640 x 360 sequence is an exact convenience export. Scale to the target viewport while preserving aspect ratio or crop deliberately.

## Performance

Full-screen transparent animation can consume texture memory. Prefer sprite sheets, texture atlases, compressed import formats, or the half-size sequence when the target platform requires it. Profile on the actual device.

## Accessibility and gameplay clarity

Do not let weather or fog obscure critical enemies, projectiles, text, or navigation. Adjust opacity, tint, density, layer order, or visibility based on gameplay state.
