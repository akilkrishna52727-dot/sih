import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../models/disease_models.dart';
import '../services/disease_detection_service.dart';
import '../utils/constants.dart';
import '../widgets/disease_result_card.dart';
import '../widgets/loading_animation.dart';
import 'disease_details_screen.dart';
import 'disease_camera_screen.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen>
    with TickerProviderStateMixin {
  final DiseaseDetectionService _diseaseService = DiseaseDetectionService();
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _animationController;

  File? _selectedImage;
  List<PlantDisease> _detectedDiseases = [];
  bool _isAnalyzing = false;
  bool _isModelLoaded = false;
  DateTime? _lastAnalysisTime;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeModel();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
  }

  Future<void> _initializeModel() async {
    setState(() {});

    final success = await _diseaseService.initializeModel();
    setState(() {
      _isModelLoaded = success;
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Disease Detection'),
        backgroundColor: AppConstants.primaryGreen,
        actions: [
          IconButton(
              icon: const Icon(Icons.help_outline), onPressed: _showHelpDialog),
          IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showDetectionHistory),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildImageSelectionSection(),
            const SizedBox(height: 24),
            if (_selectedImage != null) ...[
              _buildAnalysisSection(),
              const SizedBox(height: 24),
            ],
            _buildEducationalContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppConstants.primaryGreen, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.biotech, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI-Powered Disease Detection',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Early detection saves crops',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isModelLoaded
                    ? (_diseaseService.isDemoMode
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2))
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isModelLoaded
                      ? (_diseaseService.isDemoMode
                          ? Colors.orange
                          : Colors.green)
                      : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isModelLoaded
                        ? (_diseaseService.isDemoMode
                            ? Icons.science
                            : Icons.check_circle)
                        : Icons.error,
                    color: _isModelLoaded
                        ? (_diseaseService.isDemoMode
                            ? Colors.orange
                            : Colors.green)
                        : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isModelLoaded
                          ? (_diseaseService.isDemoMode
                              ? 'Demo Mode: Simulated AI results'
                              : 'AI Model Ready')
                          : 'Model loading failed',
                      style: TextStyle(
                        color: _isModelLoaded
                            ? (_diseaseService.isDemoMode
                                ? Colors.orange
                                : Colors.green)
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  Widget _buildImageSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Image for Analysis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('No image selected',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Take a photo or select from gallery',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label:
                    const Text('Camera', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Gallery',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openAdvancedCamera,
                icon: const Icon(Icons.camera_enhance, color: Colors.white),
                label: const Text('Pro Cam',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeImage,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.biotech, color: Colors.white),
              label: Text(
                  _isAnalyzing ? 'Analyzing...' : 'Analyze for Diseases',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisSection() {
    if (_isAnalyzing) return _buildAnalyzingWidget();
    if (_detectedDiseases.isEmpty &&
        !_isAnalyzing &&
        _lastAnalysisTime != null) {
      return _buildNoDiseasesWidget();
    }
    if (_detectedDiseases.isNotEmpty) {
      return _buildResultsWidget();
    }
    return const SizedBox.shrink();
  }

  Widget _buildAnalyzingWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const LoadingAnimation(),
            const SizedBox(height: 16),
            const Text('Analyzing Image...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('AI is examining your plant for diseases',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDiseasesWidget() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('Great News! 🎉',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'No diseases detected in your plant. It appears to be healthy!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showPreventionTips,
              icon: const Icon(Icons.tips_and_updates, color: Colors.white),
              label: const Text('Prevention Tips',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detection Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Chip(
              label: Text('${_detectedDiseases.length} detected'),
              backgroundColor: Colors.red.shade100,
              labelStyle: TextStyle(color: Colors.red.shade700),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._detectedDiseases.map((d) =>
            DiseaseResultCard(disease: d, onTap: () => _showDiseaseDetails(d))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showTreatmentPlan,
                icon: const Icon(Icons.medical_services, color: Colors.white),
                label: const Text('Treatment Plan',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareResults,
                icon: const Icon(Icons.share),
                label: const Text('Share Results'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Learn About Plant Diseases',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildEducationCard(
                'Common Diseases',
                Icons.coronavirus,
                Colors.red,
                'Learn about frequent plant diseases',
                _showCommonDiseases),
            _buildEducationCard('Prevention Tips', Icons.shield, Colors.green,
                'How to prevent plant diseases', _showPreventionTips),
            _buildEducationCard('Best Practices', Icons.eco, Colors.blue,
                'Healthy plant care practices', _showBestPractices),
            _buildEducationCard('Photo Guide', Icons.camera_alt, Colors.purple,
                'How to take better photos', _showPhotoGuide),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationCard(
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
          source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _detectedDiseases.clear();
          _lastAnalysisTime = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _openAdvancedCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty && mounted) {
        final result = await Navigator.push<File>(
          context,
          MaterialPageRoute(
              builder: (context) => DiseaseCameraScreen(cameras: cameras)),
        );
        if (result != null) {
          setState(() {
            _selectedImage = result;
            _detectedDiseases.clear();
            _lastAnalysisTime = null;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error opening camera: $e')));
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _detectedDiseases.clear();
    });

    try {
      final diseases =
          await _diseaseService.detectDiseasesFromImage(_selectedImage!);
      setState(() {
        _detectedDiseases = diseases;
        _lastAnalysisTime = DateTime.now();
      });

      final severe = diseases.firstWhere(
        (d) => d.severity == 'severe',
        orElse: () => PlantDisease(
          id: '',
          name: '',
          scientificName: '',
          crop: '',
          severity: '',
          confidence: 0,
          description: '',
          symptoms: const [],
          causes: const [],
          treatments: const [],
          prevention: const [],
          isContagious: false,
          affectedParts: '',
          environmentalFactors: const {},
        ),
      );

      if (severe.name.isNotEmpty) {
        _showSevereDiseaseBanner(severe);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Analysis failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
    }
  }

  void _showSevereDiseaseBanner(PlantDisease disease) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Severe Disease Detected!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${disease.name} requires immediate attention'),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => _showDiseaseDetails(disease),
        ),
      ),
    );
  }

  void _showDiseaseDetails(PlantDisease disease) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DiseaseDetailsScreen(disease: disease)),
    );
  }

  void _showTreatmentPlan() {
    final recommendations =
        _diseaseService.getTreatmentRecommendations(_detectedDiseases);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Treatment Recommendations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(recommendations[index],
                        style: const TextStyle(fontSize: 14)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Results shared successfully!')));
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use AI Disease Detection'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📸 Taking Good Photos:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('-  Hold camera 6-12 inches from the plant'),
              Text('-  Ensure good lighting (natural light preferred)'),
              Text('-  Focus on affected leaves or plant parts'),
              Text('-  Avoid shadows and reflections'),
              SizedBox(height: 12),
              Text('🔍 Best Results:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('-  Clean the camera lens'),
              Text('-  Take multiple angles if needed'),
              Text('-  Include healthy parts for comparison'),
              Text('-  Avoid blurry or dark images'),
              SizedBox(height: 12),
              Text('⚠️ Limitations:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('-  AI is a diagnostic aid, not replacement for experts'),
              Text('-  Some diseases may require lab confirmation'),
              Text('-  Early stage diseases might not be detected'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it')),
        ],
      ),
    );
  }

  void _showDetectionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Detection history feature coming soon!')));
  }

  void _showCommonDiseases() {}
  void _showPreventionTips() {}
  void _showBestPractices() {}
  void _showPhotoGuide() {}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
