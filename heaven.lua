-- title:  Heaven's Kitchen
-- author: Team Amogus
-- desc:   1st place submission for RetroJam 2021 organized by IEEE UP SB
-- script: lua

-- Game States
STATES = {
    MAIN_MENU = 'main_menu',
    CUTSCENE_ZERO = 'cutscene_zero',
    CUTSCENE_ONE = 'cutscene_one',
    CUTSCENE_TWO = 'cutscene_two',
    HOW_TO_PLAY_ONE = 'how_to_play_one',
    TUTORIAL_ONE = 'tutorial_one',
    HOW_TO_PLAY_TWO = 'how_to_play_two',
    TUTORIAL_TWO = 'tutorial_two',
    CUTSCENE_THREE = 'cutscene_three',
    LEVEL_ONE = 'level_one',
    RESULT_ONE = 'result_one',
    LEVEL_TWO = 'level_two',
    RESULT_TWO = 'result_two',
    LEVEL_THREE = 'level_three',
    RESULT_THREE = 'result_three',
    RESULT_FINAL = 'result_final',
    ARCADE_EASY = 'arcade_easy',
    ARCADE_MEDIUM = 'arcade_medium',
    ARCADE_HARD = 'arcade_hard'
}

SKIPPABLE_STATES = {STATES.MAIN_MENU, STATES.CUTSCENE_ZERO, STATES.CUTSCENE_ONE, STATES.CUTSCENE_TWO,
                    STATES.HOW_TO_PLAY_ONE, STATES.HOW_TO_PLAY_TWO, STATES.CUTSCENE_THREE, STATES.RESULT_ONE,
                    STATES.RESULT_TWO, STATES.RESULT_THREE, STATES.RESULT_FINAL}

PLAYABLE_STATES = {STATES.TUTORIAL_ONE, STATES.TUTORIAL_TWO, STATES.LEVEL_ONE, STATES.LEVEL_TWO, STATES.LEVEL_THREE,
                   STATES.ARCADE_EASY, STATES.ARCADE_MEDIUM, STATES.ARCADE_HARD}

CUR_STATE = STATES.MAIN_MENU

-- Faucet colors: red, blue, green
FAUCETS = {2, 9, 5}
ANY_FAUCET_DROPPING = false

-- Arcade
ARCADE_TIME = 90

-- Levels
LEVELS_METADATA = {
    -- times in seconds
    tutorial_one = {
        time = math.huge -- no timeout for tutorials
        
    },
    tutorial_two = {
        time = math.huge -- no timeout for tutorials
        
    },
    level_one = {
        time = 90,
        max_steps = 2,
        FAUCETS = FAUCETS,
        percentages = {0.25, 0.50, 0.75, 1}
    },
    level_two = {
        time = 60,
        max_steps = 3,
        FAUCETS = FAUCETS,
        percentages = {0.15, 0.25, 0.50, 0.75, 0.85, 1}
    },
    level_three = {
        time = 60,
        max_steps = 3,
        FAUCETS = FAUCETS,
        percentages = {0.15, 0.25, 0.35, 0.50, 0.65, 0.75, 0.85, 1}
    },
    arcade_easy = {
        time = ARCADE_TIME,
        max_steps = 2,
        FAUCETS = FAUCETS,
        percentages = {0.25, 0.50, 0.75, 1}
    },
    arcade_medium = {
        time = ARCADE_TIME,
        max_steps = 3,
        FAUCETS = FAUCETS,
        percentages = {0.15, 0.25, 0.50, 0.75, 0.85, 1}
    },
    arcade_hard = {
        time = ARCADE_TIME,
        max_steps = 3,
        FAUCETS = FAUCETS,
        percentages = {0.15, 0.25, 0.35, 0.50, 0.65, 0.75, 0.85, 1}
    }
}

-- Flasks
SELECTED = nil -- SELECTED flask to drag
FLASK_WIDTH = 36
FLASK_OFFSET_Y = 4
FLASK_HEIGHT = 84

FLASK1 = {
    center_x = 42, -- x position of the center of the flask
    fill_order = {}, -- order of fill with tuples (color, y0, y1) like e.g. [(red, 0, 30), (blue, 30, 35), (yellow, 35, 100)]
    cur_slot = 1 -- current slot the flask is placed in
}

FLASK2 = {
    center_x = 92,
    fill_order = {},
    cur_slot = 2
}

FLASK3 = {
    center_x = 142,
    fill_order = {},
    cur_slot = 3
}

FLASKS = {FLASK1, FLASK2, FLASK3}

-- Drop slots x ranges
DROP_SLOTS = {{24, 60}, {74, 110}, {124, 160}}

-- Scoring
TOTAL_SCORE = 0
TOTAL_STARS = 9
CURRENT_STARS = 0

LEVEL_ONE_SCORE = 1050
LEVEL_TWO_SCORE = 510
LEVEL_THREE_SCORE = 570

HAIR_THRESHOLD = 35
PERSON_THRESHOLD = 30
COW_THRESHOLD = 20
FROG_THRESHOLD = 10

-- Timer 
RECT_HEIGHT = 100
TIMER_Y = 10
TIMER_HEIGHT = 100

-- TIC-80 properties
SCREEN_WIDTH = 240
SCREEN_HEIGHT = 136
CLOCK_FREQ = 60 -- Hz

-- Keycodes
Z_KEYCODE = 26
FAUCET_KEYCODE_1 = 28
FAUCET_KEYCODE_2 = 29
FAUCET_KEYCODE_3 = 30
UP_KEYCODE = 58
DOWN_KEYCODE = 59
RETURN_KEYCODE = 50

-- Orders
ORDER_START_POS = 8
ORDER_PADDING = 44
ORDER_DELTA = 15
ORDER_OFF_SCREEN = 241
VERTICAL_TARGETS = {8, 52, 96, 137}

ORDERS = {}
COMPLETED_ORDERS = {}

-- Faucet Streams & Smoke
STREAM_WIDTH = 4
SMOKE_WIDTH = 30
SMOKE_HEIGHT = 84
SMOKE_HEIGHT_START = 40
FILL_RATE = 0.4
NUMBER_OF_STREAM_PARTICLES = 500
NUMBER_OF_SMOKE_PARTICLES = 1000
MAX_PARTICLE_SIZE = (SMOKE_WIDTH * SMOKE_HEIGHT) / NUMBER_OF_SMOKE_PARTICLES
PARTICLE_SPEED = 5
BUBBLES_GRAVITY = 0.1
MAX_PROX_X = 5
VERTICAL_ENTER_THRESHOLD = 40

-- transition particle system, each particle contains the following 
-- components: position, velocity, color, size, color, color_2, color_3
-- (used for transitions) and time_to_live
-- used to check if stream can be activated or not
SMOKE_RED_PARTICLES = {}
SMOKE_GREEN_PARTICLES = {}
SMOKE_BLUE_PARTICLES = {}
SMOKE_EVAPORATION_SPEED = 4

-- particles are simple objects that have five components:
-- position, velocity, color time-to-live, size, and whether it has passed 
-- the flask, and cannot be added to the fluid
PARTICLES_RED = {}
PARTICLES_GREEN = {}
PARTICLES_BLUE = {}

-- contains the CREATURES, and each contain the following information:
-- flask, position, y_velocity, starting sprite, width, height
CREATURES = {}
TIME_UNTIL_CREATURE_DROP = 100

-- Others
HALO_ANIM_COUNTER = 0
HALO_HEIGHT = 3
HALO_SPEED = 0.3
ORDER_ANIM_COUNTER = 0
ORDER_HEIGHT = 2
ORDER_SPEED = 0.2
BACKGROUND_COLOR = 0
FLASK_TRANSITION_TIME = 3
FRAME_COUNTER = 0
MENU_SELECTION = 1
MENU_RECT1_WIDTH = 0
MENU_RECT2_WIDTH = 0

-- TIC() is called at 60Hz by TIC-80
function TIC()
    update()
    draw()
end

function init()
    music(0)
    CUR_STATE = STATES.MAIN_MENU
end

-- updates
function update()
    FRAME_COUNTER = FRAME_COUNTER + 1
    if CUR_STATE == STATES.MAIN_MENU then
        if keyp(UP_KEYCODE) or keyp(DOWN_KEYCODE) then
            switch_selection() 
        end

        if keyp(RETURN_KEYCODE) then
            update_state_machine()
        end
    elseif has_value(SKIPPABLE_STATES, CUR_STATE) and keyp(Z_KEYCODE) then
        update_state_machine()
    elseif has_value(PLAYABLE_STATES, CUR_STATE) then
        update_orders()
        update_mouse()
        update_creatures()
        update_flasks()
        update_streams()
        update_smokes()

        -- only for arcade mode
        if MENU_SELECTION == 2 and #ORDERS <= 10 then
            generate_orders(30, LEVELS_METADATA[CUR_STATE].max_steps, LEVELS_METADATA[CUR_STATE].FAUCETS,
            LEVELS_METADATA[CUR_STATE].percentages)
        end

        -- end level if timeout or no more orders
        handle_timeout()
        if #ORDERS == 0 then
            update_state_machine()
        end
    end
end

function update_state_machine()
    -- stops all SFX
    sfx(-1)

    -- advances state machine to next state
    -- may run additional logic in between
    if CUR_STATE == STATES.MAIN_MENU then
        if MENU_SELECTION == 1 then
            CUR_STATE = STATES.CUTSCENE_ZERO
        elseif MENU_SELECTION == 2 then
            music(2)
            CUR_STATE = STATES.ARCADE_EASY
        end
    elseif CUR_STATE == STATES.CUTSCENE_ZERO then
        CUR_STATE = STATES.CUTSCENE_ONE
    elseif CUR_STATE == STATES.CUTSCENE_ONE then
        CUR_STATE = STATES.CUTSCENE_TWO
    elseif CUR_STATE == STATES.CUTSCENE_TWO then
        CUR_STATE = STATES.HOW_TO_PLAY_ONE
    elseif CUR_STATE == STATES.HOW_TO_PLAY_ONE then
        CUR_STATE = STATES.TUTORIAL_ONE
    elseif CUR_STATE == STATES.TUTORIAL_ONE then
        CUR_STATE = STATES.HOW_TO_PLAY_TWO
    elseif CUR_STATE == STATES.HOW_TO_PLAY_TWO then
        CUR_STATE = STATES.TUTORIAL_TWO
    elseif CUR_STATE == STATES.TUTORIAL_TWO then
        CUR_STATE = STATES.CUTSCENE_THREE
    elseif CUR_STATE == STATES.CUTSCENE_THREE then
        music(2)
        CUR_STATE = STATES.LEVEL_ONE
    elseif CUR_STATE == STATES.LEVEL_ONE then
        music(1)
        CUR_STATE = STATES.RESULT_ONE
        calculate_stars()
    elseif CUR_STATE == STATES.RESULT_ONE then
        music(2)
        CUR_STATE = STATES.LEVEL_TWO
    elseif CUR_STATE == STATES.LEVEL_TWO then
        music(1)
        CUR_STATE = STATES.RESULT_TWO
        calculate_stars()
    elseif CUR_STATE == STATES.RESULT_TWO then
        music(2)
        CUR_STATE = STATES.LEVEL_THREE
    elseif CUR_STATE == STATES.LEVEL_THREE then
        music(1)
        CUR_STATE = STATES.RESULT_THREE
        calculate_stars()
    elseif CUR_STATE == STATES.RESULT_THREE then
        music(ifthenelse(TOTAL_STARS >= 4, 4, 3))
        CUR_STATE = STATES.RESULT_FINAL
    elseif CUR_STATE == STATES.RESULT_FINAL then
        init()
    end

    if has_value(PLAYABLE_STATES, CUR_STATE) then
        setup_level()
    end
end

function calculate_stars()
    local threshold = ifthenelse(CUR_STATE == STATES.RESULT_ONE, LEVEL_ONE_SCORE, nil)
    threshold = ifthenelse(CUR_STATE == STATES.RESULT_TWO, LEVEL_TWO_SCORE, threshold)
    threshold = ifthenelse(CUR_STATE == STATES.RESULT_THREE, LEVEL_THREE_SCORE, threshold)
    local stars = math.floor(TOTAL_SCORE / (threshold / 3))
    CURRENT_STARS = ifthenelse(stars > 3, 3, stars)
    TOTAL_STARS = TOTAL_STARS + CURRENT_STARS
end

function update_orders()
    for i = 1, #ORDERS do
        ORDERS[i].pos[1] = ORDERS[i].pos[1] + (ORDERS[i].target[1] - ORDERS[i].pos[1]) / ORDER_DELTA
        ORDERS[i].pos[2] = ORDERS[i].pos[2] + (ORDERS[i].target[2] - ORDERS[i].pos[2]) / ORDER_DELTA
    end

    for i = 1, #COMPLETED_ORDERS do
        COMPLETED_ORDERS[i].pos[1] = COMPLETED_ORDERS[i].pos[1] +
                                         (COMPLETED_ORDERS[i].target[1] - COMPLETED_ORDERS[i].pos[1]) / ORDER_DELTA
        COMPLETED_ORDERS[i].pos[2] = COMPLETED_ORDERS[i].pos[2] +
                                         (COMPLETED_ORDERS[i].target[2] - COMPLETED_ORDERS[i].pos[2]) / ORDER_DELTA
    end
end

function update_mouse()
    local mx, _my, md = mouse()
    if not md then
        if SELECTED ~= nil then
            sfx(34, 25, -1, 1, 8)
            mouse_up(FLASKS[get_flask_at(SELECTED)])
        end
        SELECTED = nil
    elseif SELECTED == nil then
        sfx(33, 80, -1, 3, 8)
        local slot = get_slot(mx)
        SELECTED = slot
    elseif SELECTED ~= nil then
        FLASKS[get_flask_at(SELECTED)].center_x = mx
    end
end

function update_creatures()
    local i = 1

    while i < #CREATURES + 1 do
        CREATURES[i].time_to_drop = CREATURES[i].time_to_drop - 1

        if CREATURES[i].time_to_drop <= 0 then
            CREATURES[i].velocity_y = CREATURES[i].velocity_y + 0.5
        else
            CREATURES[i].pos[1] = CREATURES[i].flask.center_x
        end

        CREATURES[i].pos[2] = CREATURES[i].pos[2] + CREATURES[i].velocity_y

        if CREATURES[i].pos[2] > 200 then
            table.remove(CREATURES, i)
        else
            i = i + 1
        end
    end
end

function update_flasks()
    handle_faucet_sfx()
    if key(FAUCET_KEYCODE_1) and #SMOKE_RED_PARTICLES < 10 then
        local center_stream = (DROP_SLOTS[1][1] + DROP_SLOTS[1][2]) / 2 - 2
        generate_stream_particles(center_stream, PARTICLES_RED, 3)
    end

    if key(FAUCET_KEYCODE_2) and #SMOKE_BLUE_PARTICLES < 10 then
        local center_stream = (DROP_SLOTS[2][1] + DROP_SLOTS[2][2]) / 2 - 2
        generate_stream_particles(center_stream, PARTICLES_BLUE, 10)
    end

    if key(FAUCET_KEYCODE_3) and #SMOKE_GREEN_PARTICLES < 10 and CUR_STATE ~= STATES.TUTORIAL_ONE then
        local center_stream = (DROP_SLOTS[3][1] + DROP_SLOTS[3][2]) / 2 - 2
        generate_stream_particles(center_stream, PARTICLES_GREEN, 6)
    end

    -- handle transition of FLASKS
    if SELECTED == nil then
        for i = 1, #FLASKS do
            local cur_slot = FLASKS[i].cur_slot
            local final_center = (DROP_SLOTS[cur_slot][1] + DROP_SLOTS[cur_slot][2]) / 2
            FLASKS[i].center_x = FLASKS[i].center_x + (final_center - FLASKS[i].center_x) / FLASK_TRANSITION_TIME
        end
    end
end

function switch_selection()
    if MENU_SELECTION == 1 then
        MENU_SELECTION = 2
    elseif MENU_SELECTION == 2 then
        MENU_SELECTION = 1
    end   
end

function handle_faucet_sfx()
    if key(FAUCET_KEYCODE_1) or key(FAUCET_KEYCODE_2) or key(FAUCET_KEYCODE_3) then
        if not ANY_FAUCET_DROPPING then
            if key(FAUCET_KEYCODE_3) and CUR_STATE == STATES.TUTORIAL_ONE then
                sfx(35, 25, -1, 0, 6)
            else
                sfx(32, 25, -1, 0, 6)
            end
            ANY_FAUCET_DROPPING = true
        end
    else
        -- stop all SFX
        sfx(-1)
        ANY_FAUCET_DROPPING = false
    end
end

function generate_stream_particles(center, particles, particle_color)
    -- draw main stream
    for _ = 1, 25 do
        local pos_x = center + STREAM_WIDTH / 2 + math.random(-STREAM_WIDTH / 2, STREAM_WIDTH / 2)
        local pos_y = math.random(39, 40)
        local particle = {
            pos = {pos_x, pos_y},
            color = particle_color,
            velocity = {random_float(-0.1, 0.1), random_float(PARTICLE_SPEED - 2, PARTICLE_SPEED + 2)},
            size = random_float(1, 3),
            time_to_live = random_float(20, 40),
            has_entered = false,
            can_enter = true
        }
        if #particles < NUMBER_OF_STREAM_PARTICLES then
            table.insert(particles, particle)
        end
    end
end

function update_streams()
    local red_flask = FLASKS[get_flask_at(1)]
    update_stream(PARTICLES_RED, red_flask, SMOKE_RED_PARTICLES)

    local blue_flask = FLASKS[get_flask_at(2)]
    update_stream(PARTICLES_BLUE, blue_flask, SMOKE_BLUE_PARTICLES)

    local green_flask = FLASKS[get_flask_at(3)]
    update_stream(PARTICLES_GREEN, green_flask, SMOKE_GREEN_PARTICLES)
end

function update_stream(particles, flask, smoke_particles)
    local height = 131

    if #flask.fill_order > 0 then
        height = 131 - flask.fill_order[#flask.fill_order][3]
    end

    local i = 1
    while i <= #particles do
        if #smoke_particles > 10 then
            particles[i].time_to_live = 0
        end

        if particles[i].time_to_live <= 0 then
            table.remove(particles, i)
        else
            update_stream_particle(particles[i], flask, height)
            i = i + 1
        end
    end
end

function update_stream_particle(particle, flask, height)
    local center = flask.center_x
    local min_flask_x = center - SMOKE_WIDTH / 2
    local max_flask_x = center + SMOKE_WIDTH / 2 - 2

    -- is a part of the stream, make it speed up
    if particle.color ~= 12 then
        particle.velocity[1] = particle.velocity[1] + random_float(-0.1, 0.1)
        particle.velocity[2] = particle.velocity[2] + random_float(0.1, 0.5)
        particle.size = math.max(math.min(particle.size + random_float(-0.4, 0.3), 5), 1)
        -- has turned to foam
    else
        particle.size = math.max(math.min(particle.size + random_float(-0.4, 0.3), 2), 0)
        particle.velocity[2] = particle.velocity[2] - BUBBLES_GRAVITY
        if particle.velocity[1] > 0 then
            particle.velocity[1] = particle.velocity[1] - random_float(0.1, 0.2)
        else
            particle.velocity[1] = particle.velocity[1] + random_float(0.1, 0.2)
        end
    end

    local final_height = height

    -- if it is outside of the flask 
    if particle.pos[1] < min_flask_x or particle.pos[1] > max_flask_x and not particle.has_entered then
        final_height = 1000
        particle.can_enter = false
        -- check if it can enter the flask
    elseif particle.pos[1] > min_flask_x and particle.pos[1] < max_flask_x and particle.pos[2] <
        VERTICAL_ENTER_THRESHOLD then
        particle.can_enter = true
    end

    -- check if it entered
    if not particle.has_entered and particle.pos[2] > VERTICAL_ENTER_THRESHOLD and particle.can_enter then
        particle.has_entered = true
    end

    -- update particles inside flask or that can still enter
    if particle.has_entered or particle.can_enter then

        if particle.has_entered then
            particle.pos[1] = math.min(math.max(particle.pos[1], min_flask_x), max_flask_x)
            -- check if flask bounce is necessary
            if particle.pos[1] == min_flask_x then
                particle.velocity[1] = random_float(1, 3)
            elseif particle.pos[1] == max_flask_x then
                particle.velocity[1] = random_float(-3, -1)
            end
        end

        -- is foam, is bouncing on surface
        if particle.pos[2] < final_height and particle.color == 12 then
            particle.velocity[2] = -particle.velocity[2] / 2
        end

        -- check if particle has reached stream
        if particle.pos[2] > final_height and particle.color ~= 12 then
            particle.pos[2] = particle.pos[2] - 0.5
            particle.color = 12
            particle.velocity[1] = random_float(-2, 2)
            particle.velocity[2] = random_float(PARTICLE_SPEED / 6 - 1, PARTICLE_SPEED / 6 + 1)
            fill_flask(flask)
        end

        -- check if it hit the bottom
        if particle.pos[2] > 128 and particle.color == 12 then
            particle.velocity[2] = random_float(-2, -1)
        end
        -- update particles outside of flask
    else
        -- check if particle hits flask on the right or left side
        if particle.pos[1] < center then
            particle.pos[1] = math.min(particle.pos[1], min_flask_x)

            -- hit left side of flask
            if particle.pos[1] == min_flask_x then
                particle.velocity[1] = particle.velocity[1] + random_float(-2, -4)
            else
            end
        else
            particle.pos[1] = math.max(particle.pos[1], max_flask_x)

            -- hit right side of flask
            if particle.pos[1] == max_flask_x then
                particle.velocity[1] = particle.velocity[1] + random_float(2, 4)
            end
        end

    end

    -- update properties
    particle.time_to_live = particle.time_to_live - 1
    particle.pos[1] = particle.pos[1] + particle.velocity[1]
    particle.pos[2] = particle.pos[2] + particle.velocity[2]

    -- if it has left the screen, it should be immediately be killed
    if particle.pos[2] > 160 then
        particle.time_to_live = 0
    end

end

function update_smokes()
    local center = (DROP_SLOTS[1][1] + DROP_SLOTS[1][2]) / 2
    local red_flask = FLASKS[get_flask_at(1)]
    update_smoke(SMOKE_RED_PARTICLES, center, red_flask)

    local center = (DROP_SLOTS[2][1] + DROP_SLOTS[2][2]) / 2
    local blue_flask = FLASKS[get_flask_at(2)]
    update_smoke(SMOKE_BLUE_PARTICLES, center, blue_flask)

    local center = (DROP_SLOTS[3][1] + DROP_SLOTS[3][2]) / 2
    local green_flask = FLASKS[get_flask_at(3)]
    update_smoke(SMOKE_GREEN_PARTICLES, center, green_flask)
end

function update_smoke(smoke, center, flask)
    local i = 1
    for j = 1, #smoke do
        update_smoke_particle(smoke[j], flask.center_x, SMOKE_WIDTH, 120)
    end
    while i <= #smoke do
        if smoke[i].time_to_live <= 0 then
            table.remove(smoke, i)
        else
            i = i + 1
        end
    end
end

function update_smoke_particle(particle, center, width, height)
    if particle.size < 0.01 then
        particle.time_to_live = 0
    elseif particle.size < MAX_PARTICLE_SIZE then
        particle.color = particle.color_2
    elseif particle.size < MAX_PARTICLE_SIZE / 2 then
        particle.color = particle.color_3
    end

    particle.size = particle.size + random_float(-0.04, -0.03) * SMOKE_EVAPORATION_SPEED

    particle.velocity[1] = particle.velocity[1] + random_float(-0.1, 0.1)

    -- has reached the bottom, go up
    if particle.pos[2] > height then
        particle.velocity[2] = particle.velocity[2] + random_float(-0.05, -0.01)
    else
        particle.velocity[2] = particle.velocity[2] + random_float(-0.01, 0.01)
    end

    if particle.pos[2] < 47 then
        particle.velocity[2] = particle.velocity[2] / 1.05
    end

    -- update properties
    particle.pos[1] = particle.pos[1] + particle.velocity[1]
    particle.pos[2] = particle.pos[2] + particle.velocity[2]
    particle.pos[1] = math.min(math.max(particle.pos[1], center - width / 2), center + width / 2)

    -- check if bounce is necessary
    if particle.pos[1] == center + width / 2 then
        particle.velocity[1] = random_float(-2, -1)
        particle.pos[1] = particle.pos[1] + particle.velocity[1]
    elseif particle.pos[1] == center - width / 2 then
        particle.velocity[1] = random_float(1, 2)
        particle.pos[1] = particle.pos[1] + particle.velocity[1]
    end
end

function fill_flask(flask)
    local cur_color = FAUCETS[flask.cur_slot]

    if #flask.fill_order == 0 then
        table.insert(flask.fill_order, {cur_color, 0, 0})
    end

    if flask.fill_order[#flask.fill_order][1] == cur_color then
        -- same color as the previous, update previous entry
        flask.fill_order[#flask.fill_order][3] = flask.fill_order[#flask.fill_order][3] + 0.1 * FILL_RATE;
    else
        -- different color as the previous, create new entry
        local y = flask.fill_order[#flask.fill_order][3]
        table.insert(flask.fill_order, {cur_color, y, y + 0.1 * FILL_RATE})
    end

    check_if_flask_full(flask)
end

function check_if_flask_full(flask)
    local sum = 0
    for i = 1, #flask.fill_order do
        sum = sum + flask.fill_order[i][3] - flask.fill_order[i][2]
    end
    if sum >= FLASK_HEIGHT then
        local score = calculate_score(flask.fill_order)
        TOTAL_SCORE = TOTAL_SCORE + score
        flask.fill_order = {}

        local explosion_octave = math.random(26, 46)
        sfx(37, explosion_octave, -1, 0, 10, 0)
        generate_smoke_particles(flask)
        add_creature(flask, score)
    end
end

function add_creature(flask, score)
    local pos_x = flask.center_x
    local pos_y = 85
    local place_width = 2
    local place_height = 2
    local sprite = 66
    local random = random_float(0, 1)

    if score > HAIR_THRESHOLD then
        if random < 0.5 then
            sprite = 68
        else
            sprite = 72
        end

        place_width = 2
        place_height = 4
        pos_y = 60
    elseif score > PERSON_THRESHOLD then
        if random < 0.5 then
            sprite = 66
        else
            sprite = 70
        end

        place_width = 2
        place_height = 4
        pos_y = 60
    elseif score > COW_THRESHOLD then
        place_width = 2
        place_height = 2
        sprite = 78
    elseif score > FROG_THRESHOLD then
        place_width = 2
        place_height = 2
        sprite = 76
    else
        place_width = 2
        place_height = 2
        sprite = 74
    end

    local creature = {
        flask = flask,
        pos = {pos_x, pos_y},
        spr = sprite,
        time_to_drop = TIME_UNTIL_CREATURE_DROP,
        velocity_y = 0,
        width = place_width,
        height = place_height
    }
    table.insert(CREATURES, creature)
end

function generate_smoke_particles(flask)
    if flask.cur_slot == 1 then
        generate_smoke(flask.center_x, SMOKE_RED_PARTICLES, 12, 4, 3)
    elseif flask.cur_slot == 2 then
        generate_smoke(flask.center_x, SMOKE_BLUE_PARTICLES, 12, 11, 10)
    elseif flask.cur_slot == 3 then
        generate_smoke(flask.center_x, SMOKE_GREEN_PARTICLES, 12, 5, 6)
    end
end

function generate_smoke(center, particles, smoke_col_1, smoke_col_2, smoke_col_3)
    local min_flask_x = center - SMOKE_WIDTH / 2
    local max_flask_x = center + SMOKE_WIDTH / 2 - 2

    for i = 1, SMOKE_WIDTH / MAX_PARTICLE_SIZE do
        for j = 1, SMOKE_HEIGHT / MAX_PARTICLE_SIZE do
            local pos_x = min_flask_x + i * MAX_PARTICLE_SIZE - MAX_PARTICLE_SIZE / 2
            local pos_y = SMOKE_HEIGHT_START + j * MAX_PARTICLE_SIZE - MAX_PARTICLE_SIZE / 2

            local velocity_x = random_float(-0.05, 0.05)
            -- if it is close to the bounds, make the velocity not as intense
            if i < MAX_PROX_X then
                velocity_x = random_float(-0.05, -0.01)
            elseif i > SMOKE_WIDTH - MAX_PROX_X then
                velocity_x = random_float(0.01, 0.05)
            end

            local velocity_y = random_float(-1, 1)
            local particle = {
                size = MAX_PARTICLE_SIZE * 2,
                pos = {pos_x, pos_y},
                velocity = {velocity_x, velocity_y},
                color = smoke_col_1,
                color_2 = smoke_col_2,
                color_3 = smoke_col_3,
                time_to_live = random_float(30, 90)
            }
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
    for i = 1, math.min(3, #ORDERS) do
        local failed = false
        local total_diff = 0
        for j = 1, #ORDERS[i].content do
            if #fill_order ~= #ORDERS[i].content then
                failed = true
            elseif ORDERS[i].content[j][1] == fill_order[j][1] then
                total_diff = total_diff +
                                 math.ceil(math.abs((ORDERS[i].content[j][2] * FLASK_HEIGHT) -
                                                        (fill_order[j][3] - fill_order[j][2])))
            else
                failed = true
            end
        end
        if not failed then
            if total_diff ~= 0 then
                local failed_percentage = total_diff / 84;
                local score = math.ceil(40 - (failed_percentage * 40))
                if best_score < score then
                    best_score = score
                    best_score_index = i
                end
            else
                if best_score < 40 then
                    best_score = 40
                    best_score_index = i
                end
            end
            failed = false
        end
    end
    if best_score_index ~= nil then
        remove_order(best_score_index)
    end
    return best_score
end

function mouse_up(flask)
    local closest = get_closest_slot(flask.center_x)
    local closest_flask = FLASKS[get_flask_at(closest)]
    closest_flask.cur_slot = flask.cur_slot
    flask.cur_slot = closest
end

function get_closest_slot(x)
    local positions = {DROP_SLOTS[1][1], DROP_SLOTS[1][2], DROP_SLOTS[2][1], DROP_SLOTS[2][2], DROP_SLOTS[3][1],
                       DROP_SLOTS[3][2]}
    local positions = map(function(a)
        return math.abs(x - a)
    end, positions)
    local idx = min_i(positions)
    return math.ceil(idx / 2)
end

function get_flask_at(slot)
    for i = 1, #FLASKS do
        if FLASKS[i].cur_slot == slot then
            return i
        end
    end
end

function get_slot(mx)
    for i = 1, #DROP_SLOTS do
        local x0 = DROP_SLOTS[i][1]
        local x1 = DROP_SLOTS[i][2]
        if mx >= x0 and mx <= x1 then
            return i
        end
    end
end

function handle_timeout()
    local timeout

    if CUR_STATE == STATES.ARCADE_EASY then
        timeout = LEVELS_METADATA[CUR_STATE].time * CLOCK_FREQ
    else
        timeout = LEVELS_METADATA[CUR_STATE].time * CLOCK_FREQ
    end


    local timer_incr = RECT_HEIGHT / LEVELS_METADATA[CUR_STATE].time
    if ((FRAME_COUNTER % CLOCK_FREQ) == 0) then
        TIMER_Y = TIMER_Y + timer_incr
        TIMER_HEIGHT = TIMER_HEIGHT - timer_incr
    end

    if FRAME_COUNTER >= timeout then
        update_state_machine()
    end
end

function setup_level()
    TIMER_HEIGHT = RECT_HEIGHT
    TIMER_Y = 10
    FRAME_COUNTER = 0
    TOTAL_SCORE = 0

    -- empty FLASKS
    for i = 1, #FLASKS do
        FLASKS[i].fill_order = {}
    end

    -- remove creatures
    CREATURES = {}

    -- remove particles
    PARTICLES_RED = {}
    PARTICLES_BLUE = {}
    PARTICLES_GREEN = {}

    SMOKE_RED_PARTICLES = {}
    SMOKE_BLUE_PARTICLES = {}
    SMOKE_GREEN_PARTICLES = {}

    -- generate orders for next level
    if CUR_STATE == STATES.TUTORIAL_ONE then
        ORDERS = {{
            content = {{FAUCETS[1], 1}},
            pos = {168, 137},
            target = {168, VERTICAL_TARGETS[1]}
        }, {
            content = {{FAUCETS[2], 1}},
            pos = {168 + ORDER_PADDING, 137},
            target = {168, VERTICAL_TARGETS[2]}
        }, {
            content = {{FAUCETS[1], 1}},
            pos = {168 + ORDER_PADDING * 2, 137},
            target = {168, VERTICAL_TARGETS[3]}
        }, {
            content = {{FAUCETS[2], 1}},
            pos = {168, 137},
            target = {168, VERTICAL_TARGETS[4]}
        }}
    elseif CUR_STATE == STATES.TUTORIAL_TWO then
        ORDERS = {{
            content = {{FAUCETS[1], 0.5}, {FAUCETS[2], 0.5}},
            pos = {168, 137},
            target = {168, VERTICAL_TARGETS[1]}
        }, {
            content = {{FAUCETS[2], 0.25}, {FAUCETS[3], 0.75}},
            pos = {168 + ORDER_PADDING, 137},
            target = {168, VERTICAL_TARGETS[2]}
        }, {
            content = {{FAUCETS[3], 1}},
            pos = {168, 137},
            target = {168, VERTICAL_TARGETS[3]}
        }, {
            content = {{FAUCETS[3], 0.5}, {FAUCETS[1], 0.5}},
            pos = {168 + ORDER_PADDING * 2, 137},
            target = {168, VERTICAL_TARGETS[4]}
        }}
    else
        ORDERS = generate_orders(30, LEVELS_METADATA[CUR_STATE].max_steps, LEVELS_METADATA[CUR_STATE].FAUCETS,
                     LEVELS_METADATA[CUR_STATE].percentages)
    end
end

function generate_orders(norders, max_steps, FAUCETS, percentages)
    -- ORDERS
    local new_orders = {}
    for o = 1, norders do
        local pos = {168, 137 + (o - 1) * ORDER_PADDING}
        local target = {168, VERTICAL_TARGETS[o] or 137}

        -- what a mess lol 
        -- generate first pair (color, p)
        local ps = {percentages[math.random(1, #percentages)]}
        local colors = {FAUCETS[math.random(1, #FAUCETS)]}

        -- if first p1 is less than 1, generate another one
        -- generate also another color, different from the last
        if ps[1] < 1.0 and max_steps > 1 then
            local p2 = nil
            if max_steps == 2 then
                p2 = 1.0 - ps[1]
            else
                p2 = percentages[math.random(1, #percentages)]
                while p2 + ps[1] > 1.0 do
                    p2 = percentages[math.random(1, #percentages)]
                end
            end
            table.insert(ps, p2)

            local color = FAUCETS[math.random(1, #FAUCETS)]
            while color == colors[1] do
                color = FAUCETS[math.random(1, #FAUCETS)]
            end
            table.insert(colors, color)
        end

        -- if first p1 + p2 is still less than 1, generate another one
        -- generate also another color, different from the last
        if ps[1] < 1.0 and ps[1] + ps[2] < 1.0 and max_steps > 2 then
            local p3 = 1.0 - (ps[1] + ps[2])
            table.insert(ps, p3)

            local color = FAUCETS[math.random(1, #FAUCETS)]
            while color == colors[2] do
                color = FAUCETS[math.random(1, #FAUCETS)]
            end
            table.insert(colors, color)
        end

        local sanity_check = 0.0
        for i = 1, #ps do
            sanity_check = sanity_check + ps[i]
        end
        if sanity_check < 1.0 then
            ps[#ps] = ps[#ps] + (1.0 - sanity_check)
        end

        local content = {}
        for i = 1, #ps do
            table.insert(content, {colors[i], ps[i]})
        end

        table.insert(new_orders, {
            content = content,
            pos = pos,
            target = target
        })
    end
    return new_orders
end

function remove_order(index)
    for i = #ORDERS, index + 1, -1 do
        ORDERS[i].target[2] = ORDERS[i - 1].target[2]
    end

    ORDERS[index].target[1] = ORDER_OFF_SCREEN
    table.insert(COMPLETED_ORDERS, ORDERS[index])
    sfx(36, 65, 60, 1)
    table.remove(ORDERS, index)
end

-- draws
function draw()
    cls(BACKGROUND_COLOR)
    if has_value(PLAYABLE_STATES, CUR_STATE) then
        draw_game()
    elseif (CUR_STATE == STATES.MAIN_MENU) then
        draw_main_menu()
    elseif (CUR_STATE == STATES.CUTSCENE_ZERO) then
        draw_cutscene_zero()
    elseif (CUR_STATE == STATES.CUTSCENE_ONE) then
        draw_cutscene_one()
    elseif (CUR_STATE == STATES.CUTSCENE_TWO) then
        draw_cutscene_two()
    elseif (CUR_STATE == STATES.HOW_TO_PLAY_ONE) then
        draw_how_to_play_one()
    elseif (CUR_STATE == STATES.HOW_TO_PLAY_TWO) then
        draw_how_to_play_two()
    elseif (CUR_STATE == STATES.CUTSCENE_THREE) then
        draw_cutscene_three()
    elseif (CUR_STATE == STATES.RESULT_ONE) then
        draw_result_one()
    elseif (CUR_STATE == STATES.RESULT_TWO) then
        draw_result_two()
    elseif (CUR_STATE == STATES.RESULT_THREE) then
        draw_result_three()
    elseif (CUR_STATE == STATES.RESULT_FINAL) then
        draw_result_final()
    end
end

function draw_game()
    draw_background()
    draw_flasks_fluid()
    draw_faucets()
    draw_orders()
    draw_particles()
    draw_creatures()
    draw_smokes()
    draw_flasks_containers()

    if CUR_STATE ~= STATES.TUTORIAL_ONE and CUR_STATE ~= STATES.TUTORIAL_TWO then
        draw_timer()
        draw_score()
    end

    if SELECTED ~= nil then
        draw_selected_flask()
    end
end

function draw_background()
    spr(128, 0, 0, 0, 2, 0, 0, 8, 8)
    spr(128, 90, 0, 0, 2, 0, 0, 8, 8)
    spr(128, 140, 0, 0, 2, 0, 0, 8, 8)
end

function draw_flasks_fluid()
    for i = 1, #FLASKS do
        draw_flask_fluid(FLASKS[i])
    end
end

function draw_flask_fluid(flask)
    local x = flask.center_x - FLASK_WIDTH / 2
    for i = 1, #flask.fill_order do
        local color = flask.fill_order[i][1]
        local y = SCREEN_HEIGHT - (flask.fill_order[i][3] + FLASK_OFFSET_Y)
        local height = math.ceil(flask.fill_order[i][3]) - math.ceil(flask.fill_order[i][2])
        rect(x + 3, y, FLASK_WIDTH - 6, height, color)
    end
end

function draw_faucets()
    local width = DROP_SLOTS[1][2] - DROP_SLOTS[1][1]

    -- draw red faucet 
    local pos_red_x = (DROP_SLOTS[1][1] + DROP_SLOTS[1][2]) / 2 - width / 2
    spr(2, pos_red_x - 6, 0, 0, 3, 0, 0, 2, 2)

    -- draw blue faucet
    local pos_blue_x = (DROP_SLOTS[2][1] + DROP_SLOTS[2][2]) / 2 - width / 2
    spr(4, pos_blue_x - 6, 0, 0, 3, 0, 0, 2, 2)

    -- draw out of order faucet
    local pos_outoforder_x = (DROP_SLOTS[3][1] + DROP_SLOTS[3][2]) / 2 - width / 2

    if CUR_STATE == STATES.TUTORIAL_ONE then
        spr(8, pos_outoforder_x - 6, 0, 0, 3, 0, 0, 2, 2)
    else
        spr(6, pos_outoforder_x - 6, 0, 0, 3, 0, 0, 2, 2)
    end
end

function draw_orders()
    -- Orders are 8px from the edges
    -- Orders are spaced 12px between each other
    -- Orders are 32px by 16px and scaled by 2
    for i = 1, math.min(#ORDERS, 4) do
        create_order_ui(i, ORDERS)
    end

    for i = 1, #COMPLETED_ORDERS do
        create_order_ui(i, COMPLETED_ORDERS)
    end
end

function create_order_ui(i, o)

    ORDER_ANIM_COUNTER = ORDER_ANIM_COUNTER + 0.1 * ORDER_SPEED
    local pos_y = o[i].pos[2] + math.cos(ORDER_ANIM_COUNTER)
    

    spr(12, o[i].pos[1], pos_y, 0, 2, 0, 0, 4, 3)
    for j = 1, #o[i].content do
        local color_spr = -1
        if o[i].content[j][1] == 2 then
            color_spr = 0
        elseif o[i].content[j][1] == 9 then
            color_spr = 1
        elseif o[i].content[j][1] == 5 then
            color_spr = 16
        end

        if #o[i].content == 1 then
            spr(color_spr, o[i].pos[1] + 7, pos_y + 5, 0, 2)
            local percentage = o[i].content[j][2] * 100
            print(percentage .. "%", o[i].pos[1] + 26, pos_y + 9, 0, false, 2, true)

        elseif #o[i].content == 2 then
            spr(color_spr, o[i].pos[1] + 15 + 25 * (j - 1), pos_y + 5, 0)
            local percentage = math.floor(0.5 + o[i].content[j][2] * 100)
            print(percentage .. "%", o[i].pos[1] + 15 + 25 * (j - 1), pos_y + 17, 0, false, 1, true)
        elseif #o[i].content == 3 then
            spr(color_spr, o[i].pos[1] + 8 + 20 * (j - 1), pos_y + 5, 0)
            local percentage = math.floor(0.5 + o[i].content[j][2] * 100)
            print(percentage .. "%", o[i].pos[1] + 7 + 20 * (j - 1), pos_y + 17, 0, false, 1, true)
        end
    end
end

function draw_particles()
    for i = 1, #PARTICLES_RED do
        rect(PARTICLES_RED[i].pos[1], PARTICLES_RED[i].pos[2], math.floor(PARTICLES_RED[i].size),
            math.floor(PARTICLES_RED[i].size), PARTICLES_RED[i].color)
    end

    for i = 1, #PARTICLES_GREEN do
        rect(PARTICLES_GREEN[i].pos[1], PARTICLES_GREEN[i].pos[2], math.floor(PARTICLES_GREEN[i].size),
            math.floor(PARTICLES_GREEN[i].size), PARTICLES_GREEN[i].color)
    end

    for i = 1, #PARTICLES_BLUE do
        rect(PARTICLES_BLUE[i].pos[1], PARTICLES_BLUE[i].pos[2], math.floor(PARTICLES_BLUE[i].size),
            math.floor(PARTICLES_BLUE[i].size), PARTICLES_BLUE[i].color)
    end

end

function draw_creatures()
    for i = 1, #CREATURES do
        spr(CREATURES[i].spr, CREATURES[i].pos[1] - FLASK_WIDTH / 2 + 2, CREATURES[i].pos[2], 0, 2, 0, 0,
            CREATURES[i].width, CREATURES[i].height)
    end
end

function draw_smokes()
    draw_smoke(SMOKE_RED_PARTICLES)
    draw_smoke(SMOKE_GREEN_PARTICLES)
    draw_smoke(SMOKE_BLUE_PARTICLES)
end

function draw_smoke(particles)
    for i = 1, #particles do
        rect(particles[i].pos[1], particles[i].pos[2], particles[i].size, particles[i].size, particles[i].color)
    end
end

function draw_flasks_containers()
    for i = 1, #FLASKS do
        spr(10, FLASKS[i].center_x - FLASK_WIDTH / 2 - 6, 45, 0, 3, 0, 0, 2, 4)
    end
end

function draw_timer()
    rect(7, 10, 6, 100, 3)
    rect(7, TIMER_Y, 6, math.floor(TIMER_HEIGHT + 0.5), 4)
    rectb(7, 10, 7, 100, 4)
    local str = "TIME"
    for i = 1, #str do
        local c = str:sub(i, i)
        print(c, 8, 37 + i * 7)
    end
end

function draw_score()
    print("Score", 0, 118, 4, false, 1, true)
    print(TOTAL_SCORE, 0, 125, 4, false, 1, true)
end

function draw_selected_flask()
    -- SELECTED flask is always on top
    local selected_flask = FLASKS[get_flask_at(SELECTED)]
    draw_flask_fluid(selected_flask)

    local particles = nil
    if selected_flask.cur_slot == 1 then
        particles = PARTICLES_RED
    elseif selected_flask.cur_slot == 2 then
        particles = PARTICLES_BLUE
    elseif selected_flask.cur_slot == 3 then
        particles = PARTICLES_GREEN
    end

    for i = 1, #particles do
        -- PARTICLES_RED.pos[1]
        rect(particles[i].pos[1], particles[i].pos[2], math.floor(particles[i].size), math.floor(particles[i].size),
            particles[i].color)
    end

    if selected_flask.cur_slot == 1 then
        draw_smoke(SMOKE_RED_PARTICLES)
    elseif selected_flask.cur_slot == 2 then
        draw_smoke(SMOKE_BLUE_PARTICLES)
    elseif selected_flask.cur_slot == 3 then
        draw_smoke(SMOKE_GREEN_PARTICLES)
    end

    spr(10, selected_flask.center_x - FLASK_WIDTH / 2 - 6, 45, 0, 3, 0, 0, 2, 4)
end

function draw_main_menu()
    print('HEAVEN\'S', 20, 20, 7, false, 3, false)
    print('KITCHEN', 20, 38, 7, false, 3, false)
    print('From the minds of BOB, MOUZI 2', 20, 60, 15, false, 1, true)
    print('and SPACEBAR', 20, 68, 15, false, 1, true)
    print('Story Mode', 20, 97, 7, false, 1, true)
    print('Arcade', 20, 110, 7, false, 1, true)

    if MENU_SELECTION == 1 then
        if FRAME_COUNTER % 1 == 0 and MENU_RECT1_WIDTH <= 37 then
            MENU_RECT1_WIDTH = MENU_RECT1_WIDTH + 2
        end
        rect(20, 104, MENU_RECT1_WIDTH, 1, 7)
        MENU_RECT2_WIDTH = 0
    elseif MENU_SELECTION == 2 then
        if FRAME_COUNTER % 1 == 0 and MENU_RECT2_WIDTH <= 23 then
            MENU_RECT2_WIDTH = MENU_RECT2_WIDTH + 2
        end
        rect(20, 117, MENU_RECT2_WIDTH, 1, 7)
        MENU_RECT1_WIDTH = 0
    end

    draw_god()
end

function draw_cutscene_zero()
    spr(260, 93, 10, 0, 2, 0, 0, 4, 4)

    print_cutscene_message('Congratulations!', 93, 84)
    print_cutscene_message('You have been SELECTED as a contestant', 53, 92)
    print_cutscene_message('chef in Heaven\'s Kitchen!', 76, 100)

    draw_continue_message()
end

function draw_cutscene_one()
    spr(256, 93, 10, 0, 2, 0, 0, 4, 4)

    print_cutscene_message('I\'ve entrusted you with repopulating my', 53, 80)
    print_cutscene_message('new planet with beautiful CREATURES.', 57, 88)
    print_cutscene_message('My goal is to test your skills', 70, 96)
    print_cutscene_message('in *true* molecular cuisine.', 73, 104)

    draw_continue_message()
end

function draw_cutscene_two()
    spr(264, 93, 10, 0, 1, 0, 0, 8, 8)

    print_cutscene_message('Operate the H.E.C.K. (Heavenly Enhanced', 55, 84)
    print_cutscene_message('Creature Kreator) machine to create life.', 50, 92)
    print_cutscene_message('I have faith in you, my child.', 76, 100)

    draw_continue_message()
end

function draw_how_to_play_one()
    print_cutscene_message('Open each faucet with your \'1\', \'2\'', 20, 30)
    print_cutscene_message('and \'3\' keys and fill out the FLASKS.', 20, 38)

    print_cutscene_message('You\'ll see my requests on the right side', 20, 54)
    print_cutscene_message('with the ideal composition of each flask.', 20, 62)

    print_cutscene_message('The green faucet is inoperational for now,', 20, 78)
    print_cutscene_message('I\'ll get my best angels on the job to', 20, 86)
    print_cutscene_message('fix it as fast as possible.', 20, 94)

    draw_god()
    draw_continue_message()
end

function draw_how_to_play_two()
    print_cutscene_message('The green faucet should be working now!', 20, 30)
    print_cutscene_message('I\'ll teach you a few sophisticated recipes', 20, 38)
    print_cutscene_message('that now involve multiple reagents.', 20, 46)
    print_cutscene_message('Ensure you add the reagents in the', 20, 54)
    print_cutscene_message('specified order!', 20, 62)

    print_cutscene_message('You can drag and drop a flask into another', 20, 78)
    print_cutscene_message('to make them switch places and add multiple', 20, 86)
    print_cutscene_message('layers to your mixture. Godspeed!', 20, 94)

    draw_god()
    draw_continue_message()
end

function draw_cutscene_three()
    print_cutscene_message('Fantastic job!', 20, 46)
    print_cutscene_message('You now know the basics of how to operate', 20, 54)
    print_cutscene_message('the H.E.C.K. machine.', 20, 62)

    print_cutscene_message('You are ready to face a bigger challenge', 20, 78)
    print_cutscene_message('and work for Heaven\'s Kitchen.', 20, 86)

    draw_god()
    draw_continue_message()
end

function draw_result_one()
    if CURRENT_STARS == 0 or CURRENT_STARS == 1 then
        print_cutscene_message('You surprise me... by how bad you are.', 20, 46)
        print_cutscene_message('I\'m praying for you to do', 20, 54)
        print_cutscene_message('better next time. For your sake.', 20, 62)
    end

    if CURRENT_STARS == 2 then
        print_cutscene_message('I have seen worse performances...', 20, 46)
    end

    if CURRENT_STARS == 3 then
        print_cutscene_message('Beautifully done, my child!', 20, 46)
        print_cutscene_message('I see great things in you. I hope', 20, 54)
        print_cutscene_message('you keep up the great work.', 20, 62)
    end

    draw_god()
    draw_stars()
    draw_continue_message()
end

function draw_result_two()
    if CURRENT_STARS == 0 or CURRENT_STARS == 1 then
        print_cutscene_message('WHAT THE FORK ARE YOU DOING?', 20, 46)
        print_cutscene_message('You are entirely destroying my plan!', 20, 54)
        print_cutscene_message('DO. BETTER. Or else.', 20, 62)
    end

    if CURRENT_STARS == 2 then
        print_cutscene_message('*sigh*', 20, 46)
        print_cutscene_message('Alright. This is fine.', 20, 54)
        print_cutscene_message('You can still fix this... I believe.', 20, 62)
    end

    if CURRENT_STARS == 3 then
        print_cutscene_message('I am amazed!', 20, 46)
        print_cutscene_message('You are truly made in my image.', 20, 54)
    end

    draw_god()
    draw_stars()
    draw_continue_message()
end

function draw_result_three()
    if CURRENT_STARS == 0 or CURRENT_STARS == 1 then
        print_cutscene_message('WHY DID YOU MAKE THEM HAVE TWELVE EYES?', 20, 46)
    end

    if CURRENT_STARS == 2 then
        print_cutscene_message('Would you look at that!', 20, 46)
        print_cutscene_message('Some of those CREATURES might actually', 20, 54)
        print_cutscene_message('not drool themselves!', 20, 62)
    end

    if CURRENT_STARS == 3 then
        print_cutscene_message('It\'s like you were born for this!', 20, 46)
        print_cutscene_message('Wait... *checks notes*', 20, 54)
        print_cutscene_message('You were.', 20, 62)
    end

    draw_god()
    draw_stars()
    draw_continue_message()
end

function draw_result_final()
    if TOTAL_STARS >= 7 then
        spr(437, 150, 20, 40, 2, 0, 0, 5, 5)
        print_cutscene_message('Where once there was a desert', 10, 28)
        print_cutscene_message('wasteland now lives a thriving', 10, 36)
        print_cutscene_message('civilization, the product of', 10, 44)
        print_cutscene_message('your immaculate cooking. Your', 10, 52)
        print_cutscene_message('perfect mixing makes God shed', 10, 60)
        print_cutscene_message('a single tear, splashing on Earth', 10, 68)
        print_cutscene_message('and curing over half of all', 10, 76)
        print_cutscene_message('all known diseases.', 10, 84)

    elseif TOTAL_STARS >= 4 and TOTAL_STARS <= 6 then
        spr(437, 150, 20, 40, 2, 0, 0, 5, 5)
        print_cutscene_message('You\'ve successfully planted', 10, 36)
        print_cutscene_message('the first life forms that will', 10, 44)
        print_cutscene_message('steadily evolve throughout the', 10, 52)
        print_cutscene_message('years. The planet\'s future is', 10, 60)
        print_cutscene_message('bright, and your job here', 10, 68)
        print_cutscene_message('is done.', 10, 76)

    elseif TOTAL_STARS >= 1 and TOTAL_STARS <= 3 then
        spr(400, 150, 0, 40, 2, 0, 0, 5, 7)
        print_cutscene_message('God drops to Its knees, stunned', 10, 36)
        print_cutscene_message('at the horror you\'ve created.', 10, 44)
        print_cutscene_message('Mutated CREATURES fill the land,', 10, 52)
        print_cutscene_message('preying on each other. You\'re', 10, 60)
        print_cutscene_message('promptly fired from the kitchen.', 10, 68)

    elseif TOTAL_STARS == 0 then
        spr(400, 150, 0, 40, 2, 0, 0, 5, 7)
        print_cutscene_message('You find yourself sweating profusely', 10, 36)
        print_cutscene_message('and, oddly enough, 4 million', 10, 44)
        print_cutscene_message('kilometers underground. It finally', 10, 52)
        print_cutscene_message('dawns on you God found you asleep', 10, 60)
        print_cutscene_message('on the job.', 10, 68)
    end

    draw_continue_message()
end

function draw_stars()
    for i = 1, 3 do
        if i <= CURRENT_STARS then
            spr(34, 0 + 22 * i, 80, 0, 1, 0, 0, 2, 2) -- numero da sprite de estrela cheia
        else
            spr(32, 0 + 22 * i, 80, 0, 1, 0, 0, 2, 2) -- numero da sprite de estrela vazia
        end
    end
end

function print_cutscene_message(message, x, y)
    print(message, x, y, 12, false, 1, true)
end

function draw_continue_message()
    print('Press Z to continue...', 20, 126, 7, false, 1, true)
end

function draw_god()
    HALO_ANIM_COUNTER = HALO_ANIM_COUNTER + 0.1 * HALO_SPEED
    local pos_y = -15 + math.sin(HALO_ANIM_COUNTER) * HALO_HEIGHT

    spr(186, 160, 50, 0, 2, 0, 0, 6, 5)

    -- draw halo
    spr(106, 158, pos_y, 0, 2, 0, 0, 6, 5)
end

-- utils
function has_value(tab, val)
    for _i, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function ifthenelse(cond, t, f)
    if cond then
        return t
    else
        return f
    end
end

function map(func, tbl)
    local newtbl = {}
    for i, v in pairs(tbl) do
        newtbl[i] = func(v)
    end
    return newtbl
end

function min(tbl)
    local i = min_i(tbl)
    return ifthenelse(i == nil, nil, tbl[i])
end

function min_i(tbl)
    if #tbl == 0 then
        return nil
    end
    local idx, min = 1, tbl[1]
    for i = 1, #tbl do
        if tbl[i] < min then
            idx = i
            min = tbl[i]
        end
    end
    return idx
end

function random_float(lower, greater)
    return lower + math.random() * (greater - lower);
end

init() -- starts the game

-- DO NOT EDIT BELOW ASSETS

-- <TILES>
-- 000:00d00e0000e00e0000e20e0000d22e000d2212e0d322222ed332333e0ddddee0
-- 001:000000000e0000e00ee00ee000ea0e0000e99e0000d89e0000d88e00000dd000
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
-- 016:00e00e000e5000d0e555500dd455555dd645555ed665555ed666665e0dddddd0
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
-- 028:8dcccccc8dcccccc8ddccccc8ddddccc88dddddd088888880000000000000000
-- 029:ccccccccccccccccccccccccccccccccdddddddd888888880000000000000000
-- 030:ccccccccccccccccccccccccccccccccdddddddd888888880000000000000000
-- 031:ccccccc8ccccccc8ccccccc8ccccccc8ddddcc88888ddc800088d88000088800
-- 032:0000000d000000dc000000dc00000ddcddddddccdccccccc0ddccccc00ddcccd
-- 033:d0000000dd000000dd000000cdd00000cdddddddddddddddddddddd0ddddde00
-- 034:000000040000004c0000004c000004cc44444cc4c4cccc44044cc44400444444
-- 035:40000000c4000000440000004440000044444444444c443144c4431044443300
-- 042:00d0000000d0000000c0000000d0000000d0000000d0000000d0000000d00000
-- 043:00000d0000000e0000000e0000000d0000000e0000000e0000000e0000000e00
-- 048:000dcddd000ddddd00eddddd00eddddd0eedddeeeeddeff0edeef000eee00000
-- 049:dddde000ddddf000ddedef00deddee00eeeddde00eeeedee000fffdf00000fff
-- 050:00044c44000444c4003444440034444403444333144333101333100033300000
-- 051:4444300044443000444443004444430033444330033331300003331300000311
-- 058:00d0000000d00c0000d0000000dde000000ede000000eeee0000000000000000
-- 059:000c0e00000c0e0000c00e000000de0000dee000eeee00000000000000000000
-- 064:0000000000c0000000c0000000c0c00000c0c00000c0000000c0c00000c00000
-- 065:0000000000000c0000000c0000000c0000000d0000000d0000000c0000000d00
-- 066:00000000000001110000111100001111000014430000044300000fff00000f3f
-- 067:00000000100000001000000011000000110000003f0000003200000032000000
-- 068:000000000000aa9a0000a9a9000099990000a443000004440000044400000443
-- 069:00000000900000009000000091000000990000003f0000003200000032000000
-- 070:0000000000000332000032220000322200002444000024440000244400002224
-- 071:0000000020000000200000002100000022000000220000002220000032200000
-- 072:0000000500000566000055660000566600005444000054440000544400005664
-- 073:5600000066000000690000009900000096000000660000006620000036200000
-- 074:00000000000f000000ff00040000001300000212000024f1000023ff00ff3342
-- 075:000000f04331000033210000322211002221110f111110001121100032111100
-- 078:000000000000000c0000eecc0000fffc0000000d000dddcd000eeefe0000001d
-- 079:00f000002ff00000ccc000002ff00000cffc0000dcfc0000ccdc0000eccd0000
-- 080:00d0000000d0000000c0000000d0000000d0000000c0000000d0000000d00000
-- 081:00000d0000000d0000000d0000000d0000000d00000c0d00000c0e00000c0d00
-- 082:0000443300044333000422230004222300043224000442240000434400004344
-- 083:3322000044320000443200004322000043220000322200003220000022200000
-- 084:0000443300044333000422230004222300043224000442240000434400004344
-- 085:3322000044320000443200004322000043220000322200003220000022200000
-- 086:0000422300044323000422440004444400044333000443340000434400004344
-- 087:3243000044430000443000003300000033000000320000003200000022000000
-- 088:0000455200044662000422440004444400044322000443220000432200004442
-- 089:2242000024420000422000002200000022000000220000002220000032200000
-- 090:000ff33200123333032222110343311113333221022323220022222200000001
-- 091:2222211022221111121111111111111111211111211111102211110000010000
-- 092:000000000000000c000005550000356300005666000c66c50005600500000000
-- 093:000000005500000066700000667600006677f0007f77f0007ffff00000000000
-- 094:0000e21d0000ff1d0000021d0000001d000dddff000eeeed0000000e00000000
-- 095:dddc0000cfdc0000dffd0000dfcc0000d0cc0000dcb00000eb00000000000000
-- 096:00d0000000d0000000c0000000d0000000d0000000d0000000d0000000d00000
-- 097:00000d0000000e0000000e0000000d0000000e0000000e0000000e0000000e00
-- 098:0000344f00000442000004420000044200000333000003240000432400004203
-- 099:2220000022000000220000002200000022000000220000003200000032000000
-- 100:0000344f00000442000004420000044200000333000003240000432400004203
-- 101:2220000022000000220000002200000022000000220000003200000032000000
-- 102:0000344300000442000003320000033200000333000003240000432400004203
-- 103:2200000022000000220000002200000022000000220000003200000032000000
-- 104:0000344300000444000003440000033200000433000004440000043400000423
-- 105:3220000033200000320000002200000022000000420000003200000032000000
-- 107:0000000000000000000000000000000000000000000000000000000c0000000c
-- 108:0000000000000000000000cc0000cccc00cccccccccccccccccccccccccccccc
-- 109:0000000000000000ccccccc0cccccccccccccccccccccccdcccccddcccccccdc
-- 110:0000000000000000ddd00000ddcd0000ccdddc00dcccddd0ccccddddccccddcd
-- 112:00d0000000d00c0000d0000000dde000000ede000000eeee0000000000000000
-- 113:000c0e00000c0e0000c00e000000de0000dee000eeee00000000000000000000
-- 114:0004320000042000004300000431000000000000000000000000000000000000
-- 115:3220000003200000003200000043000000000000000000000000000000000000
-- 116:0004320000042000004300000431000000000000000000000000000000000000
-- 117:3220000003200000003200000043000000000000000000000000000000000000
-- 118:0004320000042000004300000431000000000000000000000000000000000000
-- 119:3220000003200000003200000043000000000000000000000000000000000000
-- 120:0000042000000420000003200000422000000000000000000000000000000000
-- 121:3200000032000000032000000322000000000000000000000000000000000000
-- 123:0000000c000000cc000000cc000000cc0000000c000000000000000000000000
-- 124:dccccdccdcddddcddddddedddcdddeeeccccdeeeccccddcdcccccdcccccccdcc
-- 125:cccdcccccccdccddddddddcdeeddddddeeeeedcdddeeeeedddddeeedccceeedd
-- 126:ccddddddcccdddcddcdccddddcddcdddddcddddddddcdddddddcdddeddddddde
-- 127:d0000000dd000000dd000000dd000000dd000000ed000000ee000000ee000000
-- 128:0000000000000000000000000f00000000000000000000000000000000000000
-- 129:f000000000000f00000000000000000000000000000000000000000000000000
-- 130:000000000000f000000000000000000000000000000000000000000000000000
-- 131:00000000000000000000000000f0f000000ff000000000000000000000000000
-- 132:00000000000000f0000000000000000000000000000000000000000000000000
-- 134:00000000000000000000f0000000f00f0000000f000000000000000000000000
-- 135:000f0000000f000000000000000000000000000000000000000000000000000f
-- 139:000000000000000c0000000c0000000c000000cc0000000c000000cc000000cc
-- 140:cccccddccccccdccccccddcccccccccccddccccccdcddccdcccdcccdcccdcccd
-- 141:cddcdedeccddcdeecdcddcddccdcddddcdcdddddddddddddcdddddddddccdddd
-- 142:eeeeddeeeedddeeeeedeeee0ddcede00ddcdd000dddd0000cdd00000dd000000
-- 143:ee000000e0000000000000000000000000000000000000000000000000000000
-- 144:f00f0000000000000f0f0000000f0000000000000000000000000000f00000f0
-- 146:0000000000000000000000000000000f00000000000000000000000000000000
-- 147:0000000000000000000000000000000000000000000000000000f00000000000
-- 151:0000000f0000000f0000000000000000000000000000000f0000000f00000000
-- 154:0000000000000000000000000000000000000000000000000000000000000004
-- 155:000000cc000000cc000000cc000044cc000440cc044000cc440000cc4000000c
-- 156:ccccccddcccccccdcccdcccdccccccddccccccddcccdccddccccccddccccdcdd
-- 157:ddccdddddcccdcdcccccdddccdcddddcccccddddccccddddcccdccddcccdccdc
-- 158:dd000000dd000000dd000000dd000000cd400000dd444000dd044440dd004444
-- 160:0000000000000000000000000000f00000000000000000000000000000000000
-- 163:0000000f00000000000000000000000000000000000000000000000000000000
-- 164:000000000f000000f0000000f00000f00f000000000000000000000000000000
-- 167:0000000000000000000000000000000000000000f00000000000000000000000
-- 170:0000004400000004000000040000000000000000000000000000000000000000
-- 171:4400000c44000000444000004444400000044440004444440000044400000000
-- 172:ccccdcddccccdcddccccccdd000cdddd00000000440000004444444400444444
-- 173:cccdcdddcccdccddccdddddddddddd0000000000000000044444444444444040
-- 174:dd000444d0000444000044440004444000444440444444004400000000000000
-- 187:000000000000000000000000000000000000000d0000000d00000ddd00000ddc
-- 188:00000000000ddddd00dccccdddccccdddccdddccccdddccdccddccddcdddcccc
-- 189:00000000dc000000cc00d000ccdcdce0dddcdeeddccdddddccdcdedecdccddee
-- 190:00000000000000000000000000000000d0000000ee000000eee00000eee00000
-- 203:00000dcc00000ccd0000ccdd0000ccdd000dcddc00cdddcc00ccddcc00ddddce
-- 204:ddcddc3cdccdccccccd33444ccdc4444ce344444ee444444e3444444fff4444f
-- 205:ccddddee4ceedeee4cecfeee4ddedeed4ddeddee44ddedee444deeddfffddeed
-- 206:eee00000eeee0000eeee0000ddee0000edee0000edeee000eeeee000deeedd00
-- 219:00cddcce0dccdce30ccdcce30cddcee30ddcee340dcdee33ddcdce33dcceee33
-- 220:ffff44ff9f9f4433afa3443333334433344444334444443344444433444ccc33
-- 221:f333deee9f93ddeeafa43dde444443de444443ed3444433d3344433e33c433de
-- 222:deeded00dedeee00edeeeee0eeedeee0deeeeee0eeeedeeedeeeeeeedeeeeeee
-- 223:00000000000000000000000000000000000000000000000000000000e0000000
-- 224:000000000000000000000000000000000000000000000000000000000000f0f0
-- 226:000000000000000000000000000000000000000000000000000ff00000000f00
-- 227:00000000000000000000000000000000000000000000000000000000000f0000
-- 228:0000000000000000000000000000000000000000000000000000000f00000f00
-- 229:0000000000000000000000000000000000000000000000000f000000ff000000
-- 230:000000000000000000000000000000000000000000000000f00000000000000f
-- 231:00000000000000000000000000000000000000000000000000000000fffff000
-- 234:0000000c0000000c0000000d000000ec00000cce00000ccc0000ccdc0000dccd
-- 235:cccceee3cceceeeddceceeecdcccdeeedcccceeedcddceeecdddccdecddddddc
-- 236:4cccddddccddddddcdcc4333cdc44444dddd4444dcddddddedddddeeedddeedd
-- 237:d33333dedd3ccdde333dddde333dddde4333ccded3ddccdeeddddedeeedddddd
-- 238:ddeeeeededeeedeeedeedeeedddeeeeeeedeeeeededeeeeeeddeedeeeeddedee
-- 239:e0000000eee00000eee00000eeee0000eeede000eeeee000eeeede00eeeedee0
-- 240:000000000000000000000000000000000f000000fff0000f000f0fffff0f00ff
-- 241:0000000000000000000000000000000f000ff000f00000f0f0f0f000fff0ffff
-- 242:0000000000000f0f0f0f00000000000000000f00f000000000000000000f0000
-- 243:0ff000000000000000000000000f0f000000000000f0000ff00000f0000000f0
-- 244:0000000f000000000000000000000000000000f0ff0f00f00f0f0f00f0000000
-- 245:f000f0ff000ff0ff000000ff000fff0f0ff00000000000000000000000f00000
-- 246:00000fff0f0ff0f0000ff00f0ff0000000000f0000000ff00000000f0000f00f
-- 247:0f00000000000000000000000000000000000000f0000000000000fff0000000
-- 250:000ddccc0ddcccdd0dcdcddd00cdeddc00ccdddd0cccdddd0dcddddccddcdddd
-- 251:dddcdddddcdddddddddddddddcddddddcdcdddddddddddddddcddddddccddddd
-- 252:dddddcdeddedddddeddddcddcddddddddcddddddddddddddddddcdddddcdddee
-- 253:dededdddddddddcdddddddeedeeddeecddddddedddeedcdddddedceeedddeedc
-- 254:eeddeedddeddeededdceeeeeddcdeeeeeddeeeeedcedeedeedeeeeeedeeeeeed
-- 255:eeedede0ddeeede0eeeeeee0eeedeee0eeeeeeedeeedeeeedeedeeedeeeee0ed
-- </TILES>

-- <SPRITES>
-- 000:9999999999999999cccc99a9cccca9ac9cccccac9aacccccaaaccccb9aa9abcb
-- 001:9aa999999999a99999a9aa99aaaa9aaab99a9aa9b9aaaaaab99aaaacbcbaaaaa
-- 002:9999999999a999999999999999999a99a99aaaaca9aaaaacccccccccc9cccccc
-- 003:9999999999c999999cbbb9999ccbb999cccbbb99cccbbccccccccc99ccccaa99
-- 005:0000000000000000000000000000004400000444000044410044441104444114
-- 006:000000000000000044444400444444004ccc4440ccccc444cc444cc4cc4114cc
-- 007:0000000000000000000000000000000000000000000000004440000044444000
-- 008:999999999999999999a9999a99999a99999aa99a9a999999999999999999999a
-- 009:9999999a99999999999999999999999a9a9a99a99a9aaa99a9a3aa32ba332233
-- 010:99999a99999a999a9a9999939999999999a999a3923a333a93aaa33333333333
-- 011:9999999999999999999999aaaa3a3aaa9aaaa3aaa34a33ae3333a33333433333
-- 012:9999999a999999aaaa999a99aa33aa33a333aaaaaaa33aaaa333333a33a33a44
-- 013:99a9999a99999999999933923a933322993aa999aa3aa999aaa333aa3333aaa3
-- 014:9a999999999999992229999999a99999a99999a9aaaaa99933aa33aa33a33aaa
-- 015:99999999999999999999999999999999a9999a99999aa99aa99999a9aa999999
-- 016:9aaaaaaa9aaaaaaaaaaaaaaaaaaaaa55aa9aaaa59aa9aa55aabba555cccc5564
-- 017:aabaaaa9aaaaaa9a555aaaaa556aa9aa5569aaaa566aaaab6666aabb445566cc
-- 018:cccccc999a99aaaaaaaaaa9a9aaaaaaaaaaaaaaaaaaabaaaaabbbbbbcccccccc
-- 019:cc9aaa9aaaaaaaaaaaaaaaa9aaaaaaabaaaaaaabbbaaabbacbcacbbbbcbbbbbb
-- 020:0000000000000000000000040000004400000444000004440000444400004444
-- 021:0444111144411441444144414444441144444414114444444144444144144444
-- 022:4cc1441c114cc14c144ccc4c44111ccc41111114141444441414444444144444
-- 023:44444440c4444433c44433324443322244332220433200003320000042200000
-- 024:aa99993399939a339333222a22aaa333a3333433333344333333443333333333
-- 025:3332333433a33333333333333333333333333433343333343333334333334344
-- 026:3333343333333444333334433333333334334333333333443433434444444444
-- 027:3344333344343333333433343334443433444434444433444444443344444444
-- 028:3333443333343333433333344343333444444434444444444344444444444434
-- 029:3433333333333333333333334433333333334443433443334444444344444444
-- 030:333333a333333333333333333343333344333433333333333333334444334443
-- 031:aa39aaaa33399999333a3a993333333a33333333333333a3433333aa43333344
-- 032:ccc566c4acb66cbc222222622222222222222222222332222233332333323323
-- 033:456556cc45c556cc556000225552222255522222555222225556222235551111
-- 034:cccccccccbbcccbc2b2bbbbb2222222222222222222222222211112211212222
-- 035:cccccbccccccccbccbbbcbbcb2bbbbbb22222bb2222222222222222222222222
-- 036:0004444e00444444044444440344444404444444044444444444444440344444
-- 037:44114444ee411144ee44414444ee4114444ee4444444eee4344444e443444444
-- 038:4414444344444433344443304344433034343300433333004333420043433000
-- 039:3200000020000000000000000000000000000000000000000000000000000000
-- 040:3333343433334444343333334333344433434344434434334433333433334433
-- 041:4433434434444444334433444444444434444443444444434444444444444444
-- 042:434444cc334444ce444444ce444443ce444444ce444444ce444444ce4444ccce
-- 043:cccccccceeeeeeeeeeeeeeeeeeeeeeeeeaeaeaaeeaeaeaeeeaaaeaaeeaeaeaee
-- 044:cccccccceeeeeeeeeeeeeeeeeeeeeeeeaaaeaeeaaeeeaeaeaeeeaaeeaeeeaeae
-- 045:ccc44444eec44444eec44443eec44343eec44343eec44444eec44443eec44443
-- 046:3343333344444443333334434443444434444444444344333444443434444444
-- 047:33333333334333334433333343333333443333333333333344443334434ccc33
-- 048:3333332233332333332333223332333233333333333323333333333333323332
-- 049:2551111325512222275533323343233332332323333223333332332333323333
-- 050:2212232322322222222323233333323322222333233233223333332223233333
-- 051:2332222223322222232233223322222232223222323222222332233233233323
-- 052:004444f40003444f000434440000044400000334000000030000000000000000
-- 053:44444444f44344434f44444344f44443443ff434334344340333344300033333
-- 054:3343200044330000333000003422000043220000432220004322000032200000
-- 056:444443333444444434333444344444444444444444444444cccccccccccccccc
-- 057:4444334444444444444444444444444444444444444ccccccccccccccccccccc
-- 058:444433ce4444ccce4444ccce44cccccfcccccccfccccccceccccddcedcdccdce
-- 059:eaeaeaaeeeeeeeeeeeeeeeee8111888881118999e1c1e9c9eeeeeeeeeefeefee
-- 060:aaaeaeeaeeeeeeeeeeeeeeee8888888888448668ee22e65eeeeeeeeefeefeeff
-- 061:eec44444eec44444eec4cc44eeccccc4eecccccceecccccceeccccccefcccccc
-- 062:44444444444444444444444444444444cccccccccccccccccccccccccccccccc
-- 063:43ccc4434ccc44444ccccdddccccccddccccccccccccccccccccdcccccddcdcc
-- 072:dccddddcdcccccccdccccdddccdccccccdbdbcccccbdddbccccbccbdaccccccc
-- 073:cccdcccccdcbdddbcbbbbdbbdcccccbdcddccccdccddcdccdaaaddccdcddaaad
-- 074:cccccccfbccdddcfbbbcddcfddddddcedccdddcedcccccceccdccdcedcddddff
-- 075:ffefeffffffffffffffffffeefeefeeeefeeeeeeefeefffeffeefffeffffefff
-- 076:ffeeffefffffffffeefeffefeeeeeeeeeeeeeeeeeefeefeeffffefefffffffff
-- 077:efcdccddffcdaaacffcdaaadeeeccccceecddadcfecaaaaaffeddcaaff9ddddc
-- 078:cdddccdcddddddcccccccdddccdaaaaaccddddddacdddcccdcccccccdcdddddc
-- 079:ddcddccccdddcaccddccccccaccccaaaccccddaaccc9aadacdcaaaadddaacaaa
-- 088:aaacccccaaaaccdbcccccccccccdbdddcccaaaabcaaaaaacccacaaaacaccccac
-- 089:bddddaaabbddaaaaddbbbdddccddbdddbbbadbbdddddcccccddddddcccccdcdd
-- 090:adddddffaaaaddffddddddffddddf9f9dddf9ff9dffff999cdf99989d9999999
-- 091:fffffffffffffffff9999f99999f9fffff8ff988999999998998888999999999
-- 092:fffffffff9fff99f9f99ff9ffff99f98889999989f999f999999999999ff9999
-- 093:fff9ddcdffffdddd99f99ccc999999cc8999ddddf9f99d989999999899999998
-- 094:ddddddcbcddcccccddcccaacdcccbddccc88dddd8c8cdddddcdddddd8dcdccdd
-- 095:baaaadaacaaaaaddcccddaaaccddddadaaadaaddddaaaddddcdcaaddcccddadd
-- 104:aaddcccccddaccdacccddddacacccccdcaaaadccccdddddddcccddddccccccdd
-- 105:ccccddddadddddddcdddddd9cdaaad99ccaadd99dddd9999ddd88899dd889888
-- 106:f99999999888888899999999999999999999b999b9988888b998999999999998
-- 107:88999999888989bb999999999999999998899999998888999989999888999999
-- 108:9999999889988899999999999999999999899889989999998999998899999999
-- 109:899998899999999999999b888988899899999999999999ee899e888899999988
-- 110:ccccccdc9dcccaaa89dddddd899dddda99d9dddc9ee9eecc9999cccd899888ee
-- 111:ccdcdcacaacddcccaaaddccdaddddcccddddccccccccccddcdddddddeeeddeed
-- 120:ccddddddddeedee8deedd888ddddddd98888dd8988888888d8888d88dd88dd98
-- 121:eeee88ee8888889999988999999888899899999888bb99998999999898888889
-- 122:8e99999999889999999888898899998889988888998889998899999998888888
-- 123:9999999999988889888999998999999e99999998989888889888988888898889
-- 124:9998888888899999999999998ee99999889eeeee888899988888998899988888
-- 125:999999989888988888989bb999999999888e9e88888899898889888888998889
-- 126:99988e88899e888e999e9e99999999ee88888899988889988888888899999899
-- 127:8eeeeeed8edeeedd9deeeddd9eedddde99dddddd89888ddd88d9dddd99ddd9dd
-- 144:0000000000000000000000000000000000000000003300000000000000000000
-- 160:0030000000300000000000000000000000000000000000000000003300000003
-- 161:0000000000000000000000000000000000000000000000003022000032233322
-- 162:000000000000000000000000000000000000000000000ee0222d2e002222ee20
-- 163:0000000000000000000000000000000000000000000000000000000022000000
-- 164:002111100221111203322112333223300e333330002000000000000000000000
-- 176:0000000300000003000000230000002300033223000002230300022330032323
-- 177:3233a222233333230323333333334434344224344423534444324434444d34d4
-- 178:22222332c2224232a244332233443432323e44333344422ac443343a44333433
-- 179:222211002222010022311111222311112a4421112334221222343222a2234212
-- 180:0000000000000000000000001000000010000000110030001033300011330000
-- 182:0000000000000000000000000000000000000000000000000000000a000aaacd
-- 183:000000000000000000000000000000000000000000000000ad0a0000dddad0a0
-- 192:0000232233002a340003233400012334001313a4000223240003332400024444
-- 193:444444444444433c2243433c4434434c443343cc4434d34c4444434344d44344
-- 194:44323443433234434322e4a33322e433c322e433cc2224333c2244333cc44434
-- 195:3324221133244241332244112324422123442111223421123244212244432222
-- 196:1110000011110000210110001111100011111000111100002188000011110000
-- 197:00000000000000000000000a00000dcc00000add000aaaaa000aaaaa000aaacc
-- 198:aaaccccaaaddaacaacaaccaacaaa5a5acdda5aaa555a5aaa555aa5caaaaa555a
-- 199:addaddaaaaddddddaaaaaaadaaaaaaaaccaaaaaaaaa55aaaa5555aaaa56666aa
-- 200:9a99000099900000da999000daa99000a8aa9900daaa9a88dddad898aada5998
-- 201:0000000000000000000000000000000000000000000000000000000080000000
-- 208:3004432400021324001112420001222200111122301212423002222100002211
-- 209:d434434544d3354544433444d443343323434324233443321244322422233223
-- 210:54c4434444443444444444422433434222332312232223212223233322232321
-- 211:4142222121111122339111213223112132221211222111111221111211211118
-- 212:28100000118800001f1800001810000011000000288000000000000000800000
-- 213:00aaaccc00aaaccc00aaacaa0aaaaaaa0aaaaaba0aaaaaca0aaaacaa0aacacaa
-- 214:acaacaaaaccaaaaababbaaaababacaaababbcccabbabacccabbbaaa5cbaaaaa5
-- 215:a566666a55665aaa5566aaaa5566aaaa5656aaa65666aaaa5a66aaaa565aaaa9
-- 216:adda9699ddd558986aa8eaa876aa9888a6eade98769a9889776aae98a77dae99
-- 217:80000000800000000000000088000000f8000000ff0000008800000008000000
-- 224:0000011200000002000000080000000000000000000000000000000000000000
-- 225:2222222232921111211211110111111101011111000111110000001100000000
-- 226:2223112212111111122221211211112211121211111111181011101111100000
-- 227:1222111811112118211223101121331011112340118103200000033000000320
-- 228:0000000080000022000000000000000000000000020000000000200000022000
-- 229:0aaaaaab0aaaaabb0aaaacba0aaaaabb08aaaaaa008aacca00aa9aaa000999a9
-- 230:cbaaa555aaa5555abaa5555aba55aaaaaaaaaaaaaaaaaaa9aaaaaaaaaaaaa99a
-- 231:6666a9aa66aaaaa9aaaa12aaaaa112aaaa111aa9a9112aa9911a299991a199a7
-- 232:9a77de989977d788977d999f787d79989d7a8980997e8808a78888008d988800
-- 233:8000000088000000880000008000000000000000800000000000000080000000
-- 240:0000000000000000000333300003343000003300000003000000433300004030
-- 241:0000000000000000000000000000000000000000330000000300000000000000
-- 243:0002202022202032000000230000023000000230000002200000300000000000
-- 244:0000000000000000200000000000000000000000000000000000000000000000
-- 245:0008898900000989000008880000000800000008000000000000000000000000
-- 246:9aa9999a99a989a99999999998a9991188899989008888880088888800008000
-- 247:1211da97111999d91991a899e9e1888491188888808888088880000000000000
-- 248:9d98880098088880880880004808000088004000880000000000000000000000
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

