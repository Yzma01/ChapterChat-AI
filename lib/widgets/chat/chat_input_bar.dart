import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final AppThemeColors colors;
  final ValueChanged<String>? onSendText;
  final Function(Uint8List imageBytes, String? caption)? onSendImage;
  final String hintText;
  final VoidCallback? onFocusGained;
  final bool enabled;

  const ChatInputBar({
    super.key,
    required this.colors,
    this.onSendText,
    this.onSendImage,
    this.hintText = 'Text message',
    this.onFocusGained,
    this.enabled = true,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  bool _hasText = false;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      widget.onFocusGained?.call();
    }
  }

  bool get _canSend => _hasText || _selectedImageBytes != null;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    'Add Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSourceOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      _buildSourceOption(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: widget.colors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: widget.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImageBytes = null;
    });
  }

  void _onSendPressed() {
    if (!_canSend || !widget.enabled) return;

    final text = _controller.text.trim();

    if (_selectedImageBytes != null) {
      // Enviar imagen (con o sin caption)
      widget.onSendImage?.call(
        _selectedImageBytes!,
        text.isNotEmpty ? text : null,
      );
      setState(() {
        _selectedImageBytes = null;
      });
    } else if (text.isNotEmpty) {
      // Enviar solo texto
      widget.onSendText?.call(text);
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.colors.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview de imagen seleccionada
            if (_selectedImageBytes != null) _buildImagePreview(),

            // Barra de input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Botón de adjuntar imagen
                  GestureDetector(
                    onTap: widget.enabled ? _showImageSourceDialog : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.colors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        color:
                            widget.enabled
                                ? widget.colors.iconDefault
                                : widget.colors.iconDefault.withOpacity(0.5),
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Campo de texto
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.colors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        style: TextStyle(
                          color: widget.colors.textPrimary,
                          fontSize: 16,
                        ),
                        cursorColor: widget.colors.primary,
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText:
                              _selectedImageBytes != null
                                  ? 'Add a caption...'
                                  : widget.hintText,
                          hintStyle: TextStyle(
                            color: widget.colors.textSecondary,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Botón de enviar
                  GestureDetector(
                    onTap: _canSend && widget.enabled ? _onSendPressed : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _canSend && widget.enabled
                                ? widget.colors.primary
                                : widget.colors.primary.withOpacity(0.3),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color:
                            _canSend && widget.enabled
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Stack(
        children: [
          // Imagen preview
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.colors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
          ),

          // Botón de eliminar
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: _removeSelectedImage,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
