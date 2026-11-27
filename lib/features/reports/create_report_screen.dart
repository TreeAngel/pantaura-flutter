import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/theme.dart';
import '../../core/widgets/emergency_112_dialog.dart';
import '../../core/widgets/form_app_bar.dart';
import 'create_report_notifier.dart';
import 'create_report_state.dart';
import 'widgets/create_report_urgency_banner.dart';
import 'widgets/disaster_type_selector.dart';
import 'widgets/location_picker_section.dart';
import 'widgets/report_description_section.dart';
import 'widgets/report_evidence_section.dart';
import 'widgets/submit_report_bar.dart';

/// Halaman Buat Laporan Bencana baru (bukan laporan tambahan pada insiden).
class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(createReportProvider.notifier);
    final success = await notifier.submit();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan bencana berhasil dikirim.')),
      );
      context.pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Lengkapi titik lokasi, foto, dan deskripsi sebelum mengirim laporan.',
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod 3: ref.listen harus di dalam build().
    ref.listen(createReportProvider, (_, next) {
      final description = next.value?.description ?? '';
      if (description != _descriptionController.text) {
        _descriptionController.value = TextEditingValue(
          text: description,
          selection: TextSelection.collapsed(offset: description.length),
        );
      }
    });

    final async = ref.watch(createReportProvider);
    final data = async.value ?? CreateReportData.initial();
    final notifier = ref.read(createReportProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const FormAppBar(
        title: 'Buat Laporan Bencana',
        titleStyle: AppTypography.headlineMd,
        showAvatar: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppSpacing.spaceMd,
                  bottom: AppSpacing.spaceMd,
                ),
                child: Column(
                  children: [
                    CreateReportUrgencyBanner(
                      onEmergencyCall: () => showEmergency112Dialog(context),
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    DisasterTypeSelector(
                      selectedType: data.disasterType,
                      onSelected: notifier.setDisasterType,
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    LocationPickerSection(
                      pin: data.pin,
                      address: data.address,
                      isLocating: data.isLocating,
                      onPinMoved: notifier.movePin,
                      onRefreshGps: notifier.refreshLocation,
                      onAddressChanged: notifier.setAddress,
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    ReportEvidenceSection(
                      mediaFiles: data.mediaFiles,
                      onCapturePhoto: () => notifier.capturePhoto(context),
                      onPickGallery: () => notifier.pickGallery(context),
                      onRemovePhoto: notifier.removeMedia,
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    ReportDescriptionSection(
                      disasterType: data.disasterType,
                      controller: _descriptionController,
                      currentDescription: data.description,
                      onChanged: notifier.setDescription,
                      onQuickTextToggle: notifier.toggleQuickText,
                    ),
                  ],
                ),
              ),
            ),
            SubmitReportBar(isSubmitting: data.isSubmitting, onSubmit: _submit),
          ],
        ),
      ),
    );
  }
}
