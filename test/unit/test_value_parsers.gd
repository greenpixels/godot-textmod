extends GdUnitTestSuite

var mock_part: TextmodModifier

func before_test() -> void:
	mock_part = TextmodModifier.new()
	mock_part.textmod_key = "test_key"

func after_test() -> void:
	mock_part = null

# TextmodValueParserNumber Tests
func test_number_parser_valid_examples() -> void:
	var parser: TextmodValueParserNumber = TextmodValueParserNumber.new()
	var examples: Array[String] = parser.get_docs_examples()
	
	# Test all example values
	for example in examples:
		var result: Variant = parser.parse(example, mock_part)
		assert_that(result).is_not_null()
		assert_that(result is TextmodError).is_false()
		assert_that(result is float).is_true()
		
		# Verify specific expected values
		match example:
			"42":
				assert_that(result).is_equal(42.0)
			"3.14":
				assert_that(result).is_equal(3.14)
			"-10":
				assert_that(result).is_equal(-10.0)
			"0":
				assert_that(result).is_equal(0.0)
			"100.5":
				assert_that(result).is_equal(100.5)

func test_number_parser_invalid_values() -> void:
	var parser: TextmodValueParserNumber = TextmodValueParserNumber.new()
	
	var invalid_values: Array[String] = [
		"not_a_number",
		"abc123",
		"12.34.56",
		"",
		"NaN",
		"Infinity",
		"twelve"
	]
	
	for invalid_value in invalid_values:
		var result: Variant = parser.parse(invalid_value, mock_part)
		assert_that(result is TextmodError).is_true()
		var error: TextmodError = result as TextmodError
		assert_str(error.message).contains("is not a valid number")

func test_number_parser_edge_cases() -> void:
	var parser: TextmodValueParserNumber = TextmodValueParserNumber.new()
	
	# Very large number
	var large_result: Variant = parser.parse("999999999", mock_part)
	assert_that(large_result).is_equal(999999999.0)
	
	# Very small decimal
	var small_result: Variant = parser.parse("0.000001", mock_part)
	assert_that(small_result).is_equal(0.000001)
	
	# Leading zeros
	var zero_result: Variant = parser.parse("00042", mock_part)
	assert_that(zero_result).is_equal(42.0)

# TextmodValueParserColor Tests
func test_color_parser_valid_examples() -> void:
	var parser: TextmodValueParserColor = TextmodValueParserColor.new()
	var examples: Array[String] = parser.get_docs_examples()
	
	for example in examples:
		var result: Variant = parser.parse(example, mock_part)
		assert_that(result).is_not_null()
		assert_that(result is TextmodError).override_failure_message((result as TextmodError).message if result is TextmodError else "").is_false()
		assert_that(result is Color).is_true()
		
		# Verify specific expected colors
		match example:
			"#FF0000":
				assert_that(result).is_equal(Color.RED)
			"#00FF00":
				assert_that(result).is_equal(Color.GREEN)
			"#0000FF":
				assert_that(result).is_equal(Color.BLUE)
			"#FFFFFF":
				assert_that(result).is_equal(Color.WHITE)
			"#000000":
				assert_that(result).is_equal(Color.BLACK)
			"FF0000":
				assert_that(result).is_equal(Color.RED)
			"ABC":
				# #ABC expands to #AABBCC
				assert_that(result).is_equal(Color.html("#AABBCC"))

func test_color_parser_invalid_values() -> void:
	var parser: TextmodValueParserColor = TextmodValueParserColor.new()
	
	var invalid_values: Array[String] = [
		"red",
		"blue",
		"#GGG",
		"#GGGGGG",
		"12345",
		"#12345",
		"",
		"not_a_color",
		"#FFFFFFFFF"
	]
	
	for invalid_value in invalid_values:
		var result: Variant = parser.parse(invalid_value, mock_part)
		assert_that(result is TextmodError).is_true()
		var error: TextmodError = result as TextmodError
		assert_str(error.message).contains("hexadecimal value")

func test_color_parser_case_insensitive() -> void:
	var parser: TextmodValueParserColor = TextmodValueParserColor.new()
	
	# Test lowercase
	var lower_result: Variant = parser.parse("#ff0000", mock_part)
	assert_that(lower_result).is_equal(Color.RED)
	
	# Test mixed case
	var mixed_result: Variant = parser.parse("#Ff00Ff", mock_part)
	assert_that(mixed_result).is_equal(Color.MAGENTA)

# TextmodValueParserText Tests
func test_text_parser_valid_examples() -> void:
	var parser: TextmodValueParserText = TextmodValueParserText.new()
	var examples: Array[String] = parser.get_docs_examples()
	
	for example in examples:
		var result: Variant = parser.parse(example, mock_part)
		assert_that(result).is_not_null()
		assert_that(result is TextmodError).is_false()
		assert_that(result is String).is_true()
		assert_str(result).is_equal(example)

func test_text_parser_empty_string() -> void:
	var parser: TextmodValueParserText = TextmodValueParserText.new()
	
	var result: Variant = parser.parse("", mock_part)
	assert_that(result is TextmodError).is_true()
	var error: TextmodError = result as TextmodError
	assert_str(error.message).contains("may not be empty")

func test_text_parser_with_regex() -> void:
	var parser: TextmodValueParserText = TextmodValueParserText.new()
	parser.regex_expression = "^[a-zA-Z]+$"  # Only letters
	
	# Valid input
	var valid_result: Variant = parser.parse("HelloWorld", mock_part)
	assert_that(valid_result).is_equal("HelloWorld")
	
	# Invalid input (contains numbers)
	var invalid_result: Variant = parser.parse("Hello123", mock_part)
	assert_that(invalid_result is TextmodError).is_true()
	var error: TextmodError = invalid_result as TextmodError
	assert_str(error.message).contains("does not match the regex expression")

func test_text_parser_invalid_regex() -> void:
	var parser: TextmodValueParserText = TextmodValueParserText.new()
	parser.regex_expression = "[invalid regex ("  # Invalid regex
	
	var result: Variant = parser.parse("test", mock_part)
	assert_that(result is TextmodError).is_true()
	var error: TextmodError = result as TextmodError
	assert_str(error.message).contains("Unable to parse regex expression")

func test_text_parser_special_characters() -> void:
	var parser: TextmodValueParserText = TextmodValueParserText.new()
	
	var special_texts: Array[String] = [
		"Text with spaces",
		"Text!@#$%^&*()",
		"Héröñamé",
		"Text\nwith\nnewlines",
		"Text\twith\ttabs"
	]
	
	for text in special_texts:
		var result: Variant = parser.parse(text, mock_part)
		assert_that(result).is_equal(text)

# TextmodValueParserTexture Tests  
func test_texture_parser_valid_examples() -> void:
	var parser: TextmodValueParserTexture = TextmodValueParserTexture.new()
	var examples: Array[String] = parser.get_docs_examples()
	
	for example in examples:
		var result: Variant = parser.parse(example, mock_part)
		assert_that(result).is_not_null()
		assert_that(result is TextmodError).override_failure_message((result as TextmodError).message if result is TextmodError else "").is_false()
		assert_that(result is ImageTexture).is_true()
		
		var texture: ImageTexture = result as ImageTexture
		assert_that(texture.get_image()).override_failure_message("Image was null, but shouldn't be").is_not_null()
		assert_that(texture.get_width()).override_failure_message("Image width is 0").is_greater(0)
		assert_that(texture.get_height()).override_failure_message("Image height is 0").is_greater(0)

func test_texture_parser_invalid_base64() -> void:
	var parser: TextmodValueParserTexture = TextmodValueParserTexture.new()
	
	var invalid_values: Array[String] = [
		"not_base64",
		"invalid!!!base64",
		"",
		"SGVsbG8gV29ybGQ=",  # Valid base64 but not PNG
		"12345"
	]
	
	for invalid_value in invalid_values:
		var result: Variant = parser.parse(invalid_value, mock_part)
		assert_that(result is TextmodError).is_true()
		var error: TextmodError = result as TextmodError
		assert_str(error.message).contains("Unable to load image")

func test_texture_parser_minimal_png() -> void:
	var parser: TextmodValueParserTexture = TextmodValueParserTexture.new()
	
	# 1x1 pixel transparent PNG (minimal valid PNG)
	var minimal_png: String = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
	
	var result: Variant = parser.parse(minimal_png, mock_part)
	assert_that(result is ImageTexture).is_true()
	
	var texture: ImageTexture = result as ImageTexture
	assert_that(texture.get_width()).is_equal(1)
	assert_that(texture.get_height()).is_equal(1)

# Test docs_description methods
func test_number_parser_description() -> void:
	var parser: TextmodValueParserNumber = TextmodValueParserNumber.new()
	var description: String = parser.get_docs_description()
	
	assert_str(description).is_not_empty()
	assert_str(description).contains("numeric value")
	assert_str(description).contains("Examples:")
	
	# Should contain example values
	var examples: Array[String] = parser.get_docs_examples()
	for example in examples:
		assert_str(description).contains(example)

func test_color_parser_description() -> void:
	var parser: TextmodValueParserColor = TextmodValueParserColor.new()
	var description: String = parser.get_docs_description()
	
	assert_str(description).is_not_empty()
	assert_str(description).contains("hexadecimal color")
	assert_str(description).contains("Examples:")
	
	var examples: Array[String] = parser.get_docs_examples()
	for example in examples:
		assert_str(description).contains(example)

func test_text_parser_description() -> void:
	var parser: TextmodValueParserText = TextmodValueParserText.new()
	var description: String = parser.get_docs_description()
	
	assert_str(description).is_not_empty()
	assert_str(description).contains("text value")
	assert_str(description).contains("Examples:")
	assert_str(description).contains("quotation marks if text contains dots")

func test_text_parser_description_with_regex() -> void:
	var parser: TextmodValueParserText = TextmodValueParserText.new()
	parser.regex_expression = "^[0-9]+$"
	
	var description: String = parser.get_docs_description()
	assert_str(description).contains("Must match regex pattern: ^[0-9]+$")

func test_texture_parser_description() -> void:
	var parser: TextmodValueParserTexture = TextmodValueParserTexture.new()
	var description: String = parser.get_docs_description()
	
	assert_str(description).is_not_empty()
	assert_str(description).contains("base64-encoded PNG")
	assert_str(description).contains("Examples:")

# Test example value consistency  
func test_all_parsers_have_examples() -> void:
	var parsers: Array = [
		TextmodValueParserNumber.new(),
		TextmodValueParserColor.new(), 
		TextmodValueParserText.new(),
		TextmodValueParserTexture.new()
	]
	
	for parser : Variant in parsers:
		var examples: Array[String] = parser.get_docs_examples()
		assert_that(examples.size()).is_greater(0)
		
		# All examples should be non-empty strings
		for example in examples:
			assert_that(example is String).is_true()
			assert_str(example).is_not_empty()

func test_all_parsers_have_descriptions() -> void:
	var parsers: Array = [
		TextmodValueParserNumber.new(),
		TextmodValueParserColor.new(),
		TextmodValueParserText.new(), 
		TextmodValueParserTexture.new()
	]
	
	for parser : Variant  in parsers:
		var description: String = parser.get_docs_description()
		assert_str(description).is_not_empty()
		assert_str(description).contains("Examples:")
