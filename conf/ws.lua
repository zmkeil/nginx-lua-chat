
local server = require "resty.websocket.server"
local wb, err = server:new {
	timeout = 500,
	max_payload_len = 65535
}
if not wb then
	ngx.log(ngx.ERR, "failed to new websocket: ", err)
	return ngx.exit(444)
end

if not ngx.shared.stats:get("connections") then
	ngx.shared.stats:set("connections", 0)
end
if not ngx.shared.stats:get("uid") then
	ngx.shared.stats:set("uid", 0)
end

local chatStartTime
if not ngx.shared.stats:get("chatStartTime") then
	chatStartTime = ngx.time()
	ngx.shared.stats:set("chatStartTime", chatStartTime)
end
if not ngx.shared.stats:get("lastSpeekTime") then
	ngx.shared.stats:set("lastSpeekTime", chatStartTime)
end

ngx.shared.stats:incr("connections", 1);
ngx.shared.stats:incr("uid", 1);

local name = ngx.var.arg_name
local uid = ngx.shared.stats:get("uid")

local lastUpdateTime = ngx.shared.stats:get("chatStartTime")

while true do
	local data, typ, err = wb:recv_frame()
	if wb.fatal then
		ngx.log(ngx.ERR, "failed to receive frame: ", err)
		ngx.shared.stats:incr("connections", -1)
		return ngx.exit(444)
	end
	if typ == "close" then
		ngx.shared.stats:incr("connections", -1)
		break
	elseif typ == "ping" then
		local bytes, err = wb:send_pong()
		if not bytes then
			ngx.log(ngx.ERR, "failed to send pong: ", err)
			ngx.shared.stats:incr("connections", -1)
			return ngx.exit(444)
		end
	elseif typ == "pong" then
		ngx.log(ngx.INFO, "client ponged")

	elseif typ == "text" then
		local time = ngx.time()
		ngx.shared.stats:set("lastSpeekTime", time)		
		local res = ngx.location.capture("/mysql_write"..'?speektime='..time..'&&name='..name..'&&uid='..uid..'&&msg='..data)
		if res.status ~= 200 then
			ngx.exit(500)
		end
	end

	local lastSpeekTime = ngx.shared.stats:get("lastSpeekTime")
	if lastUpdateTime < lastSpeekTime then
		local res = ngx.location.capture("/mysql_read".."?updatetime="..lastUpdateTime)
		if res.status ~= 200 then
			ngx.exit(500)
		end

		local bytes, err = wb:send_text(res.body) --sometimes we may need res.header
		if not bytes then
			ngx.log(ngx.ERR, "failed to send text: ",err)
			ngx.shared.stats:incr("connections", -1)
			return ngx.exit(444)
		end

		lastUpdateTime = lastSpeekTime
	end

end
wb:send_close()


