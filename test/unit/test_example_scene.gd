class_name TestTextmodParser
extends GdUnitTestSuite

func test_playground_scene() -> void:
	var new_hero_resource : ExampleHero = ExampleHero.new()
	var runner : GdUnitSceneRunner = scene_runner("res://examples/playground_scene.tscn")
	var parser : TextmodParser = runner.find_child("Parser")
	var name_label : Label = runner.find_child("NameValue")
	var health_label : Label = runner.find_child("HealthValue")
	var hair_color_rect : ColorRect = runner.find_child("HairColorValue")
	var inventory_label : Label = runner.find_child("InventoryValue")
	var text_edit : TextEdit = runner.find_child("TextEdit")
	
	assert_str(name_label.text).is_empty()
	assert_str(health_label.text).is_empty()
	assert_str(inventory_label.text).is_empty()
	assert_bool(hair_color_rect.color == Color.WHITE).is_true()
	
	text_edit.text = "hero."
	text_edit.text_changed.emit()

	assert_str(name_label.text).is_equal(new_hero_resource.hero_name)
	
	text_edit.text = "hero.name.Klaus"
	text_edit.text_changed.emit()
	
	assert_str(name_label.text).is_equal("Klaus")
	
	text_edit.text = 'hero.name."Klaus in Quotation"'
	text_edit.text_changed.emit()
	
	assert_str(name_label.text).is_equal("Klaus in Quotation")
