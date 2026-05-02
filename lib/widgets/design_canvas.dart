import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/layout_item.dart';
import '../providers/layout_provider.dart';
import '../painters/blueprint_painter.dart';
import 'canvas_item_widget.dart';
import 'selection_overlay.dart';

class DesignCanvas extends StatefulWidget {
  final GlobalKey? exportKey;

  const DesignCanvas({super.key, this.exportKey});

  @override
  State<DesignCanvas> createState() => _DesignCanvasState();
}

class _DesignCanvasState extends State<DesignCanvas> {
  late final GlobalKey _stackKey;
  late final GlobalKey _pageKey;
  late final TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _stackKey = widget.exportKey ?? GlobalKey();
    _pageKey = GlobalKey();
    _transformationController = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerView());
  }

  void _centerView() {
    final viewportBox = context.findRenderObject() as RenderBox?;
    if (viewportBox == null || viewportBox.size.isEmpty) {
      // Not laid out yet (e.g. still in splash transition) — retry next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centerView();
      });
      return;
    }

    final viewportSize = viewportBox.size;

    // Known layout constants that match the widget tree below
    const double padding = 100.0;      // Padding widget around the Column
    const double headerHeight = 40.0;  // Browser chrome bar
    const double stackWidth = 5000.0;  // _pageKey Stack explicit width

    // The 800px white page is topCenter-aligned inside the 5000px stack.
    // Its center X in content-space = padding + stackWidth / 2
    const double pageCenterX = padding + stackWidth / 2; // 2600

    // Top edge of the page in content-space
    const double pageTopY = padding + headerHeight; // 140

    // Place the page horizontally centered and its top ~15% down from the viewport top
    final double tx = viewportSize.width / 2 - pageCenterX;
    final double ty = viewportSize.height * 0.15 - pageTopY;

    _transformationController.value = Matrix4.translationValues(tx, ty, 0);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<LayoutProvider, bool>(
      selector: (_, provider) => provider.isDragging,
      builder: (context, isDragging, child) {
        return Container(
          color: Colors.grey[50], // Very Light Grey Infinite BG
          child: InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: !isDragging,
            scaleEnabled: !isDragging,
            boundaryMargin: const EdgeInsets.all(5000), // V15: Finite Margin
            minScale: 0.1,
            maxScale: 6.0,
            constrained: false, // Infinite Canvas
            child: GestureDetector(
              onTap: () {
                Provider.of<LayoutProvider>(context, listen: false)
                    .selectItem(null);
              },
              child: Padding(
                padding: const EdgeInsets.all(
                  100,
                ), // Huge padding for panning space
                child: RepaintBoundary(
                  key: _stackKey, // V12: Moved to capture browser header
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Browser Window Header
                      Consumer<LayoutProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            width: 800, // Fixed width for the "Page"
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black, // Header Black
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                // Traffic Lights
                                _circle(const Color(0xFFFF5F57)),
                                const SizedBox(width: 8),
                                _circle(const Color(0xFFFFBD2E)),
                                const SizedBox(width: 8),
                                _circle(const Color(0xFF28C93F)),
                                const SizedBox(width: 20),
                                // Address Bar
                                Expanded(
                                  child: Container(
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEAECF0,
                                      ), // Darker Grey Bar
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "localhost:8080/boxy-app",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    provider.showDimensions
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 16,
                                    color: provider.showDimensions
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                  tooltip: "Show Dimensions",
                                  onPressed: () => provider.toggleDimensions(
                                    !provider.showDimensions,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 0), // Header connects directly
                      // Actual Canvas Page
                      DragTarget<ItemType>(
                        onAcceptWithDetails: (details) {
                          // V22: Precise Drop Logic
                          const double canvasWidth = 5000.0;
                          const double pageWidth = 800.0;
                          const double canvasOffset = (canvasWidth - pageWidth) / 2;

                          final RenderBox? renderBox =
                              _pageKey.currentContext?.findRenderObject()
                                  as RenderBox?;

                          if (renderBox != null) {
                            // Use globalToLocal to account for InteractiveViewer transformation
                            // details.offset is the top-left of the feedback widget.
                            // We add 40,40 to estimate the actual pointer position (center of the tool icon).
                            final Offset pointerPos = renderBox.globalToLocal(
                              details.offset + const Offset(40, 40),
                            );

                            // Calculate position relative to the 800px page
                            final dropPos = Offset(
                              pointerPos.dx - canvasOffset,
                              pointerPos.dy,
                            );

                            Provider.of<LayoutProvider>(context, listen: false)
                                .addItem(details.data, dropPos);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return SizedBox(
                            width: 5000, // Explicitly wide to catch drops in background
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                              // 1. The Static Page Visuals (Theme BG + Dots)
                              Consumer<LayoutProvider>(
                                builder: (context, provider, _) {
                                  final bg = provider.currentTheme.background;
                                  final lum = bg.computeLuminance();
                                  final dotColor = lum > 0.5
                                      ? Colors.black.withAlpha(35)
                                      : Colors.white.withAlpha(35);
                                  return Container(
                                    width: 800,
                                    height: 2000,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: CustomPaint(
                                      painter: DotGridPainter(dotColor: dotColor),
                                    ),
                                  );
                                },
                              ),

                              // 2. The Items and Selection Layer (Overlaying the Page but not restricted by it)
                              // V22: Expanded to 5000px for full background interaction
                              Consumer<LayoutProvider>(
                                builder: (context, provider, child) {
                                  return Stack(
                                    key: _pageKey, 
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Expanded hit-test area (5000px wide)
                                      // Centered such that 0 is still the page edge
                                      const SizedBox(width: 5000, height: 2000),

                                      // Items
                                      ...provider.items.map(
                                        (item) => CanvasItemWidget(item: item),
                                      ),

                                      // V21: Granular Blueprint Overlay
                                      Builder(
                                        builder: (context) {
                                          final selectedItem = context
                                              .select<LayoutProvider, LayoutItem?>(
                                            (p) => p.selectedItem,
                                          );
                                          if (selectedItem == null) {
                                            return const SizedBox.shrink();
                                          }

                                          return ListenableBuilder(
                                            listenable: selectedItem,
                                            builder: (context, child) {
                                              final bgColor = context
                                                  .select<LayoutProvider, Color>(
                                                (p) => p.currentTheme.background,
                                              );
                                              return IgnorePointer(
                                                child: CustomPaint(
                                                  painter: BlueprintPainter(
                                                    selectedItem: selectedItem,
                                                    allItems: provider.items,
                                                    showDimensions: provider.showDimensions,
                                                    backgroundColor: bgColor,
                                                  ),
                                                  size: const Size(5000, 2000),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),

                                      // V21: Top-Level Selection Handles (Always Interactive & On Top)
                                      const ItemSelectionOverlay(),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _circle(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class DotGridPainter extends CustomPainter {
  final Color dotColor;

  const DotGridPainter({this.dotColor = const Color(0x22000000)});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const double step = 20.0;

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter oldDelegate) => oldDelegate.dotColor != dotColor;
}
