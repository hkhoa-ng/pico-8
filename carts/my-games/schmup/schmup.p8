pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- init
cls()

function _init()
	-- state machine
	mode="start"
	
	-- blinking index for title
	blink_index=1
	
	-- shooting cooldonwn
	max_cd=3
	curr_cd=max_cd
	
	--music(0)
	-- timer
	t=0
	btn_lock_duration=30
	
	enemy_atk_delay=40
	
	-- screenshake offset
	offset=0
	
	pickup_drop_rate=1/15
	
	debug="chicken"
end

function _update()
 cls()
 blink_index+=1
 
 t+=1
 
 if mode == "game" then
 	update_game()
 elseif mode == "start" then
 	update_start()
 elseif mode == "wavetext" then
 	update_wavetext()
 elseif mode == "over" then
 	update_over()
 elseif mode == "win" then
 	update_win()
	end
end

function _draw()
	screen_shake()
 if mode == "game" then
 	draw_game()
 elseif mode == "start" then
  draw_start()
	elseif mode == "wavetext" then
 	draw_wavetext()
 elseif mode == "over" then
 	draw_over()
 elseif mode == "win" then
 	draw_win()
	end
end

function start_game()
	wave=0
	nextwave()
	
	enemies={}
	e_bullets={}
	explosions={}
	shockwaves={}
	pickups={}
	floats={}
	shields={}
	
	-- ship stuffs
	ship=make_spr(0,0)
	ship.x=60
	ship.y=80
	ship.speed=2
	ship.sprite=2
	ship.w=1
	ship.h=1
	ship.weapon=0.5
	ship.ammo=10
	ship.bomb=1
	ship.shield=75
	ship.shield_r=10
	ship.max_shield=75
	
	create_shield(ship)
	
	exhaust=make_spr(0,0)
	
	exhaust.x=ship.x
	exhaust.y=ship.y+8
	exhaust.sprite=5
	exhaust.sheet={5,6,7,8,9}
	exhaust.ani_spd=1
	exhaust.w=1
	exhaust.h=1
	
	muzzle=0
	
	lives=5
	max_lives=5
	invul=0
	invul_time=30
	
	score=0
	
	-- boss
	
	-- bullet stuffs
	bullets={}
	bullet_speed=5
	
	-- our star field: position x,
	-- y, and speed for 100 stars
	stars={}
	for i=1,100 do
		local new_star={
			x=rnd(128),
			y=rnd(128),
			y_spd=rnd(2)+0.5,
			x_spd=1.5,
		}
		add(stars, new_star)
	end
end
-->8
-- utils
function draw_sprite(obj)
	local sprx=obj.x
	local spry=obj.y
	if obj.shake>0 then
		obj.shake-=2
		sprx+=sin(t/3)*1.5
	end
	spr(obj.sprite,sprx,spry,obj.w,obj.h)
end

function draw_outline(o)
	spr(o.sprite,o.x+1,o.y,o.w,o.h)
	spr(o.sprite,o.x-1,o.y,o.w,o.h)
	spr(o.sprite,o.x,o.y+1,o.w,o.h)
	spr(o.sprite,o.x,o.y-1,o.w,o.h)
end

function print_outline(txt,x,y,c)
	cprint(txt,x+1,y,c)
	cprint(txt,x-1,y,c)
	cprint(txt,x,y-1,c)
	cprint(txt,x,y+1,c)
end

function cprint_outline(
	txt,x,y,out_c,txt_c)
	print_outline(txt,x,y,out_c)
	cprint(txt,x,y,txt_c)
end

function make_spr(x,y)
	return {
		hp=3,
		tar_x=x,
		tar_y=y,
		sx=0,
		sy=0,
		x=x-100,
		y=y-100,
		flash=0,
		shake=0,
		frame=1,
		ani_spd=0.1,
		sprite=17,
		w=1,
		h=1,
		mission="flying",
		wait=0,
		shoot_cd=0,
		shoot_delay=60,
		lock=false,
		base=0
	}
end

function col(a, b)
	if a.ghost or b.ghost then
		return false
	end
	
	local modifier_a=0
	local modifier_b=0
	if a.is_bul then
		modifier_a=3
	end
	if b.is_bul then
		modifier_b=3
	end
	
	local a_left=a.x+modifier_a
	local a_top=a.y+modifier_a
	local a_right=a.x+a.w*7-modifier_a
	local a_bot=a.y+a.h*7-modifier_a
	
	local b_left=b.x+modifier_b
	local b_top=b.y+modifier_b
	local b_right=b.x+b.w*8-modifier_b
	local b_bot=b.y+b.h*8-modifier_b
	
	if a.type=="b" then
		a_left+=4
		a_right-=4
		a_top+=4
		a_bot-=4
	end
	if b.type=="b" then
		b_left+=4
		b_right-=4
		b_top+=4
		b_bot-=4
	end
	if a_top>b_bot then
	 return false
	end
	if b_top>a_bot then
	 return false
	end
	if a_left>b_right then
	 return false
	end
	if b_left>a_right then
	 return false
	end
	
	return true
end

-- spawn enemies in each waves
function spawn_wave()
	sfx(7)
	if wave==1 then
		place_ene(wave_1)
	elseif wave==2 then
		enemy_atk_delay-=3
		place_ene(wave_2)
	elseif wave==3 then
		enemy_atk_delay-=3
		place_ene(wave_3)
	elseif wave==4 then
		enemy_atk_delay-=3
		place_ene(wave_4)
	elseif wave==5 then
		enemy_atk_delay-=3
		place_ene(wave_5)
	elseif wave==6 then
		enemy_atk_delay-=3
		place_ene(wave_6)
	elseif wave==7 then
		enemy_atk_delay-=3
		place_ene(wave_7)
	elseif wave==8 then
		enemy_atk_delay-=3
		place_ene(wave_8)
	end
end

function place_ene(lvl)
	for y=1,#lvl do
		for x=1,#lvl[y] do
			spawn_ene_type(
				lvl[y][x],x*12-6,y*12,x*3)
		end
	end
end

-- spawn enemy types
function spawn_ene_type(e_type,x,y,wait)
	local e=make_spr(x,y)
	if e_type==nil or e_type==0 then
		return
	elseif e_type==1 then
		-- green alien
		e.sprite=17
		e.sheet={17,18,19,20}
	elseif e_type==2 then
		-- red dude
		e.sprite=25
		e.sheet={25,26}
		e.type=e_type
	elseif e_type==3 then
		-- spinning ship
		e.sprite=21
		e.sheet={21,22,23,24}
	elseif e_type==7 then
		-- big guy
		e.sprite=33
		e.sheet={33,35}
		e.hp=30
		e.w=2
		e.h=2
	elseif e_type==4 then
		--drill guy
		e.sprite=13
		e.sheet={13,14}
	elseif e_type==5 then
		-- drone
		e.sprite=37
		e.sheet={37,38,39,40}
	elseif e_type==6 then
		-- mouth
		e.sprite=27
		e.sheet={27,28,29,30}
	elseif e_type=="b" then
		-- boss
		e.w=4
		e.hp=150
		e.h=4
		e.sprite=64
		e.sheet={64,68}
		e.boss=true
		e.tar_x=48
		e.tar_y=10
		e.ph_begin=0
	end
	e.type=e_type
	add(enemies,e)
end

function nextwave()
	wave+=1
	
	if wave>8 then
		mode="win"
	else
		mode="wavetext"
		wavetime=80
	end
end

function animate(o)
	o.frame+=o.ani_spd
	if flr(o.frame)>#o.sheet then
		o.frame=1
	end
	o.sprite=o.sheet[
		flr(o.frame)
	]
end

function ship_col(obj)
	if col(obj,ship) and invul==0 then
		lives-=1
	 offset=1
		sfx(1)
		invul=invul_time
		explode(ship.x+4,
			ship.y+4,"blue",20,4)
		big_shockwave(ship.x+4,
			ship.y+4)
	end
end

function ship_shoot()
	curr_cd=0
	local num=ship.weapon
	for i=-num,num do
		local new_bul=make_spr(0,0)
		new_bul.x=ship.x+i*6
		new_bul.y=ship.y-15
		new_bul.sprite=4
		new_bul.w=1
		new_bul.h=1
		new_bul.sy=-bullet_speed
		new_bul.dmg=1
		new_bul.hp=1
		add(bullets,new_bul)
	end
	if num>0 then
		ship.ammo-=1
	end
	if ship.ammo<=0 then
		ship.weapon=0
	end
	muzzle=4
	sfx(0)
end

function ship_bomb(vel)
	if ship.bomb>0 then
		offset=1.5
		invul=invul_time
		pop_float("invul!",ship.x,ship.y)
		sfx(14)
		local num=ship.bomb*2
		ship.shield+=num*5
		local spc=0.25/num
		for i=0,num do
			local ang=0.375+spc*i
			local new_bul=make_spr(0,0)
			sx=vel*sin(ang)
			sy=vel*cos(ang)
			new_bul.x=ship.x+3
			new_bul.y=ship.y
			new_bul.sprite=56
			new_bul.w=1
			new_bul.h=1
			new_bul.sy=sy
			new_bul.sx=sx
			new_bul.dmg=3
			new_bul.hp=3
			add(bullets,new_bul)
		end
	else
	 sfx(15)
	end
	ship.bomb=0
end

function create_pickup(o)
	local new_p=make_spr(0,0)
	local t={
	"2","2","2",
	"3","3",
	"h",
	"b","b","b","b","b",
	"s","s","s"
	}
	local pickup=rnd(t)
	local sprite=10
	if pickup=="2" then
		new_p.sprite=10
		new_p.sheet={41,42,43,44}
	elseif pickup=="3" then
		new_p.sprite=15
		new_p.sheet={57,58,59,60}
	elseif pickup=="h" then
		new_p.sprite=11
		new_p.sheet={11,45,46}
	elseif pickup=="b" then
		new_p.sprite=61
		new_p.sheet={61,62}
	elseif pickup=="s" then
		new_p.sprite=15
		new_p.sheet={15,31,47}
	end
	new_p.pickup=pickup
	new_p.ani_spd=0.25
	new_p.x=o.x
	new_p.y=o.y
	new_p.sy=0.5
	add(pickups,new_p)
end

function pop_float(txt,x,y)
	add(floats,{
		x=x,
		y=y,
		txt=txt,
		age=20,
	})
end

function cprint(txt,x,y,c)
	print(txt,x-#txt*2,y,c)
end

function create_shield(o)
	local x=o.x+3
	local y=o.y+3
	local r=ship.shield_r
	for i=0,1,1/16 do
		add(shields,{
			x=x+r*cos(i),
			y=y+r*sin(i),
			w=1.5,
			h=1.5,
		})
	end
end
-->8
-- update

function update_game()
	
 -- move the ship
 ship.sprite=2
 ship.sx=0
 ship.sy=0
 if btn(➡️) then
  ship.sx=ship.speed
  ship.sprite=3
 end
 if btn(⬅️) then 
  ship.sx=-ship.speed
  ship.sprite=1
 end
 if btn(⬇️) then
  ship.sy=ship.speed
 end
 if btn(⬆️) then
  ship.sy=-ship.speed
 end
 move(ship)
 
 -- shoot & check bullet cd
 curr_cd+=1
 if curr_cd>max_cd then 
 	curr_cd=max_cd
 end
 if btn(❎) and curr_cd==max_cd then
 	ship_shoot()
 end
 if btn(🅾️) then
 	ship_bomb(bullet_speed)
 end
 
 -- checking if we hit the edge
 if ship.x>120 then 
	 ship.x=120
	 ship.sx=0
 end
 if ship.x<0 then
  ship.x=0
  ship.sx=0
 end
 if ship.y>120 then
  ship.y=120
  ship.sy=0
 end
 if ship.y<0 then
  ship.y=0
  ship.sy=0
 end
 if ship.shield>ship.max_shield then
 	ship.shield=ship.max_shield
	end
 
 -- shield collision particles
 for s in all(shields) do
 	s.sx=ship.sx
 	s.sy=ship.sy
 	move(s)
 	if ship.shield>0 then
 		-- collide with e bullets
 		for b in all(e_bullets) do
 			if col(b,s) then
 				ship.shield-=5
 				sfx(16)
 				del(e_bullets,b)
 				small_shockwave(s.x,s.y)
					explode(s.x,s.y,"spark",5,10)
 			end
 		end
 	else
 		ship.shield=0
 	end
	end
 
 invul-=1
 if invul<=0 then invul=0 end
 
 if lives <= 0 then
 	mode="over"
 	t=0
 end
 
 -- animate the flames
 animate(exhaust)
 exhaust.x=ship.x
 exhaust.y=ship.y+8
 
 -- animate the muzzle
 muzzle-=1
 if (muzzle < 0) then
 	muzzle=0
 end
 
 -- ship bullet
 for curr in all(bullets) do
 	if curr.y < -8 then
  	del(bullets, curr)
  end
  move(curr)
 end
 
 -- enemy bullets
 for b in all(e_bullets) do
 	if b.y>128 or b.y<0 or
 		b.x>128 or b.x<0 then
 		del(e_bullets,b)
 	end
 	ship_col(b)
 	move(b)
 	animate(b)
 end
 
 -- check if wave is cleared
 if mode=="game" and
 	#enemies==0 then
   nextwave()
	end
	
	-- enemies
	pick_timer()
 for curr in all(enemies) do
 	-- animate enemies
 	animate(curr)
 	
 	-- enemy ai
 	enemy_do(curr)
 	
 	-- check enemy out of bound
 	if curr.mission!="flying" then
	 	if curr.y>140 or curr.y<-40 or
	 	 curr.x>140 or curr.x<-40 then
	  	del(enemies, curr)
	  end
  end
 
 	-- ship x enemy collision
		ship_col(curr)
		
		-- bullet x enemy collision
		for bul in all(bullets) do
			if col(curr,bul) then
				e_col_bul(curr,bul)				
			end
		end
		
		-- enemy x shield collision
		for s in all(shields) do
			if ship.shield>0 and col(curr,s) then
				sfx(2)
				ship.shield-=10
				small_shockwave(s.x+4,
						s.y)
				explode(curr.x+4,
					curr.y+4,"spark",5,10)
				if curr.type!=7 and
					curr.type!="b" then
					kill_e(curr)
				end
			end
		end
 end
 
 -- pickups
 for p in all(pickups) do
 	move(p)
 	animate(p)
 	if p.y>128 then
 		del(pickups,p)
 	end
 	if col(p,ship) then
 		small_shockwave(ship.x+4,ship.y+4,14)
 		sfx(13)
 		score+=100
 		del(pickups,p)
 		if p.pickup=="2" then
 			pop_float("100",p.x,p.y)
				ship.weapon=0.5
				ship.ammo=75
			elseif p.pickup=="3" then
				pop_float("100",p.x,p.y)
				ship.weapon=1
				ship.ammo=75
			elseif p.pickup=="h" then
				if lives<max_lives then
					lives+=1
					pop_float("1 up!",p.x,p.y)
				else
					pop_float("100",p.x,p.y)
				end
			elseif p.pickup=="s" then
				pop_float("shield!",p.x,p.y)
				ship.shield+=37.5
			elseif p.pickup=="b" then
				pop_float("100",p.x,p.y)
				if ship.bomb<10 then
					ship.bomb+=1
				end
			end
 	end
 end
 
end

function update_start()
	if btn(❎) and t>btn_lock_duration then
		start_game()
	end
end

function update_over()
	if btn(❎) and t>btn_lock_duration then
		start_game()
	end
end

function update_wavetext()
	update_game()
	wavetime-=1
	if wavetime<=0 then
		spawn_wave()
		mode="game"
	end
end

function update_win()
	if btn(❎)==false and
	 btn(🅾️)==false then
		btn_released=true
	end
	
	if btn_released and
	 (btn(❎) or btn(🅾️)) and
	 t>60 then
		start_game()
	end
end
-->8
-- draw
function draw_game()
	starfield()
	
 -- ship flashing
 if lives>0 then
  if sin(invul/7)<=0 then
	 	draw_sprite(ship)
	 	draw_sprite(exhaust)
 	end
 end
 
 -- ship shield
 if ship.shield>0 then
 	local c=7
 	local r=ship.shield_r
 	if t%4<2 then
 		c=12
 	end
 	local x=ship.x
 	local y=ship.y
 	local d=r*sin(t/30)
 	circ(x+3,y+3,r,c)
 	oval(x+3-r,y+3+d,x+3+r,y+3-d,c)
 	oval(x+3+d,y-r+3,x+3-d,y+3+r,c)
 end
 
 -- draw muzzle flash
 if muzzle>0 then
 	circfill(ship.x+4, ship.y-4, muzzle, 7)
 	circfill(ship.x+3, ship.y-4, muzzle, 7)
 end
 
	-- drawing enemies
	for curr in all(enemies) do
		if curr.flash>0 then
 		curr.flash-=1
 		if curr.boss then
	 		pal(3,8)
	 		pal(11,8)
	 		curr.sprite=72
 		else
 			for i=0,16 do
	 			pal(i,7)
	 		end
 		end
 	end
 	draw_sprite(curr)
 	pal()
 end 

	-- drawing bullets
	for curr in all(bullets) do
 	draw_sprite(curr)
 end
 
 -- drawing shockwaves
 for w in all(shockwaves) do
 	w.r+=w.speed
 	if w.r>w.target then
 		del(shockwaves,w)
 	end
 	circ(w.x,w.y,w.r,w.col)
 end
 
 -- drawing explosion particles
 for p in all(explosions) do
 	local r=(p.max_age-p.age)/6
 	local c=7
 	if p.p_type=="red" or
 	 p.p_type=="spark" then
 		c=p_red(p.age)
 	elseif p.p_type=="blue" then
 		c=p_blue(p.age)
 	end
 		
 	if p.p_type=="spark" then
 		pset(p.x, p.y, c)
 	else
 		circfill(p.x, p.y, r, c)
 	end
 	
 	p.x+=p.speed_x
 	p.y+=p.speed_y
 	if p.speed_x>0 then
 		p.speed_x-=p.friction
 	end
 	if p.speed_x<0 then
 		p.speed_x+=p.friction
 	end
 	if p.speed_y>0 then
 		p.speed_y-=p.friction
 	end
 	if p.speed_y<0 then
 		p.speed_y+=p.friction
 	end
 	p.age+=1
 	
 	if p.age>p.max_age then
 		del(explosions,p)
 	end
 end
 
 -- draw pickups
 for p in all(pickups) do
 	local c=7
 	if t%4<2 then
 		c=10
 	end
 	for i=1,15 do
 		pal(i,c)
 	end
 	draw_outline(p)
 	pal()
 	draw_sprite(p)
 end
 
 -- draw floating text
 for f in all(floats) do
 	local c=7
 	if t%4<2 then
 		c=8
 	end
 	cprint(f.txt,f.x,f.y,c)
 	f.age-=1
 	if f.age<=0 then
 		del(floats,f)
 	end
 end
 
 -- drawing enemy bullets
	for bul in all(e_bullets) do
 	draw_sprite(bul)
 end
 
 -- printing ui stuff
 -- health
 spr(11,1,1)
	spr(92,10,1,3,1)
	for i=0,lives-1 do
		rectfill(13+i*4,3,15+i*4,5,8)
	end
	-- shield
	spr(76,104,1,3,1)
	spr(15,96,0)
	local s_num=ship.shield/ship.max_shield*10-1
	for i=0,s_num do
		rectfill(107+i*2,3,107+i*2,5,12)
	end
	-- weapon
	if ship.weapon==0.5 then
		spr(41,1,10)
		print("x"..ship.ammo,12,11,9)
	elseif ship.weapon==1 then
		spr(57,1,12)
		print("x"..ship.ammo,12,13,9)
	end
	cprint("score: "..score,64,2,10)
	print(ship.bomb,120,10,7)
	spr(61,110,8)
	
	
	

end

function draw_start()
	cls()
	cprint_outline(
	"destroy 'em all!",64,45,7,8)
	cprint(
	"❎ to shoot",64,55,10)
	cprint(
	"🅾️ for bomb and shield"
	,64,65,10)

	cprint(
	"press ❎ to start",64,75,blink())

end

function draw_over()
	draw_game()
	cprint_outline("gameover!",
	 64, 50, 8)
	cprint_outline("press ❎ to try again!",
	 64, 65, blink())
end

function draw_wavetext()
	draw_game()
	cprint_outline("wave "..wave,64,50
		,blink())
end

function draw_win()
	draw_game()
	cprint_outline("you won!!",
	 64, 50, 2)
	cprint_outline("press ❎ to play again!",
	 64, 65, 7)
end
-->8
-- vfx
function starfield()
	for curr in all(stars) do
	 local star_color = 7
	 
	 if (curr.y_spd < 1) then
	 	star_color=1
	 elseif (curr.y_spd < 1.5) then
	 	star_color=5
	 end
	 
	 curr.y+=curr.y_spd
	 if btn(⬅️) then
	 	curr.x+=curr.x_spd
	 end
	 if btn(➡️) then
	 	curr.x-=curr.x_spd
	 end
	 if curr.y>128 then
	  curr.y = 0
	 end
	 if curr.x>128 then
	 	curr.x=0
	 end
	 if curr.x<0 then
	 	curr.x=128
	 end
	 
		pset(curr.x, curr.y, star_color)
	end
end

function blink()
	local blink_colors=
		{5,5,5,5,6,6,7,7,6,6,5,5}
 if blink_index>#blink_colors then
 	blink_index=1
 end
	return blink_colors[blink_index]
end

function explode(x,y,p_type,num,spd,max_age)
	if max_age==nil then
		max_age=20+rnd(20)
	end
	for i=1,num do
		add(explosions, {
			x=x,
			y=y,
			speed_x=(rnd()-0.5)*spd,
			speed_y=(rnd()-0.5)*spd,
			age=0,
			max_age=max_age,
			p_type=p_type,
			friction=0.1
		})
	end
end

function p_red(age)
	local c=7
	if age>2 then
		c=10
	end
	if age>7 then
		c= 9
	end
	if age>10 then
		c= 8
	end
	if age>13 then
		c= 2
	end
	if age>17 then
		c= 5
	end
	if age>20 then
		c= 1
	end
	return c
end

function p_blue(age)
	local c=7
	if age>2 then
		c= 6
	end
	if age>7 then
		c= 12
	end
	if age>10 then
		c= 13
	end
	if age>13 then
		c= 2
	end
	if age>17 then
		c= 5
	end
	if age>20 then
		c= 1
	end
	return c
end

function small_shockwave(x,y,col)
	if col==nil then
		col=9
	end	
	add(shockwaves,{
		x=x,
		y=y,
		r=3,
		target=6,
		speed=1,
		col=col
	})
end

function big_shockwave(x,y)
	add(shockwaves,{
		x=x,
		y=y,
		r=3,
		target=17,
		speed=2,
		col=7
	})
end

function screen_shake()
	local strength=2
	local fade=0.7
	local offset_x=strength-rnd(2*strength)
	local offset_y=strength-rnd(2*strength)
	
	offset_x*=offset
	offset_y*=offset
	
	camera(offset_x,offset_y)
	
	offset*=fade
	if offset<0.1 then
		offset=0
	end
end
-->8
-- enemy behavior
function pick_timer()
	if mode!="game" then
		return
	end
	if t%enemy_atk_delay==0 then
		pick_attacker()
	end
	if t%(enemy_atk_delay*1)==0 then
		pick_shooter()
	end
end

function pick_shooter()
	local max_num=min(10,#enemies)
	local index=flr(rnd(max_num))
	index=#enemies-index
	local e=enemies[index]
	if e==nil then return end
	if e.mission=="hover" and
		e.type!="b" then
		e.flash=4
		e_shoot(e,2)
	end
end

function pick_attacker()
	local max_num=min(10,#enemies)
	local index=flr(rnd(max_num))
	index=#enemies-index
	local e=enemies[index]
	if e==nil then return end
	if e.mission=="hover" and
		e.type!="b" then
		e.ani_spd=0.4
		e.wait=30
		e.shake=60
		e.mission="attack"
	end
end

function enemy_do(e)
	if e.wait>0 then
		e.wait-=1
		return
	end
	if e.mission=="flying" then
		-- x+=(target_x-x)/n
		-- higher n, smoother ease
		local dy=(e.tar_y-e.y)/7
		local dx=(e.tar_x-e.x)/7
		
		if e.boss then
			dy=min(dy,1)
		end
		e.x+=dx
		e.y+=dy
		
		if abs(e.y-e.tar_y)<.5 then
			e.y=e.tar_y
			e.mission="hover"
			if e.type==7 then
				e.mission="attack"
			end
			if e.boss then
				e.mission="boss1"
				e.ph_begin=t
			end
		end
	elseif e.mission=="boss1" then
		boss1(e)
	elseif e.mission=="boss2" then
		boss2(e)
	elseif e.mission=="boss3" then
		boss3(e)
	elseif e.mission=="boss4" then
		boss4(e)
	elseif e.mission=="boss5" then
		boss5(e)
	elseif e.mission=="boss6" then
		boss6(e)
	elseif e.mission=="hover" then
		-- staying put
	elseif e.mission=="attack" then
		if e.type==1 then
			-- green: charge to player
			e.sy=1.2
			e.sx=sin(t/45)
			if e.x<32 then
				e.sx+=1-(e.x/32)
			end
			if e.x>120-32 then
				e.sx-=(e.x-88)/32
			end
		
		elseif e.type==2 then
		-- red guy: faster green
			e.sy=2.5
			e.sx=2*sin(t/20)
		
		elseif e.type==3 then
		-- spinny: shoot straight
			straight_shot(e,0,2)
			e.mission="hover"
			
		elseif e.type==4 then
		-- drill: fly straight to play point
			if e.sx==0 and e.sy==0 then
				dx=ship.x-e.x
				dy=ship.y-e.y
				l=sqrt(dx*dx+dy*dy)
				e.sx=dx/l*3
				e.sy=dy/l*3
			end
		
		elseif e.type==5 then
		-- drone: down, then shoot
			if e.lock==false then
				e.sy=2
			end
			local final={50,60,70}
			if rnd(final)<=e.y then
				-- stop fly down, shoot player
				e.sy=0
				e.lock=true
				e.shoot_cd+=1
				local b_sx=0
				if ship.x<e.x then
					b_sx=-2
				else
					b_sx=2
				end
				if e.shoot_cd==e.shoot_delay then
					straight_shot(e,b_sx,0)
					e.shoot_cd=0
				end
			end
		elseif e.type==6 then
		-- mouth: down, then to player
			if e.sx==0 then
				-- flying down
				e.sy=2
				if ship.y<=e.y then
					-- stop fly down, hunt player
					e.sy=0
					if ship.x<e.x then
						e.sx=-1
					else
						e.sx=1
					end
				end
			end
		elseif e.type==7 then
		-- yellow big guy
			if e.shoot_cd==e.shoot_delay then
				spread_shot(e,1,16,e.base)
				e.shoot_cd=0
				e.base+=1/64
			end
			e.shoot_cd+=1
		end
		move(e)
	end
end

function move(obj)
	obj.x+=obj.sx
	obj.y+=obj.sy
end

function kill_e(e)
	if e.boss then
		e.mission="boss6"
		e.ph_begin=t
		e.ghost=true
		e_bullets={}
		return
	end
	local chance=pickup_drop_rate
	if e.mission=="attack" then
		chance*=2
	end
	if rnd()<chance then
		create_pickup(e)
	end
	offset=1
	del(enemies,e)
	sfx(8)
	score+=10
	if e.mission=="attack" then
		score+=100
		pop_float("100",e.x,e.y)
	end
	explode(e.x+4,
		e.y+4,"red",10,4)
	explode(e.x+4,	
		e.y+4,"spark",15,5)
	big_shockwave(e.x+4,	
		e.y+4)
	if rnd()<0.5 then
		pick_attacker()
	end
	if rnd()<0.5 then
		pick_shooter()
	end
end

function e_col_bul(e,b)
	sfx(2)
	e.hp-=b.dmg
	b.hp-=1
	if b.hp==0 then
		del(bullets,b)
	end
	small_shockwave(b.x+4,
			b.y)
	explode(b.x+4,
		b.y,"spark",5,10)
	e.flash=3
	if e.hp<=0 then
		kill_e(e)
	end
end


function e_shoot(e,vel)
	e.flash=4
	sfx(9)
	local choose=rnd(
		{1,1,1,1,3}
	)
	local angle=rnd({1/8,0})
	if choose==1 then
		straight_shot(e,0,vel)
	elseif choose==2 then
		spread_shot(e,vel,4,angle)
	elseif choose==3 then
		aim_shot(e,vel)
	end
end

function straight_shot(e,sx,sy)
	local new_bul=make_spr(0,0)
	new_bul.x=e.x+4*(e.w/2)
	new_bul.y=e.y+4*(e.h/2)
	new_bul.sprite=53
	new_bul.sheet={53,54,55,54}
	new_bul.ani_spd=0.2
	new_bul.w=1
	new_bul.h=1
	new_bul.sx=sx
	new_bul.sy=sy
	new_bul.is_bul=true
	add(e_bullets,new_bul)
end

function spread_shot(e,vel,num,base)
	local angle=base
	for i=1,num do
		sx=vel*cos(angle)
		sy=vel*sin(angle)
		straight_shot(e,sx,sy)
		angle+=1/num*i
	end
end

function aim_shot(e,vel)
	dx=ship.x-e.x
	dy=ship.y-e.y
	l=sqrt(dx*dx+dy*dy)
	sx=dx/l*vel
	sy=dy/l*vel
	straight_shot(e,sx,sy)
end

-->8
-- enemy types and waves
type_1={
	hp=2,
	x=x,
	y=y,
	speed=0.5,
	flash=0,
	frame=1,
	sprite=17,
	w=1,
	h=1,
	sprite=17,
	sheet={17,18,19,20},
}
	
-- waves
wave_8={
	{0,0,"b",0,0,0,0,0,0,0}
}
wave_1={
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1},
}
wave_2={
	{2,1,1,1,2,2,1,1,1,2},
	{2,1,1,1,2,2,1,1,1,2},
	{2,1,1,1,2,2,1,1,1,2},
	{2,1,1,1,2,2,1,1,1,2},
}
wave_3={
	{1,1,2,1,1,1,1,2,1,1},
	{1,1,2,3,3,3,3,2,1,1},
	{3,3,2,3,3,3,3,2,3,3},
	{1,3,1,1,1,1,1,1,3,1}
}
wave_4={
	{4,5,2,2,3,3,2,2,5,4},
	{1,5,2,3,3,3,3,2,5,1},
	{4,4,2,3,4,4,3,2,4,4},
	{4,4,5,1,4,4,1,5,4,4}
}
wave_5={
	{1,5,4,2,0,0,2,4,5,1},
	{1,7,0,3,0,0,3,7,0,1},
	{1,0,0,6,0,0,6,0,0,1},
	{1,5,5,3,0,0,3,5,5,1}
}
wave_6={
	{4,5,6,6,6,6,6,6,5,4},
	{6,0,0,3,7,0,3,0,0,6},
	{6,0,0,6,0,0,6,0,0,6},
	{6,5,5,3,4,4,3,5,5,6}
}

wave_7={
	{0,7,0,0,0,0,0,0,7,0},
	{0,0,0,0,7,0,0,0,0,0},
	{0,7,0,0,0,0,0,0,7,0},
}

-->8
-- boss
function boss1(b)
	-- movement
	local spd=2
	b.phasetime=8
	if b.sx==0 or b.x>=107 then
		b.sx=-spd
	end
	if b.x<=-12 then
		b.sx=spd
	end
	-- shooting
	local b_m={
		x=b.x+8,
		y=b.y+8,
		w=2,
		h=2,
	}
	if t%30>=5 then
		if t%3==0 then
			sfx(17)
			straight_shot(b_m,0,2)
		end
	end
	
	if b.ph_begin+b.phasetime*30<t then
		b.ph_begin=t
		b.mission="boss2"
		b.subphase=1
	end
	move(b)
end

function boss2(b)
	local spd=1.5
	-- movement
	if b.subphase==1 then
		b.sy=0
		b.sx=-spd
		if b.x<=2 then
		 b.subphase=2
		end
	elseif b.subphase==2 then
		b.sx=0
		b.sy=spd
		if b.y>=94 then
			b.subphase=3
		end
	elseif b.subphase==3 then
		b.sy=0
		b.sx=spd
		if b.x>=94 then
			b.subphase=4
		end
	elseif b.subphase==4 then
		b.sx=0
		b.sy=-spd
		if b.y<=10 then
			b.subphase=1
		end
	end
	-- shooting
	local b_m={
		x=b.x+8,
		y=b.y+8,
		w=2,
		h=2,
	}
	if t%10==0 then
		sfx(17)
		aim_shot(b,2)
	end

	if b.ph_begin+b.phasetime*30<t then
		b.ph_begin=t
		b.mission="boss3"
	end
	move(b)
end

function boss3(b)
	-- movement
	local spd=1
	if b.y<=b.tar_y then
		b.sy=0
	end
	if b.sx==0 or b.x>=94 then
		b.sx=-spd
	end
	if b.x<=2 then
		b.sx=spd
	end
	-- shooting
	if t%15==0 then
		sfx(17)
		spread_shot(b,2,16,time())
	end
	

	if b.ph_begin+b.phasetime*30<t then
		b.ph_begin=t
		b.sx=0
		b.mission="boss4"
		b.subphase=1
	end
	move(b)
end

function boss4(b)
	local spd=1.5
	-- movement
	if b.subphase==1 then
		b.sy=0
		b.sx=spd
		if b.x>=94 then
			b.subphase=2
		end
	elseif b.subphase==2 then
		b.sx=0
		b.sy=spd
		if b.y>=94 then
			b.subphase=3
		end
	elseif b.subphase==3 then
		b.sy=0
		b.sx=-spd
		if b.x<=2 then
		 b.subphase=4
		end
	elseif b.subphase==4 then
		b.sx=0
		b.sy=-spd
		if b.y<=10 then
			b.subphase=1
		end
	end
	
	--shooting
	local b_m={
		x=b.x+8,
		y=b.y+8,
		w=2,
		h=2,
	}
	
	if t%10==0 then
		sfx(17)
		if b.subphase==1 then
			straight_shot(b_m,0,2)
		elseif b.subphase==2 then
			straight_shot(b_m,-2,0)
		elseif b.subphase==3 then
			straight_shot(b_m,0,-2)
		elseif b.subphase==4 then
			straight_shot(b_m,2,0)
		end
	end
	

	if b.ph_begin+8*30<t then
		b.ph_begin=t
		b.mission="boss5"
	end
	move(b)
end

function boss5(b)
	local spd=2
	--movement go back to beginning
	dx=b.tar_x-b.x
	dy=b.tar_y-b.y
	local l=sqrt(dx*dx+dy*dy)
	b.sx=dx/l*spd
	b.sy=dy/l*spd
	if l<=2 then
		b.x=b.tar_x
		b.y=b.tar_y
		b.sx=0
		b.sy=0
	end
	
	if b.ph_begin+2*30<t then
		b.ph_begin=t
		b.mission="boss1"
	end
	move(b)
end

function boss6(b)
	b.shake=10
	b.flash=10
	
	if t%8==0 then
		offset=1
		local e_offset=rnd(32)
		explode(b.x+e_offset,
			b.y+e_offset,"red",10,4)
		explode(b.x+e_offset,	
			b.y+e_offset,"spark",15,5)
		big_shockwave(b.x+rnd(32),
			b.y+rnd(32))
		sfx(18)
		sfx(1)
	end
	if b.ph_begin+2*30<t then
		if t%4==0 then
			offset=1
			local e_offset=rnd(32)
			explode(b.x+e_offset,
				b.y+e_offset,"red",10,4)
			explode(b.x+e_offset,	
				b.y+e_offset,"spark",15,5)
			big_shockwave(b.x+rnd(32),
				b.y+rnd(32))
			sfx(18)
			sfx(1)
		end
	end
	if b.ph_begin+4*30<t then
		sfx(1)
		sfx(20)
		explode(b.x+16,
				b.y+16,"red",20,5,80)
		big_shockwave(b.x+rnd(32),
			b.y+rnd(32))
		big_shockwave(b.x+rnd(32),
			b.y+rnd(32))
		enemies={}
		mode="win"
	end
end


__gfx__
0000000000022000000220000002200000099000000000000000000000000000000000000000000000000000088008800880088000ff880000ff880000000000
000000000028820000288200002882000097790000077000000770000007700000c77c000007700000000000888888888008800808888880088888800cccccc0
00700700002882000028820000288200009aa90000c77c000007700000c77c000cccccc000c77c0000000000888888888000000806555560076665500c7777c0
0007700000288e2002e88e2002e88200009aa90000cccc00000cc00000cccc0000cccc0000cccc0000000000888888888000000865666655765555650cccccc0
0007700002ac88202e8ac8e20288ac20009aa900000cc000000cc000000cc00000000000000cc00000000000088888800800008057655576555776550c7cc7c0
00700700021188202881188202881120009aa90000000000000cc00000000000000000000000000000000000008888000080080006557660057655500c7777c0
000000000255882028d55d8202885520009aa9000000000000000000000000000000000000000000000000000008800000088000005765000065570000c77c00
000000000029920002d99d20002992000009900000000000000000000000000000000000000000000000000000000000000000000006500000057000000cc000
00000000033003300300330003300330003300300058950000089500001891000059800020000002020000200000550000005000000500000055000000000000
0000000033b33b330b3b333033b33b330333b3b00521125000d212500011110005212d0022000022220000220005500000055000000550000005500000cccc00
000000003bbbbbb30bbbb3303bbbbbb3033bbbb0521aa1250251a12000155100021a152022222222222222220555555005555550055555500555555000c77c00
000000003b7717b30b71b3303b7717b3033b71b0621aa1260d51a12000d55d00021a15d028222282282222822222222222222222222222222222222200cccc00
000000000b7117b00b11b3000b7117b0003b11b06520025606520250006dd6000520256028888882288888822606060226060602266666622606060200c7cc00
00000000003773000077300000377300000377000650056000650560006666000650560028788782287887822000000220606062222222202060606200c77c00
00000000030330300300030003033030003000300760067000760d000006600000d0670028888882080000802060606222222220000000002222222000c77c00
000000003000000303303300300000030033033000700700000706000007700000607000080000800000000022222220000000000000000000000000000cc000
00000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000808000000800000000000
0000000000000000000000000000000000000000000bb000000bb0000007700000077000000000000000000000000000000000000088888000088800000cc000
000000000000149aa9410000000001222210000000666600006666006066660660666606000000000000000000000000000000000088888000088800000c7000
0000000000019777aa921000000029aaaa9200000566665065666656b566665bb566665b099009900099090000099000009099000088888000088800000cc000
000000000d09a77a949920d00d0497777aa920d065637656b563765b0563765005637650099009900099090000099000009099000088888000088800000c7000
000000000619aaa9422441600619a77944294160b063360b006336000063360000633600000000000000000000000000000000000008880000088800000c7000
0000000007149a922249417006149a944224416000633600006336000063360000633600000000000000000000000000000000000000800000008000000c7000
0000000007d249aaa9942d7006d249aa99442d60000660000006600000066000000660000000000000000000000000000000000000000000000000000000c000
00000000067d22444422d760077d22244222d7700000000000000000000000000099990000000000000000000000000000000000000000000000000000000000
000000000d666224422666d00d776249942677d000222200008888000033330009aaaa9000099000000090000009000000090000000000000000000000000000
00000000066d51499415d66001d1529749251d100244442008eeee8003bbbb309aa77aa9000990000000900000090000000900000000d800008d000000000000
000000000041519749151400066151944a1516600248842008eaae8003baab309a7777a900000000000000000000000000000000001d10000001d10000000000
0000000000a001944a100a0000400149a41004000248842008eaae8003baab309a7777a900000000000000000000000000000000011111000011111000000000
0000000000000049a400090000a0000000000a000244442008eeee8003bbbb309aa77aa909900990009909000009900000909900016111000016111000000000
000000000000000000000000000000000000090000222200008888000033330009aaaa9009900990009909000009900000909900016111000016111000000000
00000000000000000000000000000000000000000000000000000000000000000099990000000000000000000000000000000000001110000001110000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccccccc000000000
0000000000000007a00000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000c00000000
0000000070000007a0000007000000000000000000700007a0000700000000000000000000000007a0000000000000000c000000000000000000000c00000000
000000007700037aa9300077000000000000000007700007a0000770000000000000000070000007a0000007000000000c000000000000000000000c00000000
00000000a77733aa9933777a00000000000000000770037aa930077000000000000000007700037aa9300077000000000c000000000000000000000c00000000
000000009aaa3b3993b3aaa900000000000000009a7733aa993377a90000000000000000a77733aa9933777a000000000c000000000000000000000c00000000
0000000b3993bbb33bbb3993b00000000000000039aa3b3993b3aa9300000000000000009aaa3b3993b3aaa900000000ccccccccccccccccccccccc000000000
000000bbb33bb3b33b3bb33bbb0000000000000b3333bbb33bbb333bb00000000000000b3993bbbbbbbb3993b000000000000000000000000000000000000000
00000bb7bbbb373ff3b3bbbb3bb00000000000bbbbbbb3b33b3bbbbbbb000000000000bbb33bb7bb3bbbb33bbb00000088888888888888888888888000000000
0000bb77bbbb373ff3b3bbb333bb000000000bb73bbb373ff3b3bbb33bb0000000000bb7bbbb77bb3bbbbbbb3bb0000008000000000000000000000800000000
000bb77333b3a377f93b3b333bbbb0000000bb7733bb373ff3b3bb333bbb00000000bb77bbb77bb33bbbbbb333bb000008000000000000000000000800000000
000b777b3333a377193b3333bb33b000000bb77b3333a377f93b3333bbbbb000000bb77333bb7bb33bbbbb333bbbb00008000000000000000000000800000000
00bb777bbbb3a3f1091b3bbbb333bb00000b77bbb333a377193b333bb333b000000b777b3333bbb33bbb3333bb33b00008000000000000000000000800000000
00bb77aabbbbb390091bbbbb3333bb0000bb7733bbb3a3f1091b3bbb3333bb0000bb777bbb3333b33b3333bbb333bb0008000000000000000000000800000000
007bbaaa333bb1999e1bb333333bbb0000bb773333bbb390091bbb333333bb0000bb77aabbbbbbb33bbbbbb33333bb0088888888888888888888888000000000
0007bbbbbb333b13e1b333bbbbbbb000007bbaa33333b1999e1b3333333bbb00007bbaaa33333bb33bbb3333333bbb0000000000000000000000000000000000
000000311177b311113b7711130000000007bbbbbb333b13e1b333bbbbbbb000000bbbbbbb333b1e31b333bbbbbb700000000000000000000000000000000000
00333003311111111111111330033300000000311177b311113b771113000000000000311177b311113b77111300000000000000000000000000000000000000
0b3333008383344184433838003333b0000000033111111111111113300000000000000331111111111111133000000000000000000000000000000000000000
02bbb3322828884884888282233bbb20000000008383344184433838000000000000000083833448144338380000000000000000000000000000000000000000
00222220022989800898922002222200000033322828884884888282233300000000333228288848848882822333000000000000000000000000000000000000
00000000002a9a0000a9a20000000000000333b202298980089892202b333000000333b202298980089892202b33300000000000000000000000000000000000
0000000333207a0000a702333000000000033b0000209a7007a9a20000b3300000033b00002a9a7007a9020000b3300000000000000000000000000000000000
00000333320027700772002333300000000bb20003202a7707a20230002bb000000bb20003202a7077a20230002bb00000000000000000000000000000000000
0000333b2002220000222002b3330000000000003320082202280033000000000000000033008220228002330000000000000000000000000000000000000000
000333b200082200002280002b333000000000033000008008800003300000000000000330000880080000033000000000000000000000000000000000000000
000bbb20000088000088000002bbb000000000332000000000000002330000000000003320000000000000023300000000000000000000000000000000000000
00002200000000000000000000220000000000332200000000000022330000000000003322000000000000223300000000000000000000000000000000000000
00000000000000000000000000000000000000332200000000000022330000000000003322000000000000223300000000000000000000000000000000000000
00000000000000000000000000000000000000332200000000000022330000000000003322000000000000223300000000000000000000000000000000000000
00000000000000000000000000000000000000022000000000000002200000000000000220000000000000022000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000000088888888888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80080080088000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80888888088088808880888088808880880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80888888088088808880888088808880880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80088880088088808880888088808880880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80008800088088808880888088808880880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80000000088000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888888888888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00000000cc000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00c00c00cc0c0c0c0c0c0c0c0c0c0c0cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00cccc00cc0c0c0c0c0c0c0c0c0c0c0cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00c77c00cc0c0c0c0c0c0c0c0c0c0c0cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00c77c00cc0c0c0c0c0c0c0c0c0c0c0cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c000cc000cc000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00000000ccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000031510305102c51027510215101b510155100c500045000050000500015000250000500005000050000500005000050000500015000050000500005000050000500005000050000500015000050000500
000200001a6101a6101961019610186101661014610126100f6100d6100a610076100561003610026100161000610006100160000000000000000000000000000000000000000000000000000000000000000000
000100001a5201552012520105200f5200d5200a52009520085200250001500005000550006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e000016510165301650016500165401654016500165001f5401f5401f5001f5001f5401f5401f5001f5002e5402e5402e5002e5002e5402e5402e5002e5002454024540245002450024530245202450024500
001e000007100071000712007120071000710007120071200c1000c1000c1200c1200c1000c1000c1200c1200a1000a1000a1200a1200a1000a1000a1200a1200310003100031200312003100031000312003120
001e0000077100772007730077300772007710077100772013730137301373013730137201371013710137200f7300f7300f7300f7300f7200f7100f7100f7201873018730187301873018720187101871018720
001e000024320243202b30027320243200030022320003001f3200030018320003001f320223002a30018300183201832018300273202e3202e3001632016320323200c320163201d32030320273000330005300
290500003c5523a51236522325322f5422c5422854225542215421f5421b542195421653213532105320e5320b522095220752205522035220152200522055020450204502035020350202502005020050200502
34030000006011263111631106310f6210c6210a62108621056210261100601026010560100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
5d02000010355003050b3550735502355013550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
900300002041323413244132441300413004130142326423274332743327443004430145302453294032b4032c4030040301403034032d4032d4032e4032f403014030240304403064032f403304033140300403
760400000060200602006020060200602006020161202612026120361204612056220662208622096220b6220d6320e632116321363216642186421b6421c6421e642216522365226652286422b6322f63233622
1b04000000505015550355506555075550a5550f555185552755534555225050c5050d5050f505105051350515505005050050500505005050050500505005050050500505005050050500505005050050500505
900800000c0170f0371107714077180371f02723017280271d0072d0073b0073c0070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007
3a020000276502b670306703466034640326302e6302b630286302562020620156201661015610106100a610066100c6000860008600086000660006600056000460003600036000260001600016000160001600
220200000f2130f2130f2131c203182030d2030d2030d2031021310213102130c2030c2030c203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
b60300001a60721617296372e64731657326570060700607006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607
2001000003110041100d1100f1100a110001000010000100001003210000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
020200000050314513215232b533315333253312523095130b5030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503005030050300503
010400000060518655186551865518605186051860518605186050060500605006051865518655186551860518605186051860518605186050060500605006051865518655186551860518605186051860518605
4c030000136111c61123611286112b6112f6113261133611346113461133611316112f6112d6112b611286112661123611206111c6111961116611146110f6110c6110a611056110461103611026110160100601
__music__
02 03040506

