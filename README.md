# Minetest: mobs overrider

Override behaviour of `mobs_redo` and its mobs using a lua table.

## Why this mod?

This mod is intended to allow the redefinition of mobs and the mob engine functions without touching the original Lua files directly - instead, the properties are changed at runtime, during load.

This goes some ways to reduce technical debt - a state where every update to the original or supporting code causes you to need to maintain/reapply your changes.

This way, you can keep up to date with fast-moving developments of mobs based on `mobs_redo` without having to untangle merge conflicts.

## How to use this mod

1. Add a dependency on the mobs mod that you want to override
2. Specify the overrides in a lua file in this mod, or in your own mod after adding a dependency to this mod.

## Example

The following stands as an example, and as a reference usage of the intended API:

	mobs.override(
		name = "modname:mobname",
		{
			-- imperative substitution

			property1 = "value", -- a plain value substitution

			property2 = function(opt) dothings() end, -- just substitute the function

			-- conditional substitution of values

			property3 = { -- substitute value onto property3 only if the old value IS NOT equal to the target value
				check = function(oldvalue) return true end -- handler function to check the old value. return true to apply value override
				value = "new value"
			},

			-- function chaining, and conditions

			property4 = {
				fchain_type = "after", -- "before", "after" -- whether the new function should run before or after the existing function
				fchain_func = function(opts) dostuff() end, -- the new function to provide - in "before" mode, must return true to cause original function to run afterwards
			}
		},
		check = function(themob) return true end -- handler function that takes the registered entity as argument. return true to apply override
	)

	mobs.override(mobname, newdefs) -- and again, check function is optional
