import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/listing_model.dart';
import '../../utils/constants.dart';

class ListingFormScreen extends StatefulWidget {
  final ListingModel? listing;

  const ListingFormScreen({super.key, this.listing});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  String _selectedCategory = 'Hospital';

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.listing!.name;
      _addressController.text = widget.listing!.address;
      _contactController.text = widget.listing!.contactNumber;
      _descriptionController.text = widget.listing!.description;
      _latController.text = widget.listing!.latitude.toString();
      _lngController.text = widget.listing!.longitude.toString();
      _selectedCategory = widget.listing!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final listingProvider = context.read<ListingProvider>();
    final uid = authProvider.firebaseUser!.uid;

    final listing = ListingModel(
      id: _isEditing ? widget.listing!.id : '',
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: double.parse(_latController.text.trim()),
      longitude: double.parse(_lngController.text.trim()),
      createdBy: uid,
      timestamp: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await listingProvider.updateListing(widget.listing!.id, listing);
    } else {
      success = await listingProvider.createListing(listing);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Listing updated successfully' : 'Listing created successfully'),
          backgroundColor: const Color(0xFF4ECDC4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(listingProvider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3460),
        title: Text(
          _isEditing ? 'Edit Listing' : 'New Listing',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Place / Service Name'),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. King Faisal Hospital',
                icon: Icons.business_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Category'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F3460),
                    style: const TextStyle(color: Colors.white),
                    items: kCategories
                        .where((c) => c != 'All')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Address'),
              _buildTextField(
                controller: _addressController,
                hint: 'e.g. KG 2 Ave, Kigali',
                icon: Icons.location_on_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Enter an address' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Contact Number'),
              _buildTextField(
                controller: _contactController,
                hint: 'e.g. +250 788 000 000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Enter a contact number' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Description'),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Describe this place or service...',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Geographic Coordinates'),
              const SizedBox(height: 4),
              const Text(
                'You can find coordinates using Google Maps — long press a location and copy the numbers shown.',
                style: TextStyle(color: Color(0xFF8892B0), fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latController,
                      hint: 'Latitude',
                      icon: Icons.my_location,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _lngController,
                      hint: 'Longitude',
                      icon: Icons.my_location,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: listingProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    foregroundColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: listingProvider.isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF1A1A2E))
                      : Text(
                          _isEditing ? 'Save Changes' : 'Create Listing',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8892B0)),
        prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4)),
        filled: true,
        fillColor: const Color(0xFF0F3460),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4ECDC4)),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      ),
      validator: validator,
    );
  }
}