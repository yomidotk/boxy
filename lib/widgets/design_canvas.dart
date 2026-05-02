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
                          // V21: Corrected Coordinate Space (Relative to the actual Page)
                          final RenderBox? renderBox =
                              _pageKey.currentContext?.findRenderObject()
                                  as RenderBox?;

                          if (renderBox != null) {
                            final Offset localPos = renderBox.globalToLocal(
                              details.offset,
                            );

                            // V21: Center the item on drop point
                            final defaultSize = LayoutItem.getDefaultSize(details.data);
                            final centeredPos = Offset(
                              localPos.dx - (defaultSize.width / 2),
                              localPos.dy - (defaultSize.height / 2),
                            );

                            Provider.of<LayoutProvider>(context, listen: false)
                                .addItem(details.data, centeredPos);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              // 1. The Static Page Visuals (White Box + Dots)
                              Container(
                                width: 800,
                                height: 2000,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: DotGridPainter(),
                                ),
                              ),

                              // 2. The Items and Selection Layer (Overlaying the Page but not restricted by it)
                              // V21: Removed SizedBox(800) hit-test boundary to allow infinite canvas interaction
                              Consumer<LayoutProvider>(
                                builder: (context, provider, child) {
                                  return Stack(
                                    key: _pageKey, // V21: Fix drop position coordinate system
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Invisible placeholder to ensure this Stack has the 800px coordinate origin
                                      const SizedBox(width: 800, height: 2000),

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
                                              return IgnorePointer(
                                                child: CustomPaint(
                                                  painter: BlueprintPainter(
                                                    selectedItem: selectedItem,
                                                    allItems: provider
                                                        .items, // Only for alignment logic if implemented
                                                    showDimensions: provider
                                                        .showDimensions,
                                                  ),
                                                  size: const Size(800, 2000),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),

                                      // V21: Top-Level Selection Handles (Always Interactive & On Top)
                                      ItemSelectionOverlay(),
                                    ],
                                  );
                                },
                              ),
                            ],
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
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    const double step = 20.0;

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
