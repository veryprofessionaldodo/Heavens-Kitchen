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
-- 000:00000000000c0000000c0000000c0c00000c0c00000c0000000d0c00000d0000
-- 001:00000000000c0000000c0000000d0000000d0000000e0000000d0000000d0000
-- 002:0033333100313111003111120011312200311222001122cc0012222200122222
-- 003:1111110011111100211111002211110022211100cc22110022222f0022222f00
-- 004:8888888808888888088999990089999c0089999900899c9900899c9900899c99
-- 005:888888888888888099999800c99998009999980099c9980099c9980099c99800
-- 006:0000555500056566000566660005666c0055666c00566ccc00566ccc0066666c
-- 007:666600006666700066667000c6667000c6666700ccc67700ccc66700c6667700
-- 008:00eeeeee00eeeeee00eeeee200eee42200ee4424004442240444424404444244
-- 009:eee44430ee444430224434304224434044244430142243401442434044423440
-- 016:000e0000000d0000000d0000000d0000000e0000000d0000000ed0000000eeee
-- 017:000e0000000e0000000e0000000e00000c0e0000c00e000000ee0000eee00000
-- 018:001122cc0011122200000022000000e2000000df000000de000000dd00000000
-- 019:cc22ff00222fff00220000002f000000ff000000ff000000ee00000000000000
-- 020:008999990089999c00099999000000ff000000ff000000dd000000dd00000000
-- 021:99999800c999980099999000ff000000ff000000ee000000ee00000000000000
-- 022:0056666c006666660007666600007777000000ff000000dd000000dd00000000
-- 023:c6666700666677006667700077770000ff000000ee000000ee00000000000000
-- 024:0344223404442444044222210344344300334333000333dd000000dd00000000
-- 025:1441133044431330211113303333300033000000ee000000ee00000000000000
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
