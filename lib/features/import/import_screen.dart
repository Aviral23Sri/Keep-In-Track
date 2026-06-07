import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/merchant_providers.dart';
import '../../shared/widgets/gradient_app_bar.dart';
import 'sbi_parser.dart';
import 'import_review_screen.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _isParsing = false;
  String? _error;

  Future<void> _pickAndParse() async {
    setState(() {
      _isParsing = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty || result.files.first.bytes == null) {
        setState(() => _isParsing = false);
        return;
      }

      final bytes = result.files.first.bytes!;
      final merchantsAsync = await ref.read(merchantsControllerProvider.future);

      final parser = SbiParser(merchants: merchantsAsync);
      final parsed = await parser.parse(bytes);

      if (!mounted) return;

      if (parsed.isEmpty) {
        setState(() {
          _error =
              'No transactions found. Make sure the file is an SBI bank statement PDF.';
          _isParsing = false;
        });
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImportReviewScreen(transactions: parsed),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to parse PDF: ${e.toString().split('\n').first}';
      });
    } finally {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const GradientAppBar(title: Text('Import Bank Statement')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Import from SBI Statement',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Select your SBI bank statement PDF. Transactions will be automatically categorized using your merchant memory.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: const Column(
                  children: [
                    _InfoRow(icon: Icons.check_circle_outline,
                        text: 'Supports SBI account statements (PDF)'),
                    SizedBox(height: 6),
                    _InfoRow(icon: Icons.check_circle_outline,
                        text: 'Auto-matches merchants & categories'),
                    SizedBox(height: 6),
                    _InfoRow(icon: Icons.check_circle_outline,
                        text: 'Review & edit before importing'),
                    SizedBox(height: 6),
                    _InfoRow(icon: Icons.check_circle_outline,
                        text: 'Skips duplicate transactions'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_isParsing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Parsing statement...'),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: _pickAndParse,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select PDF Statement'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
