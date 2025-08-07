extends RefCounted
class_name TextmodError

var message : String = ""
var part : TextmodPart = null

func _init(_message: String, _part: TextmodPart = null):
	message = _message
	part = _part
