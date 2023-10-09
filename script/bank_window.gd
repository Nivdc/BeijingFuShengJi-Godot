extends Window


@onready var info_label =  $MarginContainer/VBoxContainer/Label
@onready var default_info_text = info_label.get_text()

var core = null


func set_game_core(game_core: GameCore):
	core = game_core
	var player_cash = core.player_status["cash"]
	var player_bank_deposit_amount = core.player_status["bank_deposit_amount"]
	var new_info = default_info_text % [player_cash, player_bank_deposit_amount]
	info_label.set_text(new_info)


func _ready():
	self.connect("close_requested",func():self.hide())
	var deposit_button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button
	deposit_button.pressed.connect(func():self._setup_deposit_window())
	var withdraw_button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button2
	withdraw_button.pressed.connect(func():self._setup_withdraw_window())
	var cancel_button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button3
	cancel_button.pressed.connect(func():self._cancel())


func _setup_deposit_window():
	assert(core != null, "Error: game core is undefined.")
	$DepositWindow.set_game_core(core)
	$DepositWindow.show()


func _setup_withdraw_window():
	assert(core != null, "Error: game core is undefined.")
	$WithdrawWindow.set_game_core(core)
	$WithdrawWindow.show()


func _cancel():
	self.emit_signal("close_requested")
