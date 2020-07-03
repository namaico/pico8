pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- not snake? V1
-- by Kafka Shirogane
function _init()
	-- 14x14 grid
	grid_amount=14
	grid_distance=8
	--colors 5 dark_gray; 3 dark_green; 8  red; 11  green
	grid_color=5
	snake_color=3
	item_color=8

	game_state="title"

	grid_game_state={}
	snake_dir_random=false

	directions={"up","down","left","right"}
	difficulty_levels={"normal","hard","hell"}
	selector=1
	current_difficulty=difficulty_levels[selector]

	default_delay=10
	delay=10
	player_score=0
	music(0)
	init_game()
end

function debug()
	--print("t".. #table_snake_dir,0,0,1)
	print("score: "..player_score,2,122,1)
	--if snake_dir_random==true then
		--print("⬅️"..table_snake_dir[1][1].."|➡️"..table_snake_dir[2][1].."|⬆️"..table_snake_dir[3][1].."|⬇️"..table_snake_dir[4][1],10,1,1)
	--end
end

function get_rnd_num(low,max)
	return flr(rnd(max-low))+low
end

function check_gameover()
	if snake_state_head_x < 1 or snake_state_head_x > 14 or snake_state_head_y < 1 or snake_state_head_y > 14 then
		game_state="gameover"
	end
end



function init_game()
	clear_game_state()
	snake_state_dir=directions[get_rnd_num(1,4)]
	snake_state_head_x=get_rnd_num(5,9)
	snake_state_head_y=get_rnd_num(5,9)
	snake_body={{snake_state_head_x,snake_state_head_y}}
	if snake_state_dir=="up" then
		for i=2,4 do
			snake_body[i]={snake_state_head_x,snake_state_head_y+i-1}
		end
	elseif snake_state_dir=="down" then
		for i=2,4 do
			snake_body[i]={snake_state_head_x,snake_state_head_y-i+1}
		end
	elseif snake_state_dir=="right" then
		for i=2,4 do
			snake_body[i]={snake_state_head_x-i+1,snake_state_head_y}
		end
	else
		for i=2,4 do -- is fine
			snake_body[i]={snake_state_head_x+i-1,snake_state_head_y}
		end
	end
	init_item=false
	update_grid_state()
	repeat
		item_x=get_rnd_num(1,14)
		item_y=get_rnd_num(1,14)
	until(grid_game_state[item_x][item_y]==0)
	init_item=true
	table_dir={{"left","right"},{"right","left"},{"up","down"},{"down","up"}}
	table_snake_dir={}
end

function clear_game_state()
	for i=0,grid_amount+1 do
		grid_game_state[i]={}
		for j=1,grid_amount do
			grid_game_state[i][j]=0 -- 0:empty;1:snake;2:item
		end
	end
end

function draw_grid()
	for i=1,grid_amount do
		for j=1,grid_amount do
			rect(i*grid_distance,j*grid_distance,i*grid_distance+grid_distance,j*grid_distance+grid_distance,grid_color)
		end
	end
end

function draw_grid_state()
	local current_color=0
	for i=1,grid_amount do
		for j=1,grid_amount do
			if grid_game_state[i][j]==1 then current_color=3
			elseif grid_game_state[i][j]==2 then current_color=8
			elseif grid_game_state[i][j]==3 then current_color=11 end
			if grid_game_state[i][j]~=0 then rectfill(i*grid_distance,j*grid_distance,i*grid_distance+grid_distance,j*grid_distance+grid_distance,current_color) end
		end
	end
end
--{snake direction, can't move}


function update_snake_dir()

	--if (btn(0) and snake_state_dir~="right") then snake_state_dir="left" end -- left
	--if (btn(1) and snake_state_dir~="left") then snake_state_dir="right" end -- right
	--if (btn(2) and snake_state_dir~="down") then snake_state_dir="up" end -- up
	--if (btn(3) and snake_state_dir~="up") then snake_state_dir="down" end -- down

	if snake_dir_random==false then
		local table_pnt={table_dir[1],table_dir[2],table_dir[3],table_dir[4]}
		repeat
			local c=flr(rnd(#table_pnt))+1
			add(table_snake_dir,table_pnt[c])
			del(table_pnt,table_pnt[c])
		until #table_pnt==0
		snake_dir_random=true
		sfx(4)
	end
	--table_dir={{"left","right"},{"right","left"},{"up","down"},{"down","up"}}
	if (btn(0) and snake_state_dir~=table_snake_dir[1][2]) then snake_state_dir=table_snake_dir[1][1] sfx(2) end -- left
	if (btn(1) and snake_state_dir~=table_snake_dir[2][2]) then snake_state_dir=table_snake_dir[2][1] sfx(2) end -- right
	if (btn(2) and snake_state_dir~=table_snake_dir[3][2]) then snake_state_dir=table_snake_dir[3][1] sfx(2) end -- up
	if (btn(3) and snake_state_dir~=table_snake_dir[4][2]) then snake_state_dir=table_snake_dir[4][1] sfx(2) end -- down
end

function update_item_pos()
	local x
	local y
	repeat
		x=get_rnd_num(1,14)
		y=get_rnd_num(1,14)
	until((not (x==item_x and y==item_y)) and (grid_game_state[x][y]==0))
	item_x=x
	item_y=y
	sfx(3)
end

function update_snake_head_pos()
	if snake_state_dir=="left" then snake_state_head_x=snake_state_head_x-1
	elseif snake_state_dir=="right" then snake_state_head_x=snake_state_head_x+1
	elseif snake_state_dir=="up" then snake_state_head_y=snake_state_head_y-1
	elseif snake_state_dir=="down" then snake_state_head_y=snake_state_head_y+1
	end
	--check if it collides with item
	if item_x==snake_state_head_x and item_y==snake_state_head_y then
		snake_body[#snake_body+1]={}
		snake_body[#snake_body][1]=snake_body[#snake_body-1][1]
		snake_body[#snake_body][2]=snake_body[#snake_body-1][2]
		update_item_pos()
		player_score+=1
		if player_score%4==0 then
			snake_dir_random=false
		end
	end

	for i=#snake_body,2,-1 do
		snake_body[i][1]=snake_body[i-1][1]
		snake_body[i][2]=snake_body[i-1][2]
	end
	snake_body[1][1]=snake_state_head_x
	snake_body[1][2]=snake_state_head_y
end

function update_grid_state() -- 0:empty;1:snake;2:item;3:snake head
	for i=2,#snake_body do
		grid_game_state[snake_body[i][1]][snake_body[i][2]]=1
	end
	if grid_game_state[snake_body[1][1]][snake_body[1][2]]==1 then
		--really spaghetti code damn organizing logic is hard
		game_state="gameover"
	end
	grid_game_state[snake_body[1][1]][snake_body[1][2]]=3
	if init_item then grid_game_state[item_x][item_y]=2 end

end

function _update()
	if game_state=="title" or game_state=="gameover" then
		update_difficulty()
		player_score=0
		if btn(4) or btn(5) then
			snake_dir_random=false
			game_state="game"
			init_game()
		end
	elseif game_state=="game" then
		delay=delay-1
		if delay<0 then
			update_snake_dir()
			update_snake_head_pos()
			clear_game_state()
			update_grid_state()
			check_gameover()
			delay=default_delay
		end
	end
end

function draw_title(_txt)
	print(_txt,50,40, 8)
	print("⬅️ "..current_difficulty.." ➡️",40,60, 8)
	print("press ❎ or 🅾️ to start",18,80, 8)
end
function update_difficulty()
	if btnp(⬅️) then
		if selector==1 then
			selector=3
		else
			selector-=1
		end
	elseif btnp(➡️) then
		if selector==3 then
			selector=1
		else
			selector+=1
		end
	end

	current_difficulty=difficulty_levels[selector]
	if current_difficulty=="normal" then
		default_delay=20
		delay=20
	elseif current_difficulty=="hard" then
		default_delay=10
		delay=10
	else
		default_delay=5
		delay=5
	end
end

function _draw()
	cls(15)
	debug()
	if game_state=="gameover" then
		draw_title("gameover")
	elseif game_state=="title" then
		draw_title("snake? 2")
	else
		draw_grid()
		draw_grid_state()
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011100200c0431800418000000000c0431300013000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c043000000000000000
011100000210002100025450212202510021400212502112020400212002015021420202002110021450211202145021220211002140021250211202140021200211502142021400211002145021120214002110
000100000a5500d5501155016550195501b5501d5501f550225502355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000105500f5500d5500b55008550055500255002550327500040000400004000040000400004000040000400004000040000400004000040000400004000000000000000000000000000000000000000000
00010000217501a75015750117500f7500e7500b7500a75009750087500775008750097500c7501075013750177501f75024750217501d75018750127500c7500675005750047500575006750077500975009750
__music__
03 00014244

