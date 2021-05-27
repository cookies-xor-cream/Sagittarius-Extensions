require 'control'
require 'game'
require 'container'
require 'button'
require 'planet'
require 'player'
require 'arrow'
require 'playertoggle'
require 'levels'
require 'misc'
require 'starfield'
require 'anal'
require 'splatter'
require 'trail'
require 'toggle'
require 'winnotifier'

function love.load()
    math.randomseed(os.time())

    -- native window size
    nativeWindowWidth = 560
    nativeWindowHeight = 420

    -- load assets
    -- load art
    love.graphics.setDefaultFilter('nearest', 'nearest', 1)
    backgroundNoise = love.graphics.newImage('art/background-noise.png')
    -- individual player anims have to be loaded when each player is created so they can be different...
    playerWalkAnimSheet = love.graphics.newImage('art/player-walk.png')
    playerIdleAnimSheet = love.graphics.newImage('art/player-idle.png')
    playerBaseImg = love.graphics.newImage('art/player-sprite.png')
    playerHeadImg = love.graphics.newImage('art/player-head.png')
    playerArm1Img = love.graphics.newImage('art/player-arm1.png')
    playerArm2Power1Img = love.graphics.newImage('art/player-arm2-power1.png')
    playerArm2Power2Img = love.graphics.newImage('art/player-arm2-power2.png')
    playerArm2Power3Img = love.graphics.newImage('art/player-arm2-power3.png')
    playerWinAnim = newAnimation(love.graphics.newImage('art/player-idle-winner-anim.png'), 32, 32, 0.1, 4)

    playerIndicatorAnim = newAnimation(love.graphics.newImage('art/player-indicator.png'), 16, 16, 0.04, 6)
    playerIndicatorAnim:setMode('bounce')

    aimIndicatorHeadImg = love.graphics.newImage('art/aim-indicator-head.png')
    aimIndicatorTailImg = love.graphics.newImage('art/aim-indicator-tail.png')

    arrowIndicatorImg = love.graphics.newImage('art/arrow-indicator.png')

    arrowImg = love.graphics.newImage('art/arrow-sprite.png')
    arrowCrashedImg = love.graphics.newImage('art/arrow-crashed-sprite.png')

    trail1Img = love.graphics.newImage('art/trail1.png')

    splatter1Img = love.graphics.newImage('art/splatter1.png')
    splatter2Img = love.graphics.newImage('art/splatter2.png')
    splatter3Img = love.graphics.newImage('art/splatter3.png')

    togglePlusImg = love.graphics.newImage('art/toggle-plus.png')
    toggleMinusImg = love.graphics.newImage('art/toggle-minus.png')
    toggleOutlineImg = love.graphics.newImage('art/toggle-outline.png')

    winNotifierAnim = newAnimation(love.graphics.newImage('art/win-notifier-anim.png'), 128, 64, 0.04, 6)
    winNotifierAnim:setMode('bounce')
    winNotifierAnim:seek(6)

    titleImg = love.graphics.newImage('art/title.png')


    -- load fonts
    smallFont = love.graphics.newImageFont('font/open-sans-px-16.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~?"" ')
    mediumFont = love.graphics.newImageFont('font/open-sans-px-32.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~?"" ')
    largeFont = love.graphics.newImageFont('font/open-sans-px-48.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~?"" ')
    love.graphics.setFont(mediumFont)

    -- load sounds
    killSound = love.audio.newSource('sound/kill4.wav', 'static')
    crashSound = love.audio.newSource('sound/crash6.wav', 'static')
    crashSound:setVolume(0.8)
    winSound = love.audio.newSource('sound/win8.wav', 'static')
    timeoutSound = love.audio.newSource('sound/timeout5.wav', 'static')
    timeoutSound:setVolume(0.5)
    fireSound = love.audio.newSource('sound/fire15.wav', 'static')
    walk1Sound = love.audio.newSource('sound/walk1.wav', 'static')
    walk1Sound:setVolume(0.2)
    walk2Sound = love.audio.newSource('sound/walk2.wav', 'static')
    walk2Sound:setVolume(0.2)
    debugSound = love.audio.newSource('sound/debug.wav', 'static')

    sounds = true

    love.audio.setVolume(0.8)

    -- load music
    track1 = love.audio.newSource('music/artblock.ogg', 'static')
    track1:setLooping(true)
    track1:setVolume(0.3)
    track1:play()

    -- colors
    -- hue is the color
    -- player:
    -- s = 70
    -- v = 98

    -- planet:
    -- s = 35
    -- v = 91

    --detail:
    --s=35
    --v=74
    whiteColor = {r= 0.86, g= 0.86, b= 0.90}
    white2Color = {r= 0.90, g= 0.90, b= 0.94}

    blackColor = {r= 0.10, g= 0.10, b= 0.13}

    redColor = {r= 0.98, g= 0.29, b= 0.32} --h= 1.40
    red2Color = {r= 0.91, g= 0.59, b= 0.60}
    red3Color = {r= 0.86, g= 0.56, b= 0.57}

    orangeColor = {r= 0.98, g= 0.53, b= 0.29} --h= 0.08
    orange2Color = {r= 0.91, g= 0.70, b= 0.59}
    orange3Color = {r= 0.86, g= 0.66, b= 0.56}

    --yellowColor = {r= 0.91, g= 0.98, b= 0.29} --h= 0.26
    yellow2Color = {r= 0.88, g= 0.91, b= 0.59}
    yellow3Color = {r= 0.83, g= 0.86, b= 0.56}

    greenColor = {r= 0.29, g= 0.98, b= 0.36} --114
    green2Color = {r= 0.62, g= 0.91, b= 0.59}
    green3Color = {r= 0.59, g= 0.86, b= 0.56}

    --turquoiseColor = {r= 0.29, g= 0.98, b= 0.70} --h= 0.61
    turquoise2Color = {r= 0.59, g= 0.91, b= 0.78}
    turquoise3Color = {r= 0.56, g= 0.86, b= 0.74}

    --cyanColor = {r= 0.29, g= 0.98, b= 0.92} --h= 0.71
    cyan2Color = {r= 0.59, g= 0.90, b= 0.91}
    cyan3Color = {r= 0.56, g= 0.85, b= 0.86}

    blueColor = {r= 0.29, g= 0.43, b= 0.98} --h= 0.89
    blue2Color = {r= 0.59, g= 0.65, b= 0.91}
    blue3Color = {r= 0.56, g= 0.62, b= 0.86}

    --purpleColor = {r= 0.59, g= 0.29, b= 0.98} --h= 1.03
    purple2Color = {r= 0.71, g= 0.59, b= 0.91}
    purple3Color = {r= 0.67, g= 0.56, b= 0.86}

    pinkColor = {r= 0.98, g= 0.29, b= 0.74} --h= 1.26
    pink2Color = {r= 0.91, g= 0.59, b= 0.80}
    pink3Color = {r= 0.82, g= 0.56, b= 0.75}


    control = Control:new()
    game = Game:new('Menu')

    canvas = love.graphics.newCanvas(560, 420)
    canvas:setFilter('nearest', 'nearest')

    debug = false -- HOLY FUCK TODO DON'T FORGET THIS AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH

    colorblind = false

    tutorial = true

    tutShown = false
end

function love.update(dt)
    if dt > 1/30 then
        dt = 1/30
    end

    -- determine window scale and offset
    windowScaleX = love.graphics.getWidth() / nativeWindowWidth
    windowScaleY = love.graphics.getHeight() / nativeWindowHeight
    windowScale = math.min(windowScaleX, windowScaleY)
    windowOffsetX = (windowScaleX - windowScale) * (nativeWindowWidth / 2)
    windowOffsetY = (windowScaleY - windowScale) * (nativeWindowHeight / 2)

    -- update game
    control:update(dt)
    game:update(dt)

    if (control:keyPressed('f') and control:keyDown('j')) or (control:keyPressed('j') and control:keyDown('f')) then
        if sounds then
            debugSound:stop()
            debugSound:play()
        end
        debug = not debug
    end
end

function love.draw()
    -- draw game at correct scale and offset
    love.graphics.push()
    --love.graphics.translate(windowOffsetX, windowOffsetY)
    --love.graphics.scale(windowScale, windowScale)
    love.graphics.setCanvas(canvas)
    game:draw()

    love.graphics.setCanvas()
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, windowOffsetX, windowOffsetY, 0, windowScale, windowScale)
    -- canvas:clear()

    -- draw letterboxes
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, windowOffsetX, love.graphics.getHeight())
    love.graphics.rectangle('fill', love.graphics.getWidth() - windowOffsetX, 0, windowOffsetX, love.graphics.getHeight())
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), windowOffsetY)
    love.graphics.rectangle('fill', 0, love.graphics.getHeight() - windowOffsetY, love.graphics.getWidth(), windowOffsetY)
end