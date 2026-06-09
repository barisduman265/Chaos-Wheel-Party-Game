import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Re-bases [base] on Nunito Sans for any text that shows a user-typed player
/// name (or a localized sentence that embeds one).
///
/// Player names routinely contain Turkish letters. The Fredoka display font
/// used by the display/headline/titleLarge theme tiers has a malformed ş/Ş
/// cedilla glyph, so "Barış" renders as "Baris,". Because the glyph *exists*
/// (just looks wrong), a fontFamilyFallback never kicks in — the only fix is
/// to render names with a font that draws the Turkish alphabet correctly.
/// Nunito Sans (already the body font, proven correct in the UI) does, and is
/// visually close to the rounded display font. Size/weight/colour are kept.
TextStyle turkishName(TextStyle? base) => GoogleFonts.nunitoSans(textStyle: base);
