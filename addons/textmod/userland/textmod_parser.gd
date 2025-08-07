extends Node
class_name TextmodParser

@export var bases : Array[TextmodBase]

var state : PARSE_STATE = PARSE_STATE.IDLE
var available_modifiers_by_key : Dictionary[String, TextmodModifier] = {}
var base_key : String = ""
var current_modifier_key : String = ""
var current_modifier : TextmodModifier = null
var current_modifier_value : String = ""
var parsed_base : TextmodBase = null
var base_resource : Resource = null
var is_in_quotation : bool = false

signal parse_error(message : String)
signal parse_success(result : Variant)

enum PARSE_STATE {
	IDLE,
	PREPARE,
	PARSING_BASE_KEY,
	PARSING_MODIFIER_KEY,
	PARSING_MODIFIER_VALUE
}

func parse_from_text(input : String) -> void:
	_reset()
	
	if _has_duplicate_bases():
		_handle_error(TextmodError.new("Bases contain duplicate keys. Make sure all keys in all used bases are unique."))
		return
		
	var char_index : int = 0
	state = PARSE_STATE.PARSING_BASE_KEY
	for char in input:
		if char == "\"":
			is_in_quotation = !is_in_quotation
		if char == "." and not is_in_quotation:
			if base_key.begins_with("\"") and base_key.ends_with("\""):
				base_key = base_key.substr(1, base_key.length() - 2)
			if current_modifier_key.begins_with("\"") and current_modifier_key.ends_with("\""):
				current_modifier_key = current_modifier_key.substr(1, current_modifier_key.length() - 2)
			if current_modifier_value.begins_with("\"") and current_modifier_value.ends_with("\""):
				current_modifier_value = current_modifier_value.substr(1, current_modifier_value.length() - 2)
			match(state):
				PARSE_STATE.PARSING_BASE_KEY:
					var found_key : bool = false
					for base in bases:
						if base_key.is_empty():
							_handle_error(TextmodError.new("Base key can not be empty."))
							return
						if base.textmod_key == base_key:
							found_key = true
							parsed_base = base
							for modifier in parsed_base.possible_modifiers:
								if available_modifiers_by_key.has(modifier.textmod_key):
									_handle_error(TextmodError.new("Modifiers of {BASE_KEY} contain duplicate keys. Make sure all modifier keys in the base are unique."\
										.format({"BASE_KEY": parsed_base.textmod_key})))
									return
								available_modifiers_by_key[modifier.textmod_key] = modifier
							base_resource = base.resource_to_modify.new()
							parse_success.emit(base_resource)
					if not found_key:
						_handle_error(TextmodError.new("Could not match the '{BASE_KEY}' to an existing base.".format({"BASE_KEY": base_key})))
						return
					state = PARSE_STATE.PARSING_MODIFIER_KEY
					
				PARSE_STATE.PARSING_MODIFIER_KEY:
					if not parsed_base:
						_handle_error(TextmodError.new("Can't parse modifier key when base is null."))
						return
					if current_modifier_key.is_empty():
						_handle_error(TextmodError.new("Modifier key can not be empty."))
						return
					if not available_modifiers_by_key.has(current_modifier_key):
						_handle_error(TextmodError.new("Modifier '{MODIFIER_KEY}' does not exist in given base.".format({"MODIFIER_KEY": current_modifier_key})))
						return
					current_modifier = available_modifiers_by_key[current_modifier_key]
					state = PARSE_STATE.PARSING_MODIFIER_VALUE
				PARSE_STATE.PARSING_MODIFIER_VALUE:
					var value : Variant = _on_parse_modifier_value()
					if value is TextmodError:
						_handle_error(value)
						return
					parse_success.emit(value)
					state = PARSE_STATE.PARSING_MODIFIER_KEY
				_:
					_handle_error(TextmodError.new("Unexpected parse state encountered"))
					return
		else:
			match(state):
				PARSE_STATE.PARSING_BASE_KEY:
					base_key += char
				PARSE_STATE.PARSING_MODIFIER_KEY:
					current_modifier_key += char
					
				PARSE_STATE.PARSING_MODIFIER_VALUE:
					current_modifier_value += char
					if char_index == input.length() - 1:
						var value : Variant = _on_parse_modifier_value()
						if value is TextmodError:
							_handle_error(value)
							return
						parse_success.emit(value)
		char_index += 1	


func _reset():
	is_in_quotation = false
	state = PARSE_STATE.IDLE
	available_modifiers_by_key = {}
	base_key= ""
	current_modifier_key= ""
	current_modifier = null
	current_modifier_value = ""
	parsed_base= null
	base_resource  = null

func _on_parse_modifier_value() -> Variant:
	if not parsed_base:
		return TextmodError.new("Can't parse modifier value when base is null.")
		
	if not current_modifier:
		return TextmodError.new("Can't parse modifier value when current modifier is null.")
		
	if current_modifier_value.is_empty():
		return TextmodError.new("Modifier value can not be empty.")
		
	var value : Variant = current_modifier.value_parser.parse(
		current_modifier_value,
		current_modifier
	)
	
	if value is TextmodError:
		return value
	
	var result : Variant = current_modifier.pipe_script.pipe(
		base_resource, 
		value,
		current_modifier
		)
	current_modifier = null
	current_modifier_key = ""
	current_modifier_value = ""
	return result
		
func _handle_error(error : TextmodError) -> void:
	# TODO: Use the TextmodPart to give more detailed information here when its not null (when thrown in the Parser)
	#		Could also pass in the current char index for better error messages
	parse_error.emit(error.message)
	push_error(error.message)
	
func _has_duplicate_bases() -> bool:
	var exisisting_bases : PackedStringArray = []
	for base in bases:
		if exisisting_bases.has(base.textmod_key):
			return true
		exisisting_bases.push_back(base.textmod_key)
	return false
