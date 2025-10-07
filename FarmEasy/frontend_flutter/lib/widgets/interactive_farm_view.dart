import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/virtual_farm_model.dart';

class _Grid {
  final int cols;
  final int rows;
  const _Grid(this.cols, this.rows);
}

class InteractiveFarmView extends StatefulWidget {
  final VirtualFarm virtualFarm;
  final GrowthStage currentStage;
  final List<ClimateRisk>? activeRisks;
  final bool showRiskEffects;

  const InteractiveFarmView({
    super.key,
    required this.virtualFarm,
    required this.currentStage,
    this.activeRisks,
    this.showRiskEffects = false,
  });

  @override
  State<InteractiveFarmView> createState() => _InteractiveFarmViewState();
}

class _InteractiveFarmViewState extends State<InteractiveFarmView>
    with TickerProviderStateMixin {
  late AnimationController _windController;
  late AnimationController _growthController;
  late Animation<double> _windAnimation;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();
    _windController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();

    _growthController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    _windAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _windController, curve: Curves.easeInOut),
    );

    _growthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _growthController, curve: Curves.easeOutCubic),
    );

    _growthController.forward();
  }

  @override
  void dispose() {
    _windController.dispose();
    _growthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getSkyColors(),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (widget.showRiskEffects) _buildWeatherEffects(),

          // Ground
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.brown.shade300,
                      Colors.brown.shade400,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Farm Grid
          Positioned.fill(child: _buildFarmGrid()),

          // Farm Info
          Positioned(top: 16, left: 16, child: _buildInfoCard()),

          // Stage indicator
          Positioned(top: 16, right: 16, child: _buildStageIndicator()),

          // Risk Warnings
          if (widget.showRiskEffects &&
              (widget.activeRisks?.isNotEmpty ?? false))
            Positioned(
                bottom: 16, left: 16, right: 16, child: _buildRiskWarnings()),
        ],
      ),
    );
  }

  List<Color> _getSkyColors() {
    if (widget.showRiskEffects && widget.activeRisks != null) {
      final hasFlood =
          widget.activeRisks!.any((r) => r.riskType.toLowerCase() == 'flood');
      final hasDrought =
          widget.activeRisks!.any((r) => r.riskType.toLowerCase() == 'drought');
      if (hasFlood) {
        return [Colors.grey.shade600, Colors.grey.shade400];
      } else if (hasDrought) {
        return [Colors.orange.shade300, Colors.yellow.shade200];
      }
    }
    return [Colors.blue.shade300, Colors.blue.shade100];
  }

  Widget _buildWeatherEffects() {
    if (widget.activeRisks == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            if (widget.activeRisks!
                .any((r) => r.riskType.toLowerCase() == 'flood'))
              ...List.generate(
                  50,
                  (index) => _buildRainDrop(
                      index, constraints.maxWidth, constraints.maxHeight)),
            if (widget.activeRisks!
                .any((r) => r.riskType.toLowerCase() == 'drought'))
              Container(color: Colors.yellow.withValues(alpha: 0.2)),
          ],
        );
      },
    );
  }

  Widget _buildRainDrop(int index, double maxWidth, double maxHeight) {
    return AnimatedBuilder(
      animation: _windController,
      builder: (context, child) {
        final random = math.Random(index);
        final x = random.nextDouble() * maxWidth;
        final animationOffset =
            (_windController.value + random.nextDouble()) % 1;
        final y = animationOffset * (maxHeight - 50);
        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: 2,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
    );
  }

  _Grid _calculateGrid() {
    final area = widget.virtualFarm.landSize;
    if (area <= 1) return const _Grid(8, 4);
    if (area <= 5) return const _Grid(12, 6);
    if (area <= 10) return const _Grid(16, 8);
    return const _Grid(20, 10);
  }

  Widget _buildFarmGrid() {
    final grid = _calculateGrid();
    final cropHeight = _getCropHeightForStage();
    final cropColor = _getCropColorForStage();
    return AnimatedBuilder(
      animation: _growthAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 100,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: grid.cols,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: grid.cols * grid.rows,
                itemBuilder: (context, index) {
                  return _buildCropPlant(cropHeight, cropColor, index);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  double _getCropHeightForStage() {
    final progress = widget.currentStage.progress / 100;
    switch (widget.currentStage.stage.toLowerCase()) {
      case 'seed':
        return 2.0;
      case 'germination':
        return 8.0 * _growthAnimation.value;
      case 'growth':
      case 'tillering':
        return 16.0 * _growthAnimation.value;
      case 'flowering':
      case 'panicle formation':
        return 24.0 * _growthAnimation.value;
      case 'harvest':
        return 28.0 * _growthAnimation.value;
      default:
        return 12.0 * progress * _growthAnimation.value;
    }
  }

  Color _getCropColorForStage() {
    if (widget.showRiskEffects && widget.activeRisks != null) {
      final hasDrought =
          widget.activeRisks!.any((r) => r.riskType.toLowerCase() == 'drought');
      final hasPest =
          widget.activeRisks!.any((r) => r.riskType.toLowerCase() == 'pest');
      if (hasDrought) return Colors.brown.shade400;
      if (hasPest) return Colors.yellow.shade700;
    }

    switch (widget.currentStage.stage.toLowerCase()) {
      case 'seed':
        return Colors.brown.shade600;
      case 'germination':
        return Colors.lightGreen.shade300;
      case 'growth':
      case 'tillering':
        return Colors.green.shade500;
      case 'flowering':
      case 'panicle formation':
        return Colors.green.shade600;
      case 'harvest':
        return _getHarvestColor();
      default:
        return Colors.green.shade400;
    }
  }

  Color _getHarvestColor() {
    switch (widget.virtualFarm.cropType.toLowerCase()) {
      case 'rice':
        return Colors.yellow.shade600;
      case 'wheat':
        return Colors.amber.shade600;
      case 'corn':
        return Colors.yellow.shade700;
      case 'cotton':
        return Colors.white;
      case 'tomato':
        return Colors.red.shade500;
      default:
        return Colors.green.shade600;
    }
  }

  Widget _buildCropPlant(double height, Color color, int index) {
    final random = math.Random(index);
    final variation = 0.8 + (random.nextDouble() * 0.4); // 0.8 to 1.2
    return AnimatedBuilder(
      animation: _windAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _windAnimation.value * (random.nextDouble() * 0.5 + 0.5),
          child: Container(
            margin: const EdgeInsets.all(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 3,
                  height: height * variation,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(2)),
                  ),
                ),
                Container(
                  width: 6,
                  height: 2,
                  color: Colors.brown.shade500,
                ),
              ],
            ),
          ),
        );
      },
      child: null,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.virtualFarm.cropType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '${widget.virtualFarm.landSize} hectares',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStageIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.currentStage.stage,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          Text(
            '${widget.currentStage.progress.toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskWarnings() {
    final risks = widget.activeRisks ?? const <ClimateRisk>[];
    if (risks.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Active Risks: ${risks.map((r) => r.riskType).join(', ')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
