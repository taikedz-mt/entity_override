# Minetest: Entity Override

Override behaviour of Lua entities.

## Why this mod?

This mod is intended to provide a small framework to redefine Lua entities without touching the original mods' Lua files directly - instead, the properties are changed at runtime, during load.

This goes some ways to reduce technical debt - a state where every update to the original or supporting code causes you to need to maintain/reapply your changes.

This way, you can keep up to date with regularly changing mods without having to untangle merge conflicts from your customizations.

Its main use will be to override mob behaviours, but can be used for any entity in the `minetest.registered_entities` list.

## How to use this mod

1. Create a new mod for your customizations
2. Add a dependency on this mod, as well as the mods you want to override
3. Create your Lua files using the API structure

## API

To override a Lua entity, call the `override:rewrite(name,definition)` function , where the parameters are

* `name` - the itemstring of the entity
* `definition` - a table providing new value rules for the entity

The definition is simple a table, whose keys are the names of the properties in the original definition.

### Straight subsitution

The values can be straight values (string, number, function) or a table representing the substituion rules.

For example

	local newdef = {
			-- imperative substitution
			hp_max = 40,
			on_rightclick = function(self,clicker) minetest.chat_send_player(clicker:get_player_name(),"You cannot tame "..self.name) end, -- just substitute the function
		}
	override:rewrite("dmobs:ogre", newdef)
	override:rewrite("dmobs:orc", newdef)

This modifies two mobs so that they react when right-clicked, but no more, as well as providing them with a new maximum HP.

### Tables, and Conditional substitution

The substition can also be done on a conditional basis per property, where a checking function is provided. Return the boolean `true` from the checking function to go ahead with the substitution; any other value (including the string `"true"`) will cause the original property's value to be left alone.

	override:rewrite("dmobs:hedgehog",{
		hp_max = {
			check = function(oldval)
				return oldval < 10
			end,
			value = 15
		}
	})

This assigns a new max HP to a mob only if its normal HP is less than 10, otherwise the HP is left at whatever value it had normally.

Note that to assign tables, you need to write a conditional substitution - but you can leave out the checking function:

	override:rewrite("mobs_slimes:slime_small",{
		textures = {
			value = {"newtexture_front.png","newtexture_side.png"} -- the actual table that will be assigned
		}
	})

### Function chaining

You can add a function before or after the function currently in place by providing a table defining the `fchain_type` (whether it runs before or after the original function), and the `fchain_func` as the function to run.

In the case of a `"before"` type, where your custom function runs before the original, you must return either a boolean `true` or boolean `false`. True will allow the original function to run; false will cause the original function to be skipped.

	override:rewrite("mobs_animal:sheep",{
		on_rightclick = {
			fchain_type = "before",
			fchain_func = function (self,clicker)
				if self.tame ~= true
				  or clicker:get_wielded_item() == self.follows
				  then
					return true -- run original handler
				end

				-- get wool, at the cost of the animal's health
				minetest.add_entity(self.getpos(),"default:wool" )
				self.health = self.health-1
				return false -- do not run the original handler
			end
		}
	})

This will add funcitonality before the normal right-click routine (presuming `mobs_redo` is in use, it would be the feeding and taming functionality), passing control to the original handler if the animal is generally not tamed, or if the item in hand is what the animal follows; in any other case, some custom code is run and the original handler is skipped.
