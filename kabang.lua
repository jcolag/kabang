-- title:   Kabang!
-- author:  John Colagioia (jcolag@colagioia.net)
-- desc:    A Free Culture game about an astronaut collecting mines
-- site:    https://john.colagioia.net
-- license: AGPL 3.0 or later; CC-BY-SA 4.0 for sprites, sound effects, and music
-- version: 0.1
-- script:  lua

-- Game Constants
local SCREEN_WIDTH = 240
local SCREEN_HEIGHT = 136
local ASTRONAUT_SIZE = 8
local ASTRONAUT_ACCEL = 0.25
local MINE_SIZE = 2
local MINE_SPEED = 1
local LETTERS = " ABCDEFGHIJKLMNOPQRSTUVWXYZ"

-- Game Variables
local astronautX = SCREEN_WIDTH * 0.4
local astronautY = SCREEN_HEIGHT / 2 + ASTRONAUT_SIZE / 4
local astronautRotation = 270
local astronautSpeed = 0
local mineX = SCREEN_WIDTH
local mineY = SCREEN_HEIGHT / 2 + ASTRONAUT_SIZE / 4
local gameOver = true
local about = false
local flash = 0
local score = 0
local games = 0
local addInitials = false
local initials = {}
local iInitial = 0
local highScores = {}
local li = 0
local rank = -1

-- TIC-80 Function: Update
function TIC()
    -- Clear screen
    cls(0)

    if about then
        showAbout()
    elseif flash > 0 then
        makeFlash()
    elseif addInitials then
        getInitials(score, rank)
    elseif gameOver then
        showSplash()
    else
        -- Check for input
        local left = btn(3)
        local right = btn(2)

        astronautRotation = astronautRotation + astronautSpeed

        -- Update astronaut rotation
        if left and not right then
            astronautSpeed = astronautSpeed - ASTRONAUT_ACCEL
        elseif right and not left then
            astronautSpeed = astronautSpeed + ASTRONAUT_ACCEL
        end

        -- Normalize rotation angle to 0-359 range
        astronautRotation = astronautRotation % 360

        -- Update mine position
        mineX = mineX - MINE_SPEED

        -- Check if the astronaut caught the mine
        if isCaught(astronautRotation, score, mineX, mineY) then
            sfx(2, "A#7", 2, 1, 15)
        				score = score + 1
            nextMine(score)
        elseif playerHit(astronautRotation, score, mineX, mineY) then
            sfx(1, "D-2", 16, 2, 15)
            flash = 3
            games = games + 1
            rank = addScore(score)

            if rank >= 0 then
                addInitials = true
            end
        end

        -- Missed the mine
        if mineX == 0 then
            nextMine(score)
        end

        -- Draw stars
        starfield(games)

        -- Draw astronaut
        drawAstronaut(astronautRotation, score)

        -- Draw mine
        circ(mineX, mineY, MINE_SIZE / 2, 13)
    end
end

-- Set up for the next game
function restartGame()
    astronautX = SCREEN_WIDTH * 0.4
    astronautY = SCREEN_HEIGHT / 2
    astronautRotation = 270
    astronautSpeed = 0
    mineX = SCREEN_WIDTH
    mineY = SCREEN_HEIGHT / 2
    mineCaught = false
    gameOver = false
    score = 0
    rank = -1
    iInitial = 0
    initials = {}
    li = 1
				music(0)
end

-- Show splash screen
function showSplash()
	   -- Game over/splash screen
	   music()
				spr(1, SCREEN_WIDTH / 8 - 24, SCREEN_HEIGHT / 4, -1, 5)
				circ(SCREEN_WIDTH / 5 * 3.5 - 32, SCREEN_HEIGHT / 2.5, 12, 14)
	   print("K", SCREEN_WIDTH / 2 - 76, SCREEN_HEIGHT / 2 - 17, 2, false, 2)
	   print("A", SCREEN_WIDTH / 2 - 64, SCREEN_HEIGHT / 2 - 19, 3, false, 2)
	   print("B", SCREEN_WIDTH / 2 - 52, SCREEN_HEIGHT / 2 - 20, 4, false, 2)
	   print("A", SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT / 2 - 21, 12, false, 2)
	   print("N", SCREEN_WIDTH / 2 - 28, SCREEN_HEIGHT / 2 - 20, 4, false, 2)
	   print("G", SCREEN_WIDTH / 2 - 16, SCREEN_HEIGHT / 2 - 19, 3, false, 2)
	   print("!", SCREEN_WIDTH / 2 - 4, SCREEN_HEIGHT / 2 - 17, 2, false, 2)

	   if games > 0 then
	       print("GAME OVER", SCREEN_WIDTH / 2 - 65, SCREEN_HEIGHT / 2 - 4, 12)
	       print("SCORE: " .. score, SCREEN_WIDTH / 2 - 64, SCREEN_HEIGHT / 2 + 16, 12, true)
	       print("PRESS  A  TO PLAY AGAIN", SCREEN_WIDTH / 2 - 98, SCREEN_HEIGHT / 2 + 32, 12)
				else
	       print("PRESS  A  TO PLAY", SCREEN_WIDTH / 2 - 85, SCREEN_HEIGHT / 2 + 32, 12)
	   end
	
	   print("PRESS  B  TO LEARN MORE", SCREEN_WIDTH / 2 - 99, SCREEN_HEIGHT / 2 + 38, 12)
	   print("PRESS X TO RESET SCORES", SCREEN_WIDTH / 2 - 99, SCREEN_HEIGHT / 2 + 48, 12)
	   print("HIGH SCORES", SCREEN_WIDTH / 2 + 50, 24, 12)

	   for i=0, 9 do
				    local n = pmem(i * 2 + 1)
								local l1 = ltr(math.floor(n % 256))
								local l2 = ltr(math.floor(n / 256 % 256))
								local l3 = ltr(math.floor(n / 65536))

				    print(l1, SCREEN_WIDTH / 2 + 59, 40 + 8 * i, 12, true)
				    print(l2, SCREEN_WIDTH / 2 + 66, 40 + 8 * i, 12, true)
				    print(l3, SCREEN_WIDTH / 2 + 73, 40 + 8 * i, 12, true)
								print(pmem(i * 2), SCREEN_WIDTH / 2 + 90, 40 + 8 * i, 12, true)
				end
	
	   -- Check for game restart
	   if btnp(4) then
	       restartGame()
	   elseif btnp(5) then
	       about = true
				elseif btnp(6) then
				    resetScores()
	   end
end

-- Flash to white
function makeFlash()
	   cls(12)
    flash = flash - 1

    if flash == 0 then
    				gameOver = true
    end
end

-- Display licensing
function showAbout()
	   print("K", SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT / 2 - 64, 2, false, 2)
	   print("A", SCREEN_WIDTH / 2 - 28, SCREEN_HEIGHT / 2 - 64, 3, false, 2)
	   print("B", SCREEN_WIDTH / 2 - 16, SCREEN_HEIGHT / 2 - 64, 4, false, 2)
	   print("A", SCREEN_WIDTH / 2 - 4, SCREEN_HEIGHT / 2 - 64, 12, false, 2)
	   print("N", SCREEN_WIDTH / 2 + 8, SCREEN_HEIGHT / 2 - 64, 4, false, 2)
	   print("G", SCREEN_WIDTH / 2 + 20, SCREEN_HEIGHT / 2 - 64, 3, false, 2)
	   print("!", SCREEN_WIDTH / 2 + 32, SCREEN_HEIGHT / 2 - 64, 2, false, 2)
    print("by John Colagioia", SCREEN_WIDTH / 2 - 48, SCREEN_HEIGHT / 2 - 48, 13)
    print("BASED ON AN IDEA FROM", SCREEN_WIDTH / 2 - 62, SCREEN_HEIGHT / 2 - 20, 12)
    print("'Tesseract'", SCREEN_WIDTH / 2 - 32, SCREEN_HEIGHT / 2 - 4, 9)
    print("by Michael Peterson and Kevin Czapiewski", SCREEN_WIDTH / 2 - 75, SCREEN_HEIGHT / 2 + 10, 12, false, 1, true)
    print("AVAILABLE UNDER A CC-BY-SA 3.0 LICENSE", SCREEN_WIDTH / 2 - 74, SCREEN_HEIGHT / 2 + 18, 12, false, 1, true)
    print("PRESS  A  TO EXIT", SCREEN_WIDTH / 2 - 45, SCREEN_HEIGHT / 2 + 48, 12)

	   if btnp(4) then
				    about = false
				end
end

-- Display interface to get initials
function getInitials(score, rank)
    if iInitial > 2 then
        local n = initials[0] + initials[1] * 256 + initials[2] * 65536

        pmem(rank * 2 + 1, n)
        addInitials = false
    end

    print("NEW HIGH SCORE! ADD YOUR TAG:", SCREEN_WIDTH / 2 - 74, SCREEN_HEIGHT / 2 - 60, 12)
    print("UP/DOWN TO CHANGE", SCREEN_WIDTH / 2 - 46, SCREEN_HEIGHT / 2 + 40, 12)
    print("LEFT TO ACCEPT", SCREEN_WIDTH / 2 - 35, SCREEN_HEIGHT / 2 + 50, 12)

    for i = 0, 2 do
        local letter = "-"

        if i < iInitial then
            letter = ltr(initials[i])
        end

        if i == iInitial then
            letter = ltr(li)
            rectb(SCREEN_WIDTH / 2 - 32 + 24 * i, SCREEN_HEIGHT / 2 - 12, 18, 18, 13)
        end

        print(letter, SCREEN_WIDTH / 2 - 28 + 24 * i, SCREEN_HEIGHT / 2 - 8, 12, false, 2)
    end

    if btnp(0) then
        li = math.floor((li - 1) % #LETTERS)
    elseif btnp(1) then
        li = math.floor((li + 1) % #LETTERS)
    elseif btnp(3) then
        initials[iInitial] = li
        iInitial = iInitial + 1
    end
end

-- Rotate a sprite - Based on TEXTRI example
function rspr(sx,sy,scale,angle,mx,my,mw,mh,key,useMap)
    --  this is fixed , to make a textured quad
    --  X , Y , U , V
    local sv ={{-1,-1, 0,0},
               { 1,-1, 0.999,0},
               {-1,1,  0,0.999},
               { 1,1,  0.999,0.999}}
   	local rp = {} --  rotated points storage
    --  the scale is mw ( map width ) * 4 * scale 
    --  mapwidth is * 4 because we actually want HALF width to center the image
    local scalex = (mw<<2) * scale
    local scaley = (mh<<2) * scale
    --  rotate the quad points
    for p=1,#sv do 
        -- apply scale
        local _sx = sv[p][1] * scalex 
      		local _sy = sv[p][2] * scaley
        -- apply rotation
		      local a = -angle
    		  local rx = _sx * math.cos(a) - _sy * math.sin(a)
		      local ry = _sx * math.sin(a) + _sy * math.cos(a)
        -- apply transform
        sv[p][1] = rx + sx
        sv[p][2] = ry + sy
        -- scale UV's 
        sv[p][3] = (mx<<3) + (sv[p][3] * (mw<<3))
        sv[p][4] = (my<<3) + (sv[p][4] * (mh<<3))
    end

    -- draw two triangles for the quad
    textri( sv[1][1],sv[1][2],
            sv[2][1],sv[2][2],
            sv[3][1],sv[3][2],
            sv[1][3],sv[1][4],
            sv[2][3],sv[2][4],
            sv[3][3],sv[3][4],
            useMap,key)
    textri( sv[2][1],sv[2][2],
            sv[3][1],sv[3][2],
            sv[4][1],sv[4][2],
            sv[2][3],sv[2][4],
            sv[3][3],sv[3][4],
            sv[4][3],sv[4][4],
            useMap,key)
end

-- Draw the astronaut and chain
function drawAstronaut(angle, score)
    local rAstro = math.rad(astronautRotation)
    local rMines = math.rad(astronautRotation - 90)
    rspr(astronautX - ASTRONAUT_SIZE / 2, astronautY, 1, rAstro, 1, 0, 1, 1, 14, false)
    
    for i=1, score do
    				local r = ASTRONAUT_SIZE / 2 + i * MINE_SIZE
    				local x = astronautX - math.cos(rMines) * r - ASTRONAUT_SIZE / 2
    				local y = astronautY + math.sin(rMines) * r
    				circ(x, y, 1, 13)
    end
end

-- Draw pseudo-random stars
function starfield(games)
    local x = SCREEN_WIDTH / 13 * math.floor(games % 13) + SCREEN_WIDTH / 23
    local y = SCREEN_HEIGHT / 7 * math.floor(games % 7) + SCREEN_HEIGHT / 17
    local n = x * y + 31

    for i=1,50 do
      circ(x, y, 0, 4)
      n = (n * 1949 + 2969) % (SCREEN_WIDTH * SCREEN_HEIGHT)
      x = math.floor(n % (SCREEN_WIDTH - 10)) + 5
      n = (n * 2111 + 1709) % (SCREEN_WIDTH * SCREEN_HEIGHT)
      y = math.floor(n % (SCREEN_HEIGHT - 10)) + 5
    end
end

-- Test if player has caught a mine
function isCaught(angle, score, mineX, mineY)
    local rAstro = math.rad(astronautRotation)
    local rMines = math.rad(astronautRotation - 90)
				local r = ASTRONAUT_SIZE / 2 + score * MINE_SIZE
    local x = astronautX - math.cos(rMines) * r - ASTRONAUT_SIZE / 2
    local y = astronautY + math.sin(rMines) * r

				return close(mineX, x, 2) and close(mineY, y, 2)
end

-- Test if a mine has collided with the player
function playerHit(angle, score, mineX, mineY)
    local rMines = math.rad(astronautRotation - 90)
				local r = ASTRONAUT_SIZE / 2 + score * MINE_SIZE
    local x = - math.cos(rMines) * r
    local y = math.sin(rMines) * r
    local cx = astronautX - ASTRONAUT_SIZE / 2
    local cy = astronautY

				for i=0,r do
				    if close(mineX, cx, 2) and close(mineY, cy, 2) then
												return true
								end

								cx = cx + x / r
								cy = cy + y / r
				end

    return false
end

-- Create the next mine
function nextMine(score)
    local maxH = ASTRONAUT_SIZE + score * 2 * MINE_SIZE

	   mineX = SCREEN_WIDTH + 2
    mineY = SCREEN_HEIGHT / 2 + math.floor(math.random() * maxH) - maxH / 2
end

-- Check if a is less than tolerance pixels from b
function close(a, b, tolerance)
    return a > b - tolerance and a < b + tolerance
end

-- Add score to table, if high enough
function addScore(score)
    local found = -1

    for i=9, 0, -1 do
        if pmem(i * 2) < score then
            found = i
        end
    end

    if found < 0 then
        return -1
    end

    for i=8, found, -1 do
        pmem((i + 1) * 2, pmem(i * 2))
        pmem((i + 1) * 2 + 1, pmem(i * 2 + 1))
    end

    pmem(found * 2, score)
    return found
end

function ltr(n)
    local l = #LETTERS + 2
    local i = math.floor(n % l) + 1
    return LETTERS.sub(LETTERS, i, i)
end

function resetScores()
    for i = 0, 19 do
        pmem(i, 0)
    end
end
-- <TILES>
-- 001:00c00c0000200200092222900c0440c000c99c00000cc000000cc000009cc900
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060a000000000
-- 001:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300102000000000
-- 002:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000000
-- </SFX>

-- <PATTERNS>
-- 000:d77106021600404408b00006900006600006800006400006f00004000000b00004000000800006000000482106f00004b00004d00004428106800006600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:b00004000000000000000000000000000000000000000000600006000000500006000000000000000000000000000000000000000000000000000000b00004000000000000000000000000000000000000000000600006000000500006000000000000c00006000000b00006000000000000600008000000500008000000000000c00008000000b0000800000000000060000a00000050000a000000000000000000000000000000000000000000000000000000000000100000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eca2a0
-- 002:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

