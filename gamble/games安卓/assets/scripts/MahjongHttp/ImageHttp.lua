
ImageHttp = class();

ImageHttp.ctor = function (self)
	-- body
	self.m_connectTiemOut 	= 15000;
	self.m_RecvTiemOut 		= 15000;
end

ImageHttp.dtor = function ()
	-- body
end

ImageHttp.download = function (self, url )
	-- body
	local httpRequest = new(Http, kHttpGet, kHttpReserved, url)
	httpRequest:setEvent(self, self.onResponse);
	httpRequest:setTimeout(self.m_connectTiemOut,self.m_RecvTiemOut);
	
	-- local timeoutAnim = HttpManager.createTimeoutAnim(self,command,config[HttpConfigContants.TIMEOUT] or self.m_timeout);
    -- self.m_httpCommandMap[httpRequest] = command;
    -- self.m_commandHttpMap[command] = httpRequest;
    -- self.m_commandTimeoutAnimMap[command] = timeoutAnim;

	httpRequest:execute();

	self.httpRequest = httpRequest;
end

ImageHttp.onResponse = function ( self, httpRequest)

	--HttpManager.destoryTimeoutAnim(self,command);
 print("xxxxxxxxxx onResponse");
 
 	local errorCode = HttpErrorType.SUCCESSED;
 	local data = nil;
   
	repeat 
		-- 判断http请求的错误码,0--成功 ，非0--失败.
		-- 判断http请求的状态 , 200--成功 ，非200--失败.
		if 0 ~= httpRequest:getError() or 200 ~= httpRequest:getResponseCode() then
			errorCode = HttpErrorType.NETWORKERROR;
			break;
		end
	
		-- http 请求返回值
		local data =  httpRequest:getResponse();
		print("xxxxxxxxxx");
		print("" .. data);
		print("vvvvvvvvvv");
	until true;

 --    EventDispatcher.getInstance():dispatch(HttpManager.s_event,command,errorCode,data);
	
	-- HttpManager.destroyHttpRequest(self,httpRequest);

end