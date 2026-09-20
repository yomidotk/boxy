# 📦 Boxy

**A minimalist layout sketching tool for developers and vibe coders.**

Boxy is a Flutter-based design canvas that helps you quickly sketch UI layouts and export them as clean HTML/CSS code or PNG mockup images. Perfect for rapid prototyping, wireframing, and communicating design ideas to your team.

---

## 🎯 Goal

Boxy bridges the gap between design and development by providing a **fast, intuitive, and code-friendly** way to:

- **Sketch layouts visually** without the overhead of traditional design tools
- **Export production-ready HTML/CSS** with accurate positioning, sizing, and styling
- **Save mockup images** directly from the browser with a single click
- **Annotate elements with AI Context** so AI coding tools can implement your design intent
- **Theme your entire canvas** in one click with Smart Palette presets

Whether you're a developer who needs to quickly prototype an idea or a designer who wants to hand off pixel-perfect specs, Boxy keeps things simple and focused.

---

## ✨ Features

### 🧩 Component Library (19 Components)

Drag and drop **19 UI components** from the left sidebar:

| Component | Description |
|-----------|-------------|
| **Box** | Generic container / `<div>` |
| **Image** | Image placeholder |
| **Button** | Interactive button |
| **Text** | Editable text element with size presets |
| **Card** | Elevated card component |
| **Logo** | Branding / icon placeholder |
| **NavBar** | Customizable navigation bar with links |
| **Dropdown** | Dropdown / `<select>` menu |
| **Input** | Text input field placeholder |
| **Checkbox** | Label + checkbox control |
| **List** | Sidebar-style list with configurable rows |
| **Search** | Search bar with icon |
| **Profile Image** | Circular avatar / profile picture |
| **Chart** | Bar, line, or pie chart placeholder |
| **Toggle** | On/off toggle switch |
| **Table** | Data table skeleton |
| **Pricing Card** | Tiered pricing card block |
| **Sidebar** | Navigation sidebar panel |
| **Article** | Article / blog post layout block |
| **Gallery** | Image grid placeholder |

### 🎨 Visual Editing

- **Free Dragging** – Smooth, unrestricted positioning (snapping disabled)
- **Rotation** – Rotate any element 0–360° with a dedicated handle
- **Resizing** – Drag the bottom-right handle to adjust dimensions
- **Full Width** – Toggle to make NavBars, Boxes, or Images span the full 800 px board width
- **Duplicate** – Clone any element with a 20 px offset via the properties panel

### 🗂️ Layer Management

- **Layers Panel** – View all elements in a hierarchical list
- **Reorder Layers** – Drag items to change z-index (top = front)
- **Selection Highlighting** – Clearly see which element is active

### 🔧 Properties Panel

Fine-tune every element with:

- **Position (X, Y)** – Pixel-perfect coordinates with real-time updates
- **Size (W, H)** – Exact width and height
- **Rotation** – Precise degree control
- **Border Radius** – Rounded corners
- **Text Content** – Edit labels, button text, and body copy
- **Font Size** – Typography control with presets (Title 32px · Subtitle 24px · Paragraph 14px)
- **Custom Colors** – Per-element background, text, icon, and border color overrides
- **Delete** – Remove element from canvas

#### NavBar Settings
- Add / remove navigation links
- Alignment (start · center · end · space-between · space-around · space-evenly)
- Spacing control

#### Dropdown & List Settings
- Add / remove options and list rows inline

#### Chart Settings
- Toggle between **Bar**, **Line**, and **Pie** chart types

### 🤖 AI Context Annotations

Each element has an **AI Context** field at the top of its properties panel.

- Describe the element's intended behavior, interactions, or styling intent
- The context is embedded as an **HTML comment** in the exported code
- AI coding tools (Copilot, Cursor, Claude, etc.) use these hints to implement your design accurately

### 🎨 Smart Palette (Theme System)

The **Theme** tab provides a one-click theming system:

- **20 curated presets** including:
  - Boxy Default (purple), Linear Minimal, Supabase Hacker, Cyberpunk 2077,
    Lofi Study, Midnight Ocean, Matcha Aesthetic, Dracula, Synthwave, Sakura Pink,
    Gruvbox, Stripe Blurple, Nord Frost, Brutalism, Outrun Vaporwave, Autumn Rust,
    Lavender Cloud, Coral Reef, Solarized Light, OLED Blood
- **Generate Random Palette** – Cycles through presets sequentially, applying colors to all items
- **Custom Theme** – Enter any hex codes for Primary, Surface, and Background
- **Smart contrast** – Automatically picks light or dark text based on background luminance

### 📤 Export Options

#### 1. HTML/CSS Code
- Generated via the `HtmlGenerator` utility
- Responsive wrapper using `vw` units — scales to any screen width
- Per-element classes: `boxy-button`, `boxy-input`, `boxy-checkbox-label`, etc.
- Inline CSS with: absolute positioning, exact dimensions, rotation transforms, border radius, colors, typography
- **AI Context** written as `<!-- ... -->` HTML comments above each element
- **Copy to clipboard** with one click

#### 2. PNG Mockup Image
- Captures the canvas at **3× pixel density** for crisp exports
- Crops to the **800 px page column** (strips the infinite canvas padding)
- Downloaded automatically as `boxy_export_<timestamp>.png`
- ⚠️ Web-only feature (uses `dart:html`)

### 🎨 Design Aesthetic

- **Monochrome Theme** – Black sidebar, white canvas, clean contrast
- **Dot Grid Background** – Subtle dot-grid alignment guide on the canvas
- **Blueprint Overlay** – Toggle (eye icon in the browser header) to show live dimension/alignment overlays
- **Collapsible Right Panel** – Arrow button to hide/show the Properties · Layers · Theme panel

---

## 🚀 Workflow

1. **Drag** components from the left sidebar onto the canvas
2. **Position & Style** using the Properties tab on the right
3. **Annotate** elements with AI Context for implementation hints
4. **Theme** the entire canvas with Smart Palette presets
5. **Organize** layers in the Layers tab
6. **Export** — copy HTML/CSS or download a PNG mockup via the `</>` FAB button

---

## 🛠️ Technical Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider |
| **Canvas Rendering** | `CustomPaint`, `RepaintBoundary` |
| **HTML Export** | Custom `HtmlGenerator` (scales via `vw` units) |
| **Image Export** | `dart:html` + canvas crop at 3× pixel ratio |
| **Splash Screen** | `flutter_native_splash` |
| **Icons** | `flutter_launcher_icons` |

---

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| **Web** | ✅ Primary target (image export uses `dart:html`) |
| **Android** | ✅ Supported |
| **iOS** | ✅ Supported |
| **Desktop** | ✅ Supported (Windows · macOS · Linux) |

> **Note:** The PNG image export relies on `dart:html` and is fully functional on Web. On native platforms, the HTML code export works as expected.

---

## 🎓 Usage Tips

- **Free Dragging**: Snapping is disabled — move elements freely to any pixel
- **Rotation Handle**: The circular icon at the top-right of a selected element
- **Resize Handle**: The square icon at the bottom-right of a selected element
- **Full Width**: Enable for NavBars/Boxes to snap them to the full 800 px board width
- **Text Presets**: Use Title / Subtitle / Paragraph buttons to quickly set font size
- **Layers**: Drag items in the Layers panel — top of the list = front of the canvas
- **Blueprint Mode**: Click the eye icon in the browser header to toggle dimension overlays
- **Collapsible Panel**: Click the arrow strip between the canvas and right panel to hide it for more canvas space
- **Duplicate**: Open any element's properties and click the duplicate icon to clone it

---

## 🧑‍💻 For Developers

Boxy is designed with developers in mind:

- **Pixel-Perfect Exports**: All measurements are exact — no guesswork
- **Clean Code Output**: Semantic HTML with inline CSS, ready to paste and go
- **AI-Ready**: AI Context annotations guide tools like Copilot/Cursor/Claude
- **Component-Based**: Each element maps directly to common web components
- **Responsive Wrapper**: Exported code uses `vw` units — works at any viewport width

---

## 🎨 For Designers

Boxy keeps design simple:

- **No Learning Curve**: Drag, drop, adjust — that's it
- **Realistic Mockups**: Download a high-res PNG of your canvas
- **One-Click Themes**: 20 hand-picked color palettes or build your own
- **Quick Iterations**: No complex artboards or symbols, just a canvas
- **Developer Handoff**: Export code directly — no translation needed

---

## 📝 License

This project is open-source and available under the MIT License.

---

## 🙏 Acknowledgments

Built with ❤️ for developers and vibe coders who value speed, simplicity, and clean code.

---

**Happy Sketching! 📐✨**
