import 'package:flutter/foundation.dart';
import '../models/virtual_farm_model.dart';
import '../services/virtual_farm_service.dart';
import '../services/data_persistence_service.dart';

class VirtualFarmProvider extends ChangeNotifier {
  VirtualFarm? _currentFarm;
  List<VirtualFarm> _farms = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  VirtualFarm? get currentFarm => _currentFarm;
  List<VirtualFarm> get farms => _farms;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  final VirtualFarmService _service = VirtualFarmService();

  VirtualFarmProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    if (!_isInitialized) {
      await _loadPersistedFarms();
      _isInitialized = true;
    }
  }

  Future<void> _loadPersistedFarms() async {
    _setLoading(true);
    try {
      _farms = await DataPersistenceService.loadVirtualFarms();
      if (_farms.isNotEmpty) {
        // Prefer a farm that is not too old (within ~150 days), otherwise pick the last
        final recent = _farms.where(
            (f) => DateTime.now().difference(f.plantingDate).inDays < 150);
        _currentFarm = recent.isNotEmpty ? recent.last : _farms.last;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createVirtualFarm({
    required double landSize,
    required String cropType,
    required String location,
    required DateTime plantingDate,
  }) async {
    _setLoading(true);
    try {
      _currentFarm = await _service.createVirtualFarm(
        landSize: landSize,
        cropType: cropType,
        location: location,
        plantingDate: plantingDate,
      );
      if (_currentFarm != null) {
        _farms.add(_currentFarm!);
        await DataPersistenceService.saveVirtualFarms(_farms);
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserFarms() async {
    if (!_isInitialized) {
      await _initializeProvider();
    } else {
      await _loadPersistedFarms();
    }
  }

  Future<bool> updateFarmProgress(String farmId) async {
    try {
      final updated = await _service.updateFarmProgress(farmId);
      if (updated != null) {
        final idx = _farms.indexWhere((f) => f.id == farmId);
        if (idx != -1) _farms[idx] = updated;
        if (_currentFarm?.id == farmId) _currentFarm = updated;
        await DataPersistenceService.saveVirtualFarms(_farms);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateFarmAfterHarvest() async {
    if (_currentFarm != null) {
      try {
        final harvestedFarm = VirtualFarm(
          id: '${_currentFarm!.id}_harvested_${DateTime.now().millisecondsSinceEpoch}',
          userId: _currentFarm!.userId,
          landSize: _currentFarm!.landSize,
          cropType: _currentFarm!.cropType,
          plantingDate: DateTime.now(),
          location: _currentFarm!.location,
          soilData: _currentFarm!.soilData,
          growthStages: _currentFarm!.growthStages,
          expectedYield: _currentFarm!.expectedYield,
          expectedProfit: _currentFarm!.expectedProfit,
          climateRisks: _currentFarm!.climateRisks,
          createdAt: DateTime.now(),
        );

        _farms.add(harvestedFarm);
        _currentFarm = harvestedFarm;

        await DataPersistenceService.saveVirtualFarms(_farms);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
      }
    }
  }

  Future<void> deleteFarm(String farmId) async {
    try {
      _farms.removeWhere((f) => f.id == farmId);
      if (_currentFarm?.id == farmId) {
        _currentFarm = _farms.isNotEmpty ? _farms.last : null;
      }
      await DataPersistenceService.saveVirtualFarms(_farms);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
