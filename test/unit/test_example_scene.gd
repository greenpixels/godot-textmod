class_name TestTextmodParser
extends GdUnitTestSuite

var runner: GdUnitSceneRunner
var parser: TextmodParser
var name_label: Label
var health_label: Label
var hair_color_rect: ColorRect
var inventory_label: Label
var text_edit: TextEdit
var default_hero: ExampleHero

func before_test() -> void:
	default_hero = ExampleHero.new()
	runner = scene_runner("res://examples/playground_scene.tscn")
	parser = runner.find_child("Parser")
	name_label = runner.find_child("NameValue")
	health_label = runner.find_child("HealthValue") 
	hair_color_rect = runner.find_child("HairColorValue")
	inventory_label = runner.find_child("InventoryValue")
	text_edit = runner.find_child("TextEdit")

func after_test() -> void:
	runner = null

func test_initial_state() -> void:
	assert_str(name_label.text).is_empty()
	assert_str(health_label.text).is_empty()
	assert_str(inventory_label.text).is_empty()
	assert_bool(hair_color_rect.color == Color.WHITE).is_true()

func test_base_creation_only() -> void:
	_set_text_and_wait("hero.")
	assert_str(name_label.text).is_equal(default_hero.hero_name)
	assert_str(health_label.text).is_equal(str(default_hero.health))

func test_simple_name_change() -> void:
	_set_text_and_wait("hero.name.Klaus")
	assert_str(name_label.text).is_equal("Klaus")

func test_quoted_name_with_spaces() -> void:
	_set_text_and_wait('hero.name."Klaus in Quotation"')
	assert_str(name_label.text).is_equal("Klaus in Quotation")

func test_quoted_name_with_dots() -> void:
	_set_text_and_wait('hero.name."Klaus.Dieter"')
	assert_str(name_label.text).is_equal("Klaus.Dieter")

func test_health_modification() -> void:
	_set_text_and_wait("hero.hp.150")
	assert_str(health_label.text).is_equal(str(float(150)))

func test_decimal_health() -> void:
	_set_text_and_wait('hero.hp."99.5"')
	assert_str(health_label.text).is_equal(str(99.5))

func test_negative_health() -> void:
	_set_text_and_wait("hero.hp.-10")
	assert_str(health_label.text).is_equal(str(float(-10)))

func test_zero_health() -> void:
	_set_text_and_wait("hero.hp.0")
	assert_str(health_label.text).is_equal(str(float(0)))

func test_hair_color_red() -> void:
	_set_text_and_wait("hero.hair.#FF0000")
	assert_that(hair_color_rect.color).is_equal(Color.RED)

func test_hair_color_green() -> void:
	_set_text_and_wait("hero.hair.#00FF00")
	assert_that(hair_color_rect.color).is_equal(Color.GREEN)

func test_hair_color_blue() -> void:
	_set_text_and_wait("hero.hair.#0000FF")
	assert_that(hair_color_rect.color).is_equal(Color.BLUE)

func test_hair_color_short_format() -> void:
	_set_text_and_wait("hero.hair.#F00")
	assert_that(hair_color_rect.color).is_equal(Color.RED)

func test_hair_color_without_hash() -> void:
	_set_text_and_wait("hero.hair.FF0000")
	assert_that(hair_color_rect.color).is_equal(Color.RED)

func test_single_inventory_item() -> void:
	_set_text_and_wait("hero.item.sword")
	assert_str(inventory_label.text).contains("sword")

func test_multiple_inventory_items() -> void:
	_set_text_and_wait("hero.item.sword.item.shield.item.potion")
	assert_str(inventory_label.text).contains("sword")
	assert_str(inventory_label.text).contains("shield")
	assert_str(inventory_label.text).contains("potion")

func test_complex_hero_setup() -> void:
	_set_text_and_wait("hero.name.TestHero.hp.200.hair.#00FF00.item.sword.item.potion")
	
	assert_str(name_label.text).is_equal("TestHero")
	assert_str(health_label.text).is_equal(str(float(200)))
	assert_that(hair_color_rect.color).is_equal(Color.GREEN)
	assert_str(inventory_label.text).contains("sword")
	assert_str(inventory_label.text).contains("potion")

func test_overwrite_name() -> void:
	_set_text_and_wait("hero.name.FirstName")
	assert_str(name_label.text).is_equal("FirstName")
	
	_set_text_and_wait("hero.name.SecondName")
	assert_str(name_label.text).is_equal("SecondName")

func test_overwrite_health() -> void:
	_set_text_and_wait("hero.hp.100")
	assert_str(health_label.text).is_equal(str(float(100)))
	
	_set_text_and_wait("hero.hp.200")
	assert_str(health_label.text).is_equal(str(float(200)))

func test_reset_and_rebuild() -> void:
	_set_text_and_wait("hero.name.TestName.hp.150")
	assert_str(name_label.text).is_equal("TestName")
	assert_str(health_label.text).is_equal(str(float(150)))
	
	_set_text_and_wait("hero.name.NewName.hp.75")
	assert_str(name_label.text).is_equal("NewName")
	assert_str(health_label.text).is_equal(str(float(75)))

func test_whitespace_handling() -> void:
	_set_text_and_wait("hero.name.Name With Spaces")
	assert_str(name_label.text).is_equal("Name With Spaces")

func test_special_characters_in_name() -> void:
	_set_text_and_wait("hero.name.Name!@#$%^&*()")
	assert_str(name_label.text).is_equal("Name!@#$%^&*()")

func test_unicode_characters() -> void:
	_set_text_and_wait("hero.name.Héröñamé")
	assert_str(name_label.text).is_equal("Héröñamé")

func test_very_long_name() -> void:
	var long_name: String = "A".repeat(100)
	_set_text_and_wait("hero.name." + long_name)
	assert_str(name_label.text).is_equal(long_name)

func test_large_health_value() -> void:
	_set_text_and_wait("hero.hp.999999")
	assert_str(health_label.text).is_equal(str(float(999999)))

func test_very_small_decimal() -> void:
	_set_text_and_wait('hero.hp."0.001"')
	assert_str(health_label.text).is_equal(str(float(0.001)))

func test_multiple_consecutive_items() -> void:
	var items: Array[String] = ["item1", "item2", "item3", "item4", "item5"]
	var command: String = "hero."
	for item in items:
		command += "item." + item + "."
	command = command.trim_suffix(".")
	
	_set_text_and_wait(command)
	
	for item in items:
		assert_str(inventory_label.text).contains(item)

func test_mixed_quoted_unquoted() -> void:
	_set_text_and_wait('hero.name."Quoted Name".hp.100.item.UnquotedItem.item."Quoted Item"')
	
	assert_str(name_label.text).is_equal("Quoted Name")
	assert_str(health_label.text).is_equal(str(float(100)))
	assert_str(inventory_label.text).contains("UnquotedItem")
	assert_str(inventory_label.text).contains("Quoted Item")

func test_empty_quoted_string() -> void:
	_set_text_and_wait('hero.name.""')
	assert_str(name_label.text).is_not_equal("")

func test_single_character_values() -> void:
	_set_text_and_wait("hero.name.A.hp.1")
	assert_str(name_label.text).is_equal("A")
	assert_str(health_label.text).is_equal(str(float(1)))

func _set_text_and_wait(text: String) -> void:
	text_edit.text = text
	text_edit.text_changed.emit()
	await runner.simulate_frames(1)
