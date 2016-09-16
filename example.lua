mobs.override(
	"dmobs:panda",
	{
		hp_max = 120,
		--[[
		on_rightclick = {
			fchain_type = "before",
			fchain_func = function(self,clicker)
				minetest.chat_send_player(clicker:get_player_name(),"Right clicked a panda!")
				return false
			end
		}
		--]]
	}
)

-- get necessary elements
local themob = minetest.registered_entities["dmobs:panda"]

local thefunc = function(self,clicker)
	minetest.chat_send_player(clicker:get_player_name(),"Right clicked a panda!")
	return true
end

-- assign arbitrary function

local orig = themob.on_rightclick

themob.on_rightclick = function(...)
	if thefunc(unpack(...)) then orig(unpack(...)) end
end
