pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	t=0
	player={}
	enemies={}
	weapon={}
	start_game()
end

function start_game()
	player=make_obj(
		64,64,100,2,{
			x_off=3,
			y_off=3,
			col_r=3
		})
	player.spr=1
	player.sheet={1,2}
	player.w=1
	player.h=1
end




-->8
-- tools
function move(o)
 o.x+=o.sx
 o.y+=o.sy
end

function make_obj(x,y,hp,spd,col)
	return {
		hp=hp,
		-- movement
		x=x,
		y=y,
		spd=spd,
		sx=0,
		sy=0,
		-- animation
		spr=0,
		sheet={},
		ani_spd=0.2,
		frame=1,
		flip=false,
		-- collision
		x_off=col.x_off,
		y_off=col.y_off,
		col_r=col.col_r
	}	
end


function spawn_enemy(num)
	for i=1,num do
		local x=rnd({
			-10-rnd(20),
			138+rnd(20)
		})
		local y=rnd({
			-10-rnd(20),
			138+rnd(20)
		})
		local new_e=make_obj(
			x,y,5,1,{
				x_off=3,
				y_off=3,
				col_r=3
			})
		-- animation
		new_e.spr=17
		new_e.sheet={17,18}
		new_e.w=1
		new_e.h=1
		--	distance to player
		new_e.d_to_p=0
		add(enemies,new_e)
	end
end

function animate(o)
	o.frame+=o.ani_spd
	if flr(o.frame)>#o.sheet then
		o.frame=1
	end
	o.spr=o.sheet[
		flr(o.frame)
	]
end

function col_circ(a,b)
	local a_x=a.x+a.x_off
	local a_y=a.y+a.y_off
	local b_x=b.x+b.x_off
	local b_y=b.y+b.y_off
	local dx=a_x-b_x
	local dy=a_y-b_y
	local l=sqrt(dx*dx+dy*dy)
	if l<=a.col_r+b.col_r then
		return true
	end
	return false
end
-->8
-- update
function _update()
	-- spawn 5 enemy every 2 seconds
	if t%60==0 then
		spawn_enemy(5)
	end
	update_player()
	update_enemies()
	t+=1
end

function update_player()
	-- player movement (actually move all enemies)
	for e in all(enemies) do
		if btn(⬅️) then
			e.x+=player.spd
			e.flip=false
			player.flip=false
		end
		if btn(➡️) then
			e.x-=player.spd
			e.flip=true
			player.flip=true
		end
		if btn(⬆️) then
			e.y+=player.spd
		end
		if btn(⬇️) then
			e.y-=player.spd
		end
	end
	-- player animation
	animate(player)
end

function update_enemies()
	for e in all(enemies) do
		move_to_player(e)
		move(e)
		animate(e)
		col_e=0
		-- check collision
		if col_circ(e,player) then
			del(enemies,e)
		end
	end
end
-->8
-- draw
function _draw()
	cls()
	spr(player.spr,player.x,player.y,player.w,player.h,player.flip)
	for e in all(enemies) do
		spr(e.spr,e.x,e.y,e.w,e.h,e.flip)
	end
end


-->8
-- enemy behavior
function move_to_player(e)
	local dx=player.x-e.x
	local dy=player.y-e.y
	e.d_to_p=sqrt(dx*dx+dy*dy)
	local angle=atan2(dx,dy)
	e.sx=e.spd*cos(angle)
	e.sy=e.spd*sin(angle)
end

function overlap_e(e)
	for other in all(enemies) do
		if e.x!=other.x and e.y!=other.y then
			if col_circ(e,other) then
				other.sx=-other.sx
				other.sy=-other.sy
			end
		end
	end
end
__gfx__
0000000000ccccc000ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccc00accccc00a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000fffdc000fffdc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000f0f7dc00f0f7dc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077775c0077775c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700f7777cf0f7777cf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000777cc000777cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f00f00000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008820000088200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088882000888820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000878788208878782000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000808088208808082000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888882208888822000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000802020200802020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
