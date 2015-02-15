-- Copyright (C) zhaomang.zm

local _M = { _VERSION = '0.08' }

local mt = { __index = _M }

function _M.new(self,database,host,port,user,password)
	local mysql = require "resty.mysql"
	local db = mysql:new()

	local ok, err, errno, sqlstate = db:connect({
		host = "127.0.0.1",
		port = 3306,
		database = database,
		user = "admin",
		password = "123"})

	if not ok then
		ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
		return nil
	end

	return setmetatable({
		db = db
	}, mt)
end


local function tstos(target, concat)
	local lua_table = require "table"
	local s_target = nil

	if type(target) == "table" then
		local st_target = {}
		for k,v in pairs(target) do
			if type(v) == "string" then
				lua_table.insert(st_target, k.."=\""..v.."\"")
			elseif type(v) == "number" then
				lua_table.insert(st_target, k.."="..v)
			end
		end
		s_target = lua_table.concat(st_target, concat)
	elseif type(target) == "string" then
		s_target = target
	end

	return s_target
end



function _M.update(self, table, target, rule)
	local lua_table = require "table"
	local db = self.db
	local k, v
	local s_target, s_rule

	s_target = tstos(target, ",")
	if not target then
		return nil, "target not supported"
	end

	s_rule = tstos(rule, " and ")
	if not rule then
		return nil, "rule not supported"
	end

	local st_queryline = {[1] = "update", [3] = "set", [5] = "where"}
	lua_table.insert(st_queryline, 2, table)
	lua_table.insert(st_queryline, 4, s_target)
	lua_table.insert(st_queryline, 6, s_rule)

	local res, err, errno, sqlstate
	res, err, errno, sqlstate = db:query(lua_table.concat(st_queryline, " "))
	if not res then
		ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
	end

	return res
end


function _M.select(self, table, field, rule)
	local lua_table = require "table"
	local db = self.db
	local res, err, errno, sqlstate
	local mfield = field or "*"
	local s_rule = tstos(rule, " and ")

	local st_queryline = {[1] = "select", [3] = "from"} 
	lua_table.insert(st_queryline, 2, mfield)
	lua_table.insert(st_queryline, 4, table)
	if s_rule then
		lua_table.insert(st_queryline, 5, "where")
		lua_table.insert(st_queryline, 6, s_rule)
	end
	
	res, err, errno, sqlstate = db:query(lua_table.concat(st_queryline, " "))
	if not res then
		ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
	end

	return res
end


function _M.insert(self, table, values) 
	local lua_table = require "table"
	local db = self.db
	local res, err, errno, sqlstate

	local s_values = tstos(values, ",")
	if not s_values then
		ngx.log(ngx.ERR, "mysql insert value is null")
		return nil
	end

	local st_queryline([1] = "insert into", [3] = "value(", [5]=")")
	lua_table.insert(st_queryline, 2, table)
	lua_table.insert(st_queryline, 4, s_values)

	res, err, errno, sqlstate = db:query(lua_table.concat(st_queryline, " "))
	if not res then
		ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
	end

	return res
end



return _M
