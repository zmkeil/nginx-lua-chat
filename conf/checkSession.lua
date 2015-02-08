-- Copyright (C) zhaomang.zm


local _M = { _VERSION = '0.08' }

local mt = { __index = _M }

function _M.new(self, db)

	return setmetatable({
		db = db,
		expired_time = 60
	}, mt)
end


local function urlencode(str) 
	if (str) then  
		str = string.gsub (str, "\n", "\n")  
		str = string.gsub (str, "([^%w .-])",  
		function (c) return string.format ("%%%02X", string.byte(c)) end)  
		str = string.gsub (str, " ", "+")  
	end  
	return str  
end  

local function urldecode(str)  
	str = string.gsub (str, "+", " ")  
	str = string.gsub (str, "%%(%x%x)",  
	function(h) return string.char(tonumber(h,16)) end)  
	str = string.gsub (str, "\r\n", "\n")  
	return str  
end

local function strstr(str)
	local res = ""
	local len = string.len(str)
	local s=1
	local e=4
	while e+2 <= len do
		res = res..string.sub(str,e,e+2)..string.sub(str,s,s+2)
		s = e + 3
		e = s + 3
	end 
	res = res..string.sub(str,s)
	return res
end 

function _M.xxencode(self, t)
--	local str = "name="..t.name.."&time="..t.time
	local str = t
	local ss = urlencode(str)
	return strstr(ss)
end

function _M.xxdecode(self, str)
	local t = {}
	local ss = strstr(str)
	local sstr = urldecode(ss)
	local s = 1
	local keyp, valp
	while true do
		keyp = string.find(sstr,'=',s)
		if not keyp then
			break
		end
		local key = string.sub(sstr,s,keyp-1)
		s = keyp + 1
		valp = string.find(sstr,'&',s)
		if valp then
			local val = string.sub(sstr,s,valp-1)
			t[key] = val
			s = valp + 1
		else
			local val = string.sub(sstr,s)
			t[key] = val
			break
		end
	end
	return t
end
		

function _M.updateLoginTime(self, name)
	local db = self.db
	local time = ngx.time()
	local loginUsers = ngx.shared.loginUsers
	local lasttime = loginUsers:get(name)
	if lasttime then
		queryline = "update login_users set logintime="..time.." where name=\""..name.."\""
	else
		queryline = "select logintime from login_users where name=\""..name.."\""
		res, err, errno, sqlstate = db:query(queryline)
		if not res then
			ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
			return nil, "db error"
		end
		if res[1] and res[1].logintime then
			queryline = "update login_users set logintime="..time.." where name=\""..name.."\""
			lasttime = res[1].logintime
		else
			queryline = "insert into login_users value("..uid..",\""..name.."\","..time..")"
		end
	end

	res, err, errno, sqlstate = db:query(queryline)
	if not res then
		ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
		return ngx.exit(500)
	end
	loginUsers:set(name,time)

	return time
end


function _M.getAllCookies(self, cookie)
	local start=1
	local cookies = {}
	if cookie then
		local str = string.gsub(cookie,' ','')

		if str then
			while true do
				local namep = string.find(str,'=',start)
				local name = string.sub(str,start,namep-1)
				local valuep = string.find(str,';',namep+1)
				if valuep ~= nil then
					local value = string.sub(str,namep+1,valuep-1)
					cookies[name] = value
					start = valuep + 1
				else
					local value = string.sub(str,namep+1)
					cookies[name] = value
					break
				end
			end
		end
	end
	return cookies
end

function _M.checkLogin(self)
	local cookie = ngx.var.http_cookie
	local cookies = self:getAllCookies(cookie)
	local str = cookies["DS_USER_cookie"]

	local name, flag, time, dlte
	if not str then
		flag = 1		-- 0 : login, 1 : not login, 2 : expired
	else
		local t = self:xxdecode(str)
		if not t.name or not t.time then
			ngx.log(ngx.ERR, "cookie error")
			ngx.exit(500)
		end
		name = t.name
		time = tonumber(t.time)
		dlte = ngx.time() - time
		if dlte > self.expired_time*60 then
			flag = 2
		else 
			flag = 0
		end
	end

	return flag, name
end


return _M
