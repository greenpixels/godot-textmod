extends TextmodValueParser
class_name TextmodValueParserText

@export var regex_expression: String = ""

func parse(value: String, part: TextmodPart) -> Variant:
	if value.is_empty():
		return TextmodError.new("The given value may not be empty.", part)
	if not regex_expression.is_empty():
		var regex = RegEx.new()
		var error = regex.compile(regex_expression)
		if not error == OK or not regex.is_valid():
			return TextmodError.new("Unable to parse regex expression {EXPRESSION}. For more information, see https://docs.godotengine.org/en/latest/classes/class_regex.html" \
				.format({"EXPRESSION": regex_expression}), part)
		if not regex.search(value):
			return TextmodError.new("{VALUE} does not match the regex expression ({EXPRESSION})" \
				.format({"VALUE": value, "EXPRESSION": regex_expression}), part)
	return value
