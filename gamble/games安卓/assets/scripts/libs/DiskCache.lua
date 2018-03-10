-- DiskCache.lua
-- Author: ZainTan
-- Date: 2016-10-20
-- Last modification : 2016-10-20
-- Description: 
--require('coreex/serializer')

local DiskCache = class();
local Coder = require("core.gzip")

DiskCache.DISK  = 0x0001
DiskCache.CACHE = 0x0002

function DiskCache:ctor( bEncode )
	-- body
	self.m_mapData  = {}
	self.m_mapDirty = {}

	self.m_needEncode = bEncode
end

function DiskCache:dtor( ... )
	-- body
	self:save()
	self.m_mapDirty = nil
	self.m_mapData  = nil
end


function DiskCache:getFile( filename, defaultValue )
	if not filename then 
		return nil 
	end 
	local file = self.m_mapData[filename]

	if not file then 
		file = self:readFile(filename)
		self.m_mapData[filename] = file
	end 

	return file or defaultValue
end

function DiskCache:getValue( filename, key, defaultValue )
	if not key then 
		return defaultValue 
	end 

	-- body
	local file = self:getFile(filename)
	if not file then
		return defaultValue 
	end 

	return file[key] or defaultValue
end

function DiskCache:setFile( filename, value, saveNow)
	if not filename then 
		return
	end 
	-- body
	self.m_mapData[filename] = value
	if saveNow then 
		self:writeFile(filename)
		return
	end 
	self.m_mapDirty[filename] = true
end

--这里做个优化 对数据做了判断 相同的数据 不会做脏标记(ps：对于复杂类型如table这个判断是无效的)
function DiskCache:setValue( filename, key, value,  saveNow )
	if not filename or not key then 
		return
	end 
	local isSameValue = nil
	-- body
	local file = self:getFile(filename)
	if not file then 
		self.m_mapData[filename]      = {}
	end 
	---切忌这里如果是table类型的数据 如果不(and type(value) ~= 'table')  会造成数据丢失！！！！
	if file and file[key] == value and type(value) ~= 'table' then 
		isSameValue = true
	else 
		self.m_mapData[filename][key] = value
	end 

	if saveNow and not isSameValue then 
		self:writeFile(filename)
		return
	end 

	if not isSameValue then 
		self.m_mapDirty[filename] = true
	end 
	return
end


function DiskCache:save()
	for k,v in pairs(self.m_mapDirty) do
		if v then
			self:writeFile(k, self.m_needEncode)
		end 
	end
end

function DiskCache:removeFile( filename )
	-- body
	if not filename then 
		return 
	end 
	os.remove(System.getStorageOuterRoot()..filename)
end

function DiskCache:clearAllFile(exceptFile)
	for k,v in pairs(self.m_mapData) do
		if not exceptFile or exceptFile ~= k then 
			self:removeFile(k)
		end 
	end

	local dataRef = exceptFile and self.m_mapData[exceptFile] or nil 
	local flagRef = exceptFile and self.m_mapDirty[exceptFile] or nil
	
	self.m_mapData  = {}
	self.m_mapDirty = {}

	self.m_mapData[exceptFile]  = dataRef
	self.m_mapDirty[exceptFile] = flagRef
end

----------------------------private fuctions-----------------------------------------

function DiskCache:readFile( filename )
	-- body
	if not filename then 
		return nil 
	end 
	local readContent = nil 
	local fhander = io.open(System.getStorageOuterRoot()..filename,"rb")
	if fhander then 
		readContent = fhander:read('*all')
		fhander:close()	
	end 

	if not readContent or readContent == "" then 
		return nil 
	end 

	local head    = string.sub(readContent,1,1)
	local content = string.sub(readContent,2)
	if head ~= '0' then--unEncode
		content = Coder.decodeBase64Gzip(content)
	end 

	return json.decode(content)--Serializer.unserialize(content)
end


function DiskCache:writeFile( filename, bEncode )
	if not filename then 
		return false 
	end 

	self.m_mapDirty[filename] = false

	local content = json.encode(self:getFile(filename)) --Serializer.serialize() 
	if bEncode then 
		content = Coder.encodeGzipBase64(content)
	end 

	local fhander = io.open(System.getStorageOuterRoot()..filename,"wb")
	if fhander then 
		if bEncode then 
			fhander:write('1'..(content or ''))
		else 
			fhander:write('0'..(content or ''))
		end 
		fhander:close()
		return true 
	end 
end 
return DiskCache


