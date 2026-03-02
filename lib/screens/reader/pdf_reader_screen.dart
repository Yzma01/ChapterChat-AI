import 'dart:io';
import 'package:chapter_chat_ai/core/ads/ad_provider.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:chapter_chat_ai/services/gemini_chat_service.dart';
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

class _PdfReaderScreenState extends State<PdfReaderScreen>
    with SingleTickerProviderStateMixin {
  PdfDocument? _document;
  PdfPageImage? _currentPageImage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _showControls = false;
  String? _error;

  // AI Summary state
  bool _showSummary = false;
  bool _isLoadingSummary = false;
  String? _currentSummary;
  String? _summaryError;
  late AnimationController _summaryAnimationController;
  late Animation<double> _summaryAnimation;

  final GeminiChatService _geminiService = GeminiChatService();

  @override
  void initState() {
    super.initState();
    _currentPage =
        widget.book.currentPage > 0 ? widget.book.currentPage + 1 : 1;
    _loadDocument();

    // Initialize animation controller for summary panel
    _summaryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _summaryAnimation = CurvedAnimation(
      parent: _summaryAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _document?.close();
    _summaryAnimationController.dispose();
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
        // Reset summary when page changes
        _showSummary = false;
        _currentSummary = null;
        _summaryError = null;
      });

      // Collapse summary panel if showing
      if (_summaryAnimationController.isCompleted) {
        _summaryAnimationController.reverse();
      }

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

  /// Toggle AI summary panel
  void _toggleSummary() async {
    if (_showSummary) {
      // Hide summary
      await _summaryAnimationController.reverse();
      setState(() {
        _showSummary = false;
      });
    } else {
      // Show summary
      setState(() {
        _showSummary = true;
      });
      await _summaryAnimationController.forward();

      // Load summary if not already loaded for this page
      if (_currentSummary == null && !_isLoadingSummary) {
        _loadPageSummary();
      }
    }
  }

  /// Load AI summary for current page
  Future<void> _loadPageSummary() async {
    if (_currentPageImage == null) return;

    setState(() {
      _isLoadingSummary = true;
      _summaryError = null;
    });

    try {
      final result = await _geminiService.summarizePdfPage(
        pageImageBytes: _currentPageImage!.bytes,
        pageNumber: _currentPage,
        totalPages: _totalPages,
        bookTitle: widget.book.title,
      );

      if (result.isSuccess) {
        setState(() {
          _currentSummary = result.response;
          _isLoadingSummary = false;
        });
      } else if (result.isRateLimited) {
        setState(() {
          _summaryError =
              'Rate limited. Please wait ${result.retryAfterSeconds ?? 60} seconds.';
          _isLoadingSummary = false;
        });
      } else {
        setState(() {
          _summaryError = result.errorMessage ?? 'Failed to generate summary';
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      setState(() {
        _summaryError = 'Error: ${e.toString()}';
        _isLoadingSummary = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final ads = context.watch<AdProvider>();
    final isPremium = context.watch<UserProvider>().user!.isPremium;

    // Set system UI for immersive reading
    SystemChrome.setEnabledSystemUIMode(
      _showControls ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );

    return WillPopScope(
      onWillPop: () async {
        if (!_showControls) {
          setState(() {
            _showControls = true;
          });

          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          return true;
        } else {
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  // PDF Page Content
                                  _buildPageContent(
                                    backgroundColor,
                                    constraints,
                                  ),

                                  // Loading indicator
                                  if (_isLoading)
                                    Center(
                                      child: CircularProgressIndicator(
                                        color: themeProvider.colors.primary,
                                      ),
                                    ),

                                  // Controls overlay
                                  if (_showControls)
                                    _buildControlsOverlay(
                                      themeProvider,
                                      backgroundColor,
                                    ),

                                  // AI Summary button (bottom right)
                                  if (!_showControls && !_isLoading)
                                    _buildSummaryButton(themeProvider),

                                  // AI Summary panel
                                  if (_showSummary)
                                    _buildSummaryPanel(themeProvider),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ads.getBannerWidget(isPremium),
                          ],
                        ),
                      );
                    },
                  ),
        ),
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

  /// AI Summary floating button
  Widget _buildSummaryButton(ThemeProvider themeProvider) {
    final colors = themeProvider.colors;

    return Positioned(
      bottom: 24,
      right: 24,
      child: Material(
        color: colors.primary,
        borderRadius: BorderRadius.circular(28),
        elevation: 4,
        child: InkWell(
          onTap: _toggleSummary,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                if (!_showSummary) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'AI Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// AI Summary panel (slides from bottom)
  Widget _buildSummaryPanel(ThemeProvider themeProvider) {
    final colors = themeProvider.colors;
    final isDark = themeProvider.isDarkMode;
    final panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(_summaryAnimation),
        child: Container(
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: colors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI Summary:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.iconDefault),
                        onPressed: _toggleSummary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Summary content
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                    minHeight: 150,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: _buildSummaryContent(colors),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent(colors) {
    if (_isLoadingSummary) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'Generating AI summary...',
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_summaryError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 12),
            Text(
              _summaryError!,
              style: TextStyle(fontSize: 14, color: colors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadPageSummary,
              child: Text('Retry', style: TextStyle(color: colors.primary)),
            ),
          ],
        ),
      );
    }

    if (_currentSummary != null) {
      return Text(
        _currentSummary!,
        style: TextStyle(
          fontSize: 15,
          color: colors.textSecondary,
          height: 1.5,
        ),
      );
    }

    return Center(
      child: Text(
        'No summary available',
        style: TextStyle(fontSize: 14, color: colors.textSecondary),
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

    return Center(
      child: SafeArea(
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
      ),
    );
  }
}
