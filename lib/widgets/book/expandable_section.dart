import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ExpandableSection extends StatefulWidget {
  final String title;
  final Widget content;
  final Widget? previewContent; // Contenido visible cuando está colapsado
  final AppThemeColors colors;
  final bool initiallyExpanded;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.content,
    this.previewContent,
    required this.colors,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection>
    with TickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _iconController;
  late AnimationController _fadeController;
  late Animation<double> _iconRotation;
  late Animation<double> _fadeAnimation;

  bool _showFullContent = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _showFullContent = _isExpanded;

    // Controller para el icono (rotación)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Controller para el fade del contenido
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
      value: 1.0, // Comienza visible
    );

    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _iconController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleExpanded() async {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    // Iniciar rotación del icono
    if (_isExpanded) {
      _iconController.forward();
    } else {
      _iconController.reverse();
    }

    // Fade out del contenido actual
    await _fadeController.reverse();

    // Cambiar el contenido
    setState(() {
      _showFullContent = _isExpanded;
    });

    // Fade in del nuevo contenido
    await _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con título y flecha
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            splashColor: widget.colors.textPrimary.withOpacity(0.08),
            highlightColor: widget.colors.textPrimary.withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.colors.textPrimary,
                    ),
                  ),
                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.colors.iconDefault,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Contenido con animación de fade
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child:
                _showFullContent
                    ? widget.content
                    : (widget.previewContent ?? widget.content),
          ),
        ),
      ],
    );
  }
}
