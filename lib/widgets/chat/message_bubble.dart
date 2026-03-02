import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AppThemeColors colors;
  final VoidCallback? onImageTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.colors,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? colors.primary : colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(context, isUser),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isUser) {
    // Solo texto
    if (!message.hasImage) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          message.text ?? '',
          style: TextStyle(
            fontSize: 15,
            color: isUser ? Colors.white : colors.textPrimary,
            height: 1.4,
          ),
        ),
      );
    }

    // Solo imagen
    if (!message.hasText) {
      return GestureDetector(
        onTap: onImageTap ?? () => _showFullScreenImage(context),
        child: _buildImage(),
      );
    }

    // Imagen con texto
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onImageTap ?? () => _showFullScreenImage(context),
          child: _buildImage(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            message.text!,
            style: TextStyle(
              fontSize: 15,
              color: isUser ? Colors.white : colors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    Widget imageWidget;

    if (message.imageBytes != null) {
      // Imagen desde bytes (memoria)
      imageWidget = Image.memory(
        message.imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    } else if (message.imagePath != null) {
      // Imagen desde archivo local
      imageWidget = Image.file(
        File(message.imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    } else {
      return _buildImageError();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250, minHeight: 100),
      child: imageWidget,
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 150,
      width: double.infinity,
      color: colors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: colors.iconDefault,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    if (message.imageBytes == null && message.imagePath == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageView(message: message, colors: colors);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

/// Vista de imagen a pantalla completa
class _FullScreenImageView extends StatelessWidget {
  final ChatMessage message;
  final AppThemeColors colors;

  const _FullScreenImageView({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            // Imagen centrada con zoom
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildImage(),
              ),
            ),

            // Botón de cerrar
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (message.imageBytes != null) {
      return Image.memory(message.imageBytes!, fit: BoxFit.contain);
    } else if (message.imagePath != null) {
      return Image.file(File(message.imagePath!), fit: BoxFit.contain);
    }
    return const SizedBox.shrink();
  }
}

/// Widget para mostrar indicador de "escribiendo..."
class TypingIndicator extends StatefulWidget {
  final AppThemeColors colors;

  const TypingIndicator({super.key, required this.colors});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.colors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animValue = ((_controller.value + delay) % 1.0);
                    final opacity =
                        (animValue < 0.5)
                            ? 0.3 + (animValue * 1.4)
                            : 1.0 - ((animValue - 0.5) * 1.4);

                    return Padding(
                      padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
                      child: Opacity(
                        opacity: opacity.clamp(0.3, 1.0),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.colors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
