class_name TextmodValueParserText
extends TextmodValueParser

@export var regex_expression: String = ""

func parse(value: String, part: TextmodPart) -> Variant:
	if value.is_empty():
		return TextmodError.new("The given value may not be empty.", part)
	if not regex_expression.is_empty():
		var regex = RegEx.new()
		var error = regex.compile(regex_expression)
		if not error == OK or not regex.is_valid():
			return TextmodError.new(
				"Unable to parse regex expression {EXPRESSION}. " +
				"For more information, see https://docs.godotengine.org/en/latest/classes/class_regex.html"
				.format({"EXPRESSION": regex_expression}), part)
		if not regex.search(value):
			return TextmodError.new("{VALUE} does not match the regex expression ({EXPRESSION})" \
				.format({"VALUE": value, "EXPRESSION": regex_expression}), part)
	return value

func get_docs_examples() -> Array[String]:
	return ["Hello", "World", "\"Klaus.Dieter\"", "Simple_Text", "Text with spaces"]

func get_docs_description() -> String:
	var examples: Array[String] = get_docs_examples()
	var description: String = "Enter any text value. Use quotation marks if text contains dots. "
	if not regex_expression.is_empty():
		description += "Must match regex pattern: " + regex_expression + ". "
	description += "Examples: " + ", ".join(examples)
	return description
