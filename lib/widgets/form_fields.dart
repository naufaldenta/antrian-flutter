import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

class IosField extends StatelessWidget {
  const IosField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onSubmitted,
    this.labelWidth = 104,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final int? maxLength;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: controller,
      prefix: SizedBox(
        width: labelWidth,
        child: Text(label, style: AppText.body),
      ),
      placeholder: placeholder,
      placeholderStyle: AppText.body.copyWith(color: AppColors.tertiaryLabel),
      style: AppText.body,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: 1,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
    );
  }
}

class IosTextArea extends StatelessWidget {
  const IosTextArea({
    super.key,
    required this.controller,
    this.placeholder,
    this.validator,
    this.maxLength,
    this.minLines = 3,
  });

  final TextEditingController controller;
  final String? placeholder;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: controller,
      placeholder: placeholder,
      placeholderStyle: AppText.body.copyWith(color: AppColors.tertiaryLabel),
      style: AppText.body,
      validator: validator,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: 6,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    );
  }
}
