class_name TextmodPipeSimpleSetter
extends TextmodPipeScript

@export var property_path : String

func pipe(input: Resource, value: Variant, part: TextmodPart) -> Object:
	var object : Object = input
	if property_path.is_empty():
		return TextmodError.new("Property path is not allowed to be empty.", part)
	var traverse_info = traverse_to_nested_property(input, property_path)
	if not traverse_info.error.is_empty():
		return TextmodError.new(traverse_info.error, part)
	traverse_info.object[traverse_info.variable] = value
	return input
