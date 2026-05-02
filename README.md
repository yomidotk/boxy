# 📦 Boxy

**A minimalist layout sketching tool for developers and vibe coders.**

Boxy is a Flutter-based design canvas that helps you quickly sketch UI layouts and export them as clean HTML/CSS code or polished mockup images. Perfect for rapid prototyping, wireframing, and communicating design ideas to your team.

---

## 🎯 Goal

Boxy aims to bridge the gap between design and development by providing a **fast, intuitive, and code-friendly** way to:

- **Sketch layouts visually** without the overhead of traditional design tools
- **Export production-ready HTML/CSS** with accurate positioning, sizing, and styling
- **Generate mockup images** with a realistic browser frame for presentations
- **Guide developers** with precise measurements and layer organization

Whether you're a developer who needs to quickly prototype an idea or a designer who wants to hand off pixel-perfect specs, Boxy keeps things simple and focused.

---

## ✨ Features

### 🧩 Component Library
Drag and drop **8 essential UI components**:
- **Box** – Generic container/div
- **Image** – Image placeholder
- **Button** – Interactive button
- **Text** – Editable text element
- **Card** – Elevated card component
- **Logo** – Branding/icon placeholder
- **NavBar** – Customizable navigation bar with links
- **Dropdown** – Dropdown menu placeholder

### 🎨 Visual Editing
- **Free Dragging** – Smooth, unrestricted positioning (no snapping)
- **Rotation** – Rotate any element 0-360° with a dedicated handle
- **Resizing** – Drag the bottom-right handle to adjust dimensions
- **Full Width** – Toggle to make NavBars, Boxes, or Images span the full 800px board width

### 🗂️ Layer Management
- **Layers Panel** – View all elements in a hierarchical list
- **Reorder Layers** – Drag to change z-index (top-to-bottom rendering)
- **Selection Highlighting** – Clearly see which element is active

### 🔧 Properties Panel
Fine-tune every element with:
- **Position (X, Y)** – Pixel-perfect coordinates with real-time updates
- **Size (W, H)** – Exact width and height
- **Rotation** – Precise degree control
- **Border Radius** – Rounded corners
- **Text Content** – Edit text and button labels
- **Font Size** – Typography control
- **NavBar Settings**:
  - Add/remove navigation links
  - Alignment (start, center, end, space-between, space-around, space-evenly)
  - Spacing control

### 📤 Export Options

#### 1. **HTML/CSS Code**
- Clean, semantic HTML structure
- Inline CSS with:
  - Absolute positioning (`left`, `top`)
  - Exact dimensions (`width`, `height`)
  - Rotation transforms (`transform: rotate()`)
  - Border radius, colors, typography
  - Full-width support (`width: 800px` or `width: 100%`)
- Copy to clipboard with one click

#### 2. **Mockup Image**
- Exports the entire canvas **including the browser frame**:
  - macOS-style traffic lights (red, yellow, green)
  - Address bar with "localhost:8080/boxy-app"
  - Your design rendered on a white 800x2000px canvas
- Saves directly to your device's gallery
- Perfect for presentations, portfolios, or client previews

### 🎨 Design Aesthetic
- **Monochrome Theme** – Black sidebar, white canvas, clean contrast
- **Dot Grid Background** – Subtle alignment guide
- **Blueprint Overlay** – Toggle to show dimensions and alignment guides
- **Browser Frame** – Professional mockup presentation

### 🚀 Workflow
1. **Drag** components from the left sidebar onto the canvas
2. **Position & Style** using the properties panel on the right
3. **Organize** layers in the bottom-right panel
4. **Export** as HTML/CSS or save as a mockup image

---

## 🛠️ Technical Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Canvas Rendering**: CustomPaint, RepaintBoundary
- **Export**: 
  - HTML generation via custom `HtmlGenerator`
  - Image capture via `screenshot` package + `image_gallery_saver`

---

## 📱 Platform Support

- ✅ **Android** (Primary target)
- ✅ **iOS** (Supported)
- ✅ **Web** (Supported)
- ✅ **Desktop** (Windows, macOS, Linux – Supported)

---

## 🎓 Usage Tips

- **Free Dragging**: Snapping has been disabled for smooth, unrestricted movement
- **Rotation Handle**: The circular icon at the top-right of selected items
- **Resize Handle**: The square icon at the bottom-right of selected items
- **Full Width**: Enable for NavBars to span the entire 800px board width
- **Layers**: Drag items in the layers panel to change z-index (top = front)
- **Blueprint Mode**: Click the eye icon in the browser header to toggle dimension overlays

---

## 🧑‍💻 For Developers

Boxy is designed with developers in mind:
- **Pixel-Perfect Exports**: All measurements are exact, no guesswork
- **Clean Code Output**: Semantic HTML with inline CSS, ready to integrate
- **Component-Based**: Each element type maps to common web components
- **Responsive Ready**: Full-width option for flexible layouts

---

## 🎨 For Designers

Boxy keeps design simple:
- **No Learning Curve**: Drag, drop, adjust – that's it
- **Realistic Mockups**: Browser frame makes your designs presentation-ready
- **Quick Iterations**: No complex layers or artboards, just a canvas
- **Developer Handoff**: Export code directly, no translation needed

---

## 📝 License

This project is open-source and available under the MIT License.

---

## 🙏 Acknowledgments

Built with ❤️ for developers and vibe coders who value speed, simplicity, and clean code.

---

**Happy Sketching! 📐✨**
