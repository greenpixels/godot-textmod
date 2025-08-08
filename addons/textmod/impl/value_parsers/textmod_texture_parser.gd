class_name TextmodValueParserTexture
extends TextmodValueParser

func parse(value: String, part: TextmodPart) -> Variant:
	var raw_bytes: PackedByteArray = Marshalls.base64_to_raw(value)
	var image := Image.new()
	var error: Error = image.load_png_from_buffer(raw_bytes)
	if error != OK:
		return TextmodError.new(
			"Unable to load image from provided base64 String {VALUE}"
			.format({"VALUE": value}), part)
	var texture: ImageTexture = ImageTexture.new()
	texture.set_image(image)
	return texture

func get_docs_examples() -> Array[String]:
	return [
		"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==",
		"iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAACbSURBVChTlZHBDcAgCET7H4jpmNbE="
	]

func get_docs_description() -> String:
	var examples: Array[String] = get_docs_examples()
	return "Enter a base64-encoded PNG image. The string should be the base64 representation of a valid PNG file. " + \
		"Examples: " + examples[0].substr(0, 20) + "... (truncated for readability)"
