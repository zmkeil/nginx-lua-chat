-- Copyright (C) zhaomang.zm


local _M = { _VERSION = '0.08' }

local mt = { __index = _M }

function _M.new(self, cells, fattris)
	if cells == nil then
		err = "please input cells"
		return nil, err
	end

	local nums = cells.nums
	local allot = cells.allot
	if table.getn(allot) < nums then
		err = "allot nums not map"
		return nil, err
	end

	local n = table.getn(allot)
	while n > nums do
		table.remove(allot, n)
		n = table.getn(allot)
	end

	local cattris = {}
	local total=0, v
	for _, v in pairs(allot) do
		total = total + v
		table.insert(cattris, {style=" "})
	end
	if total ~= 12 then
		err = "allot length not map"
		return nil, err
	end

	local  ffattris = fattris
	if ffattris == nil then
		ffattris = {}
	end
	if ffattris.style == nil then
		ffattris.style = " "
	end

	return setmetatable({
		nums = nums,
		fattris = ffattris,
		allot = allot,
		cattris = cattris
	}, mt)
end

function _M.setcattris(self, nums, name, value)
	if (self.cattris[nums])[name] then
		(self.cattris[nums])[name] = (self.cattris[nums])[name]..value
	else
		(self.cattris[nums])[name] = value
	end
end

function _M.paint(self, ...)
	local allot = self.allot
	local fattris = self.fattris
	local cattris = self.cattris
	local result = ""
	local k, v

	local argv = {...}
	local argc = table.getn(argv)

	result = result.."<div class=\"row clearfix\" style=\""..fattris.style.."\">\n"
	for k, v in pairs(allot) do
		result = result.."<div class=\"col-md-"..v.." column\" style=\""..cattris[k].style.."\">\n"
		if k <= argc then
			result = result..argv[k]
		end
		result = result.."</div>\n"
	end
	result = result.."</div>\n"

	return result
end


return _M
