local class = require 'middleclass'
local stateful = require 'stateful'

-- game class
Game = class('Game')
Game:include(stateful)

function Game:initialize(state)
    self.moved = false
    self.aimed = false
    self.fired = false
    self.winned = false

    self.timeSinceLast = 0


    self.numPlayers = 2
    self.isPlaying = {true, true, false, false, false}
    self.gravity = 5500--4000

    self:gotoState(state)

    self.playerScores = {0, 0, 0, 0, 0}
end

-- menu state
Menu = Game:addState('Menu')

function Menu:enteredState()
    self.playButton = Button:new(258, 210, 45, 35, 'play', function() if tutorial then game:gotoState('Tutorial') else game:gotoState('Setup') end end, 1)
    self.optionsButton = Button:new(238, 245, 85, 35, 'options', function() game:gotoState('Options') end, 9)
    self.creditsButton = Button:new(240, 280, 80, 35, 'credits', function() game:gotoState('Credits') end, 8)
    self.quitButton = Button:new(258, 315, 44, 35, 'quit', function() love.event.quit() end, 2)
    self.titleColorId = 1

    self.selectedButton = 1
    self.menuButtons = {
        self.playButton,
        self.optionsButton,
        self.creditsButton,
        self.quitButton
    }
end

function Menu:update(dt)
    for i, btn in pairs(self.menuButtons) do
        btn:update(dt, self.selectedButton == i)
    end

    gamepadDirection = control:keypadPressed()

    if gamepadDirection['up'] then
        self.selectedButton = self.selectedButton - 1
    end

    if gamepadDirection['down'] then
        self.selectedButton = self.selectedButton + 1
    end

    -- modular arithmetic sucks in 1-indexed languages: implements wraparound for menu
    self.selectedButton = (self.selectedButton + #self.menuButtons - 1) % #self.menuButtons + 1

    -- self.selectionButton %= num buttons
    -- if it's 0 then += 1

    if control:triggerPressed() then
        self.menuButtons[self.selectedButton]:onPress()
    end

    if control:backPressed() then
        love.event.quit()
    end

    if control:keyPressed('escape') and not love.window.getFullscreen() then
        love.event.quit()
    end

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=560, minheight=420})
    end

    if control:keyPressed('space') and not love.window.getFullscreen() then
        love.window.setMode(0, 0, {fullscreen=true, resizable=false})
    end
end

function Menu:draw()
    love.graphics.clear()   -- cleared canvas before each draw
    love.graphics.setCanvas{canvas, stencil=true}

    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)

    for i, btn in pairs(self.menuButtons) do
        -- selected = self.selectedButton == i
        btn:draw()
    end

    -- print("\n")

    setColor(self.titleColorId, 2)
    love.graphics.draw(titleImg, nativeWindowWidth/2 - 198, 83)
    setColor(self.titleColorId, 1)
    love.graphics.draw(titleImg, nativeWindowWidth/2 - 201, 80)
end

function Menu:exitedState()
end

-- credits state
Credits = Game:addState('Credits')

function Credits:enteredState()
    self.menuButton = Button:new(30, 370, 48, 35, 'back', function() game:gotoState('Menu') end, 4)
    self.georgeButton = Button:new(250, 140, 193, 35, 'George Prosser', function() love.system.openURL('https://twitter.com/jecatjecat') end, 4)
    self.janButton = Button:new(308, 200, 75, 35, 'Jan125', function() love.system.openURL('http://opengameart.org/users/jan125') end, 4)
end

function Credits:update(dt)
    self.menuButton:update(dt)
    self.georgeButton:update(dt)
    self.janButton:update(dt)

    if control:backPressed() then
        self.menuButton:onPress()
    end

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=560, minheight=420})
    end
end

function Credits:draw()
    love.graphics.clear()   -- cleared canvas before each draw
    love.graphics.setCanvas{canvas, stencil=true}

    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle('rough')
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.line(250, 170, 440, 170)
    love.graphics.line(308, 230, 385, 230)


    love.graphics.setFont(mediumFont)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('credits', 244, 30)
    love.graphics.print('game by', 123, 140)
    love.graphics.print('music by', 184, 200)


    self.menuButton:draw()
    for i, btn in pairs(self.menuButtons) do
        btn:draw()
    end
end

function Credits:exitedState()
end

-- options state
Options = Game:addState('Options')

function Options:enteredState()
    self.menuButton = Button:new(30, 370, 48, 35, 'back', function() game:gotoState('Menu') end, 4)
    self.fullscreenToggle = Toggle:new(380, 120, love.window.getFullscreen(), function() love.window.setMode(1120, 840, {fullscreen=not love.window.getFullscreen(), fullscreentype='desktop', resizable=true, centered=true, minwidth=560, minheight=420}) end, math.random(5, 9))
    self.colorblindToggle = Toggle:new(380, 280, colorblind, function() colorblind = not colorblind end, math.random(5, 9))
    self.tutorialToggle = Toggle:new(380, 240, tutorial, function() tutorial = not tutorial; tutShown = false; self.moved = false; self.aimed = false; self.fired = false; self.cancelled = false; self.winned = false; end, math.random(5, 9))
    self.volumeToggle = Toggle:new(380, 160, sounds, function() sounds = not sounds end, math.random(5, 9))
    self.musicToggle = Toggle:new(380, 200, track1:isPlaying(), function() if track1:isPlaying() then track1:stop() else track1:play() end end, math.random(5, 9))

    self.selectedButton = 1
    
    self.menuButtons = {
        self.fullscreenToggle,
        self.volumeToggle,
        self.musicToggle,
        self.tutorialToggle,
        self.colorblindToggle
    }
end

function Options:update(dt)
    -- self.menuButton:update(dt, false)

    -- print(self.selectedButton)

    for i, btn in pairs(self.menuButtons) do
        btn:update(dt, self.selectedButton == i)
    end

    gamepadDirection = control:keypadPressed()

    if gamepadDirection['up'] then
        self.selectedButton = self.selectedButton - 1
    end

    if gamepadDirection['down'] then
        self.selectedButton = self.selectedButton + 1
    end

    -- modular arithmetic sucks in 1-indexed languages: implements wraparound for menu
    self.selectedButton = (self.selectedButton + #self.menuButtons - 1) % #self.menuButtons + 1

    if control:backPressed() then
        self.menuButton:onPress()
    end

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=560, minheight=420})
        self.fullscreenToggle = Toggle:new(380, 120, love.window.getFullscreen(), function() love.window.setMode(1120, 840, {fullscreen=not love.window.getFullscreen(), fullscreentype='desktop', resizable=true, centered=true, minwidth=560, minheight=420}) end, math.random(5, 9))
    end
end

function Options:draw()
    love.graphics.clear()   -- cleared canvas before each draw
    love.graphics.setCanvas{canvas, stencil=true}

    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)

    self.menuButton:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('fullscreen', 140, 120)
    self.fullscreenToggle:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('colorblind mode', 140, 280)
    self.colorblindToggle:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('show tutorial', 140, 240)
    self.tutorialToggle:draw()

    love.graphics.setFont(mediumFont)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('options', 240, 30)

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('sounds', 140, 160)
    self.volumeToggle:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('music', 140, 200)
    self.musicToggle:draw()
end

function Options:exitedState()
end

-- setup state
Setup = Game:addState('Setup')

function Setup:enteredState()
    self.playerIdleAnim = newAnimation(playerIdleAnimSheet, 32, 32, 0.1, 4)

    self.playerToggles = Container:new()
    for i=1, 5 do
        self.playerToggles:add(PlayerToggle:new(164 + (i-1) * 50, 208, i))
    end

    self.menuButton = Button:new(30, 370, 49, 35, 'back', function() game:gotoState('Menu') end, 4)
    if tutorial then
        self.playButton = Button:new(450, 370, 69, 35, 'tutorial', function() if tutorial then game:gotoState('Tutorial') else game:gotoState('Versus') end end, 1)
    else
        self.playButton = Button:new(450, 370, 69, 35, 'start!', function() if tutorial then game:gotoState('Tutorial') else game:gotoState('Versus') end end, 1)
    end
end

function Setup:update(dt)
    self.playerToggles:update(dt)
    self.menuButton:update(dt)

    if control:backPressed() then
        self.menuButton:onPress()
    end

    if control:nextPressed() then
        self.playButton:onPress()
    end
    
    -- check num players
    self.numPlayers = 0
    for i=1, #self.isPlaying do
        if self.isPlaying[i] then
            self.numPlayers = self.numPlayers + 1
        end
    end

    gamepadDirection = control:keypadPressed()

    -- add a player when you press right
    -- adds players from the left hand side
    if gamepadDirection['right'] and self.numPlayers <= 5 then
        for i, playing in pairs(self.isPlaying) do
            if not playing then
                self.isPlaying[i] = true
                break
            end
        end
    end

    -- remove a player when you press left
    -- removes players from the right hand side
    if gamepadDirection['left'] and self.numPlayers > 2 then
        for i=5,1,-1 do
            if self.isPlaying[i] then
                self.isPlaying[i] = false
                break
            end
        end
    end

    if self.numPlayers >= 2 then
        if control:keyPressed('return') then
            self:gotoState('Versus')
        end

        self.playButton:update(dt)
    end

    self.playerIdleAnim:update(dt)

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=560, minheight=420})
    end
end

function Setup:draw()
    love.graphics.clear()   -- cleared canvas before each draw
    love.graphics.setCanvas{canvas, stencil=true}

    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.setFont(mediumFont)
    --love.graphics.print('select players:', 194, 90)
    love.graphics.print('select players', 194, 30)

    self.playerToggles:draw()
    if self.numPlayers >= 2 then
        self.playButton:draw()
    else
        love.graphics.setFont(mediumFont)
        love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
        if self.numPlayers == 0 then
            love.graphics.print('need 2 more players', 153, 300)
        else
            love.graphics.print('need 1 more player', 163, 300)
        end
    end

    self.menuButton:draw()
end

function Setup:exitedState()
end

-- tutorial
Tutorial = Game:addState('Tutorial')

function Tutorial:enteredState()
    self.tutTimer = 0
    tutorial = false
    self.backButton = Button:new(30, 370, 49, 35, 'back', function() if not tutShown then tutorial=true; self.moved = false; self.aimed = false; self.fired = false; self.winned = false; end game:gotoState('Menu') end, 4)
    self.playButton = Button:new(480, 370, 47, 35, 'play', function() game:gotoState('Setup') end, 1)
    self.skipButton = Button:new(480, 370, 47, 35, 'skip', function() game:gotoState('Setup') end, 1)

    self.splatters = Container:new()
    self.trails = Container:new()

    -- planets
    self.planets = Container:new()
    self.planets:add(Planet:new(200, 220, 45, true))
    self.planets:add(Planet:new(380, 130, 35, true))

    -- players
    self.players = Container:new()
    self.players:add(Player:new(1, 1, 3))
    self.players:add(Player:new(2, 2, 4))
    self.currentPlayer = 1
    self.players.contents[self.currentPlayer].controlled = true


    -- arrows
    self.arrows = Container:new()


    -- game state
    self.turnState = 'aiming'
    self.gameOver = false
    self.winner = 1

    self.wonTime = 0
end

function Tutorial:update(dt)
    if control:backPressed() then
        self.backButton:onPress()
    end

    if control:nextPressed() then
        self.skipButton:onPress()
    end

    local leftstick = control:analogueInput(0)

    local moveRight =   (control:keyDown('right') or control:keyDown('d') or control:keyDown('e')) and
                        leftstick.x > 0.2

    local moveLeft  =   (control:keyDown('left') or control:keyDown('a') or control:keyDown('q'))  and
                        leftstick.x < 0.2

    if moveRight or moveLeft then
        self.moved = true
        self.timeSinceLast = 0
    end

    if ((control:mousePressed('l') or control:triggerPressed()) and self.moved) and not self.aimed then
        self.aimed = true
        self.timeSinceLast = 0
    end

    if ((control:mouseReleased('l') or control:triggerReleased()) and self.aimed) and not self.fired then
        self.fired = true
        self.timeSinceLast = 0
    end

    if tutShown then
        self.playButton:update(dt)
    else
        self.skipButton:update(dt)
    end

    self.timeSinceLast = self.timeSinceLast + dt

    playerWinAnim:update(dt)


    self.splatters:update(dt)
    self.trails:update(dt)
    self.players:update(dt)
    self.arrows:update(dt)

    -- win state check
    self.numAlive = 0
    for i=1, #self.players.contents do
        if self.players.contents[i].alive then
            self.numAlive = self.numAlive + 1
            self.winner = self.players.contents[i].id
        end
    end

    if self.numAlive == 1 then
        self.gameOver = true
    end


    -- changing to next player
    if self.turnState == 'over' and not self.gameOver then
        self.turnState = 'aiming'

        self.players.contents[self.currentPlayer].controlled = true
    end


    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=560, minheight=420})
    end

    if self.gameOver then
        self.winned = true
        self.wonTime = self.wonTime + dt
        if self.wonTime > 3 and not tutShown then
            self:gotoState('Tutorial')
        end
    end

    self.backButton:update(dt)

    self.tutTimer = self.tutTimer + dt
end

function Tutorial:draw()
    love.graphics.clear()   -- cleared canvas before each draw
    love.graphics.setCanvas{canvas, stencil=true}

    -- background
    love.graphics.setColor(blackColor.r, blackColor.r, blackColor.b)
    love.graphics.rectangle('fill', 0, 0, nativeWindowWidth, nativeWindowHeight)

    self.planets:draw()
    self.splatters:draw()
    self.trails:draw()
    self.arrows:draw()
    self.players:draw()

    if tutShown then
        self.playButton:draw()
    else
        self.skipButton:draw()
    end

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.setFont(mediumFont)

    if (not self.moved) or (self.moved and self.timeSinceLast < 1 and not self.aimed and not self.fired and not self.winned) then
        love.graphics.print('use LEFT and RIGHT keys to move', 63, 300)
    elseif (not self.aimed) or (self.aimed and self.timeSinceLast < 1.5 and not self.fired and not self.winned) then
        love.graphics.print('click and drag anywhere to aim', 78, 300)
    elseif (not self.fired) or (self.fired and self.timeSinceLast < 2 and not self.winned) then
        love.graphics.print('release to fire or right click to cancel', 36, 300)
    elseif (not self.winned) or (self.winned and self.timeSinceLast < 2) then
        love.graphics.print('last player standing wins', 120, 300)
    else
        tutShown = true
    end

    self.backButton:draw()

    love.graphics.setFont(mediumFont)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('how to play', 206, 30)
end

function Tutorial:exitedState()
end

-- versus state
Versus = Game:addState('Versus')

function Versus:enteredState()
    self.winNotifier = WinNotifier:new()
    self.splatters = Container:new()
    self.trails = Container:new()
    self.continueButton = Button:new(483, 370, 50, 35, 'next', function() game:gotoState('Versus') end, 1)
    self.backButton = Button:new(30, 370, 49, 35, 'back', function() game:gotoState('Setup') end, 4)

    -- planets
    -- semi-randomized from list
    self.planets = Container:new()
    local levelNumber = math.random(1, #levels[self.numPlayers])
    for i=1, #levels[self.numPlayers][levelNumber] do
        self.planets:add(Planet:new(levels[self.numPlayers][levelNumber][i][1], levels[self.numPlayers][levelNumber][i][2], levels[self.numPlayers][levelNumber][i][3], levels[self.numPlayers][levelNumber][i][4]))
    end

    -- randomly flip
    -- horizontally
    if chance(0.5) then
        for i=1, #self.planets.contents do
            self.planets.contents[i].x = nativeWindowWidth - self.planets.contents[i].x
        end
    end

    -- vertically
    if chance(0.5) then
        for i=1, #self.planets.contents do
            self.planets.contents[i].y = nativeWindowHeight - self.planets.contents[i].y
            self.planets.contents[i].y = self.planets.contents[i].y
        end
    end

    self.starfield = Starfield:new()

    -- players
    self.players = Container:new()

    self.order = {}
    for i=1, #self.isPlaying do
        if self.isPlaying[i] then
            table.insert(self.order, i)
        end
    end
    shuffleTable(self.order)
    shuffleTable(self.order)
    shuffleTable(self.order) -- 3 times for luck!
    for j=1, #self.order do
        local planet = 0
        repeat
            planet = math.random(1, #self.planets.contents)
        until self.planets.contents[planet].id == 0 and self.planets.contents[planet].occupiable
        self.players:add(Player:new(self.order[j], planet))
    end
    self.currentPlayer = 1
    self.players.contents[self.currentPlayer].controlled = true


    -- arrows
    self.arrows = Container:new()


    -- game state
    self.turnState = 'aiming'
    self.gameOver = false
    self.winner = 1
    self.winnerindex = 1

    self.winTime = 0

    self.deathTimer = 10
end

function Versus:update(dt)
    if control:backPressed() then
        self.menuButton:onPress()
    end

    -- hacky slo-mo when somebody gets hit
    -- should be mostly imperceptable, just feels good
    -- VERY FINELY TUNED, THINK HARD BEFORE FIDDLING ANY MORE
    self.deathTimer = self.deathTimer + dt
    if self.deathTimer < 0.18 then
        love.timer.sleep(0.04 * (0.54 - self.deathTimer)/0.54)
    elseif self.deathTimer > 100 then
        self.deathTimer = 10
    end
    playerWinAnim:update(dt)


    self.winNotifier:update(dt)
    self.splatters:update(dt)
    self.trails:update(dt)
    self.starfield:update(dt)
    self.players:update(dt)
    self.arrows:update(dt)

    -- win state check
    self.numAlive = 0
    for i=1, #self.players.contents do
        if self.players.contents[i].alive then
            self.numAlive = self.numAlive + 1
            self.winner = self.players.contents[i].id
            self.winnerindex = i
        end
    end

    if self.numAlive == 1 then
        self.gameOver = true
    end


    -- changing to next player
    if self.turnState == 'over' and not self.gameOver then
        self.turnState = 'aiming'

        repeat
            self.currentPlayer = self.currentPlayer + 1
            if self.currentPlayer > self.numPlayers then
                self.currentPlayer = 1
            end
        until self.players.contents[self.currentPlayer].alive

        self.players.contents[self.currentPlayer].controlled = true
    end

    self.backButton:update(dt)
    if self.gameOver then
        if control:keyPressed('return') then
            self:gotoState('Versus')
        end
        self.winTime = self.winTime + dt
        if self.winTime > 1.5 then
            if not self.winNotifier.begun then
                self.winNotifier:begin(self.winnerindex)
                self.playerScores[self.winner] = self.playerScores[self.winner] + 1
                if sounds then
                    winSound:play()
                end
            end
            self.continueButton:update(dt)

            if control:nextPressed() then
                self.continueButton:onPress()
            end
        end
    end

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=560, minheight=420})
    end

end

function Versus:draw()
    love.graphics.clear()   -- cleared canvas before each draw
    love.graphics.setCanvas{canvas, stencil=true}
    
    -- background
    love.graphics.setColor(blackColor.r, blackColor.r, blackColor.b)
    love.graphics.rectangle('fill', 0, 0, nativeWindowWidth, nativeWindowHeight)

    -- stars
    self.starfield:draw()

    self.planets:draw()
    self.splatters:draw()
    self.trails:draw()
    self.arrows:draw()

    for i=1, #self.players.contents do
        if i ~= self.currentPlayer then
            self.players.contents[i]:draw()
        end
    end
    self.players.contents[self.currentPlayer]:draw()

    if self.gameOver then
        if self.winTime > 1.5 then
            self.continueButton:draw()
            self.winNotifier:draw()

            local i = 0
            for j=1, #self.isPlaying do
                if self.isPlaying[j] then
                    i = i + 1
                    setColor(j, 1)
                    love.graphics.setFont(mediumFont)
                    love.graphics.circle('fill', nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 24, 389, 15)
                    --love.graphics.roundrectangle('fill', nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 40, 15, 30, 30, 8)
                    love.graphics.setColor(blackColor.r, blackColor.r, blackColor.b)
                    if self.playerScores[j] < 10 then
                        love.graphics.print(self.playerScores[j], nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 29, 373)
                    else
                        love.graphics.print(self.playerScores[j], nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 35, 373)
                    end
                    if colorblind then
                        love.graphics.setFont(smallFont)
                        setColor(j, 2)
                        love.graphics.print(j, nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 26, 359)
                    end
                end
            end
        end
    end
    self.backButton:draw()

    --debug box
    --setColor(0, 1)
    --love.graphics.rectangle('line', 80, 80, nativeWindowWidth - 160, nativeWindowHeight - 160)
end

function Versus:exitedState()
end