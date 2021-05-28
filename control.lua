local class = require 'middleclass'

-- control class
Control = class('Control')

function Control:initialize()
    self.states = {}
    self.states.mouseDown       = {l = false, r = false}
    self.states.mouseWasDown    = {l = false, r = false}
    self.states.mousePressed    = {l = false, r = false}
    self.states.mouseReleased   = {l = false, r = false}

    self.mouseMap = {l = 1, r = 2} -- converts l and r into mouse button ids

    -- joystick stuff
    self.joysticks = love.joystick.getJoysticks()

    self.states.triggerDown     = false
    self.states.triggerPressed  = false
    self.states.triggerReleased = false

    self.triggerIdsMap  = {rt = 8, lt = 7, x = 4, a = 1}

    self.states.nextDown        = false 
    self.states.nextPressed     = false
    self.states.nextReleased    = false

    self.nextId                 = 10

    self.states.backDown        = false 
    self.states.backPressed     = false
    self.states.backReleased    = false

    self.backId                 = 2 -- b button id

    -- gamepad/analogue stuff
    self.gamepadIdsMap = {up = 14, down = 15, left = 16, right = 17}

    self.states.directionDown      = {up = false, down = false, left = false, right = false}
    self.states.directionPressed   = {up = false, down = false, left = false, right = false}
    self.states.directionReleased  = {up = false, down = false, left = false, right = false}

    self.states.keyDown = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    ['space'] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    } -- not all the keys! https://love2d.org/wiki/KeyConstant

    self.states.keyWasDown = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    ['space'] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    }

    self.states.keyPressed = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    ['space'] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    }

    self.states.keyReleased = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    ['space'] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    }
end

function Control:activeInput()
    print(2)
    return true
end

function Control:update(dt)

    -- update joystick variables
    for key, joystick in pairs(self.joysticks) do

        -- check trigger buttons
        isDown = false

        for key, id in pairs(self.triggerIdsMap) do
            isDown = isDown or joystick:isDown(id)
        end

        self.states.triggerPressed  = (not self.states.triggerDown and isDown)
        self.states.triggerReleased = (not isDown and self.states.triggerDown)
        self.states.triggerDown     = isDown

        -- check next buttons
        isDown = joystick:isDown(self.nextId)

        self.states.nextPressed     = (not self.states.nextDown and isDown)
        self.states.nextReleased    = (not isDown and self.states.nextDown)
        self.states.nextDown        = isDown

        -- check back buttons
        isDown = joystick:isDown(self.backId)

        self.states.backPressed     = (not self.states.backDown and isDown)
        self.states.backReleased    = (not isDown and self.states.backDown)
        self.states.backDown        = isDown

        -- check gamepad
        for key, id in pairs(self.gamepadIdsMap) do
            isDown = joystick:isDown(id)

            self.states.directionPressed[key]   = (not self.states.directionDown[key] and isDown)
            self.states.directionReleased[key]  = (not isDown and self.states.directionDown[key])
            self.states.directionDown[key]      = isDown
        end
    end

    -- current state
    for key, value in pairs(self.states.mouseDown) do
        self.states.mouseDown[key] = love.mouse.isDown(self.mouseMap[key])
    end

    for key, value in pairs(self.states.keyDown) do
        self.states.keyDown[key] = love.keyboard.isDown(key)
    end


    -- determine presses and releases
    for key, value in pairs(self.states.mousePressed) do
        self.states.mousePressed[key] = self.states.mouseDown[key] and not self.states.mouseWasDown[key]
    end

    for key, value in pairs(self.states.mouseReleased) do
        self.states.mouseReleased[key] = not self.states.mouseDown[key] and self.states.mouseWasDown[key]
    end


    for key, value in pairs(self.states.keyPressed) do
        self.states.keyPressed[key] = self.states.keyDown[key] and not self.states.keyWasDown[key]
    end

    for key, value in pairs(self.states.keyReleased) do
        self.states.keyReleased[key] = not self.states.keyDown[key] and self.states.keyWasDown[key]
    end


    -- save current state as old state
    for key, value in pairs(self.states.mouseWasDown) do
        self.states.mouseWasDown[key] = self.states.mouseDown[key]
    end

    for key, value in pairs(self.states.keyWasDown) do
        self.states.keyWasDown[key] = self.states.keyDown[key]
    end
end

function Control:triggerPressed()
    return self.states.triggerPressed
end

function Control:nextPressed()
    return self.states.nextPressed
end

function Control:backPressed()
    return self.states.backPressed
end

function Control:keypadPressed()
    return self.states.directionPressed
end

function Control:mouseDown(key)
    return self.states.mouseDown[key]       or self.states.triggerDown
end

function Control:mousePressed(key)
    return self.states.mousePressed[key]    or self.states.triggerPressed
end

function Control:mouseReleased(key)
    return self.states.mouseReleased[key]   or self.states.triggerReleased
end

function Control:keyDown(key)
    return self.states.keyDown[key]
end

function Control:keyPressed(key)
    return self.states.keyPressed[key]
end

function Control:keyReleased(key)
    return self.states.keyReleased[key]
end