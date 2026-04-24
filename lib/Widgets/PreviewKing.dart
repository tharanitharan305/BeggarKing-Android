import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Firebase/Insert_King.dart';
import 'locations.dart';

class PreviewKing extends StatefulWidget {
  const PreviewKing({Key? key}) : super(key: key);

  @override
  _PreviewKingState createState() => _PreviewKingState();
}

class _PreviewKingState extends State<PreviewKing>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields to manage their state
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinController = TextEditingController();
  final _countryController = TextEditingController();

  // State variables
  XFile? _kingImage;
  Uint8List? _kingImageBytes;
  String _latitude = "";
  String _longitude = "";
  bool _isUploading = false;
  bool _isFetchingLocation = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Controller for fade-in animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Controller for scale/pop animations
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Start the initial animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _streetController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    _countryController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // Increased for better quality
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _kingImage = image;
      _kingImageBytes = bytes;
    });
  }

  Future<void> _getLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });
    try {
      var add = await Locations().getcurrentLocation();
      var geolocator = add.split(",");
      // Update controllers which will update the UI
      _streetController.text = "${geolocator[0]}, ${geolocator[1]}";
      _areaController.text = geolocator[2];
      _districtController.text = geolocator[3];
      _pinController.text = geolocator[5];
      _stateController.text = geolocator[4];
      _countryController.text = geolocator[6];
      _latitude = geolocator[7];
      _longitude = geolocator[8];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  void _launchKing() {
    if (_kingImage == null || _kingImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isUploading = true;
      });
      // Assuming Insert_King().putFile is an async operation
      Insert_King()
          .putFile(
            picData: _kingImageBytes!,
            fileName: _kingImage!.name,
            location: _streetController.text,
            area: _areaController.text,
            country: _countryController.text,
            localPin: _pinController.text,
            district: _districtController.text,
            state: _stateController.text,
            latitude: _latitude,
            logitude: _longitude,
            like: 0,
            dislike: 0,
          )
          .then((_) {
            Navigator.pop(context);
          })
          .catchError((error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload failed: $error')));
          })
          .whenComplete(() {
            if (mounted) {
              setState(() {
                _isUploading = false;
              });
            }
          });
    }
  }

  void _resetImage() {
    setState(() {
      _kingImage = null;
      _kingImageBytes = null;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Launch a New King'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Image Picker ---
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildImagePicker(),
              ),
              const SizedBox(height: 24),
              // --- Location Section ---
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLocationSection(),
              ),
              const SizedBox(height: 16),
              // --- Form ---
              FadeTransition(opacity: _fadeAnimation, child: _buildForm()),
              const SizedBox(height: 24),
              // --- Action Buttons ---
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Builder methods for cleaner code ---

  Widget _buildImagePicker() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child:
          _kingImage == null
              ? GestureDetector(
                key: const ValueKey('picker'),
                onTap: _pickImage,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add a photo',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : Container(
                key: const ValueKey('image'),
                height: 350,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_kingImageBytes!, fit: BoxFit.cover),
                ),
              ),
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isFetchingLocation ? null : _getLocation,
            icon:
                _isFetchingLocation
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.my_location),
            label: const Text("Auto-detect"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Logic for manual entry can be added here
            },
            icon: const Icon(Icons.edit_location_outlined),
            label: const Text("Manual"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;
          return Column(
            children: [
              _buildTextFormField(
                controller: _streetController,
                label: "Street",
                icon: Icons.signpost_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _areaController,
                label: "Area / Taluk",
                icon: Icons.travel_explore,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _districtController,
                label: "District",
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 16),
              if (isNarrow) ...[
                _buildTextFormField(
                  controller: _pinController,
                  label: "PIN Code",
                  icon: Icons.numbers,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _stateController,
                  label: "State",
                  icon: Icons.map_outlined,
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _pinController,
                        label: "PIN Code",
                        icon: Icons.numbers,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _stateController,
                        label: "State",
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _countryController,
                label: "Country",
                icon: Icons.flag_outlined,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter a valid $label";
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _launchKing,
          icon:
              _isUploading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.rocket_launch_outlined),
          label:
              _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Launch King'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_kingImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: _resetImage,
              icon: const Icon(Icons.refresh),
              label: const Text('Choose a different photo'),
            ),
          ),
      ],
    );
  }
}
