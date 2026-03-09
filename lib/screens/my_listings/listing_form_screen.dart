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

class _ListingFormScreenState extends State<ListingFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  String _selectedCategory = 'Hospital';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

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
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final listingProvider = context.read<ListingProvider>();
    final uid = authProvider.firebaseUser!.uid;
    final username = authProvider.userProfile?.username ?? '';
    final displayName = authProvider.userProfile?.displayName ?? '';

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
      createdByUsername: username.isNotEmpty ? username : displayName,
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(listingProvider.errorMessage ?? 'Something went wrong'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Listing' : 'New Listing',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
             
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF4ECDC4), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isEditing
                              ? 'Update the details for this listing.'
                              : 'Add a place or service to help others in Kigali find it.',
                          style: const TextStyle(color: Color(0xFF8892B0), fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Basic Information'),
                _buildField(
                  controller: _nameController,
                  label: 'Place / Service Name',
                  hint: 'e.g. King Faisal Hospital',
                  icon: Icons.business_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel('Category'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF111827),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4ECDC4)),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: kCategories
                          .where((c) => c != 'All')
                          .map((c) {
                            final categoryData = kCategoryIcons[c] ?? kCategoryIcons['Other']!;
                            final color = Color(categoryData['color'] as int);
                            final iconData = IconData(categoryData['icon'] as int, fontFamily: 'MaterialIcons');
                            return DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(iconData, color: color, size: 16),
                                  const SizedBox(width: 10),
                                  Text(c),
                                ],
                              ),
                            );
                          })
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Location Details'),
                _buildField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'e.g. KG 2 Ave, Kigali',
                  icon: Icons.location_on_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Enter an address' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel('Geographic Coordinates'),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE66D).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE66D).withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates_outlined, color: Color(0xFFFFE66D), size: 14),
                          SizedBox(width: 6),
                          Text('How to find coordinates', style: TextStyle(color: Color(0xFFFFE66D), fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '1. Open Google Maps\n2. Long press on the location\n3. The coordinates appear at the top — tap to copy\n4. Paste latitude and longitude below',
                        style: TextStyle(color: Color(0xFF8892B0), fontSize: 12, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _latController,
                        label: 'Latitude',
                        hint: 'e.g. -1.9441',
                        icon: Icons.south_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final val = double.tryParse(v);
                          if (val == null) return 'Invalid number';
                          if (val < -90 || val > 90) return 'Must be -90 to 90';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _lngController,
                        label: 'Longitude',
                        hint: 'e.g. 30.0619',
                        icon: Icons.east_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final val = double.tryParse(v);
                          if (val == null) return 'Invalid number';
                          if (val < -180 || val > 180) return 'Must be -180 to 180';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Contact & Description'),
                _buildField(
                  controller: _contactController,
                  label: 'Contact Number',
                  hint: 'e.g. +250 788 000 000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Enter a contact number' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe this place or service — opening hours, what it offers, how to get there...',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty ? 'Enter a description' : null,
                ),
                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF2EAF9F)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: listingProvider.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: listingProvider.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            _isEditing ? 'Save Changes' : 'Create Listing',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(color: Color(0xFF8892B0), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: const Color(0xFF1F2937), height: 1)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4), size: 18),
            filled: true,
            fillColor: const Color(0xFF111827),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F2937))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1F2937))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE53935))),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE53935))),
            errorStyle: const TextStyle(color: Color(0xFFE53935), fontSize: 11),
          ),
          validator: validator,
        ),
      ],
    );
  }
}