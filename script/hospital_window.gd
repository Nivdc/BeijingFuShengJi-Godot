extends Window


@onready var info_label =  $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var default_info_text = info_label.get_text()
@onready var line_edit = $MarginContainer/VBoxContainer/HBoxContainer2/LineEdit

var core = null


func set_game_core(game_core: GameCore):
	core = game_core
	var player_health = core.player_status["health"]
	var player_lost_hp = core.environment_settings["max_health"] - player_health
	var new_info = default_info_text % [player_health, player_lost_hp, core.environment_settings["healing_cost_per_point_of_health"]]
	info_label.set_text(new_info)
	line_edit.set_text(str(player_lost_hp))


func _ready():
	self.connect("close_requested",func():self.hide())
	var confirm_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button
	confirm_button.pressed.connect(func():self._confirm())
	var cancel_button = $MarginContainer/VBoxContainer/HBoxContainer3/Button2
	cancel_button.pressed.connect(func():self._cancel())


func _confirm():
	assert(core != null, "Error: game core is undefined.")
	core.heal_player(line_edit.get_text() as int)
	self.emit_signal("close_requested")


func _cancel():
	self.emit_signal("close_requested")
