-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

t=0
x=96
y=24

states = {
	MAIN_MENU = 'menu',
	LEVEL_ONE = 'level_one',
	LEVEL_TWO = 'level_two',
	LEVEL_THREE = 'level_three'
}

CURR_STATE = states.MAIN_MENU

events = {
	MAIN_MENU = 'main',
	START_GAME = 'start',
	NEXT_LEVEL = 'next',
	LOST_GAME = 'lost',
	WON_GAME = 'won'
}

first_glass_lines = {
	last_y = 104,
	first_x = 60,
	last_x = 90,
	lines = {}
}

second_glass_lines = {}
third_glass_lines = {}

function update_state_machine(event)
	if event == events.MAIN_MENU then
		CURR_STATE = states.MAIN_MENU
	elseif event == events.START_GAME then
		CURR_STATE = states.LEVEL_ONE
	end
end

function draw_main_menu()
	cls(13)
	print('HEAVENS KITCHEN', 30, 20, 7, false, 2, false)
	print('From the minds of BOB, MOUZI 2', 30, 42, 15, false, 1, true)
	print('and SPACEBAR', 30, 50, 15, false, 1, true)
	print('Press Z to start...', 30, 116, 7, false, 1, true)
end

function draw_first_glass_line()
	line_to_draw = {
		x0 = first_glass_lines.first_x,
		y0 = first_glass_lines.last_y - 8,
		x1 = first_glass_lines.last_x,
		y1 = first_glass_lines.last_y - 8
	}
	first_glass_lines.last_y = first_glass_lines.last_y - 1
	table.insert(first_glass_lines.lines, line_to_draw)
end

function init()
	update_state_machine(events.MAIN_MENU)
	draw_main_menu()
end

function update()
	cls(13)
	if btn(0) then
		draw_first_glass_line()
	end

	for i = 1, #first_glass_lines.lines do
		line(first_glass_lines.lines[i].x0, first_glass_lines.lines[i].y0, first_glass_lines.lines[i].x1, first_glass_lines.lines[i].y1, 4)
	end
end

init()

function TIC()
	if (CURR_STATE == states.MAIN_MENU) then
		draw_main_menu()
			if btnp(4) then
				update_state_machine(events.START_GAME)
			end
		return
	end

	update()
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
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

