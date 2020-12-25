pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--entry in #toyboxjam #tbj2020
--code and game design by jenny schmidt (bikibird)
--in honor of max tojoby, friend 
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
left,right,up,down,fire1,fire2=0,1,2,3,4,5
becalmed,tail=6,7
bulb_colors={green,red,blue,yellow}
-->8
--initialize
function _init()
	tracks={}
	for i=0,15 do
		tracks[i]={}
	end
	tracks[0][6]=down; tracks[0][7]=left; tracks[0][8]=left; tracks[0][9]=left;
	tracks[1][6]=down; tracks[1][9]=up; 
	tracks[2][6]=down; tracks[2][9]=up; 
	tracks[3][4]=down; tracks[3][5]=left; tracks[3][6]=left; tracks[3][9]=up; tracks[3][10]=left; tracks[3][11]=left;
	tracks[4][4]=down; tracks[4][11]=up;
	tracks[5][4]=down; tracks[5][11]=up;
	tracks[6][2]=down; tracks[6][3]=left; tracks[6][4]=left; tracks[6][11]=up; tracks[6][12]=left; tracks[6][13]=left; 
	tracks[7][2]=down; tracks[7][13]=up
	tracks[8][2]=down; tracks[8][13]=up
	tracks[9][0]=down; tracks[9][1]=left; tracks[9][2]=left; tracks[9][13]=up; tracks[9][14]=left; tracks[9][15]=left;
	tracks[10][0]=down; tracks[10][15]=up
	tracks[11][0]=down; tracks[11][15]=up
	tracks[12][0]=down; tracks[12][15]=up
	tracks[13][0]=right; tracks[13][1]=right;tracks[13][2]=right; tracks[13][3]=right; tracks[13][4]=right; tracks[13][5]=right; tracks[13][6]=down;
	tracks[13][9]=right; tracks[13][10]=right;tracks[13][11]=right; tracks[13][12]=right; tracks[13][13]=right; tracks[13][14]=right; tracks[13][15]=up; 
	tracks[14][6]=down; tracks[14][9]=up
	tracks[15][6]=right; tracks[15][7]=right; tracks[15][8]=right; tracks[15][9]=up
	init_stars()
	--init_snek_yard()
	
	init_forest()
	_draw = draw_intro
	_update = update_intro
end	
function init_bulbs()
	bulbs={}
	for i=0,3 do
		local bulb=get_empty_cell()
		bulb.s=flr(rnd(4))*5 +4
		mset(bulb.x,bulb.y,bulb.s)
		add(bulbs,bulb)
	end
end
function init_forest()
	forest={}
	quasar={x=60,y=30,s={27,28}}
	pulse=0
	planted=false
end

function init_stars()
	stars={}
	for i=0,3 do
		for j=0,1 do
			local star={x=flr(rnd(30))+(30*i)+4,y=flr(rnd(14))+(14*j)+4,c=blue}
			add(stars,star)		
		end
	end
end
function init_snek()
	snek={{x=60,y=60,s=flr(rnd(4))*5,aim=becalmed,train=false, wire={x0=64, y0=64, x1=64,y1=64}}}
	tongue={x0=64,y0=59,x1=64,y1=59}
end	
-->8
--intro
function update_intro()
	if btnp(fire2) then
		init_snek_yard()
		_update=update_snek_yard
		_draw=draw_snek_yard
		init_forest()
	 
	end
end

function draw_intro()
	draw_snowscape()
	print(" tis the season to sing carols,",0,4,white)
	print("     drink nog, and decorate ",0,12)
	print(" the night with christmas sneks",0,20)
	print("        press X to play",4,119,dark_blue)
end
-->8
--snowscape
function update_stars()
	if star==nil then
		star=flr(rnd(8)+1)
		twinkle_time=time()
		twinkle_wait=rnd(3)+.5
	end	
	if time()-twinkle_time>twinkle_wait then
		if stars[star].c==blue then
			stars[star].c=dark_blue
		else
			stars[star].c=blue
			star=nil
		end	
	end	
end	
function draw_snowscape()
	rectfill(0,0,127,47,dark_blue)
	rectfill(0,48,127,48,black)
	rectfill(0,49,127,127,white)
end	
function draw_stars()
	for star in all(stars) do
		pset(star.x,star.y,star.c)
	end
end	
-->8
-->snek
function update_snek()
	if (short==0)then
		if (boarding) then
			train_travel(snek[#snek])
		else		
			travel(snek[#snek])
		end	
	else
		short_circuit(snek[#snek])
	end	
	update_burnout()
end
function train_travel(head)
	if (head) then
		local gridx=flr((head.x+3)/8)
		local gridy=flr((head.y+3)/8)
	
		if (btn(down) or btn(up) or btn(left) or btn(right)) then
			detrain(head)
		else	
			head.aim=tracks[gridy][gridx]
			if (head.aim==left) then
				head.x-=speed
				head.y=gridy*8
				
			elseif (head.aim==right) then
				head.x+=speed
				head.y=gridy*8
			elseif (head.aim==up) then
				head.y-=speed
				head.x=gridx*8
			elseif (head.aim==down) then	
				head.y+=speed
				head.x=gridx*8
			end
		end	
		update_tongue(head)
		slither()
	end	
end	
function slither()
	local dy, dx, c, gridx, gridy,aim
	for i=#snek-1,1,-1 do
		gridx=flr((snek[i].x+3)/8)
		gridy=flr((snek[i].y+3)/8)
		if (snek[i+1].train)then
			if(not snek[i].train)then
				if (fget(mget(gridx,gridy))>4 ) then
					snek[i].train=true
					snek[i].x=gridx*8
					snek[i].y=gridy*8
					--ride(i,gridx,gridy)
				else
					social_distance(i,10)
				end
			else
				ride(i,gridx,gridy)	
				social_distance(i,12)		
			end	
		else
			social_distance(i,10)
		end	
	end
	for i=#snek-1,1,-1 do
		snek[i].wire={x0=snek[i].x+4,y0=snek[i].y+4,x1=snek[i+1].x+3,y1=snek[i+1].y+3}
	end
	for i=#snek-1,1,-1 do
		if(tongue.x1>=snek[i].x) then
			if (tongue.x1<snek[i].x+8) then
				if (tongue.y1>=snek[i].y) then	
					if(tongue.y1<snek[i].y+8) then
						short=i
						break
					end	
				end
			end		
		end
	end
end	
function social_distance(i,distance)
	dx=snek[i+1].x - snek[i].x
	dy=snek[i+1].y - snek[i].y
	c=sqrt(dx*dx+dy*dy)
	if (c>distance) then
		snek[i].x=snek[i+1].x-dx/c*distance
		snek[i].y=snek[i+1].y-dy/c*distance
	end
end
function ride(i,gridx,gridy)
	aim=tracks[gridy][gridx]
	if (aim==left) then
		snek[i].x-=speed
		snek[i].y=gridy*8
	elseif (aim==right) then
		snek[i].x+=speed
		snek[i].y=gridy*8
	elseif (aim==up) then
		snek[i].y-=speed
		snek[i].x=gridx*8
	elseif (aim==down) then	
		snek[i].y+=speed
		snek[i].x=gridx*8
	end	
end	
function travel(head)
	if (head) then
		if (btn(left)) then
			head.aim=left
		elseif (btn(right)) then
			head.aim=right
		elseif (btn(up)) then
			head.aim=up
		elseif (btn(down)) then
			head.aim=down
		end	
		if (head.aim==left) then
			head.x-=speed
		elseif (head.aim==right) then
			head.x+=speed
		elseif (head.aim==up) then
			head.y-=speed
		elseif (head.aim==down) then	
			head.y+=speed
		end
		update_tongue(head)
		update_growth(head)
		update_boarding(head)
		slither(#snek-1)
	end
end
function detrain(head)

	boarding = false
	speed=1.5
	local gridx,gridy,aim,x,y
	x=head.x
	y=head.y
	gridx=flr((head.x+3)/8)
	gridy=flr((head.y+3)/8)
	while (fget(mget(gridx,gridy))>4) do
		gridx=flr((head.x+3)/8)
		gridy=flr((head.y+3)/8)
		aim=tracks[gridx][gridy]
		if (head.aim==left) then
			if(fget(mget(gridx,gridy+1))<4) then
				head.y=head.y+8
			else
				head.y+=speed	
			end
		elseif (head.aim==right) then
			if(fget(mget(gridx,gridy-1))<4) then
				head.y=head.y-8
			else
				head.y-=speed	
			end	
		elseif (head.aim==up) then
			if(fget(mget(gridx-1,gridy))<4) then
				head.x=head.x-8
			else
				head.x-=speed	
			end	
		elseif (head.aim==down) then
			if(fget(mget(gridx+1,gridy))<4) then	
				head.x=head.x+8
			else
				head.x+=speed	
			end	
		end
	end
	
	for bulb in all(snek) do
		bulb.train=false
	end
end
function short_circuit()
	local head=snek[#snek]
	if (#snek>=short) then
		add(burnouts,deli(snek,short))
		burnouts[#burnouts].wait=.01
		burnouts[#burnouts].time=time()
	
		
	end
	if (#snek<short) then
		short=0
		if (#snek>0) then
			local new_head=snek[#snek]
			new_head.aim=head.aim
			for bulb in all(snek) do
				bulb.train=false
			end
			boarding=false
			new_head.wire={x0=new_head.x+4, y0=new_head.y+4,x0=new_head.x+4, y0=new_head.y+4}
		end	
	end	
end	
function update_burnout()
	if (#burnouts>0)then
		burnout=burnouts[#burnouts]
		if (burnout.s%5==3) then
			sfx(48)
		end	
		if (time()-burnout.time>burnout.wait) then
			burnout.s+=1
			burnout.time=time()
		end	
		if (burnout.s%5==4)then
			deli(burnouts,#burnouts)
		end	
		if (#burnouts==0 and #snek==0) then
			sfx(55)
			gameover=time()
		end	
	elseif(#snek==0) then	
		if (time()-gameover>1) then
			_update=update_planting
			_draw=draw_planting
		end	
	end	
end

function update_growth(head)
	local gridx=flr(tongue.x1/8)
	local gridy=flr(tongue.y1/8)
	if (fget(mget(gridx,gridy))==1) then
		for i, bulb in pairs(bulbs) do
			if (bulb.x==gridx and bulb.y == gridy) then
				bulb.s=flr(bulb.s/5)*5
				bulb.aim=head.aim
				bulb.x*=8
				bulb.y*=8
				bulb.wire={x0=bulb.x,y0=bulb.y,x1=bulb.x,y1=bulb.y}
				bulb.train=false
				add(snek,bulb)
				deli(bulbs,i)
				break
			end
		end
		mset(gridx,gridy,26)
		sfx(41)
	end
end
function update_boarding(head)
	local gridx=flr((head.x+3)/8)
	local gridy=flr((head.y+3)/8)
	
	if (fget(mget(gridx,gridy))>4 ) then
		if (not boarding) then
			for bulb in all(snek) do
				bulb.train=false
			end
			boarding = true
			head.train=true
			head.x=gridx*8
			head.y=gridy*8
			head.aim=tracks[gridy][gridx]
			speed=2.5
		end	
	else
		boarding=false
	end	
end	
function update_tongue(head)
	local step =flr(rnd(5))+3
	if (frame%step==0) then
		flick = frame%2
	end	
	if (head.aim==up) then
		if (flick==0) then
			tongue={x0=head.x+4,y0=head.y-1,x1=head.x+3,y1=head.y-2}
		else
			tongue={x0=head.x+3,y0=head.y-1,x1=head.x+4,y1=head.y-2}
		end
	elseif (head.aim==down) then
		if (flick==0) then
			tongue={x0=head.x+4,y0=head.y+8,x1=head.x+3,y1=head.y+9}
		else
			tongue={x0=head.x+3,y0=head.y+8,x1=head.x+4,y1=head.y+9}
		end
	elseif (head.aim==left) then
		if (flick==0) then
			tongue={x0=head.x-1,y0=head.y+4,x1=head.x-2,y1=head.y+3}
		else
			tongue={x0=head.x-1,y0=head.y+3,x1=head.x-2,y1=head.y+4}
		end
	elseif (head.aim==right) then
		if (flick==0) then
			tongue={x0=head.x+8,y0=head.y+4,x1=head.x+10,y1=head.y+3}
		else
			tongue={x0=head.x+8,y0=head.y+3,x1=head.x+10,y1=head.y+4}
		end
	end
		
end
function draw_snek()
	
	for i=1,#snek-1 do
		local wire=snek[i].wire
		line(wire.x0,wire.y0,wire.x1,wire.y1)
	end
	for i=1,#snek do
		spr(snek[i].s,snek[i].x,snek[i].y)	
	end
	if (#snek>0) then
		line(tongue.x0,tongue.y0,tongue.x1,tongue.y1,dark_purple)
	end	
	for burnout in all(burnouts) do
		spr(burnout.s,burnout.x,burnout.y)
	end
end	
-->8
--Planting

function update_planting()
	update_stars()
	update_quasar()
end
function draw_planting()
	draw_snowscape()
	draw_stars()
	draw_forest()
	if (gameover) then
		print("           game over", 0,120, dark_blue)
	else	
		draw_quasar()
		if (not planted) then
			print("     move quasar, X to plant", 0,120, dark_blue)
		else	
			print("        X to build snek", 0,120, dark_blue)
		end
	end	
end

-->8
--Forestry
function plant_tree(x,y,w,h)
	local tree ={twigs={},lights={}}
	local dw, branch1, branch2, step
	step=rnd(1)+2
	for dh=0,h,step do
		dw = flr((w/h)*dh)
		twig1=rnd(3)+1 
		twig2=rnd(3)+1
		add(tree.twigs,{x0=x-flr(dw/2),y0=y+dh-twig1,x1=x+ceil(dw/2),y1=y+dh+twig2})
	end
	for bulb in all(snek) do
		add(tree.lights,{x=bulb.x/128*w+(x-w/2) ,y=bulb.y/128*h+y, c=bulb_colors[flr(bulb.s/5)+1]})
	end
	planted=true
	add(forest,tree)
	sfx(52)
	
end
function draw_forest()
	
	for tree in all(forest) do
		color(dark_green)
		for twig in all(tree.twigs) do
			line(twig.x0,twig.y0,twig.x1,twig.y1)
			line(twig.x0,twig.y1,twig.x1,twig.y0)
		end	
		for bulb in all(tree.lights)do
			pset(bulb.x,bulb.y,bulb.c)
		end
	end
end
function update_quasar()
	local step =2 +flr(rnd(3))
	if (gameover==nil) then
		if (not planted) then
			if (frame%step==0) then
				pulse = frame%2
			end	
			if (btn(left)) then
				quasar.aim=left
				quasar.x-=1
				if (quasar.x<-4) then
					quasar.x=-4
				end	
			elseif (btn(right)) then
				quasar.aim=right
				quasar.x+=1
				if (quasar.x>124) then
					quasar.x=124
				end
			elseif (btn(up)) then
				quasar.aim=up
				quasar.y-=1
				if (quasar.y<20) then
					quasar.y=20
				end
			elseif (btn(down)) then
				quasar.aim=down
				quasar.y+=1
				if (quasar.y>120) then
					quasar.y=120
				end
			elseif (btnp(fire2)) then
				plant_tree(quasar.x+3,quasar.y+8,25,30)
			end	
			frame+=1	
		else 
			if (btnp(fire2)) then
				for bulb in all(bulbs) do
					mset(bulb.x,bulb.y,26)
				end
				init_snek_yard()
				planted=false
				_update=update_snek_yard
				_draw=draw_snek_yard	
			end		
		end
	end	
end
function draw_quasar()
	spr(quasar.s[pulse+1],quasar.x,quasar.y)
end
-->8
--sneks
function init_snek_yard()
	frame=0
	short=0
	speed=1.5
	burnouts={}
	boarding=false
	init_snek()
	init_bulbs()
end	
function update_snek_yard()
	frame+=1
	if (btnp(fire2)) then
		_update=update_planting
	 	_draw=draw_planting	
	end	
	update_snek()
	if (#bulbs <4) then
		local bulb=get_empty_cell()
		if (bulb) then
			bulb.s=flr(rnd(4))*5 +4
			mset(bulb.x,bulb.y,bulb.s)
			add(bulbs,bulb)
		end
	end		
end
function draw_snek_yard()
	cls()
	map(0,0)
	print("arrows move", 0, 120)
	print("X forest",90,120)
	draw_snek()
end
function get_empty_cell()
	local gridx=flr(rnd(14)+1)
	local gridy=flr(rnd(14)+1)
	local counter =0
	local flag=fget(mget(gridx,gridy))
	local snekx=flr(snek[1].x/8)
	local sneky=flr(snek[1].y/8)
	while (((fget(mget(gridx,gridy))~=2) or
		(fget(mget(gridx-1,gridy))==1) or
		(fget(mget(gridx+1,gridy))==1) or
		(fget(mget(gridx,gridy-1))==1) or
		(fget(mget(gridx,gridy+1))==1)) or
		(snek_zone(gridx,gridy)) and counter < 1000
	) do
		gridx=flr(rnd(14)+1); gridy=flr(rnd(14)+1)
		counter+=1
	end
	return {x=gridx,y=gridy}
end
function snek_zone(x,y)
	local gridx0, gridy0, gridx1, gridy1
	for bulb in all(snek) do
		gridx0=flr((bulb.x)/8)
		gridy0=flr((bulb.y)/8)
		gridx1=flr((bulb.x+8)/8)
		gridy1=flr((bulb.y+8)/8)
		if (gridx0==x and gridy0==y) then
		 return true
		end
		if (gridx1==x and gridy0==y) then
			return true
		end
		if (gridx0==x and gridy1==y) then
			return true
		end
		if (gridx1==x and gridy1==y) then
			return true
		end
	end
	--space to move forward 
	gridx0=flr((snek[1].x-4)/8)
	gridy0=flr((snek[1].y-4)/8)
	gridx1=flr((snek[1].x+12)/8)
	gridy1=flr((snek[1].y+12)/8)
	if (gridx0==x and gridy0==y) then
		return true
	end
	if (gridx1==x and gridy0==y) then
		return true
	end
	if (gridx0==x and gridy1==y) then
		return true
	end
	if (gridx1==x and gridy1==y) then
		return true
	end
	return false
end

__gfx__
000bb00000033000000330000300003000033000000ee00000088000000880000800008000088000000cc0000001100000011000010000100001100000099000
03b77b30033bb33003377330000000000333333008e77e80088ee88008877880000000000888888001c77c10011cc110011771100000000001111110049aa940
3b7bb7b333b77b333377773300330300333bb3338e7ee7e888e77e888877778800880800888ee8881c7cc7c111c77c111177771100110100111cc11149a99a94
b7b77b7b3b7777b3377777733003b30333bbbb33e7e77e7e8e7777e8877777788008e80888eeee88c7c77c7c1c7777c1177777711001c10111cccc119a9aa9a9
b7b77b7b3b7777b337777773003bb30033bbbb33e7e77e7e8e7777e887777778008ee80088eeee88c7c77c7c1c7777c117777771001cc10011cccc119a9aa9a9
3b7bb7b333b77b333377773300033300333bb3338e7ee7e888e77e888877778800088800888ee8881c7cc7c111c77c111177771100011100111cc11149a99a94
03b77b30033bb33003377330000000300333333008e77e80088ee88008877880000000800888888001c77c10011cc110011771100000001001111110049aa940
003bb30000033000000330000300300000033000008ee80000088000000880000800800000088000001cc1000001100000011000010010000001100000499400
0004400000044000040000400004400094000049940000499400004999999999000099999999000000000030000900000000000076670600d777777dd777777d
0449944004499440000000000444444094000544445000499454444944444444000944444444900003000000009a900000090000641605005bbbbbb558888885
449aa9444497794400440400444aa4449440540000450449945555490550055000944000000449000000030009a7a900009a9000666666605bbbbbb558888885
49aaaa94497777944004940444aaaa44994540000004549994000049045004500944000000004490000300009a777a9009a7a900111111561111115511111155
49aaaa94497777940049940044aaaa440944000000004490940000490450045099454000000454993000000009a7a900009a900076d176d57bd17bd578d178d5
449aa9444497794400044400444aa44400944000000449009454444904500450944054000045044900000003009a90000009000065616560b5b1b5b085818580
04499440044994400000004004444440000944444444900094555549444444449400054444500049030000000009000000000000d650d650db50db50d850d850
00044000000440000400400000044000000099999999000094000049999999999400004994000049000030000000000000000000000000000000000000000000
d777777dd777777d0004400001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
5aaaaaa55cccccc5044444401575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
5aaaaaa55cccccc5444aa44457576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
111111551111115544aaaa44057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
7ad17ad57cd17cd544aaaa44056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
a5a1a5a0c5c1c5c0444aa4445516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
da50da50dc50dc50044444401155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
000000000000000000044000015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000030000000300000077000007dd5000076650005544550000070000676665000070000d5555000750705607776777677777776777777767777777677777776
0300000003000000007667000007500007666650554444550000770000565100007a90007665d650565656507665766576666665766666657766665576666665
000000030000000300077000077665507666666545444454000076700067650007aaa90076616560057775007665766576555565766776657676656576666665
3000000030000000076666707766665576565565455a9554000077770067650007aaa900766176d0767766606555655576566765767665657667566576666665
0003000000030000765555677666666576666665411a911407007000006765000a99990076611100057665007677767776566765767665657667566576666665
0000030000000300650000567666666576556565444554447666666700676500755655907661d650565656506576657676577765766556657676656576666665
03000000030000005650056577666655766666654444444407666670006765000aaaa90076616560750605606576657676666665766666657766665576666665
000000300000003005677650077665506555555554444445007777000676665000000000d55176d0000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
b3b00b3b0bbbbbb00000000000000900aaaaaaaaaaaaaaaa994499444444444499999999555555555555555566666666666d6666dd5555ddcccccccc00088000
b039930bbbb33bbb0000000000009a90aaa999aaaaaa99aa944494444444444499444499555d55ddd55dd55d6d6666d66dd666d6d566665dcccccccc00800800
00999200b33bb33b0000000000000900aaaaaa9aaaaaaa9a444444444444444444444444dddddddddddddddd6666666666dd6d6656666665cccccccc08099080
00944200b393323b0000090000e00b00aa9aaa9a99aaaaaa1414141499449944991111995d55d555dd555d55666666666d66666656666665cccccccc80900908
009992000099920000909a900eae0300a9aaa9aaaa9aaaaa414141419444944494111149dddddddddddddddd6666666666666dd656666665cccccccc80900908
099999200444992009a9090000e00300a9aaaaaaaaaaa9aa11111111444444449911119955dd5d55d555d55d666666666666d6665d6666d5cccccccc08099080
044499200999992000900b0000b00300aa99aaaaaa999aaa000000004444444444111144dddddddddddddddd6d6666d66dd666ddd5dddd5d1cc11cc100800800
029992200299922000b0030000300300aaaaaaaaaaaaaaaa000000004444444499111199555555555555555566666666d666666ddd5555dd1111111100088000
00000000002222200777000000044000000aa000007000000777700000bbbbbbbbbbbbbbbbbbbb002222222222222222000000000000000000000bbb00990000
2222222202944442067770000049940000a7aa0000700000070070000b333b333b333b3333b333b042244224422442240000000000000000000b3b3b00049000
44444444029999420677770000444200007aa90000700000070070000b34333433343334433343b04444444444444444000000000000000000bbb3bb09094090
44444444022222220677777000494200007aa9007770000077077000b3444444444444444444443b44444444444444220b00000000000000003b3b3094994949
222222220294949206777700004992000a7aaa907770000077077000b3344444444444444444433b4444444444444422b0b0bb00000000000bb3bbb099494490
222222220294949206777000004942000aaa99900000000000000000bb34444444444444444443bb444444444222444400b0b0b0000000000b3b3b0009949900
2442442402949492066600000049920000666d000000000000000000b3344224422442244224433b4224422442224224000b0000077707703bbb000000949000
22422424002222200000000000042200000000000000000000000000b3222222222222222222223b2222222222222222000b0000777777773300000000040000
00aaa900000ee0000000000000800000008000000000000000000000008008000000000000808000000000000fffff000fffff000fffff00002ee20000000000
00666d000eeaaee0000ee0000877000008770000008000000007000000088000000000000008800000000800f44444f0f44444f0f44444f002222220002ee200
067176d00eeaaee00eeaaee0a7170007a7170f0708770007000770700088e800080880800088e80008088000f4fff4f0f4fff4f0f4fff4f0047ff74002222220
6771766db0beeb0b0eeaaee0087777770877ff77a71777770004007708888e800088e80008888e800088e800f4f4f4f0f4f4f4f0f4f4f4f0471ff17404ffff40
6771116db3bbbb3b0bbeebb0077fff77077fff77087fff77009994400818818008888e800818888008888e80f4f444f0f4f444f0f4f444f00ffffff0471ff174
6777766d3bb1b1bb33bb1b1b077ff7700777f770077ff7700949994002888e8001888e100288888001888e80f4ff22f0f4ff1e10f4fff1e1002222000ffffff0
067766d03bbbbbbb33bbbbbb0077770000a7770000777a00099494400288888002888880022288800222888044422220444feee0444feeee00eeee0000eeee00
00666d000333333003333330000a0a0000000a00000a000009944400002228000022280000222200002222000422220004eeeee004eeeeee0040040000400400
0002ee20002ee200002ee2000000000000000000002ee2000022ee00000000000022ee000022ee000022ee00022ee00000000000002222000000000002222000
002222220222222002222220002ee2000000000002222220022222200022ee00022222200222222002222220222222000022ee00022222200022220022222200
0447ff74047ff760014ff4100222222000000000071ff170044447f002222220044447f0044447f0044447604441ff0002222220044444400222222044444440
0471ff17471ff1644f1ff1f401ffff1000000000477ff774044f71f004444ff0044f71f0044f71f0044f716044ff1d0004441ff04f4444f404444440f4444f40
00ffffff0ffffd6d0fffffd04f1ff1f4002ee2000ffffff000fffff0044f71f000fffff000fffff000fffd6d0ff4d666044ff1f00ffffff04f4444f4ffffff00
00222200002222d000222d6d0ffffff002222220002222000022220000fffff00022220000222200002222d002222d0000fffff0002222000ffffff000222200
00eee40000eeee4000eeee6000eeee00011ff11000eeee0000eeee0000eeee0000eee400004eee0000eeee400eeee00000eeee0000eeee0000eeee0004eeee00
004000000040040000400460004004004ffffff40040040000400400004004000040000000000400004004000400400000400400004004000040040000000400
__label__
dddddddddddddddddmddddddddddddddddddddddddddddddddddddddmdddddddddddmddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmdddmdddddddmddmdddddddddddddddddddddddddd
ddmmddddddddddddddddddddddddmdddmdddddddddddddddddddddmmddmmdddddddddmmdddddddddddddddddddddddddddddddddddddddddddddddddddddddmm
ddddddddddddddddddddddddddddddddddddddddddddddddddmdddmdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddmdddddddmdddddddddddddddddddmddmddddddmmddddddddddddddmdddddmmmddddddddd
ddmddddmdddmdddddddddddddddddddddddddddddddddddddddddmddddddddddddddddddddmdddmmdddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddmddddddddddddddddddddddmdddddddddddddddddddddddddddddddddddddddddmddddddddddddddddddddd
dddddddddddddddddmdddmddddddddddddddddddddddddddddddddddddddddddddddmddddddddddddmmddmmddddddmmdmddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddmddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmdddddddddddddddmmd
mdddmdddddddddddddddddddddddddddmddddddddddddddddddddddddddddddddddddmdddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmdddddddddddddddddddddmddddddddddddddddddd
dmmddmmddmmdmddddddddddddmdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddmddddddddddddmddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddmdmdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmmdddddddd
dddmdmdmddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmddmddddddddmddddddddddddddddddddddddddddd
ddmddddddddddddddddddddddddddddddddddddmddddddddddddddddddddddddddmdddddddddddddddddddddddddddddddddddmdddddddddddddddddddddddmd
dddmdmdddddddmdmddddddddddddddmdddmdddddddddddddddddddddddddddddddddmdddddddddddddddddddddddmdddddddddddddddmddddddddddddddddddd
ddddddddddddmdddmdddddddddddmdmdmdmddddddddddmdddddddddddddmddddddmdddddddddmdddmdddddddmdmddddddddddddddddddddddddddddddddddddd
ddddmddddddddddddddddddddddddddddddddddddddddmddddddddddddmdddddddddddddddddmdddddddddddddddddddddmdddddddddddddddddddddddmddddd
ddddddddddddddddddmdmdmdmdmdmdmdmdmddmddmdmddddddddddmdddddddddddddddddddddddddddddddddddddddddddddddmdddddddddddddddddddddddddd
mdddmdddmddddddddddddddddddddddddddddddddddddmdddddddddddddddddddddddddddddddddddddddddddddddddddddmddmmdddmdmdddddddddddddddddd
ddddddddddddddddddmdddddddmdddddddddddddddddmdddddddddddddddmdmdmdddmdddddddddddddddddmdddddddmdddddddddddddmddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmdddmdddmddddddddddddddmdddmddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddmdddddddmdd
ddddddddddddddddddddddddmdddmdddddddddddmddddmddddmddmdddmdddmddddddddddmdddddddddddddddmdddmdddmdddddddmddddddddmdddddddddddddd
mdddddddddddddddddddddddddddddddddddddddddddmddddddddddddddddddddddddddddddddddddddddddddmdddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddmmdmdmdddmdddmddddmddmddddmdmmddmdmmdmdmdmdmdmmdddmddddddmdddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

__gff__
0000000001000000000100000000010000000001040810204080020000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000001817171900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000161a1a1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000161a1a1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001817151a1a1417190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000161a1a1a1a1a1a160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000161a1a1a1a1a1a160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001817151a1a1a1a1a1a141719000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000161a1a1a1a1a1a1a1a1a1a16000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000161a1a1a1a1a1a1a1a1a1a16000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1817151a1a1a1a1a1a1a1a1a1a14171900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
161a1a1a1a1a1a1a1a1a1a1a1a1a1a1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
161a1a1a1a1a1a1a1a1a1a1a1a1a1a1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
161a1a1a1a1a1a1a1a1a1a1a1a1a1a1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
141717171717191a1a1817171717171500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000161a1a1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001417171500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010300003c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a1f200c4520c4510c4410c4310c4210c4110c4110c4100c4100c4100c4100c4100c4120c4120c4120c4120c4120c4210c4310c4410c4510c4610c4710c4020c4020c4020c4020c4020c4020c4020c4020c402
010f00000004400011000001c7141c7151c51510001237040704007011000001c7141c715000001c515237040504405011000001c7141c7152351510001240150204002011000001c7141c715000001c51523714
010f00000c04300000000001871418715185151c0001c700246150000000000187141871500000185151f7040c04300000000001f7141f7151f715100001f015246150000000000187141871500000245151f714
010f00000304403011000001b7141b7151b51510001237040704007011000001b7141b715000001b5152370405044050110000020714207152451510001240150a0400a011000001a51526515225151d51522714
010f00000c043287102b7101871418715185152471024702246152f7102b71018714187152b710185152b7100c0432d710307101f7141f7151f715247101f01524615347102b715187141871500000245151f714
010f00000c04324510275101871418715185151b51033700246152c5102b510187141871527510185151f7040c04327510245101f7141f7151f715245101f015246152451022510187141871522510245151f714
010f00000804408011000001b7141b7151b51510001237040804008011000001b7141b715000001b5152370407044070110000022714227152751513001270150704007011000001a51526515225151d51522714
010f00000c04330700337001871430710307152e7102e715246152e7102e71518714187152e700185151f7040c04333700307001b5142c5102c5152b5102b515246152751027515337051a71526715227151d715
010e0000184251d3252032524425356152c325184251d32520325184251d3252c325356151d32520325184251d32520325184251d32535615244251d32520325184251d3252c3252442535615203251842529325
010e00000c0430544505435054450543505445054350544501435014450143501445014350144501435014450c0430344503435034450343503445034350344500435004450043500445004350c0430043500445
010e00002042524325293252c4251d3252032524425293252c3251d4252032524325294252c3251d3252042524325293252c4251d3252032524412293252c3251d4252032524325294252c3251d3252042524325
010e00000c043014350144501435014450143520415014350c04320415014350143501435014451d415204150c043014350144501435014450143501445014350c04300445004350044500435004350043500445
010e0000182151d3251d3251d325356151d325304201d3252e4202e4201d3251d325356151d325292202c2202c2201d3251d3251d325356151d3252e4201d325294201b3251b32527420356151b3251b3251b325
010e00000c043014450143501425034450343503425034150c04305445054350542508445084350842508415356150a4450a4350a425356150c4350c4250c4150c04300445004450044500445004450043500435
010e000029420294112941229415356152b4202b4112b4122d4202d4112d4122d4123561530420304123041232411324103241032412354113541235412294163541635416294162941635416354162941629416
01100000070402671524815247150b0402671524815075010c04024715248150d040237250e0402481500000070402571524815267150b04023715248151d7150c04023715248150d0401d7150e0402481507501
011000000c50022735230252873522025237352672522035237252803523725280352672528005260050c5000c5002e7352f0252e7352f0252b7352802526735220251f735210251c7351f0250c5000c5000c500
01100000070402b715248151f7150b04030715248152d7150c04023715248150d040237150e0402481523715130400000030715000002f71500000070430000029715280152971528015297151c0052e7110a700
0110000035725340253571534025357153402532715300252e7252b0352d725280352b7252d0352f7253203537725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a700
0110000009040020003271502000317150200009043020002b7152a0152b7152a0152b7151e005307110c700000401c015297152d7002871500000040401f01529715257002871500700050401f715070400c501
0110000037725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a70024815180152b7252d7002b7253600524815220153072524815307252a0052481528715248153c715
0110000037725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a700248152d7352e0252d7352e0252d735248153402532725248152e7252f025248152b0352481528735
010e00000c0433f2153f215243032461018615243033f2150c043243033f2153f215246101203403041000410c043001053f2153f21524610186153f215003040c0433f215000053f21524610000140c02118031
010e00000c0450015500140000350c043001400003500324001550014000035001400c043186153f215003240c0450015500140000350c043001400003500324001550014000035001400c043186153f21500324
010e00000c0430010500100000050c0430010000005003040c0430010000005001000c0431202403031000310c0430010500100000050c0430010000005003040c0430010000005001000c043000140c01118021
010e00000c0450015500140000350015500140000350032400155001400003500140000351861430600003240c045001550014000035001550014000035003240015500140000350014000035186143060000324
010e00000c0433f2153f215000052461018615000053f2150c043001003f2153f215246101200403000000000c043001053f2153f21524610186153f215003040c0433f215000053f21524610000040c00018000
010e00000c0450015500150000050c043001500000500304001550015000005001500c043186153f215003040c0450015500150000050c043001500000500304001550015000005001500c043186153f21500304
011400002743018726217161871627430187162171627430295150040026435264352443526435247162043000400000001d430004002772618716217161871627700187162d5151870024615187162d51518700
011400000c04305320295150c320306150332005320295050c043053201d22505320306151d225000000c04305330000001b42005320306150000003320053300c04300320335150c043033200f3300432010330
011400002e4302a72627716247162051524716304302c430000000b2100c2100d2200f2101e420204101e420314302d7262a716277162351527716334302f4302f7262b51528716257162b5152b5152b5152b515
011400000c043083202051506330306150c04306320083300c0430b32000310013200331006320083100b9500c043099400b9400c043306150b330235150c0430994019515079400c04330615129400794013940
0114000027400187002171618716270001800021716187162740018700217161801627000184152171618716274001870021016187161831518415217161801627400187002151624506275162d3152171118016
010c00001075513755187451c7451f735247252b71512755157551a7451e74521735267252d71514755177551c7452074523735287252f7153472500000000000000000000000000000000000000000000000000
010c0000000001072513725187251c7251f725247252b70512725157251a7251e72521725267252d70514725177251c7252072523725287252f72534705000001ca051ca051ca051ca051ca051ca051ca051ca05
012000001474014731147211471516740167311672116715197401973119721197151b7401b7311b7211b7111b7101b7121b7121b7121b7151970019700197001970019700197001b7001b7001b7001b7001b700
012000001272012720127251270510720107201072510705117201172011725117051572015720157201572015722157221572215725057000570005700007000070006705087050970009700097000970009700
012000000102001020010200102506020060200602006025080200802008020080250402004020040200402004020040200402204022040250400500000000000000000000000000000000000000000000000000
000700000c6241c6252b6002f60024600286002b6002f6003060034600376001360415604176040c6040e60410604116041360400000000000000000000000000000000000000000000000000000000000000000
000100002c2502b6202a2502962028250276202625025620242502362022250216202025000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a3502a5102a515245653005030510305152a565361503651036515365053450029500295002f5003f500335003450029500295002f5003f500335003450029500295002f5003f500005000050000500
000200001021304611102230462110223046311023304631102430464110253046511026304661102630465110253046511024304641102430463110233046211022304621102130461110213046111021304611
000100000c1500e0511105114051170511705014051120510f0510c15100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200003f6142646525361242512345122341212413f6041f3050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b3501b2501c1511d1411f141211312313127121371213b1101b3301b2301c1311d1311f131211312312127121371113b1101b3101b2101c1111d1111f111211112311127111371113b1100000000000
000100000905009040090400903009031090310902109021090210a0210b0210b0210c0210d0200e0210f02111011120111c0011a0011700116001140011200111001100010d0010d00100001000010000100001
000300000c7500f041130311312500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000296632866528604276532765426605256432564524604236432264421603206351e6351c6031b6341762314604106230c625086030661503613026040c0040740400604083040c004172041160400404
0002000000373016732b3730167300473233731c26301663053631a26301663016530d253024531e3530164300343054431c2430163325333016330033325423016230162309323016231d313016131021300413
000100000f12500000000000710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000c34300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0005000011574160741357418074155641a064165641b054185541d0541a7541f5441b044217441d544220441f744245342103426734220242772424014297140070400704007040070400704007040070400704
000600000b07012741127350c07013741137350d07014741147350f0701674116735182001840018300185021800512200122050a2000a4000a3000a0050a70500000000000d0001400014005000000000000000
000300000c343236450933520621063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000600001c36311000103331031310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002d27321363164530c3430733303323013130d50309503075031550300003000030000300003000031d303123031b0030000300003000030000300003153030b3031a7031f5031b003217031d50322003
00010000352103751534100371003f10039100331001f1001f1001f1001f100231002a10034100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0150c0050c005110350c0050c0050c00516055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00020000071540f163163730b22332643216331c6231861315613136130e6130a61304600000000000000000000000b1010710105101031010110100000000000000000000000000000000000000000000000000
000100001b5611e06125061010001a0511d0512405100000197411c7412374100700187301b731227310050000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002336311000103330400010705107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 02034344
00 02034344
00 04034344
00 04034344
00 02054344
00 02054344
00 04064344
00 04064344
00 07084344
02 04084344
01 0b0a4344
00 0b0a4344
00 090a4344
00 090a4344
00 0c0d4344
00 0c0d4344
00 0c0d4344
00 0a0d4344
02 0e0f4344
01 10114344
00 12134344
00 10114344
00 12134344
00 14164344
00 14154344
00 14164344
02 14154344
01 191a4344
00 191a4344
00 17184344
00 17184344
00 1b1c4344
02 1b1c4344
01 211e7a44
00 211e7a44
00 1d1e7a44
00 1d1e7a44
00 1f207a44
02 1f207a44
04 22234344
04 24252644
