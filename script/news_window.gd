extends Window


# 明眼人应该已经看出来了，这个window和diary window一摸一样，
# 所以是可以复用的，但是写到这里的时候，我的大脑已经死机了，此时此刻我不想想太多。
func _ready():
	self.connect("close_requested",func():self.hide())
	var close_button = $MarginContainer/VBoxContainer/MarginContainer/Button
	close_button.pressed.connect(func():self.emit_signal("close_requested"))


func set_text(txt: String):
	var txt_label = $MarginContainer/VBoxContainer/HBoxContainer/Label
	txt_label.set_text(txt)

