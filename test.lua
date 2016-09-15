mobs.override(
	"dmobs:panda",
	{
		hp_max = 120,
		on_rightclick = {
		fchain_type = "before",
		fchain_func = function(self,clicker)
			minetest.chat_send_player(clicker.get_player_name(),"Right clicked a panda!")
			return true
		end
		}
	}
)
