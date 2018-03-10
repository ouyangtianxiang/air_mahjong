-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
UploadDumpFile = class();
local kUploadUrl = "http://mvusspus01.boyaagame.com/report3.php";
local kDumpPath = "dump";
local kTimeOut = 5000;
local kAppId = 0;
local kUploadDumpFile = "uploadDumpFile";
local kDumpResponse = "uploadDumpFile_response";
local kCommonEvent = "CommonEvent";
local kError = "error";
local kId = "id";
local kJson = "json";

UploadDumpFile.s_objs = CreateTable("k");
UploadDumpFile.request_id = 0;

local function request_destroy(iRequestId)
    local key = getKey(iRequestId);
    dict_delete(key);
end

local function allocId()
    UploadDumpFile.request_id = UploadDumpFile.request_id + 1;
    return UploadDumpFile.request_id;
end

local function getKey(iRequestId)
    return string.format("dumpfile_request_%d", iRequestId or 0);
end

local function getFilePath()
    return sys_get_string(kDumpPath) or "";
end

local function defaultCallBack()
    sys_set_int("delete_dump",0);
end;

UploadDumpFile.ctor = function(self, appid, url, timeout, filePath)
    self.m_requestID = allocId();
    UploadDumpFile.s_objs[self.m_requestID] = self;
    self.m_requestUrl = url or kUploadUrl;
    self.m_filePath = filePath or getFilePath();
    self.m_timeout = timeout or kTimeOut;
    self.m_appId = appid or kAppId;
    self.m_eventCallback = { };
end

--请在wifi网络的情况下调用
UploadDumpFile.execute = function(self, isWifi)
    if not isWifi or System.getPlatform() ~= kPlatformAndroid then
        return;
    end
    if not self.m_appId or self.m_appId == 0 or self.m_filePath == "" then
        return;
    end

    local key = getKey(self.m_requestID);
    local info = { };
    info.appId = self.m_appId;
    info.url = self.m_requestUrl;
    info.filePath = self.m_filePath;
    info.timeout = self.m_timeout;
    info.time = os.date("%c");
    info.mimeType = "application/octet-stream";
    local json_data = json.encode(info);
    if json_data then
        dict_set_string(key, kJson, json_data);
    end
    dict_set_string(kCommonEvent, kCommonEvent, kUploadDumpFile);
    -- 调用方法
    dict_set_int(kUploadDumpFile, kId, self.m_requestID);
    -- 上传id
    call_native(kCommonEvent);
end


UploadDumpFile.setEvent = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

UploadDumpFile.dtor = function(self)
    request_destroy(self.m_requestID);
    self.m_requestID = nil;
end


function event_uploadDumpFile_response()
    local requestID = dict_get_int(kDumpResponse, kId, 0);
    local upload = UploadDumpFile.s_objs[requestID];
    -- 1: 上传成功， 0： 上传失败
    upload.m_error = dict_get_int(getKey(requestID), kError, -1);
    if upload and upload.m_eventCallback.func then
        upload.m_eventCallback.func(upload.m_eventCallback.obj, upload);
    end
    defaultCallBack();
end

UploadDumpFile.getTimeout = function(self)
    return self.m_timeout or 0;
end

UploadDumpFile.setTimeout = function(self, timeout)
    self.m_timeout = timeout;
end

UploadDumpFile.getFilePath = function(self)
    return self.m_filePath or "";
end

UploadDumpFile.setFilePath = function(self, filePath)
    self.m_filePath = filePath;
end

UploadDumpFile.getUrl = function(self)
    return self.m_requestUrl or "";
end

UploadDumpFile.setUrl = function(self, url)
    self.m_requestUrl = url;
end

UploadDumpFile.getAppId = function(self)
    return self.m_appId or 0;
end

UploadDumpFile.setAppId = function(self, appId)
    self.m_appId = appId;
end

UploadDumpFile.getError = function(self)
    return self.m_error or -1;
end

--[[
 local upload = new(UploadDumpFile, 10090);
    upload:setEvent(self,function (self, dump)-- self参数为obj, function 为 func 传进什么obj 回调的饿时候func的self就会传过来什么
        dict_set_int("upload","errors",dump:getError());
        dict_set_string("upload","filePath",dump:getFilePath());
        dict_set_string("upload","requestID",dump.m_requestID);
        dict_save("upload");
    end);
    upload:excute(true);
--]]

-- endregion
