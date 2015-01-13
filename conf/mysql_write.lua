local mysql = require "resty.mysql"
local db = mysql:new()

local ok, err, errno, sqlstate = db:connect({
    host = "127.0.0.1",
    port = 3306,
    database = "waterarmy",
    user = "admin",
    password = "123"})

local res, err, errno, sqlstate
local args = ngx.var.arg_speektime..",\""..ngx.var.arg_name.."\","..ngx.var.arg_uid..",\""..ngx.var.arg_msg.."\""
local queryline = "insert into chat_msg values("..args..")"

res, err, errno, sqlstate = db:query(queryline)
if not res then
	ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
	return ngx.exit(500)
end

local ok, err = db:set_keepalive(10000, 50)
if not ok then
    ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    ngx.exit(500)
end
