extends TextmodValueParser
class_name TextmodValueParserTexture

func parse(value: String, part: TextmodPart) -> Variant:
	var raw_bytes: PackedByteArray = Marshalls.base64_to_raw(value)
	var image := Image.new()
	var error: Error = image.load_png_from_buffer(raw_bytes)
	if error != OK:
		return TextmodError.new("Unable to load image from provided base64 String {VALUE}".format({"VALUE": value}), part)
	var texture: ImageTexture = ImageTexture.new()
	texture.set_image(image)
	return texture
