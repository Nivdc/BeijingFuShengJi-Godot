class_name GameCore
extends RefCounted

enum {GAME_RUNNING, GAME_OVER}
var environment_settings = {}
var player_status = {}
var goods_list = {}
var _onwer = null
var _game_state = null

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
	assert(player_status["cash"] - change >= 0, "Error: Trying to reduce cash below 0.")
	player_status["cash"] -= change

func add_bank_deposit_amount(change: int):
	player_status["bank_deposit_amount"] += change

func reduce_bank_deposit_amount(change: int):
	assert(player_status["bank_deposit_amount"] - change >= 0, "Error: Trying to reduce bank_deposit_amount below 0.")
	player_status["bank_deposit_amount"] -= change

func add_debt_amount(change: int):
	player_status["debt_amount"] += change

func reduce_debt_amount(change: int):
	assert(player_status["debt_amount"] - change >= 0, "Error: Trying to reduce debt_amount below 0.")
	player_status["debt_amount"] -= change

# 我错了...我真滴错了，手贱加什么最大值啊，直接脚本里写死不就好了。
func add_health(change: int):
	assert(player_status["health"]>0, "Error: Health still increases after death.")
	var hp     = player_status["health"]
	var max_hp = environment_settings["max_health"]
	player_status["health"] = hp+change if hp+change < max_hp else max_hp

func reduce_health(change: int):
	var hp = player_status["health"]
	player_status["health"] = hp-change if hp-change > 0 else 0

func add_reputation(change: int):
	var rep     = player_status["reputation"]
	var max_rep = environment_settings["max_reputation"]
	player_status["reputation"] = rep+change if rep+change < max_rep else max_rep

func reduce_reputation(change: int):
	var rep     = player_status["reputation"]
	player_status["health"] = rep-change if rep-change > 0 else 0

func add_storage_size(change: int):
	assert(player_status["storage_size"] + change <= environment_settings["max_storage_size"], "Error: Try add storage_size beyond the upper limit.")
	player_status["storage_size"] += change


# 有些事件会直接使用这个函数，所以要检测两次。
func add_good(good_name:String, number:int, record_price:=-1):
	if player_status["used_storage_size"]+number > player_status["storage_size"]:
		print("好可惜!俺租的房子太小，只能放%d个物品。" % player_status["storage_size"])
		return

	_add_good_directly(good_name, number, record_price)


func reduce_good(good_name:String, number:int):
	assert(_verify_good_name(good_name) == true, "Error: Try to reduce undefined good.")
	assert(player_status["storage"].has(good_name) == true, "Error: Try to reduce non-existent good.")
	assert(player_status["storage"][good_name]["number"] - number >= 0, "Error: Try to reduce good number below 0.")
	player_status["storage"][good_name]["number"] -= number
	if player_status["storage"][good_name]["number"] == 0:
		player_status["storage"].erase(good_name)
	# 重新计算已用储藏空间
	player_status["used_storage_size"] = _calculate_used_storage_size()


func deposit_money_to_bank(number: int):
	if player_status["cash"] < number:
		print("我没有那么多现金存进银行。")
		return
	
	reduce_cash(number)
	add_bank_deposit_amount(number)

func withdraw_money_from_bank(number: int):
	if player_status["bank_deposit_amount"] < number:
		print("我的银行账户里没有那么多钱。")
		return
	
	reduce_bank_deposit_amount(number)
	add_cash(number)


func repay_debt(number: int):
	if player_status["cash"] < number:
		print("我没有那么多现金偿还债务。")
		return
	
	reduce_cash(number)
	reduce_debt_amount(number)


func heal_player(heal_point: int):
	var total_price = heal_point * environment_settings["healing_cost_per_point_of_health"]
	if player_status["cash"] < total_price:
		print("医生说，“钱不够哎! 拒绝治疗。")
		return
	
	reduce_cash(total_price)
	add_health(heal_point)


func buy_good(good_name:String, number:int, price:=-1):
	assert(_verify_good_name(good_name) == true, "Error: Try to buy undefined good.")

	if _check_good_is_active(good_name) == false:
		print("哦？仿佛没有人在这里做 %s 生意。" % good_name)
		return
	
	if player_status["used_storage_size"]+number > player_status["storage_size"]:
		print("好可惜!俺租的房子太小，只能放%d个物品。租更大的房子?" % player_status["storage_size"])
		return
	
	if price == -1:# 未输入价格，系统计算价格
		price = _get_good_price(good_name)
	
	var total_price = number * price
	
	if total_price > player_status["cash"]:
		if player_status["bank_deposit_amount"] > 0:
			print("俺带的现金不够，去银行提点钱吧。")
		else:
			print("俺的现金不够，银行又没有存款，咋办哩?")		
		return
	
	reduce_cash(total_price)
	add_good(good_name, number, price)


func sell_good(good_name:String, number:int):
	assert(_verify_good_name(good_name) == true, "Error: Try to sell undefined good.")

	if _check_good_is_active(good_name) == false:
		print("哦？仿佛没有人在这里做 %s 生意。" % good_name)
		return
	
	if player_status["storage"].has(good_name) != true:
		print("我没有 %s。" % good_name)
	
	if player_status["storage"][good_name]["number"] - number < 0:
		print("我没有足够的 %s。" % good_name)
	
	var price = _get_good_price(good_name)
	var total_sell_price = number * price
	reduce_good(good_name, number)
	add_cash(total_sell_price)


# 这可能是整个游戏中最常用的函数。
# 注意，整个游戏模式其实并不关心玩家的具体位置，
# 只是在合成某些提示的时候会用到这个位置。
# 所以只要在前端限制输入内容即可，后端不做限制。
func move(new_location: String):
	if _game_state == GAME_OVER:
		return

	if new_location == player_status["current_location"]:
		return

	player_status["current_location"] = new_location
	# 计算剩余时间
	var time_left = environment_settings["time_limit"] - player_status["elapsed_time"]
	# 如果不是最后两天，就随机禁用3~1种商品
	_regenerate_all_goods_status(3) if time_left > 1 else _regenerate_all_goods_status(0)
	_handle_debts_and_deposits()
	#_random_activate_events()
	#_health_check()

	if player_status["debt_amount"] > 100_000:
		print("俺欠钱太多，村长叫一群老乡揍了俺一顿!")
		reduce_health(30)

	if time_left == 1:
		print("俺明天回家乡，快把全部货物卖掉。")
	
	if time_left == 0:
		print("俺已经在北京40天了，该回去结婚去了。")
		if player_status["storage"].is_empty() != true:
			var remaining_goods_list = []
			print("player_status : \n", str(player_status).replace(", \"", ",\n  \""))
			for good_name in player_status["storage"].keys():
				remaining_goods_list.append(good_name)
				sell_good(good_name, player_status["storage"][good_name]["number"])
			print("系统替我卖了剩余货物: %s。" % ", ".join(remaining_goods_list))
		_game_over()
		return
	
	player_status["elapsed_time"] += 1
	_set_main_window_title("北京浮生记 ( %s/%s ) "% [player_status["elapsed_time"], environment_settings["time_limit"]])

func restart_game():
	_init(_onwer)

func _init(onwer: Node):
	assert(_game_state != GAME_RUNNING, "Error: call _init function while game is running.")
	_onwer = onwer
	_init_load_data()
	_init_global_variables()
	_set_main_window_title("北京浮生记 ( %s/%s ) "% [player_status["elapsed_time"], environment_settings["time_limit"]])
	_game_state = GAME_RUNNING
	#下面是一些测试函数...不要在意。
	#print("environment_settings : \n", str(environment_settings).replace(", \"", ",\n  \""))
	#add_good("进口香烟",2)
	#reduce_good("进口香烟",1)
	print("player_status : \n", str(player_status).replace(", \"", ",\n  \""))
	# print("goods_list : \n", str(goods_list).replace(", \"", ",\n  \""))
	move("somewhere")
	buy_good("进口香烟",1)
	buy_good("伪劣化妆品",1)
	print("player_status : \n", str(player_status).replace(", \"", ",\n  \""))
	# print("goods_list : \n", str(goods_list).replace(", \"", ",\n  \""))
	for i in range(100):
		move("%s"%i)
	print("player_status : \n", str(player_status).replace(", \"", ",\n  \""))

func _init_load_data():
	# 加载初始化信息
	var init_config = ConfigFile.new()
	var err = init_config.load("res://config.cfg")
	assert(err == OK, "Failed to load configuration file.")
	_load_config_section(init_config, "Environment", environment_settings)
	_load_config_section(init_config, "Player", player_status)
	# 加载物品、事件数据
	assert(FileAccess.file_exists("res://game_data.json") == true, "File does not exist -> game_data.json.")
	var game_data_file = FileAccess.open("res://game_data.json", FileAccess.READ)
	var game_data = JSON.parse_string(game_data_file.get_as_text())
	game_data_file.close()
	goods_list = game_data["goods"]

func _load_config_section(config:ConfigFile, section:String, cache:Dictionary):
	for key in config.get_section_keys(section):
		cache[key] = config.get_value(section, key)
	assert(cache.is_empty()!=true, "Failed to load config sectiion -> %s." % section)

func _init_global_variables():
	player_status["elapsed_time"] = 0
	player_status["storage"] = {}
	player_status["used_storage_size"] = 0
	player_status["current_location"] = ""
	_regenerate_all_goods_status(3)

func _calculate_used_storage_size() -> int:
	if player_status["storage"].is_empty() == true:
		return 0
	else:
		var used_size := 0
		for good_name in player_status["storage"]:
			used_size += player_status["storage"][good_name]["number"]
		return used_size

func _verify_good_name(good_name: String) ->bool:
	for good in goods_list:
		if good["name"] == good_name:
			return true
	return false

func _generate_all_goods_prices():
	for good in goods_list:
		good["price"] = good["base_price"] + _random_number(good["price_random_increase_range"])

func _set_all_goods_active_state(active_state: bool):
	for good in goods_list:
		good["is_active"] = active_state

# 生成一个范围在[0,max_value)内随机数。
func _random_number(max_value: int) ->int:
	return randi() % max_value

# 随机禁用商品，参数是尝试次数。
# 显然，在多次抽中同一商品的情况下，禁用的商品数会少于尝试次数。
# 但是原版的逻辑就是这样的（SelectionDlg.cpp 1200行），我也懒得改了。
func _random_deactivate_goods(number_of_attempts: int):
	for i in range(number_of_attempts):
		goods_list[_random_number(goods_list.size())]["is_active"] = false

# 重新生成所有商品的状态，先全部激活，再随机禁用几个。参数是随机禁用的尝试次数。
func _regenerate_all_goods_status(number_of_attempts: int):
	_set_all_goods_active_state(true)
	_random_deactivate_goods(number_of_attempts)
	_generate_all_goods_prices()

func _get_good_price(good_name: String) -> int:
	assert(_verify_good_name(good_name) == true, "Error: Try to get undefined good price.")
	for good in goods_list:
		if good["name"] == good_name:
			assert(good.has("price") == true, "Error: %s has no price yet." % good["name"])
			return good["price"]
	# 为了满足编辑器返回值检查，添加如下行，它们永远不该执行。
	assert(false, "Error: function _get_good_price error.")
	return -2

func _check_good_is_active(good_name: String) -> bool:
	assert(_verify_good_name(good_name) == true, "Error: Try to get undefined good price.")
	for good in goods_list:
		if good["name"] == good_name:
			assert(good.has("is_active") == true, "Error: %s has no is_active yet." % good["name"])
			return good["is_active"]
	# 为了满足编辑器返回值检查，添加如下行，它们永远不该执行。
	assert(false, "Error: function _check_good_is_active error.")
	return false

func _handle_debts_and_deposits():
	player_status["debt_amount"] += convert(player_status["debt_amount"] * environment_settings["debt_interest_rate"], TYPE_INT)
	player_status["bank_deposit_amount"] += convert(player_status["bank_deposit_amount"] * environment_settings["deposit_interest_rate"], TYPE_INT)

func _set_main_window_title(title: String):
	_onwer.get_window().set_title(title)

func _game_over():
	_game_state = GAME_OVER
	print("游戏已结束")

func _add_good_directly(good_name:String, number:int, record_price:=-1):
	assert(_verify_good_name(good_name) == true, "Error: Try to add undefined good.")
	if record_price == -1:# 未输入价格，系统计算价格
		record_price = _get_good_price(good_name)

	# 如果玩家还没有这个物品
	if player_status["storage"].has(good_name) != true:
		player_status["storage"][good_name] = {
			"number":number,
			"record_price":record_price,
		}
	# 如果玩家已经有了这个物品
	else:
		var new_number = player_status["storage"][good_name]["number"] + number
		# 重新计算物品买入价格，调整为均价
		var owned_good_total_price = player_status["storage"][good_name]["number"] * player_status["storage"][good_name]["record_price"]
		var new_good_total_price = number * record_price
		# 原版游戏也同样截断了小数点（SelectionDlg.cpp 802行）,因此我们在此也不做其他的处理。
		var new_record_price = (owned_good_total_price + new_good_total_price)/new_number
		player_status["storage"][good_name]["number"] = new_number
		player_status["storage"][good_name]["record_price"] = new_record_price
	# 重新计算已用储藏空间
	player_status["used_storage_size"] = _calculate_used_storage_size()
