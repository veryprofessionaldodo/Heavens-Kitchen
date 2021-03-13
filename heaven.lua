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
	["level_one"] = { ["time"] = 5 },
	["level_two"] = { ["time"] = 2 },
	["level_three"] = { ["time"] = 5 }
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

BACKGROUND_COLOR = 0
--

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
		update_mouse()
		update_flasks()
		handle_timeout()
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

	-- other code like reseting flasks and orders
end

-- draws
function draw()
	cls(BACKGROUND_COLOR)
	if (CURR_STATE == states.MAIN_MENU) then
		draw_main_menu()
	elseif (CURR_STATE == states.LEVEL_ONE or CURR_STATE == states.LEVEL_TWO or CURR_STATE == states.LEVEL_THREE) then
		draw_game()
	end
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
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <FLAGS>
-- 000:00000000ffff0000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

