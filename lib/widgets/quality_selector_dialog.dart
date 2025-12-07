import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/video_quality_service.dart';

class QualitySelectorDialog extends StatefulWidget {
  final String currentQuality;

  const QualitySelectorDialog({
    super.key,
    required this.currentQuality,
  });

  @override
  State<QualitySelectorDialog> createState() => _QualitySelectorDialogState();
}

class _QualitySelectorDialogState extends State<QualitySelectorDialog> {
  late String _selectedQuality;

  @override
  void initState() {
    super.initState();
    _selectedQuality = widget.currentQuality;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Video Quality',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quality options
            ...VideoQualityService.availableQualities.map((quality) {
              final isSelected = _selectedQuality == quality;
              final icon = VideoQualityService.getQualityIcon(quality);
              final label = VideoQualityService.getQualityLabel(quality);

              return RadioListTile<String>(
                title: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (quality == VideoQualityService.qualityAuto)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '(Recommended)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                value: quality,
                groupValue: _selectedQuality,
                onChanged: (value) {
                  setState(() {
                    _selectedQuality = value!;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto adjusts quality based on your connection speed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedQuality);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
