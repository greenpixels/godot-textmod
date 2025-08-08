extends TextmodValueParser
class_name TextmodValueParserNumber

func parse(value: String, part: TextmodPart) -> Variant:
	if not value.is_valid_float():
		return TextmodError.new(value + " is not a valid number.", part)
	return value.to_float()
