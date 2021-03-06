
local demofunction = function(self,clicker)
	minetest.chat_send_player(clicker:get_player_name(),"You right-clicked a "..self.name)
	return true
end

local genrewrite = {
	hp_max = 120,
	type="npc",
	on_rightclick = {
		fchain_type = "before",
		fchain_func = demofunction
	}
}

override:rewrite("dmobs:panda",genrewrite)
override:rewrite("dmobs:fox",genrewrite)
