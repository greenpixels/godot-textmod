class_name TextmodAutodocHTML
extends TextmodAutodoc

func _build_section(base_entry: String, modifier_entries: Array[String]) -> String:
	var section: String = "<div class=\"textmod-base\">\n" + base_entry
	if not modifier_entries.is_empty():
		section += "\n<h3>Available Modifiers:</h3>\n<ul class=\"textmod-modifiers\">\n"
		for modifier_entry in modifier_entries:
			section += "<li>\n" + modifier_entry + "\n</li>\n"
		section += "</ul>"
	else:
		section += "\n<p class=\"no-modifiers\"><em>No modifiers available</em></p>"
	section += "\n</div>"
	return section

func _build_base_entry(base: TextmodBase) -> String:
	var base_name: String = base.docs_name if not base.docs_name.is_empty() else base.textmod_key
	var base_color: String = base.docs_color.to_html()
	
	var entry: String = "<h2 class=\"base-title\" style=\"color: #" + base_color + "\">" + _escape_html(base_name) + "</h2>\n"
	entry += "<p><strong>Key:</strong> <code>" + _escape_html(base.textmod_key) + "</code></p>\n"
	
	if not base.docs_description.is_empty():
		var description: String = base.docs_description
		if base.docs_use_tr:
			description = tr(description)
		entry += "<p class=\"base-description\" style=\"color: #" + base_color + "\">" + _escape_html(description) + "</p>"
	
	return entry

func _build_modifier_entry(modifier: TextmodModifier) -> String:
	var modifier_name: String = modifier.docs_name if not modifier.docs_name.is_empty() else modifier.textmod_key
	var modifier_color: String = modifier.docs_color.to_html()
	
	var entry: String = "<div class=\"modifier-entry\">\n"
	entry += "<strong class=\"modifier-name\" style=\"color: #" + modifier_color + "\">" + _escape_html(modifier_name) + "</strong>\n"
	entry += "<ul class=\"modifier-details\">\n"
	entry += "<li><strong>key:</strong> <code>" + _escape_html(modifier.textmod_key) + "</code></li>\n"
	
	if not modifier.docs_description.is_empty():
		var description: String = modifier.docs_description
		if modifier.docs_use_tr:
			description = tr(description)
		entry += "<li><strong>Description:</strong> <span style=\"color: #" + modifier_color + "\">" + _escape_html(description) + "</span></li>\n"
	
	entry += "</ul>\n</div>"
	
	return entry

func _escape_html(text: String) -> String:
	return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;")