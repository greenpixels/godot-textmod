@abstract
class_name TextmodAutodoc
extends Node

@export var parser: TextmodParser

signal docs_generated(output: String)

func generate() -> void:
	if not parser:
		docs_generated.emit("No parser configured")
		return
	
	var bases: Array[TextmodBase] = get_all_bases()
	if bases.is_empty():
		docs_generated.emit("No bases found in parser")
		return
	
	var sections: Array[String] = []
	for base in bases:
		var base_entry: String = _build_base_entry(base)
		var modifier_entries: Array[String] = []
		for modifier in get_modifiers_for_base(base):
			modifier_entries.append(_build_modifier_entry(modifier))
		sections.append(_build_section(base_entry, modifier_entries))
	
	docs_generated.emit("\n\n".join(sections))

@abstract
func _build_section(base_entry: String, modifier_entries: Array[String]) -> String

@abstract
func _build_base_entry(base: TextmodBase) -> String

@abstract
func _build_modifier_entry(modifier: TextmodModifier) -> String

func get_all_bases() -> Array[TextmodBase]:
	if not parser:
		return []
	return parser.bases

func get_all_modifiers() -> Array[TextmodModifier]:
	var modifiers: Array[TextmodModifier] = []
	for base in get_all_bases():
		for modifier in base.possible_modifiers:
			modifiers.append(modifier)
	return modifiers

func get_modifiers_for_base(base: TextmodBase) -> Array[TextmodModifier]:
	return base.possible_modifiers
