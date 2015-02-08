local mysql = require "resty.mysql"
local db = mysql:new()

local htbuild = require "htbuild"
local elbuild = require "elbuild"

local ok, err, errno, sqlstate = db:connect({
    host = "127.0.0.1",
    port = 3306,
    database = "binshared",
    user = "admin",
    password = "123"})

local res, err, errno, sqlstate
local queryline = "select * from applist order by doit"

res, err, errno, sqlstate = db:query(queryline)
if not res then
	ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
	return ngx.exit(500)
end

for order, row in ipairs(res) do
	local fattris = {style="font-size: large;padding-top: 5px;"}
	local cells = {nums=3, allot={2, 6, 4}}
	local builder = htbuild:new(cells, fattris)
	if builder == nil then
		ngx.say("no builder")
	end
	
	local attris = {class="text-center"}
	local str1 = elbuild:paint("p",attris,order)
	
	local str2 = elbuild:paint(_,{},row.descri)
	
	local str3 = elbuild:paint(_,attris,"pv: "..row.pv..",  ex: "..row.doit)

	attris = {
		href = "/"..row.appname.."/"..row.page,
		target = "_blank"
	}
	local str4 = elbuild:paint("a",attris,str3)

	

	builder:setcattris(3,"style","background-color: antiquewhite;")
	builder:setcattris(1,"style","color: red;background-color: aliceblue;")
	builder:setcattris(2,"style","background-color: aquamarine;")
	local res = builder:paint(str1, str2, str4)
	ngx.say(res)
end


local ok, err = db:set_keepalive(10000, 50)
if not ok then
    ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    ngx.exit(500)
end
