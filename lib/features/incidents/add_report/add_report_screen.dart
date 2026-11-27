import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/form_app_bar.dart';
import 'add_report_notifier.dart';
import 'add_report_state.dart';
import 'widgets/description_section.dart';
import 'widgets/evidence_photo_section.dart';
import 'widgets/incident_summary_card.dart';
import 'widgets/location_section.dart';
import 'widgets/submit_report_bar.dart';

/// Halaman Tambah Laporan Insiden (nested dari Detail Insiden).
class AddReportScreen extends ConsumerStatefulWidget {
  const AddReportScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshLocation();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _refreshLocation() async {
    final status = await ref
        .read(addReportProvider(widget.incidentId).notifier)
        .refreshLocation();
    if (!mounted) return;
    if (status != null && status.isPermanentlyDenied) {
      await ref
          .read(permissionServiceProvider)
          .showPermanentlyDeniedDialog(context, permissionLabel: 'Lokasi');
    }
  }

  Future<void> _capturePhoto() async {
    final file = await ref
        .read(permissionServiceProvider)
        .pickImageWithPermission(ImageSource.camera, context: context);
    if (file == null || !mounted) return;
    ref.read(addReportProvider(widget.incidentId).notifier).addMedia([file]);
  }

  Future<void> _pickFromGallery() async {
    final currentCount =
        ref
            .read(addReportProvider(widget.incidentId))
            .value
            ?.mediaFiles
            .length ??
        0;
    final remaining = kMaxReportMediaCount - currentCount;
    if (remaining <= 0) {
      _showSnackBar('Maksimal $kMaxReportMediaCount foto bukti.');
      return;
    }

    final files = await ref
        .read(permissionServiceProvider)
        .pickMultiImagesWithPermission(context: context);
    if (files.isEmpty || !mounted) return;
    ref.read(addReportProvider(widget.incidentId).notifier).addMedia(files);
  }

  void _onQuickTextToggle(String text) {
    final nextText = ref
        .read(addReportProvider(widget.incidentId).notifier)
        .toggleQuickText(text);
    if (nextText != null && _descriptionController.text != nextText) {
      _descriptionController.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
  }

  Future<void> _submit() async {
    final success = await ref
        .read(addReportProvider(widget.incidentId).notifier)
        .submit();
    if (!mounted) return;

    if (success) {
      _showSnackBar(
        'Laporan tambahan berhasil dikirim.',
        backgroundColor: AppColors.statusResolved,
      );
      context.pop();
    } else {
      final errorMsg = ref
          .read(addReportProvider(widget.incidentId))
          .value
          ?.errorMessage;
      if (errorMsg != null && errorMsg.isNotEmpty) {
        _showSnackBar(errorMsg, backgroundColor: AppColors.error);
      }
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addReportAsync = ref.watch(addReportProvider(widget.incidentId));

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const FormAppBar(
        title: 'Tambah Laporan Insiden',
        titleStyle: AppTypography.headlineMd,
        subtitle: 'Pantaura Darurat',
        subtitleIcon: Icons.verified_user_rounded,
        subtitleColor: AppColors.statusResolution,
      ),
      body: addReportAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _AddReportErrorBody(
          message: error is ApiException
              ? error.message
              : 'Gagal memuat data insiden. Silakan coba lagi.',
          onRetry: () => ref.invalidate(addReportProvider(widget.incidentId)),
        ),
        data: (data) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppSpacing.spaceMd,
                  bottom: AppSpacing.spaceXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IncidentSummaryCard(incident: data.incident),
                    const SizedBox(height: AppSpacing.spaceLg),
                    LocationSection(
                      incident: data.incident,
                      userPosition: data.userPosition,
                      distanceMeters: data.distanceMeters,
                      isLocationValid: data.isLocationValid,
                      isRefreshing: data.isRefreshingLocation,
                      onRefreshGps: _refreshLocation,
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    EvidencePhotoSection(
                      mediaFiles: data.mediaFiles,
                      onCapturePhoto: _capturePhoto,
                      onPickGallery: _pickFromGallery,
                      onRemovePhoto: (index) => ref
                          .read(addReportProvider(widget.incidentId).notifier)
                          .removeMedia(index),
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    DescriptionSection(
                      disasterType: data.incident.disasterType,
                      controller: _descriptionController,
                      currentDescription: data.description,
                      onChanged: (value) => ref
                          .read(addReportProvider(widget.incidentId).notifier)
                          .updateDescription(value),
                      onQuickTextToggle: _onQuickTextToggle,
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

class _AddReportErrorBody extends StatelessWidget {
  const _AddReportErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              'Gagal Memuat Form Laporan',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.textHeader,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              message,
              style: AppTypography.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
