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
	["level_one"] = { ["time"] = 50 },
	["level_two"] = { ["time"] = 50 },
	["level_three"] = { ["time"] = 50 }
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

total_score = 0 -- total score of the player

flasks = { flask1, flask2, flask3 } -- not ordered

faucets = { 2, 9, 5 } -- red, yellow, blue faucets

drop_slots = { {6, 42}, {56, 92}, {106, 142} } -- ranges of the drop slots

selected = nil -- selected flask to drag

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
FILL_RATE = 0.2

BACKGROUND_COLOR = 0

STREAM_WIDTH = 4
MAX_NUMBER_OF_PARTICLES = 600
PARTICLE_SPEED = 5
BUBBLES_GRAVITY = 0.1

FRAME_COUNTER = 0
RECT_LENGTH = 155
TIMER_LENGTH = 155

-- Single Order -> {{<color>, <percentage>}, <activity_flag>}
orders = {}

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
	FRAME_COUNTER = FRAME_COUNTER + 1
	if (CURR_STATE == states.MAIN_MENU) then
		if keyp(Z_KEYCODE) then
			update_state_machine(events.START_GAME)
		end
	elseif (CURR_STATE == states.LEVEL_ONE or CURR_STATE == states.LEVEL_TWO or CURR_STATE == states.LEVEL_THREE) then
		update_orders()
		update_mouse()
		update_flasks()
		update_streams()
		handle_timeout()
		-- toRemove = checkCompleteOrder() #TODO -> returns index of completed task
		if keyp(1) and #orders ~= 0 then
			remove_order(math.random(1, math.min(3, #orders)))
		end
	end
end

function update_state_machine(event)
	if event == events.MAIN_MENU then
		CURR_STATE = states.MAIN_MENU
	elseif event == events.START_GAME then
		CURR_STATE = states.LEVEL_ONE
		setup_level()
	elseif event == events.NEXT_LEVEL then
		if CURR_STATE == states.LEVEL_ONE then
			CURR_STATE = states.LEVEL_TWO
			setup_level()
		elseif CURR_STATE == states.LEVEL_TWO then
			CURR_STATE = states.LEVEL_THREE
			setup_level()
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
	if key(FAUCET_KEYCODE_1) and selected ~= 1 then
		--add particles
		center_stream = (drop_slots[1][1] + drop_slots[1][2]) / 2 - 2

		generate_particles(center_stream, particles_red, 3)
	end
	if key(FAUCET_KEYCODE_2) and selected ~= 2 then
		center_stream = (drop_slots[2][1] + drop_slots[2][2]) / 2 - 2

		generate_particles(center_stream, particles_blue, 10)
	end
	if key(FAUCET_KEYCODE_3) and selected ~= 3 then
		center_stream = (drop_slots[3][1] + drop_slots[3][2]) / 2 - 2

		generate_particles(center_stream, particles_green, 6)
	end
end

function generate_particles(center, particles, particle_color)
	-- draw main stream
	for i = 1, 25 do 
		pos_x = center + STREAM_WIDTH / 2 + math.random(-STREAM_WIDTH / 2, STREAM_WIDTH / 2)
		pos_y = math.random(43,45)
		particle = {pos = {pos_x, pos_y}, color=particle_color, velocity={randomFloat(-0.1,0.1), randomFloat(PARTICLE_SPEED-2,PARTICLE_SPEED+2)}, size = randomFloat(1,3), time_to_live=randomFloat(20,40)}
		if #particles < MAX_NUMBER_OF_PARTICLES then
			table.insert(particles, particle)
		end
	end
end

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end


function update_streams() 
	red_flask = flasks[get_flask_at(1)]
	update_stream(particles_red, red_flask)
	
	blue_flask = flasks[get_flask_at(2)]
	update_stream(particles_blue, blue_flask)
	
	green_flask = flasks[get_flask_at(3)]
	update_stream(particles_green, green_flask)
end

function update_stream(particles, flask)
	height = 131
	order_length = #flask.fill_order

	if order_length > 0 then
		height = 131 - flask.fill_order[order_length][3]
	end

	i = 1
	while i <= #particles do 
		update_particle(particles[i], flask, height)

		if particles[i].time_to_live <= 0 then 
			table.remove(particles, i)
		else 
			i = i + 1
		end
	end
end

function update_particle(particle, flask, height) 
	if particle.color ~= 12 then
		particle.velocity[1] = particle.velocity[1] + randomFloat(-0.01,0.01)
		particle.size = math.max(math.min(particle.size + randomFloat(-0.4,0.3), 5),1)
	else 
		-- has turned to foam
		particle.size = math.max(math.min(particle.size + randomFloat(-0.4,0.3), 2),0)
		particle.velocity[2] = particle.velocity[2] - BUBBLES_GRAVITY
		if particle.velocity[1] > 0 then
			particle.velocity[1] = particle.velocity[1] - randomFloat(0.1,0.2)
		else 
			particle.velocity[1] = particle.velocity[1] + randomFloat(0.1,0.2)
		end
	end
	
	-- update properties
	particle.time_to_live = particle.time_to_live - 1
	particle.pos[1] = particle.pos[1] + particle.velocity[1]
	particle.pos[2] = particle.pos[2] + particle.velocity[2]

	-- check if particle has reached stream
	if particle.pos[2] > height and particle.color ~= 12 then
		particle.pos[2] = particle.pos[2] - 0.5
		particle.color = 12
		particle.velocity[1] = randomFloat(-2,2)
		particle.velocity[2] = randomFloat(PARTICLE_SPEED / 6 - 1, PARTICLE_SPEED / 6 + 1)
		fill_flask(flask)
	elseif particle.pos[2] < height and particle.color == 12 then
		particle.time_to_live = 0
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
		total_score = total_score + score
		flask.fill_order = {}
	end
end

function calculate_score(fill_order)
	local best_score = 0
	local best_score_index = nil
	if fill_order == nil then
		return 0
	end
	for i=1, #orders do
		for j=1, #orders[i].content do
			if #fill_order ~= #orders[i].content then
				score = 0
			elseif orders[i].content[j][1] == fill_order[j][1] then
				local diff = math.ceil(math.abs((orders[i].content[j][2] * FLASK_HEIGHT) - (fill_order[j][3] - fill_order[j][2])))
				if diff ~= 0 then
					score = math.floor(40 / diff)
					if best_score < score then
						best_score = score
						best_score_index = i
					end
				else
					if best_score < score then
						best_score = score
						best_score_index = i
					end
				end
			else
				score = 0
			end
		end
	end
	if best_score_index ~= nil then
		remove_order(best_score_index)
	end
	return best_score
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

	TIMER_DECREMENT = RECT_LENGTH / levels_metadata[CURR_STATE].time
	if((FRAME_COUNTER % CLOCK_FREQ) == 0) then
		TIMER_LENGTH = TIMER_LENGTH - TIMER_DECREMENT
	end

	if FRAME_COUNTER >= timeout then
		FRAME_COUNTER = 0
		update_state_machine(events.NEXT_LEVEL)
	end
end

function setup_level()
	TIMER_LENGTH = RECT_LENGTH

	-- empty flasks
	for i = 1, #flasks do
		flasks[i].fill_order = {}
	end

	-- generate orders for next level
	if CURR_STATE == states.LEVEL_ONE then
		orders = generate_orders(20, 2, {faucets[1], faucets[2]}, {0.25, 0.50, 0.75, 1})
	elseif CURR_STATE == states.LEVEL_TWO then
		orders = generate_orders(20, 3, faucets, {0.15, 0.25, 0.50, 0.75, 0.85, 1})
	elseif CURR_STATE == states.LEVEL_THREE then
		orders = generate_orders(20, 3, faucets, {0.15, 0.25, 0.35, 0.50, 0.65, 0.75, 0.85, 1})
	end
end

function generate_orders(norders, max_steps, faucets, percentages)
	-- orders
	local orders = {}
	for o = 1, norders do
		pos = {168, 137 + (o - 1) * ORDER_PADDING }
		target = { 168, vertical_targets[o] or 137 }
		
		-- what a mess lol 
		-- generate first pair (color, p)
		ps = { percentages[math.random(1, #percentages)] }
		colors = { faucets[math.random(1, #faucets)] }

		-- if first p1 is less than 1, generate another one
		-- generate also another color, different from the last
		if ps[1] < 1.0 and max_steps > 1 then
			p2 = percentages[math.random(1, #percentages)]
			while p2 + ps[1] > 1.0 do
				p2 = percentages[math.random(1, #percentages)]
			end
			table.insert(ps, p2)
			
			color = faucets[math.random(1, #faucets)]
			while color == colors[1] do
				color = faucets[math.random(1, #faucets)]
			end
			table.insert(colors, color)
		end

		-- if first p1 + p2 is still less than 1, generate another one
		-- generate also another color, different from the last
		if ps[1] < 1.0 and ps[1] + ps[2] < 1.0 and max_steps > 2 then
			table.insert(ps, 1 - math.ceil(ps[1] + ps[2]))
			
			color = faucets[math.random(1, #faucets)]
			while color == colors[2] do
				color = faucets[math.random(1, #faucets)]
			end
			table.insert(colors, color)
		end

		content = {}
		for i = 1, #ps do
			table.insert(content, { colors[i], ps[i] })
		end

		table.insert(orders, { content = content, pos = pos, target = target })
	end
	return orders
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
end

function draw_main_menu()
	print('HEAVENS KITCHEN', 30, 20, 7, false, 2, false)
	print('From the minds of BOB, MOUZI 2', 30, 42, 15, false, 1, true)
	print('and SPACEBAR', 30, 50, 15, false, 1, true)
	print('Press Z to start...', 30, 116, 7, false, 1, true)
end

function draw_game()
	draw_flasks_fluid()
	draw_particles()
	draw_flasks_containers()
	draw_faucets()
	draw_orders()
	draw_timer()
	print(total_score, 64, 64, 4)
end

-- particles are simple objects that have five components:
-- position, velocity, color time-to-live, and size
particles_red = {}
particles_green = {}
particles_blue = {}

function draw_particles()
	for i = 1, #particles_red do 
		--particles_red.pos[1]
		rect(particles_red[i].pos[1], particles_red[i].pos[2], math.floor(particles_red[i].size), math.floor(particles_red[i].size), particles_red[i].color)
	end

	for i = 1, #particles_green do 
		rect(particles_green[i].pos[1], particles_green[i].pos[2], math.floor(particles_green[i].size), math.floor(particles_green[i].size), particles_green[i].color)
	end

	for i = 1, #particles_blue do 
		rect(particles_blue[i].pos[1], particles_blue[i].pos[2], math.floor(particles_blue[i].size), math.floor(particles_blue[i].size), particles_blue[i].color)
	end
end

function draw_timer()
	rect(42, 5, 155, 7, 3)
	rect(42, 5, TIMER_LENGTH, 7, 4)
	rectb(42, 5, 155, 7, 4)
	print("Time Left", 100, 6, 0, false, 1, false)
end

function draw_flasks_containers() 
	for i = 1, #flasks do
		spr(10, flasks[i].center_x - FLASK_WIDTH / 2 - 6, 45, 0, 3, 0, 0, 2, 4)
	end

	-- selected flask is always on top
	if selected ~= nil then
		selected_flask = flasks[get_flask_at(selected)]
		spr(10, selected_flask.center_x - FLASK_WIDTH / 2 - 6, 45, 0, 3, 0, 0, 2, 4)
	end
end

function draw_flasks_fluid()
	for i = 1, #flasks do
		draw_flask_fluid(flasks[i])
	end

	-- selected flask is always on top
	if selected ~= nil then
		selected_flask = flasks[get_flask_at(selected)]
		draw_flask_fluid(selected_flask)
	end
end

function draw_flask_fluid(flask)
	x = flask.center_x - FLASK_WIDTH / 2
	for i = 1, #flask.fill_order do
		color = flask.fill_order[i][1]
		y = SCREEN_HEIGHT - (flask.fill_order[i][3] + FLASK_OFFSET_Y)
		height = math.ceil(flask.fill_order[i][3]) - math.ceil(flask.fill_order[i][2])
		rect(x + 3,	y, FLASK_WIDTH - 6, height, color)
	end
	
end

function draw_orders()
	-- Orders are 8px from the edges
	-- Orders are spaced 12px between each other
	-- Orders are 32px by 16px and scaled by 2

	for i=1, math.min(#orders, 4) do
		create_order_ui(i, orders)
	end

	for i=1, #completed_orders do
		create_order_ui(i, completed_orders)
	end

end

function create_order_ui(i, o)
	spr(12, o[i].pos[1], o[i].pos[2], 0, 2, 0, 0, 4, 2) -- Top order
		
	for j=1, #o[i].content do

		colorSpr = -1
		if o[i].content[j][1] == 2 then
			colorSpr = 16
		elseif o[i].content[j][1] == 9 then
			colorSpr = 17
		elseif o[i].content[j][1] == 5 then
			colorSpr = 32
		end

		if #o[i].content == 1 then
			spr(colorSpr, o[i].pos[1] + 7, o[i].pos[2] + 5, 0, 2)
			percentage = o[i].content[j][2] * 100
			print(percentage .. "%", o[i].pos[1]+26, o[i].pos[2] + 9, 0, false, 2, true)

		elseif #o[i].content == 2 then
			spr(colorSpr, o[i].pos[1] + 15 + 25*(j-1), o[i].pos[2] + 5, 0)
			percentage = math.floor(o[i].content[j][2] * 100)
			print(percentage .. "%", o[i].pos[1]+15+25*(j-1), o[i].pos[2] + 17, 0, false, 1, true)
		elseif #o[i].content == 3 then
			spr(colorSpr, o[i].pos[1] + 8 + 20*(j-1), o[i].pos[2] + 5, 0)
			percentage = math.floor(o[i].content[j][2] * 100)
			print(percentage .. "%", o[i].pos[1]+7+20*(j-1), o[i].pos[2] + 17, 0, false, 1, true)
		end
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
-- 016:00e00e0000e00e0000e20e0000d22e000d2222e0d322222ed332333e0ddddee0
-- 017:000000000e0000e00ee00ee000e90e0000e99e0000d89e0000d88e00000dd000
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
-- 032:00e00e000e5000e0e555500ed555555ed655555ed665555ed666665e0dddddd0
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

