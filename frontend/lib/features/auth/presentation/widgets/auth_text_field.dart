import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hintText,
    required this.fieldKey,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.textInputAction,
    this.autofillHints,
    this.prefixIcon,
    this.validator,
  });

  final String hintText;
  final String fieldKey;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final showVisibilityToggle = widget.isPassword;

    return TextFormField(
      key: ValueKey('auth-field-${widget.fieldKey}'),
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      autocorrect: false,
      enableSuggestions: !widget.isPassword,
      cursorColor: AnaboolColors.brown,
      style: const TextStyle(
        color: AnaboolColors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: widget.hintText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(
                widget.prefixIcon,
                color: AnaboolColors.brownSoft,
                size: 20,
              ),
        prefixIconConstraints: const BoxConstraints(
          minHeight: 42,
          minWidth: 40,
        ),
        hintStyle: const TextStyle(
          color: AnaboolColors.border,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        labelStyle: const TextStyle(
          color: AnaboolColors.brownSoft,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        floatingLabelStyle: const TextStyle(
          color: AnaboolColors.brown,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
        errorStyle: const TextStyle(
          color: AnaboolColors.red,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFFFFAF7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: AnaboolColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: AnaboolColors.border,
            width: 1.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: AnaboolColors.brown,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: AnaboolColors.red,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(
            color: AnaboolColors.red,
            width: 1.4,
          ),
        ),
        suffixIcon: showVisibilityToggle
            ? IconButton(
                key: ValueKey(
                  'auth-visibility-${widget.fieldKey}',
                ),
                tooltip: _obscureText
                    ? 'Lihat Kata Sandi'
                    : 'Sembunyikan Kata Sandi',
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AnaboolColors.border,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minHeight: 28,
                  minWidth: 32,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 28,
          minWidth: 36,
        ),
      ),
    );
  }
}
