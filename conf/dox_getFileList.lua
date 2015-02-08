local OPENtoTHESE = "MANG"
local mysql = require "resty.mysql"
local elbuild = require "elbuild"
--local lfs = require "lfs"


-- check allow
local checkSession = require "checkSession"
local sessionL = checkSession:new()
local flag, username = sessionL:checkLogin()



-- app content
local db = mysql:new()
local ok, err, errno, sqlstate = db:connect({
    host = "127.0.0.1",
    port = 3306,
    database = "binshared",
    user = "admin",
    password = "123"})

local function paintOneFile(filename, updatetime, fileurl, backurl)
	local at2 = {href = "javascript:dox_showUrl(\'"..filename.."\',\'"..fileurl.."\')"}
--	local res = elbuild:dg_paint(2,1,"tr",_,2,"td",_,"td",at2)
	local td = elbuild:paint("label",{},os.date("%Y-%m-%d %H:%M:%S", updatetime))
	td = td.."&nbsp;&nbsp;&nbsp"..elbuild:paint("a",at2,filename)
	res = elbuild:paint("p",_,td)
	return res
end

local function allfiles(db, backurl)
	local result = ""
	local nums = 0
	local res, err, errno, sqlstate
	local queryline = "select * from dox where user_name=\""..username.."\""

	res, err, errno, sqlstate = db:query(queryline)
	if not res then
		ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
		return ngx.exit(500)
	else
		local row, filename, updatetime, fileurl
		for _, row in ipairs(res) do
			filename = row.filename
			updatetime = row.updatetime
			fileurl = row.url
			result = result..paintOneFile(filename, updatetime, fileurl, backurl)
			nums = nums + 1
		end
	end

	local rresult
	if nums == 0 then
		rresult = "You Have Not upload files"
	else
		rresult = elbuild:paint("div",{style="height: 320px; overflow: scroll;"},result)
	end
	
	return rresult.."<br/>"..elbuild:paint("input",{type="button",onclick="dox_reflash_flist();",value="Reflash"},"")
end



local str
local res
local backurl = ngx.var.arg_backurl
if flag == 1 then
	str = "请先登录"
elseif flag == 2 then
	str = "您离开太久了，请重新登录"
elseif flag == 0 then 
	if not string.find(OPENtoTHESE, username) then
		str = elbuild:paint("p",_,"该服务目前只对少数用户可用，如果您确实希望使用，请联系管理员")
		str = str..elbuild:paint("p",_,"zhaomangzheng@163.com")
	else
		str = allfiles(db, backurl)
	end
else
	str = elbuild:paint("p",_,"server error")
end

if flag ~= 0 then
	res = "<a href=\"/login.html?backurl="..backurl.."\">"..str.."</a>"
else
	res = str
end

ngx.say(res)
