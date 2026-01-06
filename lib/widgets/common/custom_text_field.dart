import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hint;
  final IconData? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
  final Color? fillColor;
  final Color? borderSideColor;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomAppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.borderSideColor,
    this.label,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = true,
    this.fillColor,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomAppTextField> createState() => _CustomAppTextFieldState();
}

class _CustomAppTextFieldState extends State<CustomAppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.icon != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                if (widget.icon != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [const Color(0xFF6366F1).withAlpha(38), const Color(0xFFEC4899).withAlpha(38)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, size: 16, color: const Color(0xFF6366F1)),
                  ),
                if (widget.icon != null) const SizedBox(width: 10),
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937), letterSpacing: -0.2),
                  ),
              ],
            ),
          ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          obscureText: _obscure,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: widget.fillColor ?? const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: widget.maxLines > 1 ? 18 : 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: widget.borderSideColor ?? const Color(0xFF6366F1), width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2.5),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))
                : widget.suffixIcon,
          ),
          validator: (value) {
            if (widget.validator != null) return widget.validator!(value);
            if (widget.isRequired && (value == null || value.isEmpty)) {
              final fieldName = widget.label ?? 'This field';
              return '$fieldName is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
