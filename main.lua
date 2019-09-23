require("Libs/camera")
require("player")
require("obstacle")

wf = require 'Libs/windfield/windfield'

local serialize = require 'Libs/Ser/ser'

require 'collision_shapes'

local spawn_position = {  x = 350 , y = 350  }

function loadCollisionShapes()
    inner_boundary = world:newChainCollider(false, vertices[1]) 
    inner_boundary:setType('static')
    inner_boundary:setCollisionClass('Obstacle')

    outer_boundary = world:newChainCollider(false, vertices[2]) 
    outer_boundary:setType('static')
    outer_boundary:setCollisionClass('Obstacle')
end

function loadPhysics()
    world = wf.newWorld(0, 0, true)
    world:setGravity(0, 0)
    world:addCollisionClass('Player')
    world:addCollisionClass('Obstacle', {ignores = {'Obstacle'}})

    car = world:newBSGRectangleCollider(Player.Position.x, Player.Position.y, Player.Dimensions.x, Player.Dimensions.y, 10)
    car:setRestitution(0.0)
    car:setType('dynamic')
    car:setCollisionClass('Player')
    car:setObject(Player)
end

function love.load()
    canvas = love.graphics.newCanvas(800, 600)
    love.graphics.setCanvas(canvas)
    road = love.graphics.newImage("road.png")
    
    loadPhysics()
    loadCollisionShapes()
    
    love.graphics.setCanvas()
end

function love.draw()
    camera:set()
    camera:setPosition(Player.Position.x - 400, Player.Position.y - 300)
    love.graphics.draw(road, 0, 0, math.deg(0), 1, 1)
    Player.draw()
    camera:unset()
end

function save_data(filename, data)
    file, err = io.open(filename, "w")

    if file then
        file:write(data)
        io.close()
    else
        print("error:", err) 
    end
end

function readAll(file)
    file = "QLearningInterface"
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function love.keypressed(key)
    if key == 'r' then
        QLearningInterface.should_render = not QLearningInterface.should_render
    end
    if key == 'q' then
        
        for index = 1, #moves, 1 do
                if moves[index] == 's' then
                    car:applyLinearImpulse(Player.Speed * math.sin(-Player.Rotation), Player.Speed * math.cos(-Player.Rotation))
                elseif moves[index] == 'w' then
                    car:applyLinearImpulse(-Player.Speed * math.sin(-Player.Rotation), -Player.Speed * math.cos(-Player.Rotation))
                end

                if moves[index] == 'a' then
                    car:applyAngularImpulse(-1500)
                elseif moves[index] == 'd' then
                    car:applyAngularImpulse(1500)
                end 
        end
    end
end

function love.keyreleased(key)
    car:setLinearDamping(1)
    car:setAngularVelocity(0)
end

function love.update(dt)  
    Player.Position.x, Player.Position.y = car:getPosition()
    Player.Rotation = car:getAngle()
    manual_control()
    world:update(dt)
end

function manual_control()
    if love.keyboard.isDown("s") then
        car:applyLinearImpulse(Player.Speed * math.sin(-Player.Rotation), Player.Speed * math.cos(-Player.Rotation))
    elseif love.keyboard.isDown("w") then
        car:applyLinearImpulse(-Player.Speed * math.sin(-Player.Rotation), -Player.Speed * math.cos(-Player.Rotation))
    end
    
    if love.keyboard.isDown('a') then
        car:applyAngularImpulse(-1500)
    elseif love.keyboard.isDown('d') then
        car:applyAngularImpulse(1500)
    end 
end