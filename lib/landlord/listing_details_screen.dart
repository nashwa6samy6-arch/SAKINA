import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'host_profile_screen.dart';
import '../utils/universities.dart';

// ==================== LOCAL APP COLORS ====================
class AppColors {
  static const background = Color(0xFFFAF9F6);
  static const surface = Color(0xFFF2F0EB);
  static const border = Color(0xFFE0DDD6);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF888780);
  static const textHint = Color(0xFFB4B2A9);
  static const gold = Color(0xFFC8A84B);
  static const goldLight = Color(0xFFFDF6E3);
  static const goldText = Color(0xFF8A6D1A);
  static const dark = Color(0xFF1A1A1A);
  static const white = Color(0xFFFFFFFF);
}

class ListingDetailsScreen extends StatefulWidget {
  final String listingId, title, location, price, beds, tag, imageUrl;
  const ListingDetailsScreen({
    super.key,
    required this.listingId,
    required this.title,
    required this.location,
    required this.price,
    required this.beds,
    required this.tag,
    this.imageUrl = '',
  });

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  late String _policy, _propertyType, _university;
  late bool _isAvailable;
  List<String> _imageUrls = [];
  double? _latitude, _longitude;
  final List<XFile> _newPhotos = [];
  final ImagePicker _picker = ImagePicker();
  final _titleController = TextEditingController();
  final _rentController = TextEditingController();
  final _locationController = TextEditingController();
  final _bedsController = TextEditingController();
  final _aboutController = TextEditingController();

  // Amenities map – values will be set from database
  final Map<String, bool> _amenities = {
    'Wi-Fi': false,
    'AC': false,
    'Cleaning Service': false,
    'Maintenance Included': false,
    'Furnished': false,
    'Parking': false,
  };

  final Map<String, IconData> _amenityIcons = {
    'Wi-Fi': Icons.wifi,
    'AC': Icons.ac_unit,
    'Cleaning Service': Icons.cleaning_services_outlined,
    'Maintenance Included': Icons.build_outlined,
    'Furnished': Icons.chair_outlined,
    'Parking': Icons.local_parking_outlined,
  };

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _rentController.text = widget.price;
    _locationController.text = widget.location;
    _bedsController.text = widget.beds;
    _policy = 'Female Only';
    _propertyType = 'Apartment';
    _university = 'American University in Cairo (AUC)';
    _isAvailable = widget.tag != 'FULLY BOOKED';
    _loadImagesAndLocation();
    _loadAmenities();
  }

  Future<void> _loadAmenities() async {
    try {
      final response = await supabase
          .from('property_listings')
          .select('amenities')
          .eq('listing_id', widget.listingId)
          .maybeSingle();
      if (response != null && response['amenities'] != null) {
        final List<dynamic>? amenitiesList = response['amenities'];
        if (amenitiesList != null) {
          setState(() {
            for (var amenity in _amenities.keys) {
              _amenities[amenity] = amenitiesList.contains(amenity);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading amenities: $e');
    }
  }

  Future<void> _loadImagesAndLocation() async {
    final folderPath = widget.listingId.toString();
    try {
      final files =
          await supabase.storage.from('listing-images').list(path: folderPath);
      List<String> urls = [];
      for (var file in files) {
        urls.add(supabase.storage
            .from('listing-images')
            .getPublicUrl('$folderPath/${file.name}'));
      }
      urls.sort();
      setState(() => _imageUrls = urls);
    } catch (e) {}
    try {
      final locData = await supabase
          .from('location')
          .select('latitude, longitude')
          .eq('listing_id', widget.listingId)
          .maybeSingle();
      if (locData != null) {
        setState(() {
          _latitude = locData['latitude']?.toDouble();
          _longitude = locData['longitude']?.toDouble();
        });
      }
    } catch (e) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) setState(() => _newPhotos.add(image));
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Photo',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                        child:
                            _imageOption(Icons.camera_alt_outlined, 'Camera'))),
                const SizedBox(width: 16),
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                        child: _imageOption(
                            Icons.photo_library_outlined, 'Gallery'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageOption(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Column(children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label)
        ]),
      );

  List<String> get _selectedAmenities {
    return _amenities.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final folderPath = widget.listingId.toString();
      int existingCount = _imageUrls.length;
      for (int i = 0; i < _newPhotos.length; i++) {
        final file = _newPhotos[i];
        final fullPath = '$folderPath/${existingCount + i}.jpg';
        if (kIsWeb) {
          await supabase.storage
              .from('listing-images')
              .uploadBinary(fullPath, await file.readAsBytes());
        } else {
          await supabase.storage
              .from('listing-images')
              .upload(fullPath, File(file.path));
        }
      }
      await supabase.from('property_listings').update({
        'title': _titleController.text,
        'description': _aboutController.text,
        'rent_price': double.parse(_rentController.text.replaceAll(',', '')),
        'property_type': _propertyType.toLowerCase(),
        'status': _isAvailable ? 'available' : 'fully_booked',
        'amenities': _selectedAmenities, // ✅ store updated amenities
      }).eq('listing_id', widget.listingId);
      await _loadImagesAndLocation();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Listing updated!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteListing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await supabase
          .from('property_listings')
          .delete()
          .eq('listing_id', widget.listingId);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Listing deleted')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _mediaSection(),
                    _divider(),
                    _propertyBasicsSection(),
                    _divider(),
                    _studentFocusSection(),
                    _divider(),
                    _amenitiesSection(),
                    _divider(),
                    _locationSection(),
                    _divider(),
                    _aboutSection(),
                    _actionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  Widget _mediaSection() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
                title: 'Listing\nPhotos', step: 'STEP 01 / 05'),
            SizedBox(
              height: 200,
              child: _imageUrls.isEmpty
                  ? Container(
                      color: AppColors.surface,
                      child: const Center(child: Text('No images')))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(_imageUrls[index],
                                fit: BoxFit.cover)),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border)),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Add more photos', style: TextStyle(fontSize: 12))
                    ]),
              ),
            ),
          ],
        ),
      );

  Widget _propertyBasicsSection() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
                title: 'Property\nBasics', step: 'STEP 02 / 05'),
            _InputField(
                label: 'PROPERTY TITLE',
                hint: 'e.g., Sun-drenched Studio',
                controller: _titleController),
            const SizedBox(height: 14),
            _InputField(
                label: 'MONTHLY RENT (EGP)',
                hint: '8,500',
                controller: _rentController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            _InputField(
                label: 'LOCATION (AREA/NEIGHBORHOOD)',
                hint: 'New Cairo',
                controller: _locationController),
            const SizedBox(height: 14),
            _DropdownField(
                label: 'PROPERTY TYPE',
                value: _propertyType,
                items: const ['Apartment', 'Studio', 'Room', 'Villa'],
                onChanged: (v) => setState(() => _propertyType = v!)),
            const SizedBox(height: 14),
            Text('AVAILABILITY',
                style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.08)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Available', 'Fully Booked'].map((p) {
                final active = p == 'Available' ? _isAvailable : !_isAvailable;
                return GestureDetector(
                  onTap: () => setState(() => _isAvailable = p == 'Available'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.goldLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: active ? AppColors.gold : AppColors.border),
                    ),
                    child: Text(p,
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: active
                                ? AppColors.goldText
                                : AppColors.textPrimary)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );

  Widget _studentFocusSection() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'Student\nFocus', step: 'STEP 03 / 05'),
            Text('POLICY',
                style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.08)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Female Only', 'Male Only'].map((p) {
                final active = _policy == p;
                return GestureDetector(
                  onTap: () => setState(() => _policy = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.goldLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: active ? AppColors.gold : AppColors.border),
                    ),
                    child: Text(p,
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: active
                                ? AppColors.goldText
                                : AppColors.textPrimary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _DropdownField(
                label: 'NEAR UNIVERSITY',
                value: _university,
                items: egyptianUniversities,
                onChanged: (v) => setState(() => _university = v!)),
          ],
        ),
      );

  Widget _amenitiesSection() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'Amenities', step: 'STEP 04 / 05'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _amenities.entries.map((e) {
                final active = e.value;
                return GestureDetector(
                  onTap: () => setState(() => _amenities[e.key] = !active),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.goldLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: active ? AppColors.gold : AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_amenityIcons[e.key] ?? Icons.check,
                            size: 14,
                            color: active
                                ? AppColors.goldText
                                : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(e.key,
                            style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: active
                                    ? AppColors.goldText
                                    : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );

  Widget _locationSection() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Location',
                  style: GoogleFonts.manrope(
                      fontSize: 26, fontWeight: FontWeight.w300)),
              Text(widget.location,
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 16),
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border)),
              child: (_latitude != null && _longitude != null)
                  ? FlutterMap(
                      options: MapOptions(
                          initialCenter: LatLng(_latitude!, _longitude!),
                          initialZoom: 15),
                      children: [
                        TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app'),
                        MarkerLayer(markers: [
                          Marker(
                              point: LatLng(_latitude!, _longitude!),
                              width: 30,
                              height: 30,
                              child: const Icon(Icons.location_pin,
                                  color: Colors.red, size: 30))
                        ]),
                      ],
                    )
                  : const _MapPlaceholder(),
            ),
          ],
        ),
      );

  Widget _aboutSection() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
                title: 'About the\nProperty', step: 'STEP 05 / 05'),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: TextField(
                controller: _aboutController,
                maxLines: 5,
                style: GoogleFonts.manrope(fontSize: 14),
                decoration: const InputDecoration(
                    hintText: 'Describe the property...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14)),
              ),
            ),
          ],
        ),
      );

  Widget _actionButtons() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Save Changes',
                        style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deleteListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Delete Listing',
                    style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      );

  Widget _divider() => Container(
      height: 0.5,
      color: AppColors.border,
      margin: const EdgeInsets.only(top: 28));
}

// ==================== HELPER WIDGETS ====================
class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppColors.border, width: 0.5))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(children: [
              Icon(Icons.arrow_back, size: 18),
              SizedBox(width: 6),
              Text('Listing Details',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
            ]),
          ),
          const Spacer(),
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.more_horiz, size: 16)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, step;
  const _SectionHeader({required this.title, required this.step});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.manrope(
                  fontSize: 26, fontWeight: FontWeight.w300)),
          Text(step,
              style: GoogleFonts.manrope(
                  fontSize: 11, color: Colors.grey, letterSpacing: 0.04)),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label, hint;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  const _InputField(
      {required this.label,
      required this.hint,
      this.keyboardType = TextInputType.text,
      this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surface,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
              onTap: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const _NavItem(icon: Icons.grid_view, label: 'DASHBOARD')),
          const _NavItem(icon: Icons.chat_bubble_outline, label: 'MESSAGES'),
          GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HostProfileScreen())),
              child:
                  const _NavItem(icon: Icons.person_outline, label: 'PROFILE')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: Colors.white),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
    ]);
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(size: Size.infinite, painter: _GridPainter()),
        Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: AppColors.dark, shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.location_on, size: 16, color: Colors.white))),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 46) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
