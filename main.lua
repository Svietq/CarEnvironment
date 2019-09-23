require("Libs/camera")
require("player")
require("obstacle")

wf = require 'Libs/windfield/windfield'

local serialize = require 'Libs/Ser/ser'

require 'collision_shapes'

local spawn_position = {  x = 350 , y = 350  }

Background = 
{
    Color = { Red = 115/255, Green = 27/255, Blue = 135/255, Alpha = 100/100 },
    DebugColor = { Red = 200/255, Green = 0/255, Blue = 0/255, Alpha = 100/100 }
}

PythonToLua = 
{
    action = 0, -- 0, 1, 2, 3, 4 - do nothing, move forward, move backward, turn left, turn right
    should_render = 0, -- boolean
}

LuaToPython =
{
    observation_space = 
    {
        x = Player.Position.x, 
        y = Player.Position.y,
        rotation = Player.Rotation,
        x_vel = 0,
        y_vel = 0
    }, 
    reward = 0, -- progress on the road
    should_exit = 0 -- boolean
}

function setBackgroundColor(Color)
    red = Color.Red
    green = Color.Green
    blue = Color.Blue
    alpha = Color.Alpha
    love.graphics.setBackgroundColor( red, green, blue, alpha)
end

function loadCollisionShapes()
    -- vertices = love.filesystem.read("collision_shapes.lua")()

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
    -- setBackgroundColor(Background.Color)
    road = love.graphics.newImage("road.png")
    
    loadPhysics()
    loadCollisionShapes()
    
    love.graphics.setCanvas()

    -- love.filesystem.write("movement_instructions", serialize(moves))
    -- moves = love.filesystem.load("movement_instructions")()

    -- save_data("QLearningInterface", serialize(QLearningInterface))
    
    -- love.filesystem.write("LuaToPython", serialize(LuaToPython))
    -- love.filesystem.write("PythonToLua", serialize(PythonToLua))

    -- LuaToPython = love.filesystem.load("LuaToPython")()
    -- PythonToLua = love.filesystem.load("PythonToLua")()

end

function love.draw()
    -- if QLearningInterface ~= nil and QLearningInterface.should_render then
        camera:set()
        camera:setPosition(Player.Position.x - 400, Player.Position.y - 300)
        love.graphics.draw(road, 0, 0, math.deg(0), 1, 1)
        Player.draw()
        -- world:draw()
        camera:unset()
    -- end
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

    -- love.filesystem.write("collision_shapes", serialize(vertices))
end

function love.keyreleased(key)
    car:setLinearDamping(1)
    car:setAngularVelocity(0)
end

function love.update(dt)  
    Player.Position.x, Player.Position.y = car:getPosition()
    Player.Rotation = car:getAngle()
    
    LuaToPython.should_exit = 0
    
    -- temp_data = love.filesystem.load("PythonToLua")
    -- if temp_data ~= nil then
    --     PythonToLua = temp_data()
    -- end
    
    -- if PythonToLua ~= nil then
    --     if PythonToLua.action == 1 then
    --         car:applyLinearImpulse(Player.Speed * math.sin(-Player.Rotation), Player.Speed * math.cos(-Player.Rotation))
    --     elseif PythonToLua.action == 2 then
    --         car:applyLinearImpulse(-Player.Speed * math.sin(-Player.Rotation), -Player.Speed * math.cos(-Player.Rotation))
    --     end
        
    --     if PythonToLua.action == 3 then
    --         car:applyAngularImpulse(-1500)
    --     elseif PythonToLua.action == 4 then
    --         car:applyAngularImpulse(1500)
    --     end 
        
    --     calculate_reward()
    --     LuaToPython.observation_space.x = math.floor(Player.Position.x/10) * 10
    --     LuaToPython.observation_space.y = math.floor(Player.Position.y/10) * 10
    --     if Player.Rotation > math.deg(360) then
    --         Player.Rotation = Player.Rotation - math.deg(360)
    --     end
    --     LuaToPython.observation_space.rotation = math.floor(Player.Rotation*10)
    --     local x_vel, y_vel = car:getLinearVelocity()
    --     LuaToPython.observation_space.x_vel = math.floor(x_vel/100) * 100
    --     LuaToPython.observation_space.y_vel = math.floor(y_vel/100) * 100

        
    -- end
    
    manual_control()
    -- print(car:getLinearVelocity())

    -- if car:enter('Obstacle') then 
    --     LuaToPython.should_exit = 1
    --     -- love.filesystem.write("LuaToPython", serialize(LuaToPython)) 
    --     car:destroy()
    --     car = world:newBSGRectangleCollider(Player.Position.x, Player.Position.y, Player.Dimensions.x, Player.Dimensions.y, 10)
    --     car:setRestitution(0.0)
    --     car:setType('dynamic')
    --     car:setCollisionClass('Player')
    --     car:setObject(Player)
    --     car:setAngle(math.deg(0))
    --     car:setPosition(spawn_position.x, spawn_position.y)
    -- end
    
    -- love.filesystem.write("LuaToPython", serialize(LuaToPython)) 
    -- love.filesystem.write("LuaToPython", serialize(LuaToPython)) 
    
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

function love.mousepressed(x, y, button, istouch)
    -- if button == 1 or button == 2 then
    --    vertices[button][#vertices[button]+1] = x + camera.x
    --    vertices[button][#vertices[button]+1] = y + camera.y
    -- end
 end

-- TODO: adjust values
treshold1 = 1500
treshold2 = 1500
treshold3 = 1500
treshold4 = 1500
current_stage = 0

function  calculate_reward()
    if current_stage == 0 then

        LuaToPython.reward = Player.Position.x
        if LuaToPython.reward > treshold1 then
            current_stage = 1
        end
    elseif current_stage == 1 then
        LuaToPython.reward = treshold1 + Player.Position.y
        if LuaToPython.reward > treshold2 then
            current_stage = 2
        end
    elseif current_stage == 2 then
        LuaToPython.reward = treshold2 + (road:getWidth() - Player.Position.x)
        if LuaToPython.reward > treshold3 then
            current_stage = 3
        end
    elseif current_stage == 3 then
        LuaToPython.reward = treshold3 + (road:getHeight() - Player.Position.y)
        if LuaToPython.reward > treshold4 then
            LuaToPython.should_exit = 1
        end
    end

    -- LuaToPython.reward = math.floor(LuaToPython.reward)
    
end