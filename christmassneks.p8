pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
left,right,up,down,fire1,fire2=0,1,2,3,4,5
point=pset

-->8
--initialize
function _init()
	_init_stars()
	_init_snek()
	_draw = _draw_intro
	_update = _update_intro
end	
function _init_stars()
	stars={}
	for i=0,3 do
		for j=0,1 do
			local star={x=flr(rnd(30))+(30*i)+4,y=flr(rnd(14))+(14*j)+4,c=blue}
			add(stars,star)		
		end
	end
end
function _init_snek()
	snek={{x=60,y=60}}
end	
-->8
--intro
function _update_intro()
	if btnp(fire2) then
		_draw=_draw_planting
		_update=_update_planting
	end
end
function _draw_intro()
	_draw_snowscape()
	print(" tis the season to sing carols,",0,4,white)
	print("     drink nog, and decorate ",0,12)
	print(" the night with christmas sneks",0,20)
	print("        press X to play",4,119,dark_blue)
end
-->8
--snowscape
function _update_stars()
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
function _draw_snowscape()
	rectfill(0,0,127,47,dark_blue)
	rectfill(0,48,127,48,black)
	rectfill(0,49,127,127,white)
end	
function _draw_stars()
	for star in all(stars) do
		point(star.x,star.y,star.c)
	end
end	
-->8
-->snek
function _update_snek()

end	
function _draw_snek()

end	
-->8
--Planting

function _update_planting()
	_update_stars()
end
function _draw_planting()
	_draw_snowscape()
	_draw_stars()
	_draw_tree2(60,60,20,30)
	_draw_tree2(80,90,20,30)
	_draw_tree2(5,40,20,30)
	_draw_tree2(20,90,20,30)
	
end

-->8
--trees

function _draw_tree1(x,y,w,h)
	color(dark_green)
	for i=x-flr(w/2),x+ceil(w/2),3 do
		line(x,y,i,y+h)
	end
end	

function _draw_tree2(x,y,w,h)
	color(dark_green)
	local step=rnd(3)+1
	for dh=0,h,step do
		local dw = flr((w/h)*dh)
		line(x-flr(dw/2),y+dh-rnd(3)-1,x+ceil(dw/2),y+dh+rnd(3)+1)
		line(x-flr(dw/2),y+dh-rnd(3)-1,x+ceil(dw/2),y+dh+rnd(3)+1)

	end
end	