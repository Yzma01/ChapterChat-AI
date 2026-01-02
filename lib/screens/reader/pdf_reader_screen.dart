import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfx/pdfx.dart';
import '../../blocs/library/bloc/library_bloc.dart';
import '../../blocs/library/bloc/library_event.dart';
import '../../blocs/library/models/local_book_model.dart';
import '../../core/theme/theme_provider.dart';

class PdfReaderScreen extends StatefulWidget {
  final LocalBookModel book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  PdfDocument? _document;
  PdfPageImage? _currentPageImage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _showControls = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentPage =
        widget.book.currentPage > 0 ? widget.book.currentPage + 1 : 1;
    _loadDocument();
  }

  @override
  void dispose() {
    _document?.close();
    _saveProgress();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    try {
      if (widget.book.localPdfPath == null) {
        throw Exception('PDF file not found locally');
      }

      final file = File(widget.book.localPdfPath!);
      if (!await file.exists()) {
        throw Exception('PDF file does not exist');
      }

      _document = await PdfDocument.openFile(widget.book.localPdfPath!);
      _totalPages = _document!.pagesCount;

      // Ensure current page is valid
      if (_currentPage > _totalPages) {
        _currentPage = _totalPages;
      }
      if (_currentPage < 1) {
        _currentPage = 1;
      }

      await _renderPage(_currentPage);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _renderPage(int pageNumber) async {
    if (_document == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final page = await _document!.getPage(pageNumber);
      final pageImage = await page.render(
        width: page.width * 2.5,
        height: page.height * 2.5,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF',
      );
      await page.close();

      setState(() {
        _currentPageImage = pageImage;
        _currentPage = pageNumber;
        _isLoading = false;
      });

      // Save progress periodically
      _saveProgress();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _saveProgress() {
    context.read<LibraryBloc>().add(
      UpdateReadingProgress(
        bookId: widget.book.id,
        currentPage: _currentPage - 1, // 0-indexed for storage
        totalPages: _totalPages,
      ),
    );
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _renderPage(_currentPage + 1);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _renderPage(_currentPage - 1);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _handleTap(TapUpDetails details, BoxConstraints constraints) {
    final tapX = details.localPosition.dx;
    final screenWidth = constraints.maxWidth;

    if (tapX < screenWidth / 2) {
      // Left half - previous page
      _goToPreviousPage();
    } else {
      // Right half - next page
      _goToNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    // Set system UI for immersive reading
    SystemChrome.setEnabledSystemUIMode(
      _showControls ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body:
          _error != null
              ? _buildErrorState(themeProvider)
              : LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity == null) return;

                      if (details.primaryVelocity! < -100) {
                        // Swipe left (right to left) - next page
                        _goToNextPage();
                      } else if (details.primaryVelocity! > 100) {
                        // Swipe right (left to right) - previous page
                        _goToPreviousPage();
                      }
                    },
                    onTapUp: (details) => _handleTap(details, constraints),
                    onLongPress: _toggleControls,
                    child: Stack(
                      children: [
                        // PDF Page Content
                        _buildPageContent(backgroundColor, constraints),

                        // Loading indicator
                        if (_isLoading)
                          Center(
                            child: CircularProgressIndicator(
                              color: themeProvider.colors.primary,
                            ),
                          ),

                        // Controls overlay
                        if (_showControls)
                          _buildControlsOverlay(themeProvider, backgroundColor),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildPageContent(Color backgroundColor, BoxConstraints constraints) {
    if (_currentPageImage == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        ),
        child: Image.memory(
          _currentPageImage!.bytes,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(
    ThemeProvider themeProvider,
    Color backgroundColor,
  ) {
    final colors = themeProvider.colors;

    return SafeArea(
      child: Column(
        children: [
          // Top bar with back button and title
          Container(
            color: backgroundColor.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.iconDefault),
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Text(
                    widget.book.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.brightness_6, color: colors.iconDefault),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom bar with page indicator
          Container(
            color: backgroundColor.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page slider
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: colors.primary,
                    inactiveTrackColor: colors.border,
                    thumbColor: colors.primary,
                    overlayColor: colors.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _currentPage.toDouble(),
                    min: 1,
                    max: _totalPages.toDouble(),
                    divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                    onChanged: (value) {
                      _renderPage(value.toInt());
                    },
                  ),
                ),

                // Page numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page $_currentPage of $_totalPages',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      '${((_currentPage / _totalPages) * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeProvider themeProvider) {
    final colors = themeProvider.colors;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colors.error),
              const SizedBox(height: 16),
              Text(
                'Error loading PDF',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
