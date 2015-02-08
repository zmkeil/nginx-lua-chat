-- Copyright (C) zhaomang.zm


local _M = { _VERSION = '0.08' }

--local mt = { __index = _M }

--function _M.instance(self, elment, value, attris)
--	local aattris
--	if attris then
--		aattris = attris
--	else 
--		aattris = {}
--	end
--
--	return setmetatable({
--		el = elment,
--		val = value,
--		attris = aattris
--	}, mt)
--end
--
--
--function _M.setattris(self, name, value)
--	if self.attris[name] then
--		self.attris[name] = self.attris[name]..value
--	else
--		self.attris[name] = value
--	end
--end


function _M.paint(self, element, attris, value)
--	local el = self.el
--	local val = self.val or value
--	if val == nil then
--		val = " "
--	end

	local val = value or "NO VALUE"
	local el = element or "p"

	local na, att
	local aattris = ""
	if attris then
		for na, att in pairs(attris) do
			aattris = aattris..na.."=\""..att.."\"  "
		end
	end

	local res = "<"..el.." "..aattris..">"..val.."</"..el..">"
	return res
end

function _M.dg_paint(self,levels,...)
	local argv = {...}
	local argc = table.getn(argv)

	local lev = 1
	while lev <= levels do


	end


end


return _M
