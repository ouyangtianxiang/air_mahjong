-- DiskCache.lua
-- Author: ZainTan
-- Date: 2016-10-20
-- Last modification : 2016-10-20
-- Description:


local MahjongDiskData = class();
local Coder = require("core.gzip")

MahjongDiskData.APP_FILE_NAME  = 'scmjappdata'
MahjongDiskData.USER_FILE_NAME = 'scmjuserdata'

-- if 1 == DEBUGMODE then
	MahjongDiskData.ENCODE = true
-- else
-- 	MahjongDiskData.ENCODE = false
-- end

function MahjongDiskData:ctor( ... )
	-- body
	local diskCache = require('libs.DiskCache')
	self.m_cache = new(diskCache,MahjongDiskData.ENCODE)

	--self.m_groupInfo = {}

	self:loadData()

	self.m_timerAnim = Clock.instance():schedule(function ( ... )
		self:save()
	end,300)--300s = 5min检查一次更新

end

function MahjongDiskData:dtor( ... )
	-- body
	delete(self.m_cache)
	self.m_cache = nil

	if self.m_timerAnim then
		self.m_timerAnim:cancel()
		self.m_timerAnim = nil
	end

	self.m_groupInfo = nil
end
---------------------------------------------------------get/set data----------------------------------------------
function MahjongDiskData:setAppData( key, value )
	-- body
	self:setFileKeyValue(self.APP_FILE_NAME, key, value)
end

function MahjongDiskData:getAppData( key, defaultValue )
	-- body
	return self:getFileKeyValue(self.APP_FILE_NAME, key, defaultValue)
end

function MahjongDiskData:setUserData( uid, key, value )
	-- body
	self:setFileKeyValue(self.USER_FILE_NAME, key, value)
end

function MahjongDiskData:getUserData( uid, key, defaultValue)
	-- body
	return self:getFileKeyValue(self.USER_FILE_NAME, key, defaultValue)
end


function MahjongDiskData:setFileData( filename, tableValue )
	-- body
	self.m_cache:setFile(filename, tableValue)
end

function MahjongDiskData:getFileData(  filename, defaultValue )
	-- body
	return self.m_cache:getFile(filename, defaultValue)
end

function MahjongDiskData:setFileKeyValue( filename, key, value )
	-- body
	self.m_cache:setValue(filename, key, value)
end

function MahjongDiskData:getFileKeyValue( filename, key, defaultValue )
	-- body
	return self.m_cache:getValue(filename, key, defaultValue)
end

function MahjongDiskData:clearFile( filename )
	-- body
	self.m_cache:setFile(filename,nil)
	self.m_cache:removeFile(filename)
end

function MahjongDiskData:clearAllFile( ... )
	-- body
	self.m_cache:clearAllFile(kCDNLocalFile)
end
-----------------------------------------------------------------group------------------------------------------------
-- function MahjongDiskData:setFileGroup( filename, group )
-- 	-- body
-- end

-- function MahjongDiskData:addFileGroup( filename, group )
-- 	-- body
-- end

-- function MahjongDiskData:getFileGroup( filename )
-- 	-- body
-- end
function MahjongDiskData:save()
	-- body
	self.m_cache:save()
end

function MahjongDiskData:loadData()
	-- body
	self.m_cache:getFile(self.APP_FILE_NAME)
	self.m_cache:getFile(self.USER_FILE_NAME)

end

--------------------------------------------private---------------------------------------------------------

return MahjongDiskData
