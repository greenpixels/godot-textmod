@abstract
class_name TextmodPipeScript
extends Resource

@abstract
func pipe(input: Resource, value: Variant, part: TextmodPart) -> Variant

class TraverseInfo:
	var error : String
	var object : Object
	var variable: String
	
	func _init(_object : Object, _variable : String, _error: String):
		self.error = _error
		self.object = _object
		self.variable = _variable

func traverse_to_nested_property(obj: Object, path: String) -> TraverseInfo:
	var parts : PackedStringArray = path.split(".")
	var current : Variant = obj
	for i in range(parts.size() - 1):
		if not parts[i] in current:
			return TraverseInfo.new(null, "", path + " does not exist in given the Object")
		current = current.get(parts[i])
	return TraverseInfo.new(current, parts[-1], "")
