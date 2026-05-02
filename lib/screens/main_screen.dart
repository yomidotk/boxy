import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:boxy/widgets/tool_sidebar.dart';
import 'package:boxy/widgets/design_canvas.dart';
import 'package:boxy/providers/layout_provider.dart';
import 'package:boxy/utils/html_generator.dart';
import 'package:boxy/utils/exporter.dart';
import '../widgets/layers_panel.dart';
import '../widgets/properties_panel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isPanelOpen = true;

  void _showExportDialog(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    final htmlCode = HtmlGenerator.generate(provider.items);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Export Design"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "HTML/CSS Blueprint",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.maxFinite,
                height: 200,
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: SingleChildScrollView(
                  child: SelectableText(
                    htmlCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: htmlCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Code copied to clipboard!")),
              );
            },
            child: const Text("Copy Code"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              bool success = await Exporter.saveCanvas(_canvasKey);
              if (!mounted) return;

              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? "Image saved to Gallery!"
                        : "Failed to save image.",
                  ),
                ),
              );
            },
            icon: const Icon(Icons.image),
            label: const Text("Save Image"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ToolSidebar(),
          // RepaintBoundary for Export
          // RepaintBoundary is now inside DesignCanvas (via exportKey)
          Expanded(child: DesignCanvas(exportKey: _canvasKey)),
          // Right Panel (Properties - Collapsible/Optional)
          // Right Panel (Properties - Collapsible)
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toggle Button Strip
              Container(
                width: 20,
                color: Colors.black, // Monochrome Black
                child: Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isPanelOpen
                          ? Icons.arrow_forward_ios
                          : Icons.arrow_back_ios,
                      size: 12,
                      color: Colors.white, // White Icon
                    ),
                    onPressed: () {
                      setState(() {
                        _isPanelOpen = !_isPanelOpen;
                      });
                    },
                  ),
                ),
              ),

              // Actual Panel
              if (_isPanelOpen)
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.black, // Monochrome Black
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Colors.white, // White
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(text: "PROPERTIES"),
                            Tab(text: "LAYERS"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // 1. Properties Tab
                              const PropertiesPanel(),

                              // 2. Layers Tab
                              const LayersPanel(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExportDialog(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.code, color: Colors.white),
      ),
    );
  }
}
