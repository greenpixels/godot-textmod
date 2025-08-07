extends Control


func _on_text_edit_text_changed() -> void:
	%Parser.parse_from_text(%TextEdit.text)


func _on_parser_parse_success(result: Variant) -> void:
	if result is ExampleHero:
		%HBoxContainerInfo.show()
		%ScrollContainerError.hide()
		%FaceTexture.texture = result.face_texture
		%NameValue.text = result.hero_name
		%HealthValue.text = str(result.health)
		%HairColorValue.color = result.hair_color
		%InventoryValue.text = ", ".join(result.items)


func _on_parser_parse_error(message: String) -> void:
	%HBoxContainerInfo.hide()
	%ScrollContainerError.show()
	%ErrorMessage.text = message
