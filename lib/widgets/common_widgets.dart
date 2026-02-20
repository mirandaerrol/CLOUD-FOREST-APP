import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ---- CF Logo Widget ----
class CFLogo extends StatelessWidget {
  final double size;
  final double fontSize;

  const CFLogo({super.key, this.size = 160, this.fontSize = 60});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.black, width: 2),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'CF',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange,
                      shadows: const [
                        Shadow(offset: Offset(2, 2), color: AppColors.black),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors.black,
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: const Text(
                  'CCTV / SOLAR / FDAS / HOTSPOT /\nNETWORKING / INTERNET / COMPUTER\nAUDIO SYSTEM / OFFICE SUPPLY ETC.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- App Text Field ----
class AppTextField extends StatelessWidget {
  final String placeholder;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onSuffixTap;
  final TextInputType keyboardType;

  const AppTextField({
    super.key,
    required this.placeholder,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.onSuffixTap,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: AppColors.gray.withValues(alpha: 0.7)),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: AppColors.gray, size: 20),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ---- App Dropdown ----
class AppDropdown extends StatelessWidget {
  final String placeholder;
  final List<String> options;
  final String? value;
  final Function(String?) onChanged;
  final String? label;
  final IconData? prefixIcon;

  const AppDropdown({
    super.key,
    required this.placeholder,
    required this.options,
    this.value,
    required this.onChanged,
    this.label,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.gray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLight),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: 18, color: AppColors.gray),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    placeholder,
                    style: TextStyle(
                        color: AppColors.gray.withValues(alpha: 0.7),
                        fontSize: 14),
                  ),
                ],
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray),
              items: options.map((opt) {
                return DropdownMenuItem<String>(value: opt, child: Text(opt));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ---- Primary Button ----
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? trailingIcon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.trailingIcon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.black,
          foregroundColor: textColor ?? AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

// ---- Section Label ----
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.gray,
        letterSpacing: 1,
      ),
    );
  }
}

// ---- Status Badge ----
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.pending() => const StatusBadge(
        label: 'PENDING',
        backgroundColor: Color(0xFFFFF6DB),
        textColor: Color(0xFFCA6400),
      );

  factory StatusBadge.resolved() => const StatusBadge(
        label: 'RESOLVED',
        backgroundColor: Color(0xFFDCFCE7),
        textColor: Color(0xFF16A34A),
      );

  factory StatusBadge.unpaid() => const StatusBadge(
        label: 'UNPAID',
        backgroundColor: AppColors.redLight,
        textColor: AppColors.red,
      );

  factory StatusBadge.remitted() => const StatusBadge(
        label: 'REMITTED',
        backgroundColor: Color(0xFFDCFCE7),
        textColor: Color(0xFF16A34A),
      );

  factory StatusBadge.partial() => const StatusBadge(
        label: 'PARTIAL',
        backgroundColor: Color(0xFFFFF7ED),
        textColor: Color(0xFFEA580C),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

// ---- Info Row ----
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.redLight : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFFFECACA)
              : AppColors.grayLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? AppColors.red : AppColors.gray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isHighlighted
                  ? const Color(0xFFB91C1C)
                  : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Summary Row ----
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const SummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ---- App Card ----
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? AppColors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: border ??
              Border.all(color: AppColors.grayLight.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow08,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
