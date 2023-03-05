pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
function _init()
	objs={}
	gravity=1
	game_start()
end

function _update()
	cls()
	if btn(⬅️) then
		rotate_cam(1/180)
	end
	if btn(➡️) then
		rotate_cam(-1/180)
	end
	if btn(⬆️) then
		for o in all(objs) do
			o.y-=1
		end
	end
	if btn(⬇️) then
		for o in all(objs) do
			o.y+=1
		end
	end
end

function _draw()
	-- sort by depth
	qsort(objs,
		function(a,b) return a.y<b.y end)
	-- draw the shadow first
	for o in all(objs) do
		--circfill(o.x,o.y,o.r,5)
		ovalfill(o.x-o.r,o.y-o.r/3,
			o.x+o.r,o.y+o.r/3,5)
	end
	-- draw the objects
	for o in all(objs) do
		circfill(o.x,o.y-o.h,o.r,o.c)
	end
end
-->8
-- game inits
function game_start()
	for i=0,20 do
		local x=64+(rnd(100)-50)
		local y=64+(rnd(100)-50)
		local h=rnd(20)
		local r=rnd(5)+2
		local c=rnd({7,8,9,10})
		make_obj(x,y,h,r,c)
	end
end
-->8
-- updates
-->8
-- draw
-->8
-- tools
function make_obj(x,y,h,r,c)
	add(objs,{
		x=x,
		y=y,
		h=h,
		scr_y=y,
		scr_h=h,
		depth=r,
		r=r,
		c=c,
	})
end

-- a: array to be sorted in-place
-- c: comparator (optional, defaults to ascending)
-- l: first index to be sorted (optional, defaults to 1)
-- r: last index to be sorted (optional, defaults to #a)
function qsort(a,c,l,r)
 c,l,r=c or ascending,l or 1,r or #a
 if l<r then
  if c(a[r],a[l]) then
   a[l],a[r]=a[r],a[l]
  end
  local lp,rp,k,p,q=l+1,r-1,l+1,a[l],a[r]
  while k<=rp do
   if c(a[k],p) then
    a[k],a[lp]=a[lp],a[k]
    lp+=1
   elseif not c(a[k],q) then
    while c(q,a[rp]) and k<rp do
     rp-=1
    end
     a[k],a[rp]=a[rp],a[k]
     rp-=1
     if c(a[k],p) then
      a[k],a[lp]=a[lp],a[k]
      lp+=1
     end
   end
   k+=1
  end
  lp-=1
  rp+=1
  a[l],a[lp]=a[lp],a[l]
  a[r],a[rp]=a[rp],a[r]
  qsort(a,c,l,lp-1       )
  qsort(a,c,  lp+1,rp-1  )
  qsort(a,c,       rp+1,r)
 end
end

-- rotate camera related to center
-- of the screen (64,64)
function rotate_cam(angle)
	for o in all(objs) do
		local dx=64
		local dy=64
		local x_r=((o.x-dx)*cos(angle))
			-((o.y-dy)*sin(angle))+dx
		local y_r=((o.x-dx)*sin(angle))
		 +((o.y-dy)*cos(angle))+dy
		o.x=x_r
		o.y=y_r
	end
end
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
