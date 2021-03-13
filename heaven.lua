-- title:  Heaven's Kitchen
-- author: Amogus
-- desc:   Cook creatures for God himself
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

CURR_STATE = states.MAIN_MENU

flask1 = {
	y = 104, -- y of last line
	x0 = 60, -- left x
	x1 = 90, -- right x
	lines = {}, -- lines drawn so far
	fill_order = {} -- order of fill like [(color, frames), ...]
}

flasks = { flask1, nil, nil } -- flask order indicates under which faucet it is

faucets = { 2, 4, 9 } -- red, yellow, blue faucets

drop_slots = { {60, 90}, {100, 130}, {140, 170} } -- ranges of the drop slots

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

ORDER_START_POS = 8
ORDER_PADDING = 44
ORDER_DELTA = 15
ORDER_OFF_SCREEN = 241

function TIC()
	update()
	draw()
end

function update()
	if (CURR_STATE == states.MAIN_MENU) then
		if btnp(4) then
			update_state_machine(events.START_GAME)
		end
	elseif (CURR_STATE == states.LEVEL_ONE or CURR_STATE == states.LEVEL_TWO or CURR_STATE == states.LEVEL_THREE) then
		-- generateOrders() #TODO
		update_orders()
		-- toRemove = checkCompleteOrder() #TODO -> returns index of completed task
		if keyp(1) then
			remove_order(1)
		end
		if btn(0) then
			new_flask_line(flasks[1])
		end
	end
end

function draw()
	cls(13)
	if (CURR_STATE == states.MAIN_MENU) then
		draw_main_menu()
	elseif (CURR_STATE == states.LEVEL_ONE or CURR_STATE == states.LEVEL_TWO or CURR_STATE == states.LEVEL_THREE) then
		draw_game()
	end
end

-- updates
function update_state_machine(event)
	if event == events.MAIN_MENU then
		CURR_STATE = states.MAIN_MENU
	elseif event == events.START_GAME then
		CURR_STATE = states.LEVEL_ONE
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

function new_flask_line(flask)
	line_to_draw = {
		x0 = flask.x0,
		y0 = flask.y - 8,
		x1 = flask.x1,
		y1 = flask.y - 8
	}
	flask.y = flask.y - 1
	table.insert(flask.lines, line_to_draw)
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
function draw_game()
	draw_flask(flasks[1])
	draw_orders(orders)
	rectb(160, 0, 80, 136, 6)
	rectb(0, 0, 240, 136, 5)
end

function draw_main_menu()
	cls(13)
	print('HEAVENS KITCHEN', 30, 20, 7, false, 2, false)
	print('From the minds of BOB, MOUZI 2', 30, 42, 15, false, 1, true)
	print('and SPACEBAR', 30, 50, 15, false, 1, true)
	print('Press Z to start...', 30, 116, 7, false, 1, true)
end

function draw_flask(flask)
	for i = 1, #flask.lines do
		line(flask.lines[i].x0, flask.lines[i].y0, flask.lines[i].x1, flask.lines[i].y1, 4)
	end
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

-- init
function init()
	update_state_machine(events.MAIN_MENU)
	draw_main_menu()
end
init()

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 032:00888888088ccccc88cccccc8ccccccc8ccccccc8ccccccc8ccccccc8ccccccc
-- 033:88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 034:88888888cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 035:88888800ccccc880cccccc88ccccccc8ccccccc8ccccccc8ccccccc8ccccccc8
-- 048:8ccccccc8ccccccc8ccccccc88cccccc088ccccc008888880000000000000000
-- 049:cccccccccccccccccccccccccccccccccccccccc888888880000000000000000
-- 050:cccccccccccccccccccccccccccccccccccccccc888888880000000000000000
-- 051:ccccccc8ccccccc8ccccccc8ccccccc8cccccc8888ccc880088c880000888000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

