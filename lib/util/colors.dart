import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class WidgetColors {
  // ── Brand / legacy ────────────────────────────────────────
  static const borderBlueCard = Color(0xFF0060EB);
  static const blue           = Color(0xFF2A7DBB);
  static const orange         = Color(0xFFE28C0B);
  static const radicalRed     = Color(0xFFFF4856);
  static const darkPink       = Color(0xFFBB0439);
  static const grey           = Color(0xFF888888);
  static const gray_86        = Color(0xFF868686);
  static const white          = Color(0xFFFFFFFF);
  static const black          = Color(0xFF000000);
  static const activeGreen    = Color(0xFF08B578);
  static const greenColorCard = Color(0xFF64B472);

  // ── Semantic ──────────────────────────────────────────────
  static const green      = Color(0xFF16A34A);
  static const greenBg    = Color(0xFFDCFCE7);
  static const greenGlow  = Color(0xFF4ADE80);
  static const red        = Color(0xFFDC2626);
  static const redBg      = Color(0xFFFEE2E2);
  static const redGlow    = Color(0xFFF87171);

  // ── Neutral ───────────────────────────────────────────────
  static const ink        = Color(0xFF0F1117);
  static const ink2       = Color(0xFF6B7280);
  static const ink3       = Color(0xFF9CA3AF);
  static const page       = Color(0xFFF0F2F8);
  static const surface    = Color(0xFFFFFFFF);
  static const opacWhite  = Color(0x73FFFFFF);

  // ── Brand ─────────────────────────────────────────────────
  static const indigo600  = Color(0xFF4338CA);
  static const indigo500  = Color(0xFF4F46E5);
  static const indigo400  = Color(0xFF6366F1);
  static const indigoBg   = Color(0xFFEEF2FF);
  static const teal       = Color(0xFF0D9488);
  static const deepPurple = Color(0xFF7C3AED);
  static const pink       = Color(0xFFDB2777);
  static const amber      = Color(0xFFD97706);

  // ── Balance card ──────────────────────────────────────────
  static const balanceGreen = Color(0xFF4ADE80);
  static const balanceRed   = Color(0xFFF87171);
  static const darkCard     = Color(0xFF0F172A);

  // ── Category icon backgrounds ─────────────────────────────
  static const catBgFood          = Color(0xFFFFF7ED);
  static const catBgTransport     = Color(0xFFEFF6FF);
  static const catBgShopping      = Color(0xFFFDF4FF);
  static const catBgEntertainment = Color(0xFFF0FDF4);
  static const catBgBills         = Color(0xFFFEFCE8);
  static const catBgHealth        = Color(0xFFFFF1F2);
  static const catBgSalary        = Color(0xFFEFF6FF);
  static const catBgFreelance     = Color(0xFFEEF2FF);
  static const catBgBusiness      = Color(0xFFF0FDF4);
  static const catBgInvestment    = Color(0xFFECFDF5);
  static const catBgGift          = Color(0xFFFDF4FF);
  static const catBgBonus         = Color(0xFFFEFCE8);
  static const catBgOther         = Color(0xFFF8F8F8);

  // ── Custom category colors (rotating palette) ─────────────
  static const List<Color> customCategoryColors = [
    Color(0xFF7C3AED), // violet
    Color(0xFF0891B2), // cyan
    Color(0xFFD97706), // amber
    Color(0xFF059669), // emerald
    Color(0xFFDB2777), // pink
    Color(0xFFEA580C), // orange
    Color(0xFF4F46E5), // indigo
    Color(0xFF0F766E), // teal dark
    Color(0xFF7E22CE), // purple
    Color(0xFFB45309), // brown amber
  ];

  static const List<Color> customCategoryBgColors = [
    Color(0xFFEDE9FE), // violet bg
    Color(0xFFE0F7FA), // cyan bg
    Color(0xFFFEF3C7), // amber bg
    Color(0xFFD1FAE5), // emerald bg
    Color(0xFFFCE7F3), // pink bg
    Color(0xFFFFEDD5), // orange bg
    Color(0xFFEEF2FF), // indigo bg
    Color(0xFFCCFBF1), // teal bg
    Color(0xFFF3E8FF), // purple bg
    Color(0xFFFEF9C3), // brown amber bg
  ];

  // ── Date/time picker icon backgrounds ────────────────────
  static const dateIconBg  = Color(0xFFFFF7ED);
  static const dateIconFg  = Color(0xFFF97316);
  static const timeIconBg  = Color(0xFFEFF6FF);
  static const timeIconFg  = Color(0xFF3B82F6);

  // ── Filter chip ───────────────────────────────────────────
  static const chipInactive       = Color(0xFFF8F8F8);
  static const chipInactiveBorder = Color(0xFFF1F1F1);

  // ── Card divider / border ─────────────────────────────────
  static const cardBorder    = Color(0xFFF5F5F5);
  static const dividerColor  = Color(0xFFF1F1F1);
}


class CategoryColorHelper {
  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':          return WidgetColors.orange;
      case 'transport':     return WidgetColors.blue;
      case 'shopping':      return WidgetColors.darkPink;
      case 'entertainment': return WidgetColors.radicalRed;
      case 'bills':         return WidgetColors.borderBlueCard;
      case 'health':        return WidgetColors.greenColorCard;
      case 'salary':        return WidgetColors.green;
      case 'freelance':     return WidgetColors.teal;
      case 'business':      return WidgetColors.indigo600;
      case 'investment':    return WidgetColors.deepPurple;
      case 'gift':          return WidgetColors.pink;
      case 'bonus':         return WidgetColors.amber;
      case 'other':         return WidgetColors.grey;
      default:
        return TransactionConstants.customCategoryColor(category);
    }
  }
}