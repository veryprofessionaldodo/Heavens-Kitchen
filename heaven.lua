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

orders = { {{2, 1}}, {{2, 0.5}, {4, 0.5}} }

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

-- draws
function draw_game()
	draw_flask(flasks[1])
	draw_orders(orders)
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
-- 032:00088888008888880888cccc888ccccc88cccccc88cccccc88cccccc88cccccc
-- 033:8888888888888888cccccccccccccccccccccccccccccccccccccccccccccccc
-- 034:8888888088888888cccccc88ccccccc8cccccccccccccccccccccccccccccccc
-- 035:0000000000000000800000008800000088000000880000008800000088000000
-- 048:88cccccc88cccccc88cccccc88cccccc888ccccc0888cccc0088888800088888
-- 049:cccccccccccccccccccccccccccccccccccccccccccccccc8888888888888888
-- 050:ccccccccccccccccccccccccccccccccccccccccccccccc888cccc88888ccc80
-- 051:8800000088000000880000008800000088000000800000000000000000000000
-- 066:0088c88000088800000000000000000000000000000000000000000000000000
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

