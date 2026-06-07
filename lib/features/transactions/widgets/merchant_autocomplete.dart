import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/merchant_model.dart';
import '../../../shared/providers/merchant_providers.dart';
import '../../../core/theme/app_colors.dart';

class MerchantAutocomplete extends ConsumerStatefulWidget {
  final void Function(MerchantModel?) onMerchantSelected;
  final String? initialValue;

  const MerchantAutocomplete({
    super.key,
    required this.onMerchantSelected,
    this.initialValue,
  });

  @override
  ConsumerState<MerchantAutocomplete> createState() => _MerchantAutocompleteState();
}

class _MerchantAutocompleteState extends ConsumerState<MerchantAutocomplete> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchantsAsync = ref.watch(merchantsControllerProvider);
    // final theme = Theme.of(context);

    return merchantsAsync.when(
      data: (merchants) {
        return Autocomplete<MerchantModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            if (query.isEmpty) {
              return const Iterable<MerchantModel>.empty();
            }
            
            // Basic fuzzy match
            final matches = merchants.where((m) {
              if (m.name.toLowerCase().contains(query)) return true;
              for (final v in m.nameVariants) {
                if (v.toLowerCase().contains(query)) return true;
              }
              return false;
            }).toList();
            
            matches.sort((a, b) => b.usageCount.compareTo(a.usageCount));
            return matches.take(5);
          },
          displayStringForOption: (MerchantModel option) => option.name,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Keep reference to external controller sync if needed
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Merchant / Payee (Optional)',
                hintText: 'Start typing merchant name...',
                prefixIcon: const Icon(Icons.store_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                if (val.isEmpty) {
                  widget.onMerchantSelected(null);
                }
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.storefront, color: AppColors.primary),
                        title: Text(option.name),
                        subtitle: option.typicalAmount != null
                            ? Text('Usually ₹${option.typicalAmount?.toStringAsFixed(0)}')
                            : null,
                        onTap: () {
                          onSelected(option);
                          widget.onMerchantSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const TextField(
        decoration: InputDecoration(
          labelText: 'Merchant / Payee (Loading...)',
          prefixIcon: Icon(Icons.store_outlined),
        ),
        enabled: false,
      ),
      error: (_, __) => const SizedBox(),
    );
  }
}
