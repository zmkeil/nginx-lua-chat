
local checkSession = require "checkSession"
local xcode = checkSession:new()

local t = {name = "MANG", time = 123}
local enc = xcode:xxencode(t)
print(enc)

local dec = xcode:xxdecode(enc)
print(dec.name, dec.time)
