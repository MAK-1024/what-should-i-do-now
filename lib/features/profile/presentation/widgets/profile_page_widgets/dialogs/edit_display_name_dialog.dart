import 'package:flutter/material.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';

/// Dialog for editing the display name. Resolves to the trimmed new name, or
/// `null` when cancelled. The dialog owns its controller so it is disposed
/// only after the route's exit animation completes.
class EditDisplayNameDialog extends StatefulWidget {
  const EditDisplayNameDialog({super.key, required this.initialName});

  final String initialName;

  static Future<String?> show(BuildContext context, {required String initialName}) =>
      showDialog<String>(
        context: context,
        builder: (_) => EditDisplayNameDialog(initialName: initialName),
      );

  @override
  State<EditDisplayNameDialog> createState() => _EditDisplayNameDialogState();
}

class _EditDisplayNameDialogState extends State<EditDisplayNameDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editDisplayName),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: l10n.displayName,
            hintText: l10n.enterYourName,
          ),
          validator: (String? value) {
            final String text = value?.trim() ?? '';
            if (text.isEmpty) return l10n.nameCannotBeEmpty;
            if (text.length < 2) return l10n.nameTooShort;
            return null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
