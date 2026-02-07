import 'dart:io';

import 'package:chapter_chat_ai/blocs/book/bloc/book_bloc.dart';
import 'package:chapter_chat_ai/blocs/book/bloc/book_event.dart';
import 'package:chapter_chat_ai/blocs/book/bloc/book_state.dart';
import 'package:chapter_chat_ai/blocs/book/models/book_model.dart';
import 'package:chapter_chat_ai/blocs/book/models/character_model.dart';
import 'package:chapter_chat_ai/core/ads/ad_provider.dart';
import 'package:chapter_chat_ai/core/user/user_provider.dart';
import 'package:chapter_chat_ai/models/book.dart';
import 'package:chapter_chat_ai/widgets/form/multi_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../widgets/common/detail_header.dart';
import '../../widgets/form/validating_text_field.dart';
import '../../widgets/form/validating_dropdown.dart';
import '../../widgets/form/age_rating_selector.dart';
import '../../widgets/form/pdf_uploader.dart';
import '../../widgets/form/cover_image_uploader.dart'; // NEW
import '../../widgets/form/character_form_card.dart';
import '../../widgets/form/add_character_button.dart';
import '../../widgets/form/section_title.dart';

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
  File? _pdfFile;
  File? _coverImageFile; // NEW
  List<String> _selectedGenres = [];

  // Validation state
  bool _hasTriedToSubmit = false;
  bool _pdfHasError = false;
  bool _coverImageHasError = false; // NEW

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

  BookModel getBook() {
    return BookModel(
      title: _titleController.text,
      description: _descriptionController.text,
      genres: _selectedGenres,
      language: _selectedLanguage!,
      pages: int.tryParse(_pagesController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0,
      minAge: _minimumAge,
      publisher: _publisherController.text,
      storySetting: _settingController.text,
      pdfFile: _pdfFile!,
      coverImageFile: _coverImageFile!, // NEW
      characters:
          _characters.map((c) {
            return CharacterModel(
              name: c.nameController.text,
              description: c.descriptionController.text,
            );
          }).toList(),
    );
  }

  void _onPublish() {
    if (!mounted) return;
    setState(() {
      _hasTriedToSubmit = true;
      _pdfHasError = _pdfFileName == null;
      _coverImageHasError = _coverImageFile == null; // NEW
    });

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

      // NEW: Validate cover image
      if (_coverImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a book cover image')),
        );
        return;
      }

      if (_pdfFileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload your book PDF')),
        );
        return;
      }

      final bookBloc = context.read<BookBloc>();
      bookBloc.add(UploadBookRequested(book: getBook()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final _isPremium = context.watch<UserProvider>().user!.isPremium;
    final ads = context.watch<AdProvider>();

    return BlocListener<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookLoading) {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const Center(child: CircularProgressIndicator()),
          );
        } else {
          // Hide loading indicator
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is BookSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book published successfully!')),
          );
          context.read<BookBloc>().add(FetchBooksRequested());
          Navigator.pop(context);
        } else if (state is BookFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: Column(
          children: [
            // Header
            DetailHeader(
              colors: colors,
              onBackPressed: () => Navigator.pop(context),
              title: 'Publish a book',
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

                      // Subtitle
                      Text(
                        'Share your story with the world',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Book Details Section
                      SectionTitle(title: 'Book details', colors: colors),
                      const SizedBox(height: 16),

                      // Title field
                      ValidatingTextField(
                        controller: _titleController,
                        label: 'Book title',
                        colors: colors,
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),

                      // Description field
                      ValidatingTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        colors: colors,
                        maxLines: 4,
                        maxLength: 500,
                        helperText: 'Describe your book to attract readers',
                        isRequired: true,
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
                            child: ValidatingMultiSelect(
                              label: 'Genres',
                              value: _selectedGenres,
                              items: _genres,
                              colors: colors,
                              validator: (values) {
                                if (values == null || values.isEmpty) {
                                  return 'Please select';
                                }
                                return null;
                              },
                              onChanged: (values) {
                                setState(() {
                                  _selectedGenres = values;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ValidatingDropdown(
                              label: 'Language',
                              value: _selectedLanguage,
                              items: _languages,
                              colors: colors,
                              isRequired: true,
                              onChanged: (value) {
                                setState(() {
                                  _selectedLanguage = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // Pages and Price row
                      Row(
                        children: [
                          Expanded(
                            child: ValidatingTextField(
                              controller: _pagesController,
                              label: 'Pages',
                              colors: colors,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              isRequired: true,
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
                            child: ValidatingTextField(
                              controller: _priceController,
                              label: 'Price (CRC)',
                              colors: colors,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              isRequired: true,
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
                      AgeRatingSelector(
                        selectedAge: _minimumAge,
                        ageRatings: _ageRatings,
                        colors: colors,
                        label: 'Minimum age',
                        onAgeSelected: (age) {
                          setState(() {
                            _minimumAge = age;
                          });
                        },
                      ),

                      // Publisher (optional)
                      ValidatingTextField(
                        controller: _publisherController,
                        label: 'Publisher (optional)',
                        colors: colors,
                      ),

                      // Setting (optional)
                      ValidatingTextField(
                        controller: _settingController,
                        label: 'Story setting (optional)',
                        colors: colors,
                        helperText:
                            'E.g., "New York, 1920s" or "Medieval fantasy world"',
                      ),

                      const SizedBox(height: 32),

                      // NEW: Cover Image Upload Section
                      SectionTitle(title: 'Book cover', colors: colors),
                      const SizedBox(height: 8),
                      Text(
                        'Upload an attractive cover image for your book',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CoverImageUploader(
                        colors: colors,
                        onImageSelected: (file) {
                          setState(() {
                            _coverImageFile = file;
                            if (file != null) {
                              _coverImageHasError = false;
                            }
                          });
                        },
                        validator: (file) {
                          if (_hasTriedToSubmit && file == null) {
                            return 'Please upload a book cover image';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // PDF Upload Section
                      SectionTitle(title: 'Book file', colors: colors),
                      const SizedBox(height: 16),
                      PdfUploader(
                        colors: colors,
                        validator: (file) {
                          if (file == null) {
                            return 'Please upload your book PDF';
                          }
                          return null;
                        },
                        onFileSelected: (file) {
                          _pdfFile = file;
                          _pdfFileName = file.path.split('/').last;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Characters Section
                      SectionTitle(title: 'AI Characters', colors: colors),
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
                        (entry) => CharacterFormCard(
                          index: entry.key,
                          character: entry.value,
                          colors: colors,
                          onRemove: () => _removeCharacter(entry.key),
                          showValidationErrors: _hasTriedToSubmit,
                        ),
                      ),

                      // Add character button
                      AddCharacterButton(
                        colors: colors,
                        onPressed: _addCharacter,
                      ),

                      const SizedBox(height: 40),

                      // Publish button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            ads.getRewarded(_isPremium, _onPublish);
                          },
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
      ),
    );
  }
}
