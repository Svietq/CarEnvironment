Player = 
{ 
    Position = { x = 280, y = 300 }, 
    Dimensions = { x = 50, y = 100 },
    Rotation = math.deg(0),
    Speed = 100,
    Texture = love.graphics.newImage("car.png")
}

function Player:draw()
    love.graphics.draw( Player.Texture,
                        Player.Position.x, Player.Position.y,
                        Player.Rotation,
                        0.2, 0.2, 
                        Player.Texture:getWidth()/2, Player.Texture:getHeight()/2)
end

world = love.physics.newWorld(0, 0, true)