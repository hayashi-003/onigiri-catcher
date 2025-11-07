function love.load()
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    --PLAYER BLOCK
    player = {}
    player.x = 620
    player.y = 390
    player.sprite = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid( 12, 18, player.sprite:getWidth(), player.sprite:getHeight() )

    --OBJECT BLOCK
    onigiri = {}
    spawnTimer = 0
    spwanInterval = 2
    score = 0
    lives = 5


    font = love.graphics.newFont("font/pizel.otf",50)
    love.graphics.setFont(font)

    --ANIMATION BLOACK
    player.animation = {}
    player.animation.down = anim8.newAnimation( player.grid('1-4', 1), 0.2 )
    player.animation.left = anim8.newAnimation( player.grid('1-4', 2), 0.2 )
    player.animation.right = anim8.newAnimation( player.grid('1-4', 3), 0.2 )
    player.animation.up = anim8.newAnimation( player.grid('1-4', 4), 0.2 )
    player.anim = player.animation.left

    background = love.graphics.newImage('sprites/background.jpg')
    riceball = love.graphics.newImage('sprites/riceball.png')


    showLevelUp = false
    levelUpTimer = 0
    levelUpSound = love.audio.newSource("sound/level up.mp3", "static")

     gamoverTimer = 0
     overdealy = 3
    level = 1
    
end

function love.update(dt)
    speed = 380
    math.randomseed(os.time())

    gameover = false
    if gameover then
        return
    end
    --MOVING LOGIC 
        local isMoving = false
        if love.keyboard.isDown("right") then
            player.x = math.min(player.x + speed *dt, love.graphics:getWidth() - player.sprite:getWidth())
            player.anim = player.animation.right
            isMoving = true
        end
        if love.keyboard.isDown("left") then
            player.x = math.max(player.x - speed *dt, 0)
            player.anim = player.animation.left
            isMoving = true
        end
        --[[if love.keyboard.isDown("up") then
            player.y = player.y - speed *dt
            player.anim = player.animation.up
            isMoving = true
        end
        if love.keyboard.isDown("down") then
            player.y = player.y + speed *dt
            player.anim = player.animation.down
            isMoving = true
        end]]

        if isMoving == false then
            player.anim:gotoFrame(2)
        end

        spawnTimer = spawnTimer - dt
        if spawnTimer <= 0 then
            spawnTimer = spwanInterval
            spawnObject()
        end
        for i = #onigiri, 1, -1 do
            local obj = onigiri[i]
            obj.y = obj.y + obj.speed *dt
                if checkCollison(player.x, player.y, player.sprite:getWidth(), player.sprite:getHeight(), obj.x, obj.y, obj.size, obj.size) then
                    score = score + 1
                    table.remove(onigiri, i)
                elseif obj.y > love.graphics.getHeight() then
                    lives = lives - 1
                    table.remove(onigiri, 1)
                
                end
        end    

        for _, obj in ipairs(onigiri) do 
            obj.y = obj.y + obj.speed *dt
            obj.rotation = obj.rotation + obj.rotationSpeed * dt
        end

    if lives <= 0 then 
        gameover = true;
        if gameover then
            gamoverTimer = gamoverTimer + dt
            if gamoverTimer >= overdealy then 
                love.event.quit()
            end
        end

    end 
    
    if score >= level * 10 and level < 6 then
        level = level + 1 
        showLevelUp = true
        levelUpTimer = 0
        love.audio.play(levelUpSound)
    end

    if showLevelUp then 
        levelUpTimer = levelUpTimer + dt
        if levelUpTimer >= 2 then
            showLevelUp = false
        end
    end
  

    player.anim:update(dt)
end

function love.draw()
    bgX = love.graphics:getWidth() / background:getWidth()
    bgY = love.graphics:getHeight() / background:getHeight()
    love.graphics.draw(background, 0, 0, nil, bgX, bgY)
    player.anim:draw(player.sprite, player.x, player.y, nil, 8)


    
    for _, obj in ipairs(onigiri) do
        local ox = riceball:getWidth() / 2
        local oy = riceball:getHeight() / 2
        love.graphics.draw(riceball, obj.x + ox, obj.y + oy, obj.rotation, obj.size, obj.size, ox, oy)
    end

    love.graphics.setColor(1,1,1)
    love.graphics.print("Score: ".. score, 20,20)
    love.graphics.print("Lives: ".. lives, 20, 55)

    if showLevelUp then
        love.graphics.print("LEVEL UP!", 220, 130, 0, 2, 2)
    end

    if gameover then
        love.graphics.printf("Game Over", 0, love.graphics.getHeight()/2 - 10, love.graphics.getWidth(), "center")
    end
    
end



function spawnObject()
    local obj = {}
    obj.x = math.random(0, love.graphics.getWidth() - 20)
    obj.y = -15
    obj.size = 2
    obj.rotation = math.random() * 2 * math.pi 
    obj.rotationSpeed = math.random(-1, 1) * 0.5
     if level == 1 then
        obj.speed = math.random(110, 150)
        speed = 400
    elseif level == 2 then
        obj.speed = math.random(160, 200)
        spwanInterval = 1
        speed = 430
    else
        obj.speed = math.random(210, 230)
    end
    table.insert(onigiri, obj)
end

function checkCollison(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1 
end
