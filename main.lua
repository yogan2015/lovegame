local anim8 = require 'anim8'
local image, animation

imgs={}                 --библиотека изображений с ключами-словами 

deco={}                 --карта декораций
deco_l={}; 
deco_r={};   --границы декораций
deco_set={}             --набор индексов декораций

coll={}                 --карта препятствий
coll_l={};  
coll_r={};  --границы препятствий
coll_set={}             --набор индексов препятствий

scr_vshift=150          --ширина нижней части уровня
scr_w=1600
scr_h=900               --параметры экрана
scr_field=400         --поля

flag_d_l=1;   flag_d_r=1;  --флаги декораций
pos_d_l=0;    pos_d_r=0;   --соответствующие координаты
flag_c_l=1;   flag_c_r=1;  --флаги препятствий
pos_c_l=0;    pos_c_r=0;   --соответствующие координаты

her_offset=0;           --текущее положение героя
scr_offset=-400;

mov_left=false;           --команда налево
mov_right=false;          --команда направо
mov_lastr=true;           --последняя команда
mov_currr=true;           --текущая команда

her_speed=0;
her_maxsp=260;
scr_speed=1500;

--Анимации героя (когда все переведем на анимации - хз, возможно, придется переписать все)--
im_anim_idle_l = love.graphics.newImage('images/hero_idle_l.png')
local grid_hero_idle_l = anim8.newGrid(64, 64, im_anim_idle_l:getWidth(), im_anim_idle_l:getHeight())  -- куски анимации
hero_idle_l = anim8.newAnimation(grid_hero_idle_l('1-1',1), {0.12})     

im_anim_idle_r = love.graphics.newImage('images/hero_idle_r.png')
local grid_hero_idle_r = anim8.newGrid(64, 64, im_anim_idle_r:getWidth(), im_anim_idle_r:getHeight())  -- куски анимации
hero_idle_r = anim8.newAnimation(grid_hero_idle_r('1-1',1), {0.12})       

im_anim_walk_l = love.graphics.newImage('images/hero_walk_l.png')
local grid_hero_walk_l = anim8.newGrid(64, 64, im_anim_walk_l:getWidth(), im_anim_walk_l:getHeight())  -- куски анимации
hero_walk_l = anim8.newAnimation(grid_hero_walk_l('6-1',1), {0.12,0.16,0.09,0.12,0.16,0.09})     

im_anim_walk_r = love.graphics.newImage('images/hero_walk_r.png')
local grid_hero_walk_r = anim8.newGrid(64, 64, im_anim_walk_r:getWidth(), im_anim_walk_r:getHeight())  -- куски анимации
hero_walk_r = anim8.newAnimation(grid_hero_walk_r('1-6',1), {0.12,0.16,0.09,0.12,0.16,0.09})       


hero_anim = nil
hero_image= nil
her_width=50
her_status='idle'     --статус героя, для понятности это просто слово

function isleft(a,b)
  return a[2]<b[2]
end

function getindex(tab, val)
  i=1
  while (not(tab[i]==val) and i<=#tab) do i=i+1; end
  return i
end

function scr_build()      --конструируем наборы индексов и устанавливаем флаги
  --для декораций
  flag_d_l=#deco;   flag_d_r=1
  for i=1, #deco do
    if deco_l[i][2]<scr_offset+scr_w and deco_r[i][2]>scr_offset then 
      table.insert(deco_set,i)
      if i<flag_d_l then flag_d_l=i; end        --самый левый видимый объект L
      if i>flag_d_r then flag_d_r=i; end        --самый правый видимый объект R
    end
  end
  pos_d_l=deco_r[flag_d_l][2]                   --ПРАВЫЙ край самого ЛЕВОГО объекта
  pos_d_r=deco_l[flag_d_r][2]                   --ЛЕВЫЙ край самого ПРАВОГО объекта
  
  --для препятствий (то же самое практически)
  flag_c_l=#coll;   flag_c_r=1
  for i=1, #coll do
    if coll_l[i][2]<scr_offset+scr_w and coll_r[i][2]>scr_offset then 
      table.insert(coll_set,i) 
      if i<flag_c_l then flag_c_l=i; end
      if i>flag_c_r then flag_c_r=i; end
    end
  end
  pos_c_l=coll_r[flag_c_l][2]
  pos_c_r=coll_l[flag_c_r][2]
end

function scr_shift()    --проверяем для текущего положения экрана актуальность флагов и если что, передвигаем
                        -- этой функции все считается исключительно в зависимости от положения экрана и направления движения
                        --суть функции - поставить флаги границ отображения на граничные объекты, то есть следующий объект должен быть уже нерисуемым
  local scr_right=scr_offset+scr_w
  if mov_currr then     --двигаемся вправо (в принципе, при переползании экрана функция может глючить) !переписать после ввода героя! (а может и нет)
  --работаем с декором
    while not(pos_d_l>=scr_offset and deco_r[flag_d_l-1][2]<=scr_offset) do         --правые края левых объектов
      --удаляем объект из набора
      table.remove(deco_set,getindex(deco_set,flag_d_l))
      --сдвигаем флаг
      flag_d_l=flag_d_l+1
      pos_d_l=deco_r[flag_d_l][2]
    end
    
    while not(pos_d_r<=scr_right and deco_l[flag_d_r+1][2]>=scr_right) do   --левые края правых объектов
      --добавляем объект в набор
      table.insert(deco_set,flag_d_r+1)
      --сдвигаем флаг
      flag_d_r=flag_d_r+1
      pos_d_r=deco_l[flag_d_r][2]

    end
    
  else                  --двигаемся влево
    
    while not(pos_d_l>=scr_offset and deco_r[flag_d_l-1][2]<scr_offset) do         --правые края левых объектов
      --добавляем объект в набор
      table.insert(deco_set,flag_d_l-1)
      --сдвигаем флаг
      flag_d_l=flag_d_l-1
      pos_d_l=deco_r[flag_d_l][2]

    end
    
    
    while not(pos_d_r<=scr_offset+scr_w and deco_l[flag_d_r+1][2]>scr_offset+scr_w) do   --левые края правых объектов
      --удаляем объект из набора
      table.remove(deco_set,getindex(deco_set,flag_d_r))
      --сдвигаем флаг
      flag_d_r=flag_d_r-1
      pos_d_r=deco_l[flag_d_r][2]

    end
  end
end

function love.load()
  love.window.setTitle( "AHAV Разработка" ) -- название игры и окна игры
  love.window.setFullscreen(true, "desktop") --полный экран  
  love.mouse.setVisible(false) -- курсор невидим
  n=0
  
  -- загрузка уровня

  --загрузка всех изображений подряд (перечислены в файле images.txt
  for line in io.lines('images\\level1\\images.txt') do
    a=string.find(tostring(line),':')
    b=string.len(tostring(line))
    key=string.sub(tostring(line),1,a-1)
    val=string.sub(tostring(line),a+1,b)
    imgs[key]=love.graphics.newImage(val)
  end

  deco_l[0]={0,-10000};  deco_r[0]={0,-10000};
  i=1 --индексация объектов
  --загрузка декораций уровня
  for line in io.lines('images\\level1\\deco.txt') do                           --грузим слова формата "position:object"
    a=string.find(tostring(line),':')                                           --определяем позицию двоеточия в полученной строке
    b=string.len(tostring(line))                                                --длина строки
    pos=string.sub(tostring(line),1,a-1)                                        --вычленяем position
    pic=string.sub(tostring(line),a+1,b)                                        --вычленяем имя объекта и записываем его в пул 
    deco[i]=pic
    deco_l[i]={i,tonumber(pos)};                      table.sort(deco_l,isleft) --составляем упорядоченый массив левых краев {i,pos}
    wid=imgs[pic]:getWidth();
    deco_r[i]={i,tonumber(pos+imgs[pic]:getWidth())}; table.sort(deco_r,isleft) --составляем упорядоченный массив правых краев {i,pos}
    i=i+1
  end
  deco_l[i]={i,99999};  deco_r[i]={i,99999};
  i=1
  --загрузка препятствий уровня (всё то же самое)
  for line in io.lines('images\\level1\\coll.txt') do
    a=string.find(tostring(line),':')
    b=string.len(tostring(line))
    pos=string.sub(tostring(line),1,a-1)
    pic=string.sub(tostring(line),a+1,b)
    coll[i]=pic
    coll_l[i]={i,tonumber(pos)};                      table.sort(coll_l,isleft)
    coll_r[i]={i,tonumber(pos+imgs[pic]:getWidth())}; table.sort(coll_r,isleft)
    i=i+1
  end
  
  scr_build()       --определяем первичную картинку
end

function love.update(dt) 
  --обрабатываем движение
  --реализуем вариант, когда движение определяется последней нажатой клавишей, если нажаты обе
  dir=0                   --коэффициент скорости (-1/0/1)
  her_status='idle'
  if mov_left then
    if mov_right then     --нажаты обе клавиши
      if mov_lastr then
        dir=1
        mov_currr=true
        her_status='walk'
      else
        dir=-1
        mov_currr=false
        her_status='walk'
      end
    else                  --нажато только "влево"
      dir=-1
      mov_currr=false
      her_status='walk'
    end
  else
    if mov_right then     --нажато только "вправо"
      dir=1
      mov_currr=true
      her_status='walk'
    end
  end
  
  --Двигаем героя
  her_speed=dir*her_maxsp*dt
  her_offset=her_offset+her_speed
  
  --Двигаем экран
  --Если идем влево
  if not(mov_currr) then
    if (((scr_offset+scr_w)-(her_width+her_offset+scr_field))>(dt*scr_speed)) then
      scr_offset=scr_offset-dt*scr_speed                          --плавно летим
    else
      scr_offset=her_offset+her_width+scr_field-scr_w --прилипаем к правой части
    end
  else      --идем вправо
    if ((her_offset)-(scr_offset+scr_field)>(dt*scr_speed)) then
      scr_offset=scr_offset+dt*scr_speed
    else
      scr_offset=her_offset-scr_field
    end
  end

  --учет сдвига экрана
  scr_shift()
  
  --анимации
  hero_walk_l:update(dt)
  hero_walk_r:update(dt)
  hero_idle_l:update(dt)  --пока там одна анимация, ну да ладно
  hero_idle_r:update(dt)
end 

function love.draw() 
  --рисуем фон
  
  --рисуем декорации (пока один слой и без параллакса)
  for i=1, #deco_set do     --из всех объектов рисуем только те, что попали в текущий набор deco_set
    love.graphics.draw(imgs[deco[deco_set[i]]],deco_l[deco_set[i]][2]-scr_offset, scr_h-scr_vshift-imgs[deco[deco_set[i]]]:getHeight())
  end
  
  --рисуем препятствия
  --for i=1, #coll_set do     --из всех объектов рисуем только те, что попали в текущий набор deco_set
  --  love.graphics.draw(imgs[coll[coll_set[i]]],coll_l[i][2]-scr_offset, scr_h-scr_vshift-imgs[coll[coll_set[i]]]:getHeight())
  --end
  
  --рисуем героя (тут применены анимации)
  if her_status=='idle' then
    if mov_lastr then
      hero_anim=hero_idle_r
      hero_image=im_anim_idle_r
    else
      hero_anim=hero_idle_l
      hero_image=im_anim_idle_l
    end
  elseif her_status=='walk' then
    if her_speed>0 then
      hero_anim=hero_walk_r
      hero_image=im_anim_walk_r
    else
      hero_anim=hero_walk_l
      hero_image=im_anim_walk_l
    end
  end
  hero_anim:draw(hero_image,her_offset-scr_offset, scr_h-scr_vshift-hero_image:getHeight())
    
  --служебные параметры
  love.graphics.print(love.window.getWidth()..' x '..love.window.getHeight()..' '..love.timer.getFPS(),100,100)
  --for i=1, #deco_set do 
  --  love.graphics.print(deco[deco_set[i]],100,100+i*20)
  --end  
  for i=1, #deco do
    love.graphics.print(i..':'..deco[i],100,100+i*18)
  end
  
  for i=1, #deco_l do
    love.graphics.print(deco_l[i][1]..':'..deco_l[i][2],200,100+i*18)
  end
  
  for i=1, #deco_r do
    love.graphics.print(deco_r[i][1]..':'..deco_r[i][2],300,100+i*18)
  end

  for i=1, #deco_set do
    love.graphics.print(i..':'..deco_set[i],400,100+i*18)
  end
  love.graphics.print(pos_d_l..'   '..pos_d_r, 500,140)
  love.graphics.print(flag_d_l..'   '..flag_d_r, 500,120)
  --love.graphics.print(deco_r[flag_d_l][2]..' '..deco_l[flag_d_r][2], 300,160)
  love.graphics.print(string.format('%d',scr_offset)..' '..string.format('%d',scr_offset+scr_w), 500,100)
  --love.graphics.print(pos_d_r..' '..deco_l[flag_d_r+1][2]..' '..scr_offset+scr_w,300,200)
  
end

function love.keypressed(key) 
  if key == "left" then
    mov_left=true
    mov_lastr=false
  end
  if key == "right" then
    mov_right=true
    mov_lastr=true
  end
  if key == "escape" then  -- выход из игры
    love.event.quit() 
  end 
end

function love.keyreleased(key)
  if key == "left" then
    mov_left=false
  end
  if key == "right" then
    mov_right=false
  end
end
