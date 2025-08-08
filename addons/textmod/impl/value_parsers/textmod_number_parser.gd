class_name TextmodValueParserNumber
extends TextmodValueParser

func parse(value: String, part: TextmodPart) -> Variant:
	if not value.is_valid_float():
		return TextmodError.new(value + " is not a valid number.", part)
	return value.to_float()

func get_docs_examples() -> Array[String]:
	return ["42", "3.14", "-10", "0", "100.5"]

func get_docs_description() -> String:
	var examples: Array[String] = get_docs_examples()
	return "Enter a numeric value (integer or decimal). Examples: " + ", ".join(examples)
