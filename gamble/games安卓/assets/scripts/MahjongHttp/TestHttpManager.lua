require("gameBase/httpManager");

TestHttpManager = class(HttpManager);

TestHttpManager.ctor = function(self,configMap,postDataOrganizer,urlOrganizer)
	self.m_timeout  = 15000;
end

TestHttpManager.dtor = function(self)
	
end

TestHttpManager.execute = function(self,command,data,commonUrl)
	if not HttpManager.checkCommand(self,command) then
		return false;
	end

	HttpManager.destroyHttpRequest(self,self.m_commandHttpMap[command]);

	local config = self.m_configMap[command];
	local httpType = config[HttpConfigContants.TYPE] or kHttpPost;

	local url = self.m_urlOrganizer(commonUrl..config[HttpConfigContants.URL],
								config[HttpConfigContants.METHOD], httpType);
	
	local httpRequest = new(Http,httpType,kHttpReserved,url)
	httpRequest:setEvent(self, self.onResponse);
	httpRequest:setTimeout(self.m_timeout,self.m_timeout);

	if httpType == kHttpPost then 
		local postData =  self.m_postDataOrganizer(config[HttpConfigContants.METHOD],data);
		httpRequest:setData(postData);
	end

	local timeoutAnim = TestHttpManager.createTimeoutAnim(self, httpRequest.m_requestID, command,config[HttpConfigContants.TIMEOUT] or self.m_timeout);

    self.m_httpCommandMap[httpRequest] = command;
    self.m_commandHttpMap[command] = httpRequest;
    self.m_commandTimeoutAnimMap[command] = timeoutAnim;

	httpRequest:execute();
	return httpRequest.m_requestID;
end

TestHttpManager.onResponse = function(self , httpRequest)
	local command = self.m_httpCommandMap[httpRequest];

	if not command then
		HttpManager.destroyHttpRequest(self,httpRequest);
		return;
	end

	HttpManager.destoryTimeoutAnim(self,command);
 
 	local errorCode = HttpErrorType.SUCCESSED;
 	local data = nil;
   	local resultStr = nil;
	repeat 
		-- 判断http请求的错误码,0--成功 ，非0--失败.
		-- 判断http请求的状态 , 200--成功 ，非200--失败.
		if 0 ~= httpRequest:getError() or 200 ~= httpRequest:getResponseCode() then
			errorCode = HttpErrorType.NETWORKERROR;
			break;
		end
	
		-- http 请求返回值
		resultStr =  httpRequest:getResponse();
		-- http 请求返回值的json 格式
		local json_data = json.mahjong_decode_node(resultStr);
		--返回错误json格式.
	    if not json_data then
	    	errorCode = HttpErrorType.JSONERROR;
			break;
	    end

	    data = json_data;
	until true;

    EventDispatcher.getInstance():dispatch(HttpManager.s_event, httpRequest.m_requestID, command, errorCode, data, resultStr);
	
	HttpManager.destroyHttpRequest(self,httpRequest);
end

TestHttpManager.createTimeoutAnim = function(self, requestID, command, timeoutTime)
	local timeoutAnim = new(AnimInt,kAnimRepeat,0,1,timeoutTime,-1);
	timeoutAnim:setDebugName("AnimInt | httpTimeoutAnim");
    timeoutAnim:setEvent({["obj"] = self, ["command"] = command, ["requestID"] = requestID},self.onTimeout);

    return timeoutAnim;
end

TestHttpManager.onTimeout = function(callbackObj)
	local self = callbackObj["obj"];
	local command = callbackObj["command"];
    local requestID = callbackObj["requestID"];
	EventDispatcher.getInstance():dispatch(HttpManager.s_event, requestID, command, HttpErrorType.TIMEOUT);

	HttpManager.destroyHttpRequest(self,self.m_commandHttpMap[command]);
end

