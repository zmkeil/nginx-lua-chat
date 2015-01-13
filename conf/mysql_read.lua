local mysql = require "resty.mysql"
local db = mysql:new()

local ok, err, errno, sqlstate = db:connect({
    host = "127.0.0.1",
    port = 3306,
    database = "waterarmy",
    user = "admin",
    password = "123"})

local res, err, errno, sqlstate
local queryline = "select * from chat_msg where time>"..ngx.var.arg_updatetime

res, err, errno, sqlstate = db:query(queryline)
if not res then
	ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
	return ngx.exit(500)
end

local messages = ""
for _, row in ipairs(res) do
	local times = os.date("%Y-%m-%d %H:%M:%S", row.time)
	messages = messages..times.."\t"..row.uname.." SAYS: "..row.msg.."##"
end

ngx.say(messages) -- in ngx_lua module, result of subRequest return to mainRequest

local ok, err = db:set_keepalive(10000, 50)
if not ok then
    ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    ngx.exit(500)
end
