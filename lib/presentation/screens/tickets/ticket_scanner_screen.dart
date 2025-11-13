import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/ticket.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/event_provider.dart';

/// Screen for scanning and validating tickets at event entrances
/// This screen is used by event organizers/staff to check in attendees
class TicketScannerScreen extends ConsumerStatefulWidget {
  final String eventId;

  const TicketScannerScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends ConsumerState<TicketScannerScreen> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    // Request camera permission
    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        );
      });
    } else if (status.isDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog(isPermanent: true);
      }
    }
  }

  void _showPermissionDialog({bool isPermanent = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: Text(
          isPermanent
              ? 'Camera permission is required to scan tickets. Please enable it in Settings.'
              : 'Camera permission is required to scan tickets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isPermanent) {
                openAppSettings();
              } else {
                _initializeScanner();
              }
            },
            child: Text(isPermanent ? 'Open Settings' : 'Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final qrCode = barcode.rawValue;

    if (qrCode == null || qrCode.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Scan the ticket
    await ref.read(ticketValidationProvider.notifier).scanTicket(qrCode);

    // Show validation dialog
    if (mounted) {
      _showValidationDialog(qrCode);
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _showValidationDialog(String qrCode) {
    final state = ref.read(ticketValidationProvider);

    if (state.error != null) {
      _showErrorDialog(state.error!);
      return;
    }

    if (state.scannedTicket == null) return;

    final ticket = state.scannedTicket!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TicketValidationDialog(
        ticket: ticket,
        qrCode: qrCode,
        onCheckIn: () async {
          Navigator.of(context).pop();
          await _handleCheckIn(qrCode);
        },
        onCancel: () {
          Navigator.of(context).pop();
          ref.read(ticketValidationProvider.notifier).reset();
        },
      ),
    );
  }

  Future<void> _handleCheckIn(String qrCode) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await ref.read(ticketValidationProvider.notifier).checkInTicket(qrCode);

    if (mounted) {
      Navigator.of(context).pop(); // Close loading

      if (success) {
        _showSuccessDialog();
      } else {
        final error = ref.read(ticketValidationProvider).error ?? 'Failed to check in ticket';
        _showErrorDialog(error);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Check-in Successful!'),
        content: const Text('Ticket has been checked in successfully.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(ticketValidationProvider.notifier).reset();
            },
            child: const Text('Continue Scanning'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 64),
        title: const Text('Validation Error'),
        content: Text(error),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(ticketValidationProvider.notifier).reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventAsync = ref.watch(eventByIdProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on),
            onPressed: () {
              _scannerController?.toggleTorch();
            },
          ),
        ],
      ),
      body: eventAsync.when(
        data: (event) => Column(
          children: [
            // Event info header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              color: theme.colorScheme.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d, y • h:mm a').format(event.startDatetime),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Scanner view
            Expanded(
              child: _hasPermission && _scannerController != null
                  ? Stack(
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: _onDetect,
                        ),
                        // Scanning overlay
                        Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        // Instructions
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Position the QR code within the frame to scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, size: 64),
                          const SizedBox(height: AppDimensions.spacingMedium),
                          const Text('Camera permission required'),
                          const SizedBox(height: AppDimensions.spacingSmall),
                          FilledButton(
                            onPressed: _initializeScanner,
                            child: const Text('Grant Permission'),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// Dialog to display ticket validation information
class _TicketValidationDialog extends ConsumerWidget {
  final Ticket ticket;
  final String qrCode;
  final VoidCallback onCheckIn;
  final VoidCallback onCancel;

  const _TicketValidationDialog({
    required this.ticket,
    required this.qrCode,
    required this.onCheckIn,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventAsync = ref.watch(eventByIdProvider(ticket.eventId));

    final bool canCheckIn = !ticket.isCheckedIn &&
                           ticket.status.toLowerCase() != 'cancelled' &&
                           ticket.status.toLowerCase() != 'transferred';

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status icon
            Icon(
              canCheckIn ? Icons.check_circle : Icons.warning,
              color: canCheckIn ? Colors.green : Colors.orange,
              size: 64,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),

            // Title
            Text(
              canCheckIn ? 'Valid Ticket' : 'Ticket Issue',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),

            // Ticket details
            eventAsync.when(
              data: (event) => Column(
                children: [
                  _buildInfoRow(theme, 'Event', event.title),
                  const SizedBox(height: 8),
                  _buildInfoRow(theme, 'Ticket #', ticket.ticketNumber),
                  const SizedBox(height: 8),
                  if (ticket.assignedName != null)
                    _buildInfoRow(theme, 'Holder', ticket.assignedName!),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    theme,
                    'Status',
                    ticket.isCheckedIn
                        ? 'Already checked in'
                        : ticket.status,
                  ),
                  if (ticket.isCheckedIn) ...[ const SizedBox(height: 8),
                    _buildInfoRow(
                      theme,
                      'Checked in at',
                      DateFormat('MMM d, h:mm a').format(ticket.checkedInAt!),
                    ),
                  ],
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading event: $error'),
            ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: canCheckIn ? onCheckIn : null,
                  child: const Text('Check In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
