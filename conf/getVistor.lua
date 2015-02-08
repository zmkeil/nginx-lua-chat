local checkSession = require "checkSession"
local sessionL = checkSession:new()


-- check allow
local checkSession = require "checkSession"
local sessionL = checkSession:new(db)
local flag, username = sessionL:checkLogin()



local res
if flag == 1 or flag == 2 then
	local backurl = ngx.var.arg_backurl
	res = "<br/><p><a href=\"/login.html?backurl="..backurl.."\" style=\"font-size: initial;\">登 录</a></p>"
elseif flag == 0 then
	res = "<br/><p>欢迎  "..username.."</p>"
end

ngx.say(res)
