--大厅美女互动提示语信息

MMWordListInfo = class();


function MMWordListInfo.ctor( self )
	self._config = {}
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onHttpRequestsListenster);
end

function MMWordListInfo.dtor( self )
	self._config = nil

	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onHttpRequestsListenster);
end

function MMWordListInfo:requestConfig()
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_MM_WORDLIST, {});
end

function MMWordListInfo:requestDataCallBack( isSuccess, data )
	-- body
	if isSuccess and data then 
		if data.status and tonumber(data.status) == 1 then 
			self._config = {}
			for i=1,#data.data do
				local item = {}
				item.type = data.data[i].type
				item.text = data.data[i].words
				table.insert(self._config, item)
			end
		end 
	end 
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onHttpRequestsListenster);
end


function MMWordListInfo:getConfig(  )
	return self._config
end


function MMWordListInfo:onHttpRequestsListenster(param, cmd, isSuccess )
	if self.httpRequestMap[cmd] then
		self.httpRequestMap[cmd](self,isSuccess,param)
	end
end

MMWordListInfo.httpRequestMap = {
    [PHP_CMD_REQUEST_MM_WORDLIST] = MMWordListInfo.requestDataCallBack,
};





