class_name GameCore
extends RefCounted

var environment_settings = {}
var player_status = {}
var goods_list = {}
var _onwer = null

# 下面这个console的实现无法调用内部的变量，可能是我没有找到正确的用法，
# 姑且将其保留，后面再研究下，我先看看 Expression 能不能做到类似的功能。
# https://ask.godotengine.org/339/does-gdscript-have-method-to-execute-string-code-exec-python
# https://www.reddit.com/r/godot/comments/vo40ya/how_can_i_run_strings_as_code_during_runtime/
#func console(command: String):
# 	var script = GDScript.new()
# 	script.set_source_code("func eval():" + command)
# 	script.reload()
# 	var ref = RefCounted.new()
# 	ref.set_script(script)
# 	return ref.eval()


func console(command: String):
	var expr = Expression.new()
	expr.parse(command)
	expr.execute([],self)

func add_cash(change: int):
	player_status["cash"] += change

func reduce_cash(change: int):
	player_status["cash"] -= change

func set_bank_deposit_amount(value: int):
	player_status["bank_deposit_amount"] = value

func set_debt_amount(value: int):
	player_status["debt_amount"] = value

# 我错了...我真滴错了，手贱加什么最大值啊，直接脚本里写死不就好了。
func add_health(change: int):
	assert(player_status["health"]>0, "Warning: health still increases after death.")
	var hp     = player_status["health"]
	var max_hp = player_status["max_health"]
	player_status["health"] = hp+change if hp+change < max_hp else max_hp

func reduce_health(change: int):
	var hp = player_status["health"]
	player_status["health"] = hp-change if hp-change > 0 else 0

func add_reputation(change: int):
	var rep     = player_status["reputation"]
	var max_rep = player_status["max_reputation"]
	player_status["reputation"] = rep+change if rep+change < max_rep else max_rep

func reduce_reputation(change: int):
	var rep     = player_status["reputation"]
	player_status["health"] = rep-change if rep-change > 0 else 0

func add_good(good_name:String, number:int, record_price:=-1):
	if record_price == -1:# 未输入价格，系统计算价格
		pass
	else:				  # 已输入价格，使用输入的价格
		if player_status["storage"].has[good_name] == true:
			pass
		else:
			player_status["storage"][good_name] = {
				"number":number,
				"record_price":record_price,
			}


func _init(onwer: Node):
	_onwer = onwer
	_onwer.get_window().set_title("北京浮生记 ( 0/40 ) ")
	_init_load_data()
	_init_global_variables()
	print("environment_settings : \n", str(environment_settings).replace(", \"", ",\n  \""))
	print("player_status : \n", str(player_status).replace(", \"", ",\n  \""))

func _init_load_data():
	# 加载初始化信息
	var init_config = ConfigFile.new()
	var err = init_config.load("res://config.cfg")
	assert(err == OK, "Failed to load configuration file.")
	_load_config_section(init_config, "Environment", environment_settings)
	_load_config_section(init_config, "Player", player_status)
	# 加载物品、事件数据
	assert(FileAccess.file_exists("res://game_data.json") == true, "File does not exist -> game_data.json")
	var game_data_file = FileAccess.open("res://game_data.json", FileAccess.READ)
	var game_data = JSON.parse_string(game_data_file.get_as_text())
	goods_list = game_data["goods"]
	print(typeof(goods_list[1]))

func _load_config_section(config:ConfigFile, section:String, cache:Dictionary):
	for key in config.get_section_keys(section):
		cache[key] = config.get_value(section, key)
	assert(cache.is_empty()!=true, "Failed to load config sectiion -> %s." % section)

func _init_global_variables():
	player_status["elapsed_time"] = 0
	player_status["storage"] = {}
