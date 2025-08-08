class_name TextmodAutodocBBCode
extends TextmodAutodoc

func _build_section(base_entry: String, modifier_entries: Array[String]) -> String:
	var section: String = base_entry
	if not modifier_entries.is_empty():
		section += "\n[b]Available Modifiers:[/b]\n"
		section += "\n".join(modifier_entries)
	else:
		section += "\n[color=gray]No modifiers available[/color]"
	return section

func _build_base_entry(base: TextmodBase) -> String:
	var base_name: String = base.docs_name if not base.docs_name.is_empty() else base.textmod_key
	var base_color: String = base.docs_color.to_html()
	
	var entry: String = "[font_size=16][b][color=#" + base_color + "]" + base_name + "[/color][/b][/font_size]\n"
	entry += "[b]Key:[/b] [code]" + base.textmod_key + "[/code]\n"
	
	if not base.docs_description.is_empty():
		var description: String = base.docs_description
		if base.docs_use_tr:
			description = tr(description)
		entry += "[color=#" + base_color + "]" + description + "[/color]"
	
	return entry

func _build_modifier_entry(modifier: TextmodModifier) -> String:
	var modifier_name: String = modifier.docs_name if not modifier.docs_name.is_empty() else modifier.textmod_key
	var modifier_color: String = modifier.docs_color.to_html()
	
	var entry: String = "- [b][color=#" + modifier_color + "]" + modifier_name + "[/color][/b]\n"
	entry += "\t- [b]key:[/b] [code]" + modifier.textmod_key + "[/code]\n"
	
	if not modifier.docs_description.is_empty():
		var description: String = modifier.docs_description
		if modifier.docs_use_tr:
			description = tr(description)
		entry += "\t[b]Description:[/b] [color=#" + modifier_color + "]" + description + "[/color]"
	
	return entry
