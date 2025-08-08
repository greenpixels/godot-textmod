class_name TextmodAutodocMarkdown
extends TextmodAutodoc

func _build_section(base_entry: String, modifier_entries: Array[String]) -> String:
	var section: String = base_entry
	if not modifier_entries.is_empty():
		section += "\n\n### Available Modifiers:\n\n"
		section += "\n\n".join(modifier_entries)
	else:
		section += "\n\n*No modifiers available*"
	return section

func _build_base_entry(base: TextmodBase) -> String:
	var base_name: String = base.docs_name if not base.docs_name.is_empty() else base.textmod_key
	
	var entry: String = "## " + base_name + "\n\n"
	entry += "**Key:** `" + base.textmod_key + "`\n\n"
	
	if not base.docs_description.is_empty():
		var description: String = base.docs_description
		if base.docs_use_tr:
			description = tr(description)
		entry += description
	
	return entry

func _build_modifier_entry(modifier: TextmodModifier) -> String:
	var modifier_name: String = modifier.docs_name if not modifier.docs_name.is_empty() else modifier.textmod_key
	
	var entry: String = "- **" + modifier_name + "**\n"
	entry += "  - **key:** `" + modifier.textmod_key + "`\n"
	
	if not modifier.docs_description.is_empty():
		var description: String = modifier.docs_description
		if modifier.docs_use_tr:
			description = tr(description)
		entry += "  **Description:** " + description
	
	return entry