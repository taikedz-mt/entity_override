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

	mobs.override:mob(
		name = "mobs:name",
		{
			-- imperative substitution

			property1 = "value", -- a plain value substitution

			property2 = function(opt) end, -- just substitute the function

			-- conditional substitution of values

			property3 = {
				ifnot = true, -- substitute value onto property3 only if the old value IS NOT equal to the ifnot value
				value = "new value"
			},

			property4 = {
				ifis = nil, -- substitute value onto property4 only if the old value IS equal to the ifis value
				value = "new value"
			},

			-- function chaining

			property5 = {
				function_override_type = "after", -- "before", "after" -- whether the new function should run before or after the existing function
				function_override_cond = value, -- the value expected from the first function called in order for the second to execute
				function_override_func = function(opts) end, -- the new function to provide
			}
		}
	)

	mobs.override:mob(mobname, newdefs) -- and again
