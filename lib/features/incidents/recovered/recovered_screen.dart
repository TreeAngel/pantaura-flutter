import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../../core/theme/theme.dart';
import '../add_report/add_report_state.dart';
import 'recovered_notifier.dart';
import 'widgets/incident_summary_card.dart';
import 'widgets/invalid_location_dialog.dart';
import 'widgets/recovered_app_bar.dart';
import 'widgets/recovery_description_section.dart';
import 'widgets/recovery_evidence_section.dart';
import 'widgets/recovery_reassurance_banner.dart';
import 'widgets/submit_recovery_bar.dart';
import 'widgets/truth_declaration_card.dart';

/// Halaman Lapor Kondisi Pulih (nested dari Detail Insiden).
class RecoveredScreen extends ConsumerStatefulWidget {
  const RecoveredScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  ConsumerState<RecoveredScreen> createState() => _RecoveredScreenState();
}

class _RecoveredScreenState extends ConsumerState<RecoveredScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _hasShownInitialLocationCheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkInitialLocation();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialLocation() async {
    if (_hasShownInitialLocationCheck) return;
    _hasShownInitialLocationCheck = true;

    final result = await ref
        .read(recoveredProvider(widget.incidentId).notifier)
        .refreshLocation();
    if (!mounted) return;

    final status = result.status;
    if (status != null && status.isPermanentlyDenied) {
      await ref.read(permissionServiceProvider).showPermanentlyDeniedDialog(
            context,
            permissionLabel: 'Lokasi',
          );
      if (!mounted) return;
    }

    if (!result.isValid) {
      await _showInvalidLocationDialog(result.distanceMeters);
    }
  }

  Future<void> _showInvalidLocationDialog(double? distanceMeters) async {
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InvalidLocationDialog(
        initialDistanceMeters: distanceMeters,
        onClosePage: () {
          if (mounted) context.pop();
        },
        onRefreshLocation: () async {
          final result = await ref
              .read(recoveredProvider(widget.incidentId).notifier)
              .refreshLocation();
          return (
            isValid: result.isValid,
            distanceMeters: result.distanceMeters,
          );
        },
      ),
    );

    if (verified == true && mounted) {
      _showSnackBar(
        'Posisi berhasil diverifikasi',
        backgroundColor: AppColors.statusResolved,
      );
    }
  }

  Future<void> _capturePhoto() async {
    final permissionService = ref.read(permissionServiceProvider);
    final status = await permissionService.requestCameraPermission();
    if (!mounted) return;

    if (status.isPermanentlyDenied) {
      await permissionService.showPermanentlyDeniedDialog(
        context,
        permissionLabel: 'Kamera',
      );
      return;
    }
    if (!status.isGranted) {
      _showSnackBar('Izin kamera diperlukan untuk mengambil foto bukti.');
      return;
    }

    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      ref.read(recoveredProvider(widget.incidentId).notifier).addMedia([file]);
    }
  }

  Future<void> _pickFromGallery() async {
    final permissionService = ref.read(permissionServiceProvider);
    final status = await permissionService.requestGalleryPermission();
    if (!mounted) return;

    if (status.isPermanentlyDenied) {
      await permissionService.showPermanentlyDeniedDialog(
        context,
        permissionLabel: 'Galeri',
      );
      return;
    }
    if (!status.isGranted && !status.isLimited) {
      _showSnackBar('Izin galeri diperlukan untuk memilih foto bukti.');
      return;
    }

    final currentCount =
        ref.read(recoveredProvider(widget.incidentId)).value?.mediaFiles.length ??
            0;
    if (currentCount >= kMaxReportMediaCount) {
      _showSnackBar('Maksimal $kMaxReportMediaCount foto bukti.');
      return;
    }

    final files = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty && mounted) {
      ref.read(recoveredProvider(widget.incidentId).notifier).addMedia(files);
    }
  }

  void _onQuickTextTap(String text) {
    final nextText = ref
        .read(recoveredProvider(widget.incidentId).notifier)
        .appendQuickText(text);
    if (nextText != null && _descriptionController.text != nextText) {
      _descriptionController.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
  }

  Future<void> _submit() async {
    final success =
        await ref.read(recoveredProvider(widget.incidentId).notifier).submit();
    if (!mounted) return;

    if (success) {
      _showSnackBar(
        'Pengajuan status pulih berhasil dikirim.',
        backgroundColor: AppColors.statusResolved,
      );
      context.pop();
    } else {
      final errorMsg =
          ref.read(recoveredProvider(widget.incidentId)).value?.errorMessage;
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
    final recoveredAsync = ref.watch(recoveredProvider(widget.incidentId));

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: const RecoveredAppBar(),
      body: recoveredAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _RecoveredErrorBody(
          message: error is ApiException
              ? error.message
              : 'Gagal memuat data insiden. Silakan coba lagi.',
          onRetry: () => ref.invalidate(recoveredProvider(widget.incidentId)),
        ),
        data: (data) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.spaceXl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RecoveryReassuranceBanner(),
                    const SizedBox(height: AppSpacing.spaceMd),
                    IncidentSummaryCard(
                      incident: data.incident,
                      distanceMeters: data.distanceMeters,
                      isLocationValid: data.isLocationValid,
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    RecoveryEvidenceSection(
                      mediaFiles: data.mediaFiles,
                      onCapturePhoto: _capturePhoto,
                      onPickGallery: _pickFromGallery,
                      onRemovePhoto: (index) => ref
                          .read(recoveredProvider(widget.incidentId).notifier)
                          .removeMedia(index),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    RecoveryDescriptionSection(
                      controller: _descriptionController,
                      currentDescription: data.description,
                      onChanged: (value) => ref
                          .read(recoveredProvider(widget.incidentId).notifier)
                          .updateDescription(value),
                      onQuickTextTap: _onQuickTextTap,
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    TruthDeclarationCard(
                      isChecked: data.isDeclarationChecked,
                      onChanged: (checked) => ref
                          .read(recoveredProvider(widget.incidentId).notifier)
                          .setDeclaration(checked),
                    ),
                  ],
                ),
              ),
            ),
            SubmitRecoveryBar(
              isEnabled: data.isLocationValid && data.isDeclarationChecked,
              isSubmitting: data.isSubmitting,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveredErrorBody extends StatelessWidget {
  const _RecoveredErrorBody({
    required this.message,
    required this.onRetry,
  });

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
              'Gagal Memuat Halaman Pulih',
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
