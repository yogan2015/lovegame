-- Анимация и прочее дерьмо

— прописать условия для нужной анимации, а не просто аним мув 1
— сбрасывать состояния и удары после их соврешения/ время работы
— прописать какое конкретно изображение выводить
— и само перемещение.


--bla
local anim8 = require 'anim8'

local image, animation

function love.load()
  heroPosition=0 -- состояние героя
  position=0  -- стойка или ходьба
  attack=0  -- тип атаки героя
  scale=2 -- масштаб
  im_anim_move1 = love.graphics.newImage('images/move1.png') -- загрузка изображения
  im_anim_move2 = love.graphics.newImage('images/move2.png')

  local grid_anim_move1 = anim8.newGrid(64, 64, im_anim_move1:getWidth(), im_anim_move1:getHeight()) -- куски анимации
  anim_move1 = anim8.newAnimation(grid_anim_move1('1-6',1), {0.12,0.16,0.09,0.12,0.16,0.09}) -- анимация, какие куски и с каким интервалом
  local grid_anim_move2 = anim8.newGrid(64, 64, im_anim_move2:getWidth(), im_anim_move2:getHeight())  
  anim_move2 = anim8.newAnimation(grid_anim_move2('6-1',1), {0.12,0.16,0.09,0.12,0.16,0.09})

end



function love.update(dt) 
  --! прописать условия для нужной анимации, а не просто аним мув 1
  
  --! и само перемещение
    anim_move1:update(dt)
    heroPosition=position..attack -- число состоящее из стойки и атаки = комбо
    -- ! сбрасывать состояния и удары после их соврешения/ время работы
end 

function love.draw() 
  -- ! прописать какое конкретно изображение выводить
anim_move1:draw(im_anim_move1, 100, 0,0, 1, 1,scale,scale) -- вывод 
love.graphics.print(heroPosition, 10, 200) 
end 

function love.keypressed(key) 
  if key == "q" then  -- стойки
    position=1 
    elseif key == "w" then 
    position=2 
    elseif key == "e" then 
    position=3
    elseif key == "left" then -- движение
    position=8 
    elseif key == "right" then 
    position=9       
  else
    position=0
  end 
  if key == "a" then  -- удары
    attack=1 
    elseif key == "s" then 
    attack=2 
    elseif key == "d" then 
    attack=3
    else 
    attack=0
  end 
  if key == "escape" then  -- выход из игры
  love.event.quit() 
  end 
end
