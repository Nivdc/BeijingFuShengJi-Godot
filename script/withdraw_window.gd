extends Window


@onready var line_edit = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

var core = null


func set_game_core(game_core: GameCore):
	core = game_core
	line_edit.set_text(str(core.player_status["bank_deposit_amount"]))


func _ready():
	self.connect("close_requested",func():self.hide())
	var confirm_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button
	confirm_button.pressed.connect(func():self._confirm())
	var cancel_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button2
	cancel_button.pressed.connect(func():self._cancel())


func _confirm():
	assert(core != null, "Error: game core is undefined.")
	core.withdraw_money_from_bank(line_edit.get_text() as int)
	self.emit_signal("close_requested")
	get_parent().emit_signal("close_requested")


func _cancel():
	self.emit_signal("close_requested")
