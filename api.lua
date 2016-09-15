-- mobs override

mobs.override = {}

local matchmob = function(themob,check)
	for i,j in pairs(check)  do
		if i ~= "checkmode" then
			if check.checkmode == "and" then
				if themob[i] ~= j.target and j.mode == "match" then return false end
				if themob[i] == j.target and j.mode == "diff" then return false end
			elseif check.checkmode == "or" then
				if themob[i] == j.target and j.mode == "match" then return true end
				if themob[i] ~= j.target and j.mode == "diff" then return true end
			else
				minetest.debug("Invalid checkmode "..check.checkmode)
				return nil
			end
		end
	end

	if check.checkmode == "and" then return true end
	return false
end

local sethas = function(needle,haystack)
	for _,i in pairs(haystack) do
		if i == needle then return true end
	end
	return false
end

local mobs_override = function(mobname,def,check)
	local themob = minetest.registered_entities[mobname]
	if check ~= nil then
		if not matchmob(themob,check) then return end
	end

	for property,definition in pairs(def) do
		if type(definition) == "string"
		  or type(definition) == "number"
		  or type(definition) == "function"
		  then
			themob[property] = definition
		elseif type(definition) == "table" then
			if definition.mode == "diff" then
				if themob[property] ~= defintion.target then themob[property] = definition.value end
			elseif definition.mode == "match"
				if themob[property] == defintion.target then themob[property] = definition.value end
			elseif sethas(definition.fchain_type, {"after","before"}) and type(fchain_func) == "function" then
				local extantf = themob[property]
				if type(extantf) == "function" then
					if definition.fchain_type == "after" then
						themob[property] = function(...)
							extantf( unpack(arg) )
							definition.fchain_func( unpack(arg) )
						end
					elseif definition.fchain_type == "before" then
						themob[property] = function(...)
							if definition.fchain_func( unpack(arg) ) then
								extantf( unpack(arg) )
							end
						end
					end
						
				else
					minetest.debug("Expected existing function in "..property.." for "..mobname.." but got a "..type(extantf))
				end
			else
				minetest.debug("No valid definition for "..mobname.."["..property.."] in "..dump(definition))
			end
		end
	end
end

mobs.override = mobs_override
