--
-- Author: zen.zhao88@gmail.com
-- Date: 2015-10-10 11:42:15
--
local lfs = require "lfs"

local EncryptKey = "ERLDBPERLDBPERLDBPERLDBPERLDBP"

--文件MD5验证
function lfs.checkFile(file, md5)

	if not io.exists(file) then
		return false
	end

	local fd = io.open(file, "rb")
	local data = fd:read("*all")
	io.close(fd)

	if not data or data == "" then
		return false
	end

	local ms = crypto.md5(common.hex(data))

	return ms == md5
	
end

function lfs.getFilePath(...)
	local path = device.writablePath

	if string.sub(path, string.len(path)) ~= device.directorySeparator then
		path = path .. device.directorySeparator .. "born2play/Solitaire"
	else
		path = path .. "born2play/Solitaire"
	end

	for _, v in ipairs{...} do
		path = path .. device.directorySeparator .. v
	end

	return path
end

function lfs.writeFile(path,data)
	local json = json.encode(data)	
	-- local json = crypto.encryptXXTEA(json, EncryptKey)
	return io.writefile(path,json)
end

function lfs.readFile(path)
	local data = CCFileUtils:sharedFileUtils():getStringFromFile(path)
	if not data or string.len(data) < 1 then
		return nil
	end
	-- local data = crypto.decryptXXTEA(data, EncryptKey)
	if data then
		local json = json.decode(data)
		return json
	end
	return nil
end

function lfs.checkDir(path,base)
	local current = lfs.currentdir()
	local dirs = string.split(path,"/")
	local new = device.writablePath

	if string.sub(new, string.len(new)) == device.directorySeparator then
		new = string.sub(new, 1, string.len(new) - 1)
	end

	if base then
		new = new .. "/" .. base
	end

	for _, dir in pairs(dirs) do
		
		new = new .. "/" .. dir

		if not lfs.chdir(new) then
			printf("创建新文件：%s", tostring(new))
			if not lfs.mkdir(new) then
				lfs.chdir(current)
				return false
			end
		end
	end

	lfs.chdir(current)
	return true	
end

function lfs.rmdir(path)
	if CCFileUtils:sharedFileUtils():isFileExist(path) then
		local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    -- printf("common.rmdir_mode:%s,%s", mode,curDir)
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then printf(des) end
            return succ
        end
        _rmdir(path)
	end
end

return lfs