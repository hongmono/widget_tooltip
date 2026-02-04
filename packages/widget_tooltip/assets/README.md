# Assets Guide

This folder contains demo assets for the README.

## Required GIFs

Record these GIFs from the example app (`cd example && flutter run`):

### 1. `demo.gif` (Main demo)
- **Tab**: Any
- **Content**: Quick overview showing basic tooltip interaction
- **Duration**: 5-8 seconds
- **Size**: ~400px width

### 2. `trigger_modes.gif`
- **Tab**: Triggers
- **Content**: Show tap, long press, hover, and manual control in sequence
- **Duration**: 8-10 seconds
- **Steps**:
  1. Tap "Tap me" button
  2. Long press "Hold me" button
  3. Hover over "Hover me" (if on desktop)
  4. Click Show/Hide buttons for manual control

### 3. `auto_position.gif`
- **Tab**: Features
- **Content**: Scroll the page to show how tooltip position changes based on screen location
- **Duration**: 5-8 seconds
- **Steps**:
  1. Tap "Auto Position" button when it's in top half (tooltip appears below)
  2. Scroll down so button is in bottom half
  3. Tap again (tooltip appears above)

### 4. `directions.gif`
- **Tab**: Directions
- **Content**: Show all four directions
- **Duration**: 6-8 seconds
- **Steps**:
  1. Tap Top button
  2. Tap Bottom button
  3. Tap Left button
  4. Tap Right button

### 5. `styling.gif`
- **Tab**: Features → Custom Styling section
- **Content**: Show different styled tooltips
- **Duration**: 5-6 seconds
- **Steps**:
  1. Tap Success chip
  2. Tap Warning chip
  3. Tap Error chip

## Recording Tips

### macOS Simulator Recording
```bash
# Start recording
xcrun simctl io booted recordVideo demo.mp4

# Stop with Ctrl+C, then convert to GIF
ffmpeg -i demo.mp4 -vf "fps=15,scale=400:-1:flags=lanczos" -loop 0 demo.gif
```

### Alternative: Use Gifski
1. Record screen with QuickTime or simulator
2. Convert with [Gifski](https://gif.ski/) for better quality

### Recommended Settings
- **FPS**: 15 (good balance of quality/size)
- **Width**: 400px (scales down from retina)
- **Loop**: Infinite
- **Quality**: Medium-High

## After Recording

1. Place GIFs in this folder
2. Uncomment the image tags in `../README.md`
3. Commit and push
