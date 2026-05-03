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
import '../widgets/theme_panel.dart';

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

    const Color bg       = Color(0xFF0A0A0A);
    const Color surface  = Color(0xFF1A1A1A);
    const Color accent   = Color(0xFF8B3DFF);
    const Color textPrimary   = Colors.white;
    const Color textSecondary = Color(0xFF888888);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.code_rounded, color: accent, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    "Export Design",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: textSecondary, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Label
              const Text(
                "HTML / CSS",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Code box
              Container(
                width: double.maxFinite,
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    htmlCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      color: Color(0xFFCDD6F4),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  // Copy Code
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: htmlCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: surface,
                            content: const Text(
                              "Code copied to clipboard!",
                              style: TextStyle(color: textPrimary),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 15),
                      label: const Text("Copy Code"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPrimary,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Save Image
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await Exporter.saveCanvas(_canvasKey);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            backgroundColor: surface,
                            content: Text(
                              success ? "Image downloaded!" : "Failed to save image.",
                              style: const TextStyle(color: textPrimary),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 15),
                      label: const Text("Save Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                    length: 3,
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
                            Tab(text: "THEME"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // 1. Properties Tab
                              const PropertiesPanel(),

                              // 2. Layers Tab
                              const LayersPanel(),

                              // 3. Theme Tab
                              const ThemePanel(),
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
