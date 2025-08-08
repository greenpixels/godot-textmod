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
		"iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAc9JREFUWIXtVzFuwzAMpIo+oXM8G50MdDMyds7Qwv/IC+K8wP8Q7CFzxiCbgUxG53r2H9whpcqylEwJLbKUQADHkXSn44lUzDzPM9ww7m4J/k8AAOBeO9AYE724xl4qBVLAtfMWCaSCa+cHUyBNPu03avD17uDW8aUjyoQx4Hy8TwnjK0R8ggSe5YUX/P3t4p5RCRCMmXwMQ+D895Byf1oHlkhCTB3wRdce3fPL6/OP90+PD8H5ogc07u+HSU1ya8/uOcoDo61htDUAMxKCb+3ZfSRQ6T0PbwrojpEEdbYUNAUacAil4LTfuF1zAtRcnBT/Db+vqusa6hRkeeGAV1W9uPvUCJpwtFfg9e6gTgM1Jz0BqKZKARyEssWWYA4eCm8phoRmxAuPVI45XJCAloSvJqAKoV6QREAigYEq/Eoz4uBNVYqLYvTDBF17hK49OiLSuG8YWg9QcFpkuBK8DnAC6hT4wOEzt0s7k0KCElOguQdyUinggArEOh3dje+0iogKSOBNVUI/TNAPE2R5obpYNFXpqqUvJCwz2noGdmz4uaZdjo8FYjx6OcGQ1KFKOAISgK/AICHa7XzgNKRqKN4HviSXGw9VgKuh6QH0f8IH61Yfo9azJAYAAAAASUVORK5CYII=",
		"iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAABVElEQVQ4EQXBMWsTYQAA0NePIyi0txnpoPv9AKVDl6yiDiUILu5HnCx1zn6ca9dMbYaQIYMds2SJPyAZiiJdLikEIZf2wnEU3zv48HMEAAAAAAAiAACyPAUuzi8BAAgAgCxPi7IqyqooqyxPAQAIAJDlaVFWAIqyyvIUABAAAACAoqyyPAWAAAAX55c/+oPTT7vjo+fo/NqhKKvJyQhAAACMF93fNy+KssL07SHQRH8mJyMgAoDxoluXL3kCgBVns+8AAoDxohvev8Gr07BiBXDVHwBABAznPUf213eIkvgjmNw8AAAQAODZ59dAq9PG2bfjq/4AABAwnPfqzRr767tWp90st0+rPZrlFgCAAGD3F+rpfavTbpbbKIkBAEAYznv1Zg1ESYx6eh8lcbPcRkkMAEAAgMfZbb1ZR0ncLLdREj/ObgEAOPj3FQAAAPDl3QgA/gNurnwn2X/a9wAAAABJRU5ErkJggg==",
		]

func get_docs_description() -> String:
	var examples: Array[String] = get_docs_examples()
	return "Enter a base64-encoded PNG image. The string should be the base64 representation of a valid PNG file. " + \
		"Examples: " + examples[0].substr(0, 20) + "... (truncated for readability)"
