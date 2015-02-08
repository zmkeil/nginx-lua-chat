local mysql = require "resty.mysql"
local checkSession = require "checkSession"
local db = mysql:new()


-- get name
ngx.req.read_body()
local post_args, err = ngx.req.get_post_args()
local lr_email
if post_args then
	local k, v
	for k ,v in pairs(post_args) do
		if k == "lr_lemail" then
			lr_email = v
		end
	end
end
if not lr_email then
	ngx.log("NO post body")
	ngx.exit(500)
end



-- check name, and set Cookie
local ok, err, errno, sqlstate = db:connect({
    host = "127.0.0.1",
    port = 3306,
    database = "binshared",
    user = "admin",
    password = "123"})

local sessionL = checkSession:new(db)

local res, err, errno, sqlstate
local queryline = "select * from uic where email=\""..lr_email.."\""

res, err, errno, sqlstate = db:query(queryline)
if not res then
	ngx.log(ngx.ERR, "bad result #1: ", err, ": ", errno, ": ", sqlstate, ".")
	return ngx.exit(500)
else
	local row, name, uid
	for _, row in ipairs(res) do
		name = row.name
		uid = row.uid
	end

	if not name then
		ngx.redirect(ngx.req.get_headers()['Referer']..'&again=1')
	else
		local time, err = sessionL:updateLoginTime(name)
		if not time then
			ngx.exit(500)
		end
		
	--	local times = os.date("%Y-%m-%d %H:%M:%S", time)
		local str = "name="..name.."&time="..time
		local user_cookie = sessionL:xxencode(str)
		ngx.header['Set-Cookie'] = {'DS_USER_cookie='..user_cookie..'; path=/'}
		local backurl = ngx.var.arg_backurl
		ngx.redirect(backurl)
	end
end


