class_name TextmodParser
extends Node

signal parse_error(message: String)
signal parse_success(result: Variant)

enum ParseState {
	IDLE,
	PREPARE,
	PARSING_BASE_KEY,
	PARSING_MODIFIER_KEY,
	PARSING_MODIFIER_VALUE
}

@export var bases: Array[TextmodBase]

var state: ParseState = ParseState.IDLE
var available_modifiers_by_key: Dictionary[String, TextmodModifier] = {}
var base_key: String = ""
var current_modifier_key: String = ""
var current_modifier: TextmodModifier = null
var current_modifier_value: String = ""
var parsed_base: TextmodBase = null
var base_resource: Resource = null
var is_in_quotation: bool = false

func parse_from_text(input: String) -> void:
	_reset()

	if _has_duplicate_bases():
		_handle_error(TextmodError.new(
			"Bases contain duplicate keys. Make sure all keys in all used bases are unique."))
		return

	var char_index: int = 0
	state = ParseState.PARSING_BASE_KEY
	for char in input:
		var should_continue: bool = _process_character(char, input, char_index)
		if not should_continue:
			return
		char_index += 1

func _process_character(char: String, input: String, char_index: int) -> bool:
	if char == "\"":
		is_in_quotation = !is_in_quotation

	if char == "." and not is_in_quotation:
		return _handle_delimiter()

	return _handle_regular_character(char, input, char_index)

func _handle_delimiter() -> bool:
	match (state):
		ParseState.PARSING_BASE_KEY:
			return _handle_base_key_parsing()
		ParseState.PARSING_MODIFIER_KEY:
			return _handle_modifier_key_parsing()
		ParseState.PARSING_MODIFIER_VALUE:
			return _handle_modifier_value_parsing()
		_:
			_handle_error(TextmodError.new("Unexpected parse state encountered"))
			return false

func _strip_quotes(value : String) -> String:
	if value.begins_with("\"") and value.ends_with("\""):
		return value.substr(1, value.length() - 2)
	else: return value

func _handle_base_key_parsing() -> bool:
	base_key = _strip_quotes(base_key)
	
	if base_key.is_empty():
		_handle_error(TextmodError.new("Base key can not be empty."))
		return false
	
	var found_key: bool = false
	for base in bases:
		if base.textmod_key == base_key:
			found_key = true
			parsed_base = base
			if not _setup_modifiers():
				return false
			base_resource = base.resource_to_modify.new()
			parse_success.emit(base_resource)
			break

	if not found_key:
		_handle_error(TextmodError.new(
			"Could not match the '{BASE_KEY}' to an existing base."
			.format({"BASE_KEY": base_key})))
		return false

	state = ParseState.PARSING_MODIFIER_KEY
	return true

func _setup_modifiers() -> bool:
	for modifier in parsed_base.possible_modifiers:
		if available_modifiers_by_key.has(modifier.textmod_key):
			_handle_error(TextmodError.new(
				"Modifiers of {BASE_KEY} contain duplicate keys. " +
				"Make sure all modifier keys in the base are unique."
				.format({"BASE_KEY": parsed_base.textmod_key})))
			return false
		available_modifiers_by_key[modifier.textmod_key] = modifier
	return true

func _handle_modifier_key_parsing() -> bool:
	
	if not parsed_base:
		_handle_error(TextmodError.new("Can't parse modifier key when base is null."))
		return false
	current_modifier_key = _strip_quotes(current_modifier_key)
	if current_modifier_key.is_empty():
		_handle_error(TextmodError.new("Modifier key can not be empty."))
		return false
	
	if not available_modifiers_by_key.has(current_modifier_key):
		_handle_error(TextmodError.new(
			"Modifier '{MODIFIER_KEY}' does not exist in given base."
			.format({"MODIFIER_KEY": current_modifier_key})))
		return false
	current_modifier = available_modifiers_by_key[current_modifier_key]
	state = ParseState.PARSING_MODIFIER_VALUE
	return true

func _handle_modifier_value_parsing() -> bool:
	var value: Variant = _on_parse_modifier_value()
	if value is TextmodError:
		_handle_error(value)
		return false
	parse_success.emit(value)
	state = ParseState.PARSING_MODIFIER_KEY
	return true

func _handle_regular_character(char: String, input: String, char_index: int) -> bool:
	match (state):
		ParseState.PARSING_BASE_KEY:
			base_key += char
		ParseState.PARSING_MODIFIER_KEY:
			current_modifier_key += char
		ParseState.PARSING_MODIFIER_VALUE:
			current_modifier_value += char
			if char_index == input.length() - 1:
				return _handle_modifier_value_parsing()
	return true

func _reset() -> void:
	is_in_quotation = false
	state = ParseState.IDLE
	available_modifiers_by_key = {}
	base_key = ""
	current_modifier_key = ""
	current_modifier = null
	current_modifier_value = ""
	parsed_base = null
	base_resource = null

func _on_parse_modifier_value() -> Variant:
	if not parsed_base:
		return TextmodError.new("Can't parse modifier value when base is null.")

	if not current_modifier:
		return TextmodError.new("Can't parse modifier value when current modifier is null.")
		
	current_modifier_value = _strip_quotes(current_modifier_value)
	
	if current_modifier_value.is_empty():
		return TextmodError.new("Modifier value can not be empty.")
	
	var value: Variant = current_modifier.value_parser.parse(
		current_modifier_value,
		current_modifier
	)

	if value is TextmodError:
		return value

	var result: Variant = current_modifier.pipe_script.pipe(
		base_resource,
		value,
		current_modifier
		)
	current_modifier = null
	current_modifier_key = ""
	current_modifier_value = ""
	return result

func _handle_error(error: TextmodError) -> void:
	# TODO: Use the TextmodPart to give more detailed information here when its not null
	# (when thrown in the Parser). Could also pass in the current char index for better error messages
	parse_error.emit(error.message)
	push_error(error.message)

func _has_duplicate_bases() -> bool:
	var existing_bases: PackedStringArray = []
	for base in bases:
		if existing_bases.has(base.textmod_key):
			return true
		existing_bases.push_back(base.textmod_key)
	return false
