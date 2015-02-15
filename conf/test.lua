local bs_upsql = require "bs_upsql"


local wrapdb = bs_upsql:new("binshared")
if not wrapdb then
	return ngx.say("connect DB error")
end

local res = wrapdb:select("uic")
if not res then
	ngx.say("log is writen, please exit")
else
	local row, name, uid
	for _, row in ipairs(res) do
		name = row.name
		uid = row.uid
		ngx.say(uid..":  "..name)
	end
end

local res = wrapdb:insert("test_table_test",{"jxj",2})
ngx.say(res)
