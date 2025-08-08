class_name TextmodBase
extends TextmodPart

@export var possible_modifiers: Array[TextmodModifier]
@export var resource_to_modify: Resource

func _has_duplicate_modifiers() -> bool:
	var exisisting_modifiers: PackedStringArray = []
	for modifiers in possible_modifiers:
		if exisisting_modifiers.has(modifiers.textmod_key):
			return true
		exisisting_modifiers.push_back(modifiers.textmod_key)
	return false
