import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../domain/models/tcg_card.dart';
import '../../viewmodels/form_view_model.dart';
import 'brand_selector.dart';
import 'card_text_fields.dart';

class CardFormScreen extends StatefulWidget {
  const CardFormScreen({super.key, required this.createViewModel});

  final FormViewModel Function() createViewModel;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  late final FormViewModel _viewModel = widget.createViewModel();
  late final _nameController = TextEditingController(text: _viewModel.initialName);
  late final _valueController =
      TextEditingController(text: _viewModel.initialValue);

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _onChanged() {
    final state = _viewModel.state;
    if (!mounted || state is! CardFormSaved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_viewModel.isEditing ? 'Saved' : 'Added'} ${state.card.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  void _save() => _viewModel.save(_nameController.text, _valueController.text);

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop || _viewModel.state is CardFormSaving) return;
    final discard = await showDiscardDialog(context);
    if (!mounted) return;
    if (discard) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;
        return PopScope(
          canPop: !state.draft.isDirty || state is CardFormSaved,
          onPopInvokedWithResult: _handlePop,
          child: Scaffold(
            appBar: AppBar(
              title: Text(_viewModel.isEditing ? 'Edit card' : 'Add card'),
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
                  child: _fields(state),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fields(CardFormState state) {
    final CardDraft draft = state.draft;
    final bool busy = state is CardFormSaving || state is CardFormSaved;
    final String? nameError = state is CardFormEditing ? state.nameError : null;
    final String? valueError =
        state is CardFormEditing ? state.valueError : null;
    final String? failure = state is CardFormFailed ? state.message : null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        CardNameField(
          controller: _nameController,
          errorText: nameError,
          enabled: !busy,
          onChanged: _viewModel.nameChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        BrandSelector(
          selected: draft.brand,
          enabled: !busy,
          onChanged: _viewModel.setBrand,
        ),
        const SizedBox(height: AppSpacing.md),
        LabeledDropdown<String>(
          label: 'Rarity',
          value: draft.rarity,
          enabled: !busy,
          options: {for (final r in cardRarities) r: r},
          onChanged: _viewModel.setRarity,
        ),
        const SizedBox(height: AppSpacing.md),
        LabeledDropdown<CardCondition>(
          label: 'Condition',
          value: draft.condition,
          enabled: !busy,
          options: {for (final c in CardCondition.values) c: c.label},
          onChanged: _viewModel.setCondition,
        ),
        const SizedBox(height: AppSpacing.md),
        CardValueField(
          controller: _valueController,
          errorText: valueError,
          enabled: !busy,
          onChanged: _viewModel.valueChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (failure != null) ...[
          Text(
            failure,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy ? null : _save,
            icon: state is CardFormSaving
                ? const SizedBox.square(
                    dimension: AppSpacing.md,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_viewModel.isEditing ? 'Save changes' : 'Save card'),
          ),
        ),
      ],
    );
  }
}

Future<bool> showDiscardDialog(BuildContext context) async {
  final discard = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Discard changes?'),
      content: const Text('What you entered will be lost.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep editing'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return discard ?? false;
}

class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      expandedInsets: EdgeInsets.zero,
      label: Text(label),
      enabled: enabled,
      initialSelection: value,
      requestFocusOnTap: false,
      dropdownMenuEntries: [
        for (final entry in options.entries)
          DropdownMenuEntry<T>(value: entry.key, label: entry.value),
      ],
      onSelected: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}
