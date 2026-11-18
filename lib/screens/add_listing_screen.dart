import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

import '../models/listing.dart';
import '../services/contact_links.dart';
import '../services/database_helper.dart';
import '../services/photo_service.dart';

/// Form for listing a textbook: photo, title, author, subject, price,
/// condition, seller name and phone.
class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _subject = listingSubjects.first;
  String _condition = 'Good';
  String? _photoPath;
  bool _saving = false;
  final _photoService = PhotoService();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final path = await _photoService.pickAndStorePhoto(source);
    if (path != null) setState(() => _photoPath = path);
  }

  void _showPhotoSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final listing = Listing(
      title: _titleController.text.trim(),
      author: _authorController.text.trim().isEmpty
          ? null
          : _authorController.text.trim(),
      subject: _subject,
      price: double.parse(_priceController.text.trim()),
      condition: _condition,
      photoPath: _photoPath,
      sellerName: _nameController.text.trim(),
      sellerPhone: _phoneController.text.trim(),
      createdAt: DateTime.now(),
    );
    await DatabaseHelper.instance.insertListing(listing);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your book is listed!')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell a book')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _showPhotoSheet,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _photoPath != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(_photoPath!), fit: BoxFit.cover),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: _showPhotoSheet,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 44,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          const Text('Add a photo of the book'),
                          const Text(
                            'Tap to use camera or gallery',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Book title *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter the title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              decoration: const InputDecoration(
                labelText: 'Subject / stream',
                border: OutlineInputBorder(),
              ),
              items: listingSubjects
                  .map(
                    (s) => DropdownMenuItem(value: s, child: Text(s)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _subject = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (₹) *',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a price';
                final price = double.tryParse(v.trim());
                if (price == null || price <= 0) {
                  return 'Enter a valid price above ₹0';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: listingConditions
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _condition = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your name *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Your WhatsApp number *',
                hintText: '9876543210',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter your phone number';
                }
                if (!isValidPhone(v)) {
                  return 'Enter a valid number (at least 10 digits)';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Buyers will reach you on WhatsApp or by call. '
              'Your number is only shown on your own listings.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('List this book'),
            ),
          ],
        ),
      ),
    );
  }
}
