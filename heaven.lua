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
	["level_one"] = { ["time"] = 15 },
	["level_two"] = { ["time"] = 15 },
	["level_three"] = { ["time"] = 15 }
}

flask1 = {
	center_x = 24, -- center x
	fill_order = {}, -- order of fill like e.g. [(red, 0, 30), (blue, 30, 35), (yellow, 35, 100)]
	cur_slot = 1, -- current slot the flask is placed in
}

flask2 = {
	center_x = 74,
	fill_order = {},
	cur_slot = 2,
}

flask3 = {
	center_x = 124,
	fill_order = {}, 
	cur_slot = 3,
}

orders = {
	{
		color = 2,
		percentage = 0.5
	},
	{
		color = 9,
		percentage = 0.5
	}
}

score = 0 -- total score of the player

flasks = { flask1, flask2, flask3 } -- not ordered

faucets = { 2, 9, 5 } -- red, yellow, blue faucets

drop_slots = { {6, 42}, {56, 92}, {106, 142} } -- ranges of the drop slots

selected = nil -- selected flask to drag

frame_count = 0 -- count of elapsed frames

-- constants
SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136
CLOCK_FREQ = 60 --Hz

CURR_STATE = states.MAIN_MENU

FLASK_WIDTH = 36
FLASK_OFFSET_Y = 4
FLASK_HEIGHT = 84

Z_KEYCODE = 26
FAUCET_KEYCODE_1 = 28
FAUCET_KEYCODE_2 = 29
FAUCET_KEYCODE_3 = 30

ORDER_START_POS = 8
ORDER_PADDING = 44
ORDER_DELTA = 15
ORDER_OFF_SCREEN = 241
FILL_RATE = 3

BACKGROUND_COLOR = 0

STREAM_WIDTH = 6
MAX_NUMBER_OF_PARTICLES = 300

-- Single Order -> {{<color>, <percentage>}, <activity_flag>}
orders = { 
	{content = {{2, 1}}, pos = {168, 137}, target = {168, 8}}, 
	{content = {{2, 0.5}, {4, 0.5}}, pos = {168, 137 + 44}, target = {168, 52}},
	{content = {{2, 0.5}, {4, 0.5}}, pos = {168, 137 + 88}, target = {168, 96}},
	{content = {{2, 0.5}, {4, 0.5}}, pos = {168, 137}, target = {168, 137}},
	{content = {{2, 0.5}, {4, 0.5}}, pos = {168, 137}, target = {168, 137}}
}

completed_orders = {}
vertical_targets = { 8, 52, 96, 137 }

-- called at 60Hz by TIC-80
function TIC()
	update()
	draw()

	-- TODO: remove debug slot lines and center
	-- for i = 1, #drop_slots do
	-- 	l = drop_slots[i][1]
	-- 	r = drop_slots[i][2]
	-- 	line(l, 0, l, 135, 5)
	-- 	line(r, 0, r, 135, 5)
	-- end

	-- for i = 1, #flasks do
	-- 	x = flasks[i].center_x
	-- 	line(x, 0, x, 135, 10)
	-- end
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
		level_timer()
		update_orders()
		update_mouse()
		update_flasks()
		update_streams()
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

function level_timer()
end


function update_flasks()
	if key(FAUCET_KEYCODE_1) and selected ~= 1 then
		fill_flask(flasks[get_flask_at(1)])
	end
	if key(FAUCET_KEYCODE_2) and selected ~= 2 then
		fill_flask(flasks[get_flask_at(2)])
	end
	if key(FAUCET_KEYCODE_3) and selected ~= 3 then
		fill_flask(flasks[get_flask_at(3)])
	end
end

function update_streams() 
	for i = 1, #particles_red do 

	end
end

function fill_flask(flask)
	cur_color = faucets[flask.cur_slot]

	if #flask.fill_order == 0 then
		table.insert(flask.fill_order, {cur_color, 0, 0})
	end

	if flask.fill_order[#flask.fill_order][1] == cur_color then
		-- same color as the previous, update previous entry
		flask.fill_order[#flask.fill_order][3] = flask.fill_order[#flask.fill_order][3] + 0.1 * FILL_RATE;
	else
		-- different color as the previous, create new entry
		y = flask.fill_order[#flask.fill_order][3]
		table.insert(flask.fill_order, {cur_color, y, y + 0.1 * FILL_RATE})
	end

	check_if_flask_full(flask)
end

function check_if_flask_full(flask)
	sum = 0
	for i=1, #flask.fill_order do
		sum = sum + flask.fill_order[i][3] - flask.fill_order[i][2]
	end
	if sum >= FLASK_HEIGHT then
		local score = calculate_score(flask.fill_order)
		flask.fill_order = {}
	end
	print(score, 0, 0, 6)
end

function calculate_score(fill_order)
	total = 85
	if #orders ~= #fill_order then
		return 0
	end
	for i=1, #orders do
		if orders[i].color == fill_order[i][1] then
			local diff = math.abs((orders[i].percentage * FLASK_HEIGHT) - (fill_order[i][3] - fill_order[i][2]))
			if diff ~= 0 then
				score = math.floor(40 / diff)
			else
				score = 40
			end
		else
			score = 0
		end
	end
	return score
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
	closest = get_closest_slot(flask.center_x)
	closest_flask = flasks[get_flask_at(closest)]
	closest_flask.cur_slot = flask.cur_slot
	closest_flask.center_x = (drop_slots[closest_flask.cur_slot][2] + drop_slots[closest_flask.cur_slot][1]) / 2
	flask.cur_slot = closest
	flask.center_x = (drop_slots[flask.cur_slot][2] + drop_slots[flask.cur_slot][1]) / 2
end

function get_closest_slot(x)
	positions = { 
		drop_slots[1][1], drop_slots[1][2], 
		drop_slots[2][1], drop_slots[2][2], 
		drop_slots[3][1], drop_slots[3][2] 
	}
	positions = map(function(a) return math.abs(x - a) end, positions)
	idx = min_i(positions)
	return math.ceil(idx / 2) 
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
	draw_orders()
	draw_timer()
	draw_streams()
end

-- particles are simple objects that have four components:
-- position, velocity, color and time-to-live
particles_red = {}
particles_green = {}
particles_blue = {}

function draw_streams()
	if key(FAUCET_KEYCODE_1) then
		draw_stream(1)
	end
	if key(FAUCET_KEYCODE_2) then
		draw_stream(2)
	end
	if key(FAUCET_KEYCODE_3) then
		draw_stream(3)
	end

	draw_particles()
end

function draw_stream(slot)
	cur_color = faucets[slot]
	center_stream = (drop_slots[slot][1] + drop_slots[slot][2]) / 2 + 2
	targetFlask = flasks[get_flask_at(slot)]
	length = #targetFlask.fill_order

	-- draw main stream
	for i = 1, STREAM_WIDTH do 
		pos_x = center_stream + STREAM_WIDTH / 2 + i
		if length > 0 then
			line(pos_x, 47, pos_x, 131 - targetFlask.fill_order[length][3], cur_color+1)
		end
	end

	-- draw foam
	
	-- draw bubbles
end

function draw_particles()
	for i = 1, #particles_red do 
		--particles_red.pos[1]
		pix(particles_red.pos[1], particles_red.pos[2], particles_red.color)
	end

	for i = 1, #particles_green do 
		pix(particles_green.pos[1], particles_green.pos[2], particles_green.color)
	end

	for i = 1, #particles_blue do 
		pix(particles_blue.pos[1], particles_blue.pos[2], particles_blue.color)
	end
end

function draw_timer()
	rect(42, 5, 155, 7, 4)
	rectb(42, 5, 155, 7, 4)
	print("Time Left", 100, 6, 0, false, 1, false)
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
		rect(x + 3,	y, FLASK_WIDTH - 6, height, color)
	end
	spr(10, flask.center_x - FLASK_WIDTH / 2 - 6, 45, 0, 3, 0, 0, 2, 4)
end

function draw_orders()
	-- Orders are 8px from the edges
	-- Orders are spaced 12px between each other
	-- Orders are 32px by 16px and scaled by 2

	for i=1, math.min(#orders, 4) do
		spr(12, orders[i].pos[1], orders[i].pos[2], 0, 2, 0, 0, 4, 2) -- Top order
		--Draw order elements
		print(orders[i].content[1][2], orders[i].pos[1]+16, orders[i].pos[2] + 16)
	end

	for i=1, #completed_orders do
		spr(12, completed_orders[i].pos[1], completed_orders[i].pos[2], 0, 2, 0, 0, 4, 2) -- Top order
		--Draw order elements
		print(completed_orders[i].content[1][2], completed_orders[i].pos[1]+16, completed_orders[i].pos[2] + 16)
	end

end

function draw_faucets()
	if CURR_STATE == states.LEVEL_ONE then
		width = drop_slots[1][2] - drop_slots[1][1]

		-- draw red faucet 
		pos_red_x = (drop_slots[1][1] + drop_slots[1][2])/2 - width/2
		spr(2,pos_red_x - 6, 5, 0, 3, 0, 0, 2, 2)

		-- draw blue faucet
		pos_blue_x = (drop_slots[2][1] + drop_slots[2][2])/2 - width/2
		spr(4,pos_blue_x - 6, 5, 0, 3, 0, 0, 2, 2)

		-- draw out of order faucet
		pos_outoforder_x = (drop_slots[3][1] + drop_slots[3][2])/2 - width/2
		spr(8,pos_outoforder_x - 6, 5, 0, 3, 0, 0, 2, 2)
	else  
		width = drop_slots[1][2] - drop_slots[1][1]

		-- draw red faucet 
		pos_red_x = (drop_slots[1][1] + drop_slots[1][2])/2 - width/2
		spr(2,pos_red_x - 6, 5, 0, 3, 0, 0, 2, 2)

		-- draw blue faucet
		pos_blue_x = (drop_slots[2][1] + drop_slots[2][2])/2 - width/2
		spr(4,pos_blue_x - 6, 5, 0, 3, 0, 0, 2, 2)

		-- draw green faucet
		pos_outoforder_x = (drop_slots[3][1] + drop_slots[3][2])/2 - width/2
		spr(6, pos_outoforder_x - 6, 5, 0, 3, 0, 0, 2, 2)
	end
end

-- utils
function map(func, tbl)
	local newtbl = {}
	for i, v in pairs(tbl) do
		newtbl[i] = func(v)
	end
	return newtbl
end

-- Does not work for empty tables
function min(tbl)
	return tbl[min_i(tbl)]
end

-- Does not work for empty tables
function min_i(tbl)
	local idx, min = 1, tbl[1]
	for i = 1, #tbl do
		if tbl[i] < min then 
			idx = i
			min = tbl[i] 
		end
	end
	return idx
end

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
-- 012:0888888888cccccc8ccccccc8ccccccc8ccccccc8ccccccc8ccccccc8ccccccc
-- 013:88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 014:88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 015:88888880cccccc88ccccccc8ccccccc8ccccccc8ccccccc8ccccccc8ccccccc8
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
-- 028:8ccccccc8ccccccc8ccccccc8ccccccc88cccccc088888880000000000000000
-- 029:cccccccccccccccccccccccccccccccccccccccc888888880000000000000000
-- 030:cccccccccccccccccccccccccccccccccccccccc888888880000000000000000
-- 031:ccccccc8ccccccc8ccccccc8ccccccc8cccccc88888ccc800088c88000088800
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

