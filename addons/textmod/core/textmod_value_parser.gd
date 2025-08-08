@abstract
class_name TextmodValueParser
extends Resource

@abstract
func parse(value: String, part: TextmodPart) -> Variant

@abstract
func get_docs_examples() -> Array[String]

@abstract
func get_docs_description() -> String
