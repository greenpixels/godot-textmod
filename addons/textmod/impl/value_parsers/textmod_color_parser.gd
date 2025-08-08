class_name TextmodValueParserColor
extends TextmodValueParser

func parse(value: String, part: TextmodPart) -> Variant:
	if not Color.html_is_valid(value):
		return TextmodError.new(
			value + " was given, but needs to be a hexadecimal value (case-insensitive) " +
			"of either 3, 4, 6 or 8 digits, and may be prefixed by a hash sign (#).", part)
	return Color.html(value)
