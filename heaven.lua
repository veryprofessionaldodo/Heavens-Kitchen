-- title:  Heaven's Kitchen
-- author: Amogus
-- desc:   Play as a mad chemist working for God
-- script: lua

states = {
	MAIN_MENU = 'main_menu',
	CUTSCENE_ZERO = 'cutscene_zero',
	HOW_TO_PLAY_ONE = 'how_to_play_one',
	TUTORIAL_ONE = 'tutorial_one',
	HOW_TO_PLAY_TWO = 'how_to_play_two',
	TUTORIAL_TWO = 'tutorial_two',
	CUTSCENE_ONE = 'cutscene_one',
	LEVEL_ONE = 'level_one',
	RESULT_ONE = 'result_one',
	LEVEL_TWO = 'level_two',
	RESULT_TWO = 'result_two',
	LEVEL_THREE = 'level_three',
	RESULT_THREE = 'result_three',
	RESULT_FINAL = 'result_final'
}

skipable_states = {
	states.MAIN_MENU,
	states.CUTSCENE_ZERO,
	states.HOW_TO_PLAY_ONE,
	states.HOW_TO_PLAY_TWO,
	states.CUTSCENE_ONE,
	states.RESULT_ONE,
	states.RESULT_TWO,
	states.RESULT_THREE,
	states.RESULT_FINAL,
}

playable_states = {
	states.TUTORIAL_ONE,
	states.TUTORIAL_TWO,
	states.LEVEL_ONE,
	states.LEVEL_TWO,
	states.LEVEL_THREE
}

faucets = { 2, 9, 5 } -- red, yellow, blue faucets

-- table with information for each level like time (possible others in the future)
-- time in seconds
levels_metadata = {
	tutorial_one = { 
		time = 1000
	},
	tutorial_two = { 
		time = 1000
	},
	level_one = { 
		time = 15,
		max_steps = 2,
		faucets = faucets,
		percentages = {0.25, 0.50, 0.75, 1}
	},
	level_two = { 
		time = 15,
		max_steps = 3,
		faucets = faucets,
		percentages = {0.15, 0.25, 0.50, 0.75, 0.85, 1}
	},
	level_three = { 
		time = 15,
		max_steps = 3,
		faucets = faucets,
		percentages = {0.15, 0.25, 0.35, 0.50, 0.65, 0.75, 0.85, 1}
	}
}

flask1 = {
	center_x = 42, -- center x
	fill_order = {}, -- order of fill like e.g. [(red, 0, 30), (blue, 30, 35), (yellow, 35, 100)]
	cur_slot = 1, -- current slot the flask is placed in
}

flask2 = {
	center_x = 92,
	fill_order = {},
	cur_slot = 2,
}

flask3 = {
	center_x = 142,
	fill_order = {}, 
	cur_slot = 3,
}

total_score = 0 -- total score of the player

flasks = { flask1, flask2, flask3 } -- not ordered

drop_slots = { {24, 60}, {74, 110}, {124, 160} } -- ranges of the drop slots

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
FILL_RATE = 0.4

BACKGROUND_COLOR = 0

STREAM_WIDTH = 4
NUMBER_OF_STREAM_PARTICLES = 500
NUMBER_OF_SMOKE_PARTICLES = 600
PARTICLE_SPEED = 5
BUBBLES_GRAVITY = 0.1

FRAME_COUNTER = 0
RECT_HEIGHT = 100
TIMER_Y = 10
TIMER_HEIGHT = 100

orders = {}

completed_orders = {}
vertical_targets = { 8, 52, 96, 137 }

-- miguel code for sfx
ANY_FAUCET_DROPPING = false

-- called at 60Hz by TIC-80
function TIC()
	update()
	draw()	

	-- TODO: remove debug slot lines and center
	-- print(CURR_STATE, 100, 100)
	-- for i = 1, #drop_slots do
	--  	l = drop_slots[i][1]
	--  	r = drop_slots[i][2]
	-- 	line(l, 0, l, 135, 5)
	-- 	line(r, 0, r, 135, 5)
	-- end

	-- for i = 1, #flasks do
	-- 	x = flasks[i].center_x
	-- 	line(x, 0, x, 135, 10)
	-- end

	-- rectb(0, 0, 240, 136, 5) -- screen box
end

-- updates
function update()
	FRAME_COUNTER = FRAME_COUNTER + 1
	if has_value(skipable_states, CURR_STATE) and keyp(Z_KEYCODE) then
		update_state_machine()
	elseif has_value(playable_states, CURR_STATE) then
		update_orders()
		update_mouse()
		update_flasks()
		update_streams()
		update_smokes()
		handle_timeout()
		if #orders == 0 then update_state_machine()	end
		-- toRemove = checkCompleteOrder() #TODO -> returns index of completed task
		if keyp(1) and #orders ~= 0 then
			remove_order(math.random(1, math.min(3, #orders)))
		end
	end
end

function update_state_machine()
	sfx(-1)
	-- just advances linearly
	-- could be done with indexes in the future
	if CURR_STATE == states.MAIN_MENU then
		CURR_STATE = states.CUTSCENE_ZERO
	elseif CURR_STATE == states.CUTSCENE_ZERO then
		CURR_STATE = states.HOW_TO_PLAY_ONE
	elseif CURR_STATE == states.HOW_TO_PLAY_ONE then
		CURR_STATE = states.TUTORIAL_ONE
	elseif CURR_STATE == states.TUTORIAL_ONE then
		CURR_STATE = states.HOW_TO_PLAY_TWO
	elseif CURR_STATE == states.HOW_TO_PLAY_TWO then
		CURR_STATE = states.TUTORIAL_TWO
	elseif CURR_STATE == states.TUTORIAL_TWO then
		CURR_STATE = states.CUTSCENE_ONE
	elseif CURR_STATE == states.CUTSCENE_ONE then
		CURR_STATE = states.LEVEL_ONE
	elseif CURR_STATE == states.LEVEL_ONE then
		CURR_STATE = states.RESULT_ONE
	elseif CURR_STATE == states.RESULT_ONE then
		CURR_STATE = states.LEVEL_TWO
	elseif CURR_STATE == states.LEVEL_TWO then
		CURR_STATE = states.RESULT_TWO
	elseif CURR_STATE == states.RESULT_TWO then
		CURR_STATE = states.LEVEL_THREE
	elseif CURR_STATE == states.LEVEL_THREE then
		CURR_STATE = states.RESULT_THREE
	elseif CURR_STATE == states.RESULT_THREE then
		CURR_STATE = states.RESULT_FINAL
	elseif CURR_STATE == states.RESULT_FINAL then
		CURR_STATE = states.MAIN_MENU
	end

	if has_value(playable_states, CURR_STATE) then setup_level() end
end

function update_mouse()
	mx, my, md = mouse()
	if not md then
		if selected ~= nil then
			sfx(34, 25, -1, 1, 8)
			mouse_up(flasks[get_flask_at(selected)])
		end
		selected = nil
	elseif selected == nil then
		sfx(33, 80, -1, 3, 8)
		slot = get_slot(mx)
		selected = slot
	elseif selected ~= nil then
		flask = flasks[get_flask_at(slot)]
		flask.center_x = mx
	end
end

function update_flasks()
	handle_faucet_sfx()
	if key(FAUCET_KEYCODE_1) and #smoke_red_particles < 10 then
		center_stream = (drop_slots[1][1] + drop_slots[1][2]) / 2 - 2
		generate_stream_particles(center_stream, particles_red, 3)
	end
	if key(FAUCET_KEYCODE_2) and #smoke_blue_particles < 10 then	
		center_stream = (drop_slots[2][1] + drop_slots[2][2]) / 2 - 2
		generate_stream_particles(center_stream, particles_blue, 10)
	end
	if key(FAUCET_KEYCODE_3) and #smoke_green_particles < 10 and CURR_STATE ~= states.TUTORIAL_ONE then
		center_stream = (drop_slots[3][1] + drop_slots[3][2]) / 2 - 2
		generate_stream_particles(center_stream, particles_green, 6)
	end

	-- handle transition of flasks
	for i = 1, #flasks do
		cur_slot = flasks[i].cur_slot
		final_center = (drop_slots[cur_slot][1] + drop_slots[cur_slot][2]) / 2
		flasks[i].center_x = flasks[i].center_x + (final_center - flasks[i].center_x) / 10
	end	
	
end

function generate_stream_particles(center, particles, particle_color)
	-- draw main stream
	for i = 1, 25 do 
		pos_x = center + STREAM_WIDTH / 2 + math.random(-STREAM_WIDTH / 2, STREAM_WIDTH / 2)
		pos_y = math.random(39, 40)
		particle = {pos = {pos_x, pos_y}, color=particle_color, velocity={random_float(-0.1,0.1), random_float(PARTICLE_SPEED-2,PARTICLE_SPEED+2)}, size = random_float(1,3), time_to_live=random_float(20,40)}
		if #particles < NUMBER_OF_STREAM_PARTICLES then
			table.insert(particles, particle)
		end
	end
end

function random_float(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function handle_faucet_sfx()
	if key(FAUCET_KEYCODE_1) or key(FAUCET_KEYCODE_2) or key(FAUCET_KEYCODE_3) then
		if not ANY_FAUCET_DROPPING then
			if key(FAUCET_KEYCODE_3) and CURR_STATE == states.TUTORIAL_ONE then
				sfx(35, 25, -1, 0, 6)
			else
				sfx(32, 25, -1, 0, 6)
			end
			ANY_FAUCET_DROPPING = true
		end
	else
		sfx(-1)
		ANY_FAUCET_DROPPING = false
	end
end


function random_float(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function update_smokes() 
	center = (drop_slots[1][1] + drop_slots[1][2]) / 2 - 2
	red_flask = flasks[get_flask_at(1)]
	update_smoke(smoke_red_particles, center, red_flask)
	
	center = (drop_slots[2][1] + drop_slots[2][2]) / 2 - 2
	blue_flask = flasks[get_flask_at(2)]
	update_smoke(smoke_blue_particles, center, blue_flask)
	
	center = (drop_slots[3][1] + drop_slots[3][2]) / 2 - 2
	green_flask = flasks[get_flask_at(3)]
	update_smoke(smoke_green_particles, center, green_flask)
end

function update_smoke(particles, center, flask) 
	width = 30
	height = 84

	i = 1
	for j = 1, #particles do 
		update_smoke_particle(particles[j], flask.center_x, width, height)
	end
	while i < #particles do 
		if particles[i].time_to_live <= 0 then
			table.remove(particles, i, center)
		else 
			i = i +1
		end
	end
end

function update_smoke_particle(particle, center, width, height) 
	if particle.size < 0.5 then 
		particle.color = particle.color_2
	elseif particle.size < 0.2 then
		particle.color = particle.color_3
	elseif particle.size < 0.01 then 
		particle.time_to_live = 0
	end

	particle.time_to_live = particle.time_to_live - 1
	particle.size = particle.size + random_float(-0.2, -0.1)
	
	if particle.pos[1] < center - width/2 then 
		particle.velocity[1] = particle.velocity[1] + random_float(0.1, 0.8)
	elseif particle.pos[1] > center + width/2 then
		particle.velocity[1] = particle.velocity[1] + random_float(-0.8, -0.1)
	else 
		particle.velocity[1] = particle.velocity[1] + random_float(-0.1, 0.1)
	end

	

	if height - particle.pos[2] < max_prox_x then 
		particle.velocity[2] = particle.velocity[2] + random_float(-0.1, -0.01)
	elseif particle.pos[2] < 47 then
		particle.velocity[2] = particle.velocity[2] / 1.1
	else
		particle.velocity[2] = particle.velocity[2] + random_float(-0.01, 0.01)
	end

	--velocity_y = random_float(-1, 1)
	-- update properties
	particle.pos[1] = particle.pos[1] + particle.velocity[1]
	particle.pos[2] = particle.pos[2] + particle.velocity[2]

	particle.pos[1] = math.min(math.max(particle.pos[1], center - width / 2), center + width / 2)

	-- check if bounce is necessary
	if particle.pos[1] == center + width / 2 then 
		particle.velocity[1] = random_float(-2,-1)
		particle.pos[1] = particle.pos[1] + particle.velocity[1]
	elseif particle.pos[1] == center - width / 2 then 
		particle.velocity[1] = random_float(1,2)
		particle.pos[1] = particle.pos[1] + particle.velocity[1]
	end
end

function update_streams() 
	red_flask = flasks[get_flask_at(1)]
	update_stream(particles_red, red_flask, smoke_red_particles)
	
	blue_flask = flasks[get_flask_at(2)]
	update_stream(particles_blue, blue_flask, smoke_blue_particles)
	
	green_flask = flasks[get_flask_at(3)]
	update_stream(particles_green, green_flask, smoke_green_particles)
end

function update_stream(particles, flask, smoke_particles)
	height = 131
	order_length = #flask.fill_order

	if order_length > 0 then
		height = 131 - flask.fill_order[order_length][3]
	end

	i = 1
	while i <= #particles do 
		update_stream_particle(particles[i], flask, height)

		if #smoke_particles > 10 then 
			particles[i].time_to_live = particles[i].time_to_live / 10
		end

		if particles[i].time_to_live <= 0 then 
			table.remove(particles, i)
		else 
			i = i + 1
		end
	end
end

function update_stream_particle(particle, flask, height) 
	center = flask.center_x

	if particle.color ~= 12 then
		particle.velocity[1] = particle.velocity[1] + random_float(-0.01,0.01)
		particle.size = math.max(math.min(particle.size + random_float(-0.4,0.3), 5),1)
	else 
		-- has turned to foam
		particle.size = math.max(math.min(particle.size + random_float(-0.4,0.3), 2),0)
		particle.velocity[2] = particle.velocity[2] - BUBBLES_GRAVITY
		if particle.velocity[1] > 0 then
			particle.velocity[1] = particle.velocity[1] - random_float(0.1,0.2)
		else 
			particle.velocity[1] = particle.velocity[1] + random_float(0.1,0.2)
		end
	end
	
	-- update properties
	particle.time_to_live = particle.time_to_live - 1
	particle.pos[1] = particle.pos[1] + particle.velocity[1]
	particle.pos[2] = particle.pos[2] + particle.velocity[2]

	final_height = height

	if particle.pos[1] < center - FLASK_WIDTH / 2 or particle.pos[1] > center + FLASK_WIDTH / 2 then
		final_height = 1000
	end

	-- check if particle has reached stream
	if particle.pos[2] > final_height and particle.color ~= 12 then
		particle.pos[2] = particle.pos[2] - 0.5
		particle.color = 12
		particle.velocity[1] = random_float(-2,2)
		particle.velocity[2] = random_float(PARTICLE_SPEED / 6 - 1, PARTICLE_SPEED / 6 + 1)
		fill_flask(flask)
	elseif particle.pos[2] < final_height and particle.color == 12 then
		particle.velocity[2] = -particle.velocity[2]/2 
	elseif particle.pos[2] > 160 then
		particle.time_to_live = 0
	end

	if particle.color == 12 then
		particle.pos[1] = math.min(math.max(particle.pos[1], center - width / 2), center + width / 2)
	end

	-- check if bounce is necessary
	if particle.pos[1] == center + width / 2 and color == 12 then 
		particle.velocity[1] = random_float(-2,-1)
		particle.pos[1] = particle.pos[1] + particle.velocity[1]
	elseif particle.pos[1] == center - width / 2 and color == 12 then 
		particle.velocity[1] = random_float(1,2)
		particle.pos[1] = particle.pos[1] + particle.velocity[1]
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

		explosion_octave = math.random(26, 46)
		sfx(37, explosion_octave, -1, 0, 10, 0)
		generate_smoke_particles(flask)
	end
end

-- transition particle system, each particle contains the follwoing 
-- components: position, velocity, color, size, color, color_2, color_3
-- (used for transitions) and time_to_live
-- used to check if stream can be activated or not
smoke_red_particles = {}
smoke_blue_particles = {}
smoke_green_particles = {}

function generate_smoke_particles(flask)
	slot = flask.cur_slot
	
	if slot == 1 then
		generate_smoke(flask.center_x, smoke_red_particles, 12, 4, 3)
	elseif slot == 2 then	
		generate_smoke(flask.center_x, smoke_blue_particles, 12, 11, 10)
	elseif slot == 3 then
		generate_smoke(flask.center_x, smoke_green_particles, 12, 5, 6)
	end
end

function generate_smoke(center, particles, smoke_col_1, smoke_col_2, smoke_col_3)
	width = 30
	height = 84
	max_prox_x = 5
	particle_size = (width * height / NUMBER_OF_SMOKE_PARTICLES)
	for i = 1, width do 
		for j = 1, height do 
			pos_x = center - width/2 + i + particle_size / 2
			pos_y = height/2 + j + particle_size / 2

			velocity_x = random_float(-0.05,0.05)
			-- if it is close to the bounds, make the velocity not as intense
			if i < max_prox_x then
				velocity_x = random_float(-0.05, -0.01)
			elseif i > width - max_prox_x then
				velocity_x = random_float(0.01, 0.05)
			end

			velocity_y = random_float(-1, 1)
			particle = {size = particle_size, pos={pos_x, pos_y}, velocity={velocity_x, velocity_y}, color=smoke_col_1, color_2= smoke_col_2, color_3=smoke_col_3, time_to_live=random_float(30,60)}
			table.insert(particles, particle)
		end
	end
end

function calculate_score(fill_order)
	local best_score = 0
	local best_score_index = nil
	if fill_order == nil then
		return 0
	end
	for i=1, math.min(3, #orders) do
		for j=1, #orders[i].content do
			if #fill_order ~= #orders[i].content then
				score = 0
			elseif orders[i].content[j][1] == fill_order[j][1] then
				local diff = math.ceil(math.abs((orders[i].content[j][2] * FLASK_HEIGHT) - (fill_order[j][3] - fill_order[j][2])))
				if diff ~= 0 then
					score = math.floor((40 / diff) * 1.5)
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
	--closest_flask.center_x = (drop_slots[closest_flask.cur_slot][2] + drop_slots[closest_flask.cur_slot][1]) / 2
	flask.cur_slot = closest
	--flask.center_x = (drop_slots[flask.cur_slot][2] + drop_slots[flask.cur_slot][1]) / 2
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

	timer_incr = RECT_HEIGHT/levels_metadata[CURR_STATE].time
	if((FRAME_COUNTER % CLOCK_FREQ) == 0) then
		TIMER_Y = TIMER_Y + timer_incr
		TIMER_HEIGHT = TIMER_HEIGHT - timer_incr
	end

	if FRAME_COUNTER >= timeout then update_state_machine()	end
end

function setup_level()
	--music(2)
	TIMER_HEIGHT = RECT_HEIGHT
	TIMER_Y = 10
	FRAME_COUNTER = 0

	-- empty flasks
	for i = 1, #flasks do
		flasks[i].fill_order = {}
	end

	-- generate orders for next level
	if CURR_STATE == states.TUTORIAL_ONE then
		orders = {
			{ content = {{faucets[1], 1}}, pos = {168, 137}, target = {168, vertical_targets[1] } },
			{ content = {{faucets[2], 1}}, pos = {168 + ORDER_PADDING, 137}, target = {168, vertical_targets[2] } },
			{ content = {{faucets[1], 1}}, pos = {168 + ORDER_PADDING * 2, 137}, target = {168, vertical_targets[3] } },
			{ content = {{faucets[2], 1}}, pos = {168, 137}, target = {168, vertical_targets[4] } },
		}
	elseif CURR_STATE == states.TUTORIAL_TWO then
		orders = {
			{ content = {{faucets[1], 0.5}, {faucets[2], 0.5}}, pos = {168, 137}, target = {168, vertical_targets[1] } },
			{ content = {{faucets[2], 0.25}, {faucets[3], 0.75}}, pos = {168 + ORDER_PADDING, 137}, target = {168, vertical_targets[2] } },
			{ content = {{faucets[3], 1}}, pos = {168, 137}, target = {168, vertical_targets[3] } },
			{ content = {{faucets[3], 0.5}, {faucets[1], 0.5}}, pos = {168 + ORDER_PADDING * 2, 137}, target = {168, vertical_targets[4] } },
		}
	else
		orders = generate_orders(
			30, 
			levels_metadata[CURR_STATE].max_steps, 
			levels_metadata[CURR_STATE].faucets, 
			levels_metadata[CURR_STATE].percentages
		)
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
			p2 = nil
			if max_steps == 2 then
				p2 = 1.0 - ps[1]
			else
				p2 = percentages[math.random(1, #percentages)]
				while p2 + ps[1] > 1.0 do
					p2 = percentages[math.random(1, #percentages)]
				end
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
			p3 = 1.0 - (ps[1] + ps[2])
			table.insert(ps, p3)
			
			color = faucets[math.random(1, #faucets)]
			while color == colors[2] do
				color = faucets[math.random(1, #faucets)]
			end
			table.insert(colors, color)
		end

		sanity_check = 0.0
		for i = 1, #ps do
			sanity_check = sanity_check + ps[i]
		end
		if sanity_check < 1.0 then
			ps[#ps] = ps[#ps] + (1.0 - sanity_check)
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
	sfx(36, 65, 60, 1)
	table.remove(orders, index)
end

-- draws
function draw()
	cls(BACKGROUND_COLOR)
	if (CURR_STATE == states.MAIN_MENU) then
		draw_main_menu()
	elseif (CURR_STATE == states.CUTSCENE_ZERO) then
		draw_cutscene_zero()
	elseif (CURR_STATE == states.HOW_TO_PLAY_ONE) then
		draw_how_to_play_one()
	elseif (CURR_STATE == states.HOW_TO_PLAY_TWO) then
		draw_how_to_play_two()
	elseif (CURR_STATE == states.CUTSCENE_ONE) then
		draw_cutscene_one()
	elseif (CURR_STATE == states.RESULT_ONE) then
		draw_result_one()
	elseif (CURR_STATE == states.RESULT_TWO) then
		draw_result_two()
	elseif (CURR_STATE == states.RESULT_THREE) then
		draw_result_three()
	elseif (CURR_STATE == states.RESULT_FINAL) then
		draw_result_final()
	elseif has_value(playable_states, CURR_STATE) then
		draw_game()
	end
end

function draw_main_menu()
	print('HEAVENS KITCHEN', 30, 20, 7, false, 2, false)
	print('From the minds of BOB, MOUZI 2', 30, 42, 15, false, 1, true)
	print('and SPACEBAR', 30, 50, 15, false, 1, true)
	print('Press Z to start...', 30, 116, 7, false, 1, true)
end

function draw_cutscene_zero()
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_how_to_play_one()
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_how_to_play_two()
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_cutscene_one()
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_result_one()
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_result_two()
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_result_three()
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_result_final()
	-- use total_stars global to display diff stuff
	print('PRESS Z TO SKIP', 30, 116, 7, false, 1, true)
end

function draw_game()
	draw_flasks_fluid()
	draw_faucets()
	draw_orders()
	draw_timer()
	draw_score()
	draw_particles()
	draw_smokes()
	draw_flasks_containers()
	if selected ~= nil then	draw_selected_flask() end
end

function draw_smokes()
	draw_smoke(smoke_red_particles)
	draw_smoke(smoke_green_particles)
	draw_smoke(smoke_blue_particles)
end

function draw_smoke(particles)
	for i = 1, #particles do 
		-- if is shrinking, draw a circle
		if particles[i].color == particles[i].color_2 or particles[i].color == particles[i].color_3 then 
			circ(particles[i].pos[1], particles[i].pos[2], particles[i].size / 2, particles[i].color)
		else
			rect(particles[i].pos[1], particles[i].pos[2], particles[i].size, particles[i].size, particles[i].color)
		end
	end
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
	rect(7, 10, 6, 100, 3)
	rect(7, TIMER_Y, 6, math.floor(TIMER_HEIGHT+0.5), 4)
	rectb(7, 10, 7, 100, 4)
	str = "TIME"
	for i = 1, #str do
		local c = str:sub(i,i)
		print(c, 8, 37 + i*7)
	end
end

function draw_flasks_containers() 
	for i = 1, #flasks do
		spr(10, flasks[i].center_x - FLASK_WIDTH / 2 - 6, 45, 0, 3, 0, 0, 2, 4)
	end
end

function draw_flasks_fluid()
	for i = 1, #flasks do
		draw_flask_fluid(flasks[i])
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

function draw_selected_flask()
	-- selected flask is always on top
	selected_flask = flasks[get_flask_at(selected)]
	draw_flask_fluid(selected_flask)

	particles = nil
	if selected_flask.cur_slot == 1 then
		particles = particles_red
	elseif selected_flask.cur_slot == 2 then
		particles = particles_blue
	elseif selected_flask.cur_slot == 3 then
		particles = particles_green
	end

	for i = 1, #particles do 
		--particles_red.pos[1]
		rect(particles[i].pos[1], particles[i].pos[2], math.floor(particles[i].size), math.floor(particles[i].size), particles[i].color)
	end

	if selected_flask.cur_slot == 1 then
		draw_smoke(smoke_red_particles)
	elseif selected_flask.cur_slot == 2 then
		draw_smoke(smoke_blue_particles)
	elseif selected_flask.cur_slot == 3 then
		draw_smoke(smoke_green_particles)
	end

	spr(10, selected_flask.center_x - FLASK_WIDTH / 2 - 6, 45, 0, 3, 0, 0, 2, 4)
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
	spr(12, o[i].pos[1], o[i].pos[2], 0, 2, 0, 0, 4, 3)
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
			percentage = math.floor(0.5 + o[i].content[j][2] * 100)
			print(percentage .. "%", o[i].pos[1]+15+25*(j-1), o[i].pos[2] + 17, 0, false, 1, true)
		elseif #o[i].content == 3 then
			spr(colorSpr, o[i].pos[1] + 8 + 20*(j-1), o[i].pos[2] + 5, 0)
			percentage = math.floor(0.5 + o[i].content[j][2] * 100)
			print(percentage .. "%", o[i].pos[1]+7+20*(j-1), o[i].pos[2] + 17, 0, false, 1, true)
		end
	end
end

function draw_faucets()
	width = drop_slots[1][2] - drop_slots[1][1]

	-- draw red faucet 
	pos_red_x = (drop_slots[1][1] + drop_slots[1][2])/2 - width/2
	spr(2,pos_red_x - 6, 0, 0, 3, 0, 0, 2, 2)

	-- draw blue faucet
	pos_blue_x = (drop_slots[2][1] + drop_slots[2][2])/2 - width/2
	spr(4,pos_blue_x - 6, 0, 0, 3, 0, 0, 2, 2)

	-- draw out of order faucet
	pos_outoforder_x = (drop_slots[3][1] + drop_slots[3][2])/2 - width/2

	if CURR_STATE == states.TUTORIAL_ONE then
		spr(8, pos_outoforder_x - 6, 0, 0, 3, 0, 0, 2, 2)
	else
		spr(6, pos_outoforder_x - 6, 0, 0, 3, 0, 0, 2, 2)
	end
end

function draw_score()
	print("Score", 0, 118, 4, false, 1, true)
	print(total_score, 0, 125, 4, false, 1, true)
end

-- utils
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

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
	CURR_STATE = states.MAIN_MENU
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
-- 012:0999999999cccccc9ccccccc9ccccccc9ccccccc9ccccccc9ccccccc9ccccccc
-- 013:99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 014:99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 015:99999990cccccc99ccccccc9ccccccc9ccccccc9ccccccc9ccccccc9ccccccc9
-- 016:00d00e0000e00e0000e20e0000d22e000d2212e0d322222ed332333e0ddddee0
-- 017:000000000e0000e00ee00ee000ea0e0000e99e0000d89e0000d88e00000dd000
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
-- 028:9ccccccc9ccccccc9ccccccc9ccccccc99cccccc099999990000000000000000
-- 029:cccccccccccccccccccccccccccccccccccccccc999999990000000000000000
-- 030:cccccccccccccccccccccccccccccccccccccccc999999990000000000000000
-- 031:ccccccc9ccccccc9ccccccc9ccccccc9cccccc99999ccc900099c99000099900
-- 032:00e00e000e5000d0e555500dd455555dd645555ed665555ed666665e0dddddd0
-- 034:0000000d000000dc000000dc00000ddcddddddccdccccccc0ddccccc00ddcccd
-- 035:d0000000dd000000dd000000cdd00000cdddddddddddddddddddddd0ddddde00
-- 036:000000040000004c0000004c000004cc44444cc4c4cccc44044cc44400444444
-- 037:40000000c4000000440000004440000044444444444c443144c4431044443300
-- 042:00d0000000d0000000c0000000d0000000d0000000d0000000d0000000d00000
-- 043:00000d0000000e0000000e0000000d0000000e0000000e0000000e0000000e00
-- 050:000dcddd000ddddd00eddddd00eddddd0eedddeeeeddeff0edeef000eee00000
-- 051:dddde000ddddf000ddedef00deddee00eeeddde00eeeedee000fffdf00000fff
-- 052:00044c44000444c4003444440034444403444333144333101333100033300000
-- 053:4444300044443000444443004444430033444330033331300003331300000311
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
-- 009:0123456789abcdef0123456789abcdef
-- 010:88877665555555555555667788899998
-- </WAVES>

-- <SFX>
-- 000:fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00fa00400000000000
-- 001:070047007700a700e700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700700000000000
-- 002:06f026c036b046a05690667066607650864096209610a600a600b600b600c600d600d600e600e600f600f600f600f600f600f600f600f600f600f600402000000000
-- 003:16006600d600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600602000000000
-- 004:525062408230a220c210e200f20002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200482000070800
-- 005:060016002600360036004600460056005600660076007600860096009600a600b600c600c600d600e600f600f600f600f600f600f600f600f600f6006e2000000000
-- 006:0700470077009700b700d700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700772000000000
-- 007:0600160026002600360036004600560056006600760086008600960096009600a600b600b600c600c600d600e600e600f600f600f600f600f600f600202000000000
-- 008:040034004400640074009400a400b400d400e400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400409000000000
-- 009:04000400140014002400240034003400440044005400540064006400740074008400840094009400a400a400b400b400c400c400d400d400e400f400300000000000
-- 010:080008c008c0080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800400000000400
-- 011:0800180028002800380038004800480058006800680078007800780088008800880098009800a800a800b800c800c800d800d800e800e800e800f800400000000000
-- 012:050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500400000000000
-- 013:080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800300000000000
-- 014:09002900490069008900a900c900e900f9000900090009000900090009000900090009000900090009000900090009000900090009000900090009004800000a0008
-- 015:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400500000000000
-- 016:07002700370047006700770087009700a700b700c700d700e700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700500000000000
-- 019:050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500404000000000
-- 032:f810e830c840a860888068a048c028e008f0080008000800080008000800080008000800080008000800080008000800080008000800080008000800210000090900
-- 033:060046009600c600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600700000000000
-- 034:0700370057008600a600d600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600400000000000
-- 035:0730577097b0d7f0f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700f700d80000000000
-- 036:0100110021003100f100f100f100f10001c001c011c011c021c021c031c031c041c041c0f100f100f100f100f100f100f100f100f100f100f100f100510000000000
-- 037:5b006b006b107b107b207b207b208b308b308b409b409b409b50ab60ab60ab70ab70bb80bb80bb90bba0cba0cbb0dbc0dbd0dbd0ebe0ebf0ebf0fbf0380000000000
-- 050:090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900100000000000
-- </SFX>

-- <PATTERNS>
-- 000:40001800000000000000000040001800001000001000000040001800001040006a00000040001800001000001000000040001800001000001000000040001800001040006a00000040001800000000000000000040001800000000000000000040001800000040006a000000400018000000000000000000400018000000000000000010400018000000000000000000400018000000000000000000400018000000000000000000400018000000000000000000400018000000000000000000
-- 001:40005a000050000050000000b0005a00000000000000000080005a00000000000000000060005a000000000000000000a0005a000000000000000000d0005a00000000000000000080005a00000000000000000060005a000000000000000000a0005a00000000000000000050005a00000000000000000050005a000000000000000000b0005a00000000000000000040005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:80005a000000000000000000000000000000000000000000000000000000000000000000a0005a000000000000000000000000000000000000000000000000000000000000000000b0005a00000000000000000000000000000000000000000000000000000000000000000080005a00000000000000000000000000000000000000000000000000000000000000000080005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:40005c000000000000000000000000000000000000000000000000000000000000000000d0005a000000000000000000000000000000000000000000000000000000000000000000f0005a000000000000000000000000000000000000000000000000000000000000000000f0005a000000000000000000000000000000000000000000000000000000000000000000f0005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:45f158000000800058000000400058000000800058000000400058000000800058000000b0005800000060005a000000b0005800000060005a000000b0005800000060005a00000080005a000000b0005800000080005a000000b0005800000080005a000000b00058000000500058000000c00058000000500058000000c00058000000500058000000c00058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:bf5158000000000000000000b00058000000000000000000b00058000000000000000000d00058000000000000000000d00058000000000000000000d00058000000000000000000b0005a000000000000000000b0005a000000000000000000b0005a00000000000000000080005a00000000000000000080005a00000000000000000080005a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:f99158000000000000000000f00058000000000000000000f00058000000000000000000a0005a000000000000000000a0005a000000000000000000a0005a000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000f00058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
-- 018:75a188000000700088000000000000000000700088000000700088000000000000700088000000400086a00086900086000000400086900086000000000000b000860000007256b80000000000000000000000000000006000b80000000000000000000000000000004000b8000000000000000000000000000000a000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:ba5188000000b00088000000000000000000e00086000000e00086000000000000d000860000000000000000000000000000000000000000000000000000000000000000004256ba0000000000000000000000000000006250ba0000000000000000000000000000007250ba000000000000000000000000000000a000ba000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:4f51b80000000000000000000000009000b80000000000000000000000000000004000b80000000000000000000000000000009000b80000000000000000000000000000000000004000b80000000000000000000000006000ba0000000000000000000000000000004000b8000000000000000000000000000000b000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:85f1b80000000000000000000000007720b8000000000000000000006000000000b000b8000000000000000000000000000000c000b80000000000000000004000ba9000ba0000008000ba000000000000000000000000b000ba0000000000000000000000000000007000ba000000000000000000000000000000f000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:b034c89f30c87000c89000c87000c86000c87000c86000c84000c86000c84000c8e000c6d000c6000000000000b000c8e000c8d000c8000000000000000000b000c8e000c80000004000ca0000000000007000c6b000c6e000c60000000000000000004000c6b000c6d000c60000000000000000004000c67000c69000c60000000000000000004000c67000c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:4124ba0000000000000000000000007000ba0000000000000000009000b8000000000000000000000000d000b80000000000000000007000b8000000000000b000b8000000000000e000b8000000000000e000b8000000000000e000b8000000000000e000b80000000000009000b80000000000009000b80000000000009000b80000000000007000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:400014000000400014000000000000400014400014000000400014000000000000000000400014000000400014000000000000400014400014000000400014000000000000000000400014000000400014000000000000400014400014000000400014000000000000000000400014000000400014000000000000400014400014000000400014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:79517a40007a70007ab0007a70007a40007a70007a40007a70007ab0007a70007a40007a60007af0007860007ab0007a60007af0007860007af0007860007ab0007a60007af00078c00078900078c0007840007ac00078900078c00078900078c0007840007ac00078900078b00078700078b0007840007ab0007870007860007af0007860007ab0007a60007af00078000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 026:759188000000700088000000700088000000700088000000707488000000000000000000f00088000000f00088000000f00088000000f00088000000f00088000000000000000000c00088000000c00088000000c00088000000c00088000000c00088000000000000000000700088000000700088000000700088000000b00088000000f00088000000b0008a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:406484400084400084400084400084400084400084400084400084900086900086900086b00086b00086b00086b00086b00086b00086b00086b00086b00086c00086c00086c00086900086900086900086900086900086900086900086900086900086400084400084400084700084710084700084700084700084b00084600084600084600084600084600084600084000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:8000c60000000000000000004000c60000000000000000008000c8000000000000000000e000c80000000000000000005000c8000000000000000000a000c40000000000000000007000c40000000000000000004000c40000000000000000004000c80000000000000000004000c40000000000000000009000c40000000000000000007000c40000000000000000007000c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 029:b691c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000c80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 030:4961c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:e991c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000ca0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:499162000000400062000000000000000000000000000000400062000000400062000000000000000000000000000000400062000000400062000000000000000000000000000000400062000000400062000000000000000000000000000000400062000000400062000000000000000000000000000000400062000000400062000000000000000000000000000000400062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:400012000000000000000000400012000000000000000000400012000000000000000000400012000000000000000000400012000000000000000000400012000000000000000000400012000000000000000000400012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 034:45f1e40000000000000000004000e40000000000000000007000e40000000000000000007000e40000000000000000004000e60000000000000000004000e60000000000000000004000b80000000000000000004000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 035:8f51e40000000000000000009000e4000000000000000000b000e40000000000000000004000e6000000000000000000b000e60000000000000000009000e60000000000000000007000b80000000000000000006000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 036:4ff1e200000003740000000000000000000000000000000045f1e600000000000000000000000000000000000000000075f0e20000000000000000000000000000000000000000009000e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 037:400012000000000000400012400009000000400012000000400012000000000000400012400009000000400012000000400012000000000000400012400009000000400012000000400012000000000000400012400009000000400012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:eff1b8000000000000000000b000b80000007000b8000000b000b80000000000000000004000b8000000b000b80000009000b80000000000000000000000000000004000bab000ba9000ba00000046618cb0008c90008c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:45f1e60000000374000000000000000000000000000000004f51e6000000000000000000000000000000000000000000e5f0e6000000000000000000000000000000000000000000d000e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:8f51e600000003740000000000000000000000000000000045f1e60000000000000000000000000000000000000000009f50e60000000000000000000000000000000000000000009000e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:4124ba0000000000000000000000007000ba0000000000000000009000b8000000000000000000000000d000b80000000000000000007000b8000000000000b000b8000000000000e000b8000000000000e000b8000000000000e000b8000000000000e000b80000000000009000b80000000000009000b80000000000009000b8000000000000b000b8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:45f1e60000000374000000000000000000000000000000004000e60000000000000000000000000000000000000000009000e6000000000000000000000000000000000000000000d000e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:8f51e60000000374000000000000000000000000000000007000e6000000000000000000000000000000000000000000d000e60000000000000000000000000000000000000000009000e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 044:4ff1e2000000037400000000000000000000000000000000b000e60000000000000000000000000000000000000000004000e80000000000000000000000000000000000000000009000e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:0416c18416c10000000000000000000000000000000000000000000000000000000000000000000000000000000000006a0100
-- 001:042ac2c42ac20000000000000000000000000000000000000000000000000000000000000000000000000000000000002e0000
-- 002:194000194315194315194710194716194595194595996000996b10996b16196b16196b17196b1719471619479a994000ec0100
-- 003:d97f18d97f58000000000000000000000000000000000000000000000000000000000000000000000000000000000000ce0000
-- 004:2e84e962a9696eac6b0000000000000000000000000000000000000000000000000000000000000000000000000000002e0260
-- </TRACKS>

-- <FLAGS>
-- 000:00000000ffff0000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

