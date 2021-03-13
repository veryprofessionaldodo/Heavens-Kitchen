-- title:  Heaven's Kitchen
-- author: Amogus
-- desc:   Play as a mad chemist working for God
-- script: lua

states = {
	MAIN_MENU = 'menu',
	LEVEL_ONE = 'level_one',
	LEVEL_TWO = 'level_two',
	LEVEL_THREE = 'level_three'
}

events = {
	MAIN_MENU = 'main',
	START_GAME = 'start',
	NEXT_LEVEL = 'next',
	LOST_GAME = 'lost',
	WON_GAME = 'won'
}

-- table with information for each level like time (possible others in the future)
-- time in seconds
levels_metadata = {
	level_one = { time = 10 },
	level_two = { time = 15 },
	level_three = { time = 20 }
}

flask1 = {
	center_x = 50, -- center x
	fill_order = {}, -- order of fill like e.g. [(red, 0, 30), (blue, 30, 35), (yellow, 35, 100)]
	cur_slot = 1, -- current slot the flask is placed in
}

flask2 = {
	center_x = 100,
	fill_order = {},
	cur_slot = 2,
}

flask3 = {
	center_x = 150,
	fill_order = {}, 
	cur_slot = 3,
}

flasks = { flask1, flask2, flask3 } -- not ordered

faucets = { 2, 9, 5 } -- red, yellow, blue faucets

drop_slots = { {35, 65}, {85, 115}, {135, 165} } -- ranges of the drop slots

selected = nil -- selected flask to drag

frame_count = 0 -- count of elapsed frames

-- constants
SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136
CLOCK_FREQ = 60 --Hz

CURR_STATE = states.MAIN_MENU

FLASK_WIDTH = 30
FLASK_OFFSET_Y = 4

Z_KEYCODE = 26
FAUCET_KEYCODE_1 = 28
FAUCET_KEYCODE_2 = 29
FAUCET_KEYCODE_3 = 30

ORDER_START_POS = 8
ORDER_PADDING = 44
ORDER_DELTA = 15
ORDER_OFF_SCREEN = 241

BACKGROUND_COLOR = 0

-- Single Order -> {{<color>, <percentage>}, <activity_flag>}
orders = { 
	{{2, 1}, pos = {168, 137}, target = {168, 8}}, 
	{{2, 0.5}, {4, 0.5}, pos = {168, 137 + 44}, target = {168, 52}},
	{{2, 0.5}, {4, 0.5}, pos = {168, 137 + 88}, target = {168, 96}},
	{{2, 0.5}, {4, 0.5}, pos = {168, 137}, target = {168, 137}},
	{{2, 0.5}, {4, 0.5}, pos = {168, 137}, target = {168, 137}}
}

completed_orders = {}
vertical_targets = { 8, 52, 96, 137 }

-- called at 60Hz by TIC-80
function TIC()
	update()
	draw()
end

-- updates
function update()
	frame_count = frame_count + 1
	if (CURR_STATE == states.MAIN_MENU) then
		if keyp(Z_KEYCODE) then
			update_state_machine(events.START_GAME)
		end
	elseif (CURR_STATE == states.LEVEL_ONE or CURR_STATE == states.LEVEL_TWO or CURR_STATE == states.LEVEL_THREE) then
		-- generateOrders() #TODO
		update_orders()
		update_mouse()
		update_flasks()
		handle_timeout()
		-- toRemove = checkCompleteOrder() #TODO -> returns index of completed task
		if keyp(1) then
			remove_order(1)
		end
	end
end

function update_state_machine(event)
	if event == events.MAIN_MENU then
		CURR_STATE = states.MAIN_MENU
	elseif event == events.START_GAME then
		CURR_STATE = states.LEVEL_ONE
	elseif event == events.NEXT_LEVEL then
		if CURR_STATE == states.LEVEL_ONE then
			CURR_STATE = states.LEVEL_TWO
		elseif CURR_STATE == states.LEVEL_TWO then
			CURR_STATE = states.LEVEL_THREE
		end		
	end
end

function update_mouse()
	mx, my, md = mouse()
	if not md then
		if selected ~= nil then
			mouse_up(flasks[get_flask_at(selected)])
		end
		selected = nil
	elseif selected == nil then
		slot = get_slot(mx)
		selected = slot
	elseif selected ~= nil then
		flask = flasks[get_flask_at(slot)]
		flask.center_x = mx
	end
end

function update_flasks()
	if key(FAUCET_KEYCODE_1) then
		fill_flask(flasks[get_flask_at(1)])
	end
	if key(FAUCET_KEYCODE_2) then
		fill_flask(flasks[get_flask_at(2)])
	end
	if key(FAUCET_KEYCODE_3) then
		fill_flask(flasks[get_flask_at(3)])
	end
end

function fill_flask(flask)
	cur_color = faucets[flask.cur_slot]

	if #flask.fill_order == 0 then
		table.insert(flask.fill_order, {cur_color, 0, 0})
	end

	if flask.fill_order[#flask.fill_order][1] == cur_color then
		-- same color as the previous, update previous entry
		flask.fill_order[#flask.fill_order][3] = flask.fill_order[#flask.fill_order][3] + 1;
	else
		-- different color as the previous, create new entry
		y = flask.fill_order[#flask.fill_order][3]
		table.insert(flask.fill_order, {cur_color, y, y + 1})
	end
end

function update_orders()
	for i = 1, #orders do
		orders[i].pos[1] = orders[i].pos[1] + (orders[i].target[1] - orders[i].pos[1]) / ORDER_DELTA
		orders[i].pos[2] = orders[i].pos[2] + (orders[i].target[2] - orders[i].pos[2]) / ORDER_DELTA
	end

	for i = 1, #completed_orders do
		completed_orders[i].pos[1] = completed_orders[i].pos[1] + (completed_orders[i].target[1] - completed_orders[i].pos[1]) / ORDER_DELTA
		completed_orders[i].pos[2] = completed_orders[i].pos[2] + (completed_orders[i].target[2] - completed_orders[i].pos[2]) / ORDER_DELTA
	end
end

function get_flask_at(slot)
	for i = 1, #flasks do
		if flasks[i].cur_slot == slot then return i end
	end
end

function get_slot(mx)
	for i = 1, #drop_slots do
		x0 = drop_slots[i][1]
		x1 = drop_slots[i][2]
		if mx >= x0 and mx <= x1 then return i end
	end
end

function mouse_up(flask)
	curr_diff = 240
	closest = 1
	for i=1, #drop_slots do
		temp_diff_lower_bound = math.abs(flask.center_x - drop_slots[i][1])
		temp_diff_upper_bound = math.abs(flask.center_x - drop_slots[i][2])
		if temp_diff_lower_bound < curr_diff then
			curr_diff = temp_diff_lower_bound
			closest = i
		elseif temp_diff_upper_bound < curr_diff then
			curr_diff = temp_diff_upper_bound
			closest = i
		end
	end

	-- swap stuff
	closest_flask = flasks[get_flask_at(closest)]
	closest_flask.cur_slot = flask.cur_slot
	closest_flask.center_x = (drop_slots[closest_flask.cur_slot][2] + drop_slots[closest_flask.cur_slot][1]) / 2
	flask.cur_slot = closest
	flask.center_x = (drop_slots[flask.cur_slot][2] + drop_slots[flask.cur_slot][1]) / 2
end

function handle_timeout()
	timeout = levels_metadata[CURR_STATE].time * CLOCK_FREQ
	if frame_count >= timeout then
		frame_count = 0
		next_level()
	end
end

function next_level()
	update_state_machine(events.NEXT_LEVEL)

	-- reset game world
	for i = 1, #flasks do
		flasks[i].fill_order = {}
	end
end

function remove_order(index)
		
	for i = #orders, index + 1, -1 do
		orders[i].target[2] = orders[i-1].target[2]
	end

	orders[index].target[1] = ORDER_OFF_SCREEN
	table.insert(completed_orders, orders[index])
	table.remove(orders, index)
end

-- draws
function draw()
	cls(BACKGROUND_COLOR)
	if (CURR_STATE == states.MAIN_MENU) then
		draw_main_menu()
	elseif (CURR_STATE == states.LEVEL_ONE or CURR_STATE == states.LEVEL_TWO or CURR_STATE == states.LEVEL_THREE) then
		draw_game()
	end
	rectb(160, 0, 80, 136, 6)
	rectb(0, 0, 240, 136, 5)
end

function draw_main_menu()
	print('HEAVENS KITCHEN', 30, 20, 7, false, 2, false)
	print('From the minds of BOB, MOUZI 2', 30, 42, 15, false, 1, true)
	print('and SPACEBAR', 30, 50, 15, false, 1, true)
	print('Press Z to start...', 30, 116, 7, false, 1, true)
end

function draw_game()
	draw_faucets()
	draw_flasks()
end

function draw_flasks()
	for i = 1, #flasks do
		draw_flask(flasks[i])
	end

	-- selected flask is always on top
	if selected ~= nil then
		selected_flask = flasks[get_flask_at(selected)]
		draw_flask(selected_flask)
	end
end

function draw_flask(flask)
	x = flask.center_x - FLASK_WIDTH / 2
	for i = 1, #flask.fill_order do
		color = flask.fill_order[i][1]
		y = SCREEN_HEIGHT - (flask.fill_order[i][3] + FLASK_OFFSET_Y)
		height = flask.fill_order[i][3] - flask.fill_order[i][2]
		rect(x + 9,	y, FLASK_WIDTH, height, color)
	end
	spr(10, flask.center_x - FLASK_WIDTH / 2, 45, 0, 3, 0, 0, 3, 4)
end

function draw_orders(orders)
	-- Orders are 8px from the edges
	-- Orders are spaced 12px between each other
	-- Orders are 32px by 16px and scaled by 2

	for i=1, math.min(#orders, 4) do
		spr(32, orders[i].pos[1], orders[i].pos[2], 0, 2, 0, 0, 4, 2) -- Top order
		--Draw order elements
		print(orders[i][1][2], orders[i].pos[1]+16, orders[i].pos[2] + 16)
	end

	for i=1, #completed_orders do
		spr(32, completed_orders[i].pos[1], completed_orders[i].pos[2], 0, 2, 0, 0, 4, 2) -- Top order
		--Draw order elements
		print(completed_orders[i][1][2], completed_orders[i].pos[1]+16, completed_orders[i].pos[2] + 16)
	end

end

function draw_faucets()
	if CURR_STATE == states.LEVEL_ONE then
		width = drop_slots[1][2] - drop_slots[1][1]

		-- draw red faucet 
		pos_red_x = (drop_slots[1][1] + drop_slots[1][2])/2 - width/2
		spr(2,pos_red_x,5,0,3,0,0,2,2)

		-- draw blue faucet
		pos_blue_x = (drop_slots[2][1] + drop_slots[2][2])/2 - width/2
		spr(4,pos_blue_x,5,0,3,0,0,2,2)

		-- draw out of order faucet
		pos_outoforder_x = (drop_slots[3][1] + drop_slots[3][2])/2 - width/2
		spr(8,pos_outoforder_x,5,0,3,0,0,2,2)
	else  
		width = drop_slots[1][2] - drop_slots[1][1]

		-- draw red faucet 
		pos_red_x = (drop_slots[1][1] + drop_slots[1][2])/2 - width/2
		spr(2,pos_red_x,5,0,3,0,0,2,2)

		-- draw blue faucet
		pos_blue_x = (drop_slots[2][1] + drop_slots[2][2])/2 - width/2
		spr(4,pos_blue_x,5,0,3,0,0,2,2)

		-- draw green faucet
		pos_outoforder_x = (drop_slots[3][1] + drop_slots[3][2])/2 - width/2
		spr(6,pos_outoforder_x,5,0,3,0,0,2,2)
	end
end

-- init
function init()
	update_state_machine(events.MAIN_MENU)
	draw_main_menu()
end
init()

-- <TILES>
-- 002:0033333100313111003111120011312200311222001122cc0012222200122222
-- 003:1111110011111100211111002211110022211100cc22110022222f0022222f00
-- 004:8888888808888888088999990089999c0089999900899c9900899c9900899c99
-- 005:888888888888888099999800c99998009999980099c9980099c9980099c99800
-- 006:0000555500056566000566660005666c0055666c00566ccc00566ccc0066666c
-- 007:666600006666700066667000c6667000c6666700ccc67700ccc66700c6667700
-- 008:00eeeeee00eeeee200eee42200ee442400444224044442440444424403442234
-- 009:ee44443022443430422443404424443014224340144243404442344014411330
-- 010:0000000000c0000000c0000000c0c00000c0c00000c0000000c0c00000c00000
-- 011:0000000000000c0000000c0000000c0000000d0000000d0000000c0000000d00
-- 018:001122cc0011122200000022000000e2000000df0000000e0000000000000000
-- 019:cc22ff00222fff00220000002f000000ff000000f00000000000000000000000
-- 020:008999990089999c00099999000000ff000000ff0000000d0000000000000000
-- 021:99999800c999980099999000ff000000ff000000e00000000000000000000000
-- 022:0056666c006666660007666600007777000000ff0000000d0000000000000000
-- 023:c6666700666677006667700077770000ff000000e00000000000000000000000
-- 024:04442444044222210344344300334333000333ff0000000d0000000000000000
-- 025:44431330211113303333300033f00000ff000000f00000000000000000000000
-- 026:00d0000000d0000000c0000000d0000000d0000000c0000000d0000000d00000
-- 027:00000d0000000d0000000d0000000d0000000d00000c0d00000c0e00000c0d00
-- 042:00d0000000d0000000c0000000d0000000d0000000d0000000d0000000d00000
-- 043:00000d0000000e0000000e0000000d0000000e0000000e0000000e0000000e00
-- 058:00d0000000d00c0000d0000000dde000000ede000000eeee0000000000000000
-- 059:000c0e00000c0e0000c00e000000de0000dee000eeee00000000000000000000
-- </TILES>

-- <SPRITES>
-- 002:00000000000000000000cccc000ccccc00cccccc00cccccc000cccdc000cccdd
-- 003:0000000000000000c0000000cc000000cccc0000cccd0000cccd0000dddd0000
-- 018:0000cccc0000cccc0000cccc0000ccdc0000dddd000000000044444404400000
-- 019:cdd00000dd000000cd000000dd000000dd000000000000004440000000440000
-- 034:044000000044000000044444000cdddc00cdd4dd0ccd44440dd44444cdeee4ee
-- 035:000400000044000044400000d0000000ddd000004ddd000044de0000e4de0000
-- 049:0000000000000000000000000000000d0000000c000000cc00000ccc00000ccd
-- 050:cd494449cd444444cdd44444ccddddddddd44444ccd44d44ddddddddecddeded
-- 051:44eee00044ede000444ee000ddede000ddeee000dedeee00deeeee00edeeeee0
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:66666666767b777748488889999aaaab
-- 004:ffffe1100000bccddccb1100000effff
-- 005:777777777777777789ab777777777777
-- 006:012345689bcdeffffffedcb986543210
-- 008:01348acefeddddddca86332233332100
-- </WAVES>

-- <SFX>
-- 000:fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00fb00400000000000
-- 001:070047007700a700e700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700700000000000
-- 002:06f026c036b046a05690667066607650864096209610a600a600b600b600c600d600d600e600e600f600f600f600f600f600f600f600f600f600f600100000000000
-- 003:16006600d600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600600000000000
-- 004:525062408230a220c210e200f20002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200480000070800
-- 005:060016002600360036004600460056005600660076007600860096009600a600b600c600c600d600e600f600f600f600f600f600f600f600f600f6006e0000000000
-- 006:0700470077009700b700d700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700770000000000
-- 007:0600160026002600360036004600560056006600760086008600960096009600a600b600b600c600c600d600e600e600f600f600f600f600f600f600200000000000
-- 008:040034004400640074009400a400b400d400e400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400409000000000
-- 009:04000400140014002400240034003400440044005400540064006400740074008400840094009400a400a400b400b400c400c400d400d400e400f400300000000000
-- 010:080008c008c0080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800400000000400
-- 011:0800180028002800380038004800480058006800680078007800780088008800880098009800a800a800b800c800c800d800d800e800e800e800f800400000000000
-- 012:050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500402000000000
-- 019:050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500404000000000
-- 050:090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900102000000000
-- </SFX>

-- <PATTERNS>
-- 000:40001800000000000000000040001800001000001000000040001800001040006a00000040001800001000001000000040001800001000001000000040001800001040006a00000040001800000000000000000040001800000000000000000040001800000040006a000000400018000000000000000000400018000000000000000010400018000000000000000000400018000000000000000000400018000000000000000000400018000000000000000000400018000000000000000000
-- 001:40005a000050000050000000b0005a00000000000000000080005a00000000000000000060005a000000000000000000a0005a000000000000000000d0005a00000000000000000080005a00000000000000000060005a000000000000000000a0005a00000000000000000050005a00000000000000000050005a000000000000000000b0005a00000000000000000040005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:80005a000000000000000000000000000000000000000000000000000000000000000000a0005a000000000000000000000000000000000000000000000000000000000000000000b0005a00000000000000000000000000000000000000000000000000000000000000000080005a00000000000000000000000000000000000000000000000000000000000000000080005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:40005c000000000000000000000000000000000000000000000000000000000000000000d0005a000000000000000000000000000000000000000000000000000000000000000000f0005a000000000000000000000000000000000000000000000000000000000000000000f0005a000000000000000000000000000000000000000000000000000000000000000000f0005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:400058000000800058000000400058000000800058000000400058000000800058000000b0005800000060005a000000b0005800000060005a000000b0005800000060005a00000080005a000000b0005800000080005a000000b0005800000080005a000000b00058000000500058000000c00058000000500058000000c00058000000500058000000c00058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:b00058000000000000000000b00058000000000000000000b00058000000000000000000d00058000000000000000000d00058000000000000000000d00058000000000000000000b0005a000000000000000000b0005a000000000000000000b0005a00000000000000000080005a00000000000000000080005a00000000000000000080005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:f00058000000000000000000f00058000000000000000000f00058000000000000000000a0005a000000000000000000a0005a000000000000000000a0005a000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:400074000000b00074f00074400076000000000000600076000000400076000000000000600074000000a00074d00074600076000000000000800076000000a00076000000000000800076000000f00076b00076a00076000000000000a00076000000800076000000000000500076000000800076c00076500078000000000000a00076000000800076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:400086400086000000700086000000000000e00086000000400088000000000000000000000000000000000000000000b00086000000000000000000000000000000000000000000b00086000000000000000000000000000000000000000000700088000000600088400088000000000000e00086000000400088000000000000000000400088000000700088b00088400088000000000000000000000000000000000000000000400086000000000000000000000000000000000000000000
-- 009:b00086000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700086000000000000000000000000000000000000000000d00086000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600088000000000000000000000000000000000000000000700088000000000000000000000000000000000000000000
-- 010:e00086000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0008600000000000000000000000000000000000000000040008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090008a000000000000000000000000000000000000000000d00088000000000000000000000000000000000000000000
-- 011:40006200000000000040001440006200000040006a40001440006200000040001400000040006200000000000040001440006200000040001400000040006200000000000040001440006240006a40001400000040006240006a00000040001440006200000040001400000040006200000000000040001440006240006a40001400000040006240006a00000040001440006200000040001400000040006240006a40006c40001440006200000040001440006a40006240006c40006c400014
-- 012:b00074e00074f00074400076000000000000b00076400076e00074000000000000000000b00074a00074900074000000000000000000700074400074700074000000000000000000700074900074a00074400076000000000000b00076400076e00074000000000000000000b00074a00074900074000000000000000000700074400074700074000000000000000000700074900074a00074400076000000000000b00076400076e00074000000000000000000b00074a00074900074000000
-- 013:0000000000000000007221a80000000000009220a80000006220a80000000000000000004220a80000000000007220a80000000000004220a8000000a220a8000000000000000000b220a80000007220a80000000000000000000000000000006220a80000000000000000000000000000004220a8000000000000000000000000000000a000aa000000000000000000b000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:0000000000000000004221aa000000000000b000aa0000009000aa0000000000000000006000aa0000000000007000aa000000000000b000a80000006000a8000000000000000000b000a80000004000a80000000000000000000000000000004000aa0000000000000000000000000000007000aa000000000000000000000000000000a000aa000000000000000000f000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:000000000000000000400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014400062000000400014000000000000400014400062000000400014400014
-- 016:400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014400062000000400014000000000000400014400062000000400014400014000000400014000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:400076000000000000b00076400076e00074000000000000000000b00074a00074900074000000000000000000700074400074700074000000000000000000700074900074a00074400076000000000000b00076400076e00074000000000000000000b00074a00074900074000000000000000000700074400074700074000000000000000000700074900074a00074700074900074a00074400076000000000000b00076400076e00074000000000000000000b00074a00074900074000000
-- 018:788188000000700088000000000000000000700088000000700088000000000000700088000000400086a00086900086000000400086900086000000000000b000860000007256b80000000000000000000000000000006000b80000000000000000000000000000004000b8000000000000000000000000000000a000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:b88188000000b00088000000000000000000e00086000000e00086000000000000d000860000000000000000000000000000000000000000000000000000000000000000004256ba0000000000000000000000000000006250ba0000000000000000000000000000007250ba000000000000000000000000000000a000ba000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:4000b80000000000000000000000009000b80000000000000000000000000000004000b80000000000000000000000000000009000b80000000000000000000000000000000000004000b80000000000000000000000006000ba0000000000000000000000000000004000b8000000000000000000000000000000b000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:8110b80000000000000000000000007720b8000000000000000000006000000000b000b8000000000000000000000000000000c000b80000000000000000004000ba9000ba0000008000ba000000000000000000000000b000ba0000000000000000000000000000007000ba000000000000000000000000000000f000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:b034c89000c87000c89000c87000c86000c87000c86000c84000c86000c84000c8e000c6d000c6000000000000b000c8e000c8d000c8000000000000000000b000c8e000c80000004000ca0000000000007000c6b000c6e000c60000000000000000004000c6b000c6d000c60000000000000000004000c67000c69000c60000000000000000004000c67000c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:4124ba0000000000000000000000007000ba0000000000000000009000b8000000000000000000000000d000b80000000000000000007000b8000000000000b000b8000000000000e000b8000000000000e000b8000000000000e000b8000000000000e000b80000000000009000b80000000000009000b80000000000009000b80000000000007000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:400014000000400014000000000000400014400014000000400014000000000000000000400014000000400014000000000000400014400014000000400014000000000000000000400014000000400014000000000000400014400014000000400014000000000000000000400014000000400014000000000000400014400014000000400014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:70007a40007a70007ab0007a70007a40007a70007a40007a70007ab0007a70007a40007a60007af0007860007ab0007a60007af0007860007af0007860007ab0007a60007af00078c00078900078c0007840007ac00078900078c00078900078c0007840007ac00078900078b00078700078b0007840007ab0007870007860007af0007860007ab0007a60007af00078000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 026:700088000000700088000000700088000000700088000000700088000000000000000000f00088000000f00088000000f00088000000f00088000000f00088000000000000000000c00088000000c00088000000c00088000000c00088000000c00088000000000000000000700088000000700088000000700088000000b00088000000f00088000000b0008a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:406484400084400084400084400084400084400084400084400084900086900086900086b00086b00086b00086b00086b00086b00086b00086b00086b00086c00086c00086c00086900086900086900086900086900086900086900086900086900086400084400084400084700084710084700084700084700084b00084600084600084600084600084600084600084000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:0416c18416c10000000000000000000000000000000000000000000000000000000000000000000000000000000000006a0100
-- 001:042ac2c42ac20000000000000000000000000000000000000000000000000000000000000000000000000000000000002e0000
-- 002:194000194315194315194710194716194595194595996000996b10996b16196b16196b17196b17000000000000000000ec0100
-- </TRACKS>

-- <FLAGS>
-- 000:00000000ffff0000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

