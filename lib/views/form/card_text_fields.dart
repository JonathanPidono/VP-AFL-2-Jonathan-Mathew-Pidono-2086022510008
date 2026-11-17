import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardNameField extends StatelessWidget {
  const CardNameField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      maxLength: 80,
      decoration: InputDecoration(
        labelText: 'Card name',
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class CardValueField extends StatelessWidget {
  const CardValueField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: (_) => onChanged(),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      decoration: InputDecoration(
        labelText: 'Estimated value',
        prefixText: 'Rp ',
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
