import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../widgets/common/detail_header.dart';

class PublishBookScreen extends StatefulWidget {
  const PublishBookScreen({super.key});

  @override
  State<PublishBookScreen> createState() => _PublishBookScreenState();
}

class _PublishBookScreenState extends State<PublishBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // Book details controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pagesController = TextEditingController();
  final _priceController = TextEditingController();
  final _publisherController = TextEditingController();
  final _settingController = TextEditingController();

  // Selected values
  String? _selectedGenre;
  String? _selectedLanguage;
  int _minimumAge = 0;
  String? _pdfFileName;

  // Characters list
  final List<CharacterFormData> _characters = [];

  // Available genres
  final List<String> _genres = [
    'Fiction',
    'Non-Fiction',
    'Fantasy',
    'Science Fiction',
    'Mystery',
    'Thriller',
    'Romance',
    'Horror',
    'Biography',
    'Self-Help',
    'History',
    'Poetry',
    'Drama',
    'Adventure',
    'Children',
    'Young Adult',
  ];

  // Available languages
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Portuguese',
    'Italian',
    'Japanese',
    'Chinese',
    'Korean',
    'Russian',
    'Arabic',
    'Other',
  ];

  // Age ratings
  final List<int> _ageRatings = [0, 7, 10, 13, 16, 18];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pagesController.dispose();
    _priceController.dispose();
    _publisherController.dispose();
    _settingController.dispose();
    for (var character in _characters) {
      character.dispose();
    }
    super.dispose();
  }

  void _addCharacter() {
    setState(() {
      _characters.add(CharacterFormData());
    });
  }

  void _removeCharacter(int index) {
    setState(() {
      _characters[index].dispose();
      _characters.removeAt(index);
    });
  }

  void _pickPDF() async {
    // TODO: Implement actual PDF picker using file_picker package
    // For now, just simulate selection
    setState(() {
      _pdfFileName = 'my_book.pdf';
    });
  }

  void _onPublish() {
    if (_formKey.currentState!.validate()) {
      // Validate characters if any are added
      bool hasEmptyCharacters = false;
      for (var character in _characters) {
        if (character.nameController.text.isEmpty ||
            character.descriptionController.text.isEmpty) {
          hasEmptyCharacters = true;
          break;
        }
      }

      if (hasEmptyCharacters) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please fill in all character details or remove empty characters',
            ),
          ),
        );
        return;
      }

      if (_pdfFileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your book PDF')),
        );
        return;
      }

      // TODO: Implement Firebase upload
      debugPrint('Publishing book...');
      debugPrint('Title: ${_titleController.text}');
      debugPrint('Description: ${_descriptionController.text}');
      debugPrint('Genre: $_selectedGenre');
      debugPrint('Language: $_selectedLanguage');
      debugPrint('Pages: ${_pagesController.text}');
      debugPrint('Price: ${_priceController.text}');
      debugPrint('Age: $_minimumAge+');
      debugPrint('Characters: ${_characters.length}');
      debugPrint('PDF: $_pdfFileName');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book published successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // Header
          DetailHeader(
            colors: colors,
            onBackPressed: () => Navigator.pop(context),
            searchHint: 'Search',
          ),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'Publish a book',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: colors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Share your story with the world',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Book Details Section
                    _buildSectionTitle('Book details', colors),
                    const SizedBox(height: 16),

                    // Title field
                    _buildTextField(
                      controller: _titleController,
                      label: 'Book title',
                      colors: colors,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    // Description field
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      colors: colors,
                      maxLines: 4,
                      maxLength: 500,
                      helperText: 'Describe your book to attract readers',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    // Genre and Language row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Genre',
                            value: _selectedGenre,
                            items: _genres,
                            colors: colors,
                            onChanged: (value) {
                              setState(() {
                                _selectedGenre = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Language',
                            value: _selectedLanguage,
                            items: _languages,
                            colors: colors,
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // Pages and Price row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _pagesController,
                            label: 'Pages',
                            colors: colors,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Price (CRC)',
                            colors: colors,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    // Age rating
                    _buildAgeRatingSelector(colors),

                    // Publisher (optional)
                    _buildTextField(
                      controller: _publisherController,
                      label: 'Publisher (optional)',
                      colors: colors,
                    ),

                    // Setting (optional)
                    _buildTextField(
                      controller: _settingController,
                      label: 'Story setting (optional)',
                      colors: colors,
                      helperText:
                          'E.g., "New York, 1920s" or "Medieval fantasy world"',
                    ),

                    const SizedBox(height: 32),

                    // PDF Upload Section
                    _buildSectionTitle('Book file', colors),
                    const SizedBox(height: 16),
                    _buildPDFUploader(colors),

                    const SizedBox(height: 32),

                    // Characters Section
                    _buildSectionTitle('AI Characters', colors),
                    const SizedBox(height: 8),
                    Text(
                      'Add characters that readers can chat with. Characters are optional, but if added, all fields are required.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Characters list
                    ..._characters.asMap().entries.map(
                      (entry) =>
                          _buildCharacterCard(entry.key, entry.value, colors),
                    ),

                    // Add character button
                    _buildAddCharacterButton(colors),

                    const SizedBox(height: 40),

                    // Publish button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _onPublish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Publish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppThemeColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required AppThemeColors colors,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(color: colors.textPrimary, fontSize: 16),
        cursorColor: colors.primary,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperMaxLines: 2,
          labelStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
          floatingLabelStyle: TextStyle(color: colors.primary, fontSize: 14),
          helperStyle: TextStyle(color: colors.textSecondary, fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required AppThemeColors colors,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: colors.iconDefault),
        dropdownColor: colors.surface,
        style: TextStyle(color: colors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
          floatingLabelStyle: TextStyle(color: colors.primary, fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        items:
            items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAgeRatingSelector(AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minimum age',
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                _ageRatings.map((age) {
                  final isSelected = _minimumAge == age;
                  return ChoiceChip(
                    label: Text(age == 0 ? 'All ages' : '$age+'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _minimumAge = age;
                      });
                    },
                    selectedColor: colors.primary,
                    backgroundColor: colors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : colors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.border,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFUploader(AppThemeColors colors) {
    return GestureDetector(
      onTap: _pickPDF,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.border,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _pdfFileName != null ? Icons.picture_as_pdf : Icons.upload_file,
              size: 48,
              color: _pdfFileName != null ? colors.primary : colors.iconDefault,
            ),
            const SizedBox(height: 12),
            Text(
              _pdfFileName ?? 'Upload PDF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _pdfFileName != null
                  ? 'Tap to change file'
                  : 'Only PDF files are accepted',
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard(
    int index,
    CharacterFormData character,
    AppThemeColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Character ${index + 1}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => _removeCharacter(index),
                icon: Icon(Icons.delete_outline, color: colors.error, size: 22),
                tooltip: 'Remove character',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Name field
          TextFormField(
            controller: character.nameController,
            style: TextStyle(color: colors.textPrimary, fontSize: 16),
            cursorColor: colors.primary,
            decoration: InputDecoration(
              labelText: 'Character name',
              labelStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
              floatingLabelStyle: TextStyle(
                color: colors.primary,
                fontSize: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: colors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Description field
          TextFormField(
            controller: character.descriptionController,
            style: TextStyle(color: colors.textPrimary, fontSize: 16),
            cursorColor: colors.primary,
            maxLines: 3,
            maxLength: 150,
            decoration: InputDecoration(
              labelText: 'Character description',
              helperText:
                  'Describe personality, role, and key traits. Be detailed for better AI responses.',
              helperMaxLines: 2,
              labelStyle: TextStyle(color: colors.textSecondary, fontSize: 16),
              floatingLabelStyle: TextStyle(
                color: colors.primary,
                fontSize: 14,
              ),
              helperStyle: TextStyle(color: colors.textSecondary, fontSize: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: colors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: colors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCharacterButton(AppThemeColors colors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _addCharacter,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.primary,
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: colors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Add character',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class to manage character form data
class CharacterFormData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}
