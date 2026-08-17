import 'package:flutter/material.dart';
import '../models/time_category.dart';
import '../services/tracking_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Screen for starting and running a time-tracking session.
///
/// If a session is already active, this opens straight into the
/// active-timer view instead of the setup form.
class TrackingScreen extends StatefulWidget {
  final TrackingService trackingService;

  const TrackingScreen({super.key, required this.trackingService});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TextEditingController _nameController = TextEditingController();
  TimeCategory _selectedCategory = TimeCategory.study;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleStart() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter an activity name');
      return;
    }
    setState(() => _errorText = null);
    widget.trackingService.start(name, _selectedCategory);
  }

  void _handleStop() {
    widget.trackingService.stop();
    Navigator.of(context).pop();
  }

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:'
        '${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Track Time')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.trackingService,
          builder: (context, _) {
            return widget.trackingService.isTracking
                ? _buildActiveView(widget.trackingService)
                : _buildSetupForm();
          },
        ),
      ),
    );
  }

  Widget _buildSetupForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you working on?', style: AppTextStyles.title),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g. Reading, Team standup...',
              errorText: _errorText,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Category', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: TimeCategory.values.map((category) {
              final isSelected = category == _selectedCategory;
              return ChoiceChip(
                label: Text(category.label),
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.white : category.color,
                ),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _selectedCategory = category),
                selectedColor: category.color,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(TrackingService service) {
    final category = service.activeCategory!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, size: 40, color: category.color),
          const SizedBox(height: 12),
          Text(
            service.activeActivityName ?? '',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(category.label, style: AppTextStyles.caption),
          const SizedBox(height: 32),
          Text(
            _formatElapsed(service.elapsed),
            style: AppTextStyles.headline.copyWith(
              fontSize: 48,
              color: category.color,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Stop Tracking'),
            ),
          ),
        ],
      ),
    );
  }
}