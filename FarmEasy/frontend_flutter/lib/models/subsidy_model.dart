class SubsidyScheme {
  final String id;
  final String name;
  final String description;
  final String eligibility;
  final String benefits;
  final String applicationProcess;
  final String category; // 'income_support', 'insurance', 'credit', 'equipment'
  final bool isActive;
  final String ministry;
  final String contactInfo;
  final List<String>? states; // null => all India
  final List<String>? crops; // null => any crop
  final double? minLandSize; // hectares
  final double? maxLandSize; // hectares
  final String? applicationUrl;

  const SubsidyScheme({
    required this.id,
    required this.name,
    required this.description,
    required this.eligibility,
    required this.benefits,
    required this.applicationProcess,
    required this.category,
    required this.isActive,
    required this.ministry,
    required this.contactInfo,
    this.states,
    this.crops,
    this.minLandSize,
    this.maxLandSize,
    this.applicationUrl,
  });
}
