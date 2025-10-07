class PlantDisease {
  final String id;
  final String name;
  final String scientificName;
  final String crop;
  final String severity; // 'mild', 'moderate', 'severe', 'none'
  final double confidence;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatments;
  final List<String> prevention;
  final String? imageUrl;
  final bool isContagious;
  final String affectedParts; // 'leaves', 'stem', 'fruit', 'roots'
  final Map<String, dynamic> environmentalFactors;

  PlantDisease({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.crop,
    required this.severity,
    required this.confidence,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatments,
    required this.prevention,
    this.imageUrl,
    required this.isContagious,
    required this.affectedParts,
    required this.environmentalFactors,
  });

  factory PlantDisease.fromJson(Map<String, dynamic> json) {
    return PlantDisease(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      crop: json['crop'] ?? '',
      severity: json['severity'] ?? 'moderate',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : double.tryParse(json['confidence']?.toString() ?? '0') ?? 0.0,
      description: json['description'] ?? '',
      symptoms:
          (json['symptoms'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      causes: (json['causes'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      treatments:
          (json['treatments'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      prevention:
          (json['prevention'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      imageUrl: json['image_url']?.toString(),
      isContagious: json['is_contagious'] == true,
      affectedParts: json['affected_parts']?.toString() ?? 'leaves',
      environmentalFactors: (json['environmental_factors'] as Map?)
              ?.map((k, v) => MapEntry(k.toString(), v)) ??
          const {},
    );
  }
}

class DiseaseDetectionResult {
  final String imageId;
  final DateTime detectionTime;
  final List<PlantDisease> detectedDiseases;
  final String imagePath;
  final Map<String, dynamic> imageMetadata;
  final String location;
  final String? notes;

  DiseaseDetectionResult({
    required this.imageId,
    required this.detectionTime,
    required this.detectedDiseases,
    required this.imagePath,
    required this.imageMetadata,
    required this.location,
    this.notes,
  });

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionResult(
      imageId: json['image_id'] ?? '',
      detectionTime:
          DateTime.tryParse(json['detection_time']?.toString() ?? '') ??
              DateTime.now(),
      detectedDiseases: (json['detected_diseases'] as List? ?? [])
          .map((d) => PlantDisease.fromJson(d as Map<String, dynamic>))
          .toList(),
      imagePath: json['image_path'] ?? '',
      imageMetadata: (json['image_metadata'] as Map?)
              ?.map((k, v) => MapEntry(k.toString(), v)) ??
          const {},
      location: json['location'] ?? 'Unknown',
      notes: json['notes']?.toString(),
    );
  }
}

class CropDiseaseDatabase {
  static final Map<String, List<String>> _cropDiseases = {
    'tomato': [
      'Tomato Bacterial Spot',
      'Tomato Early Blight',
      'Tomato Late Blight',
      'Tomato Leaf Mold',
      'Tomato Septoria Leaf Spot',
      'Tomato Spider Mites',
      'Tomato Target Spot',
      'Tomato Yellow Leaf Curl Virus',
      'Tomato Mosaic Virus',
      'Healthy'
    ],
    'potato': ['Potato Early Blight', 'Potato Late Blight', 'Potato Healthy'],
    'pepper': ['Pepper Bell Bacterial Spot', 'Pepper Bell Healthy'],
    'corn': [
      'Corn Common Rust',
      'Corn Northern Leaf Blight',
      'Corn Gray Leaf Spot',
      'Corn Healthy'
    ],
    'wheat': [
      'Wheat Leaf Rust',
      'Wheat Stem Rust',
      'Wheat Stripe Rust',
      'Wheat Powdery Mildew',
      'Wheat Healthy'
    ],
    'rice': ['Rice Blast', 'Rice Brown Spot', 'Rice Leaf Smut', 'Rice Healthy']
  };

  static List<String> getDiseasesForCrop(String crop) {
    return _cropDiseases[crop.toLowerCase()] ?? [];
  }

  static List<String> getAllSupportedCrops() {
    return _cropDiseases.keys.toList();
  }
}
