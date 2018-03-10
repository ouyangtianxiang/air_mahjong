FeeBackData = class();

FeeBackData.m_instance = nil;

FeeBackData.ctor = function ( self )
	-- body
	self.m_tipNum = 0;
end

FeeBackData.dtor = function( self )
	-- body
end

FeeBackData.getInstance = function ()
	-- body
	if not FeeBackData.m_instance then
		FeeBackData.m_instance =  new(FeeBackData);
	end
	return FeeBackData.m_instance;
end

FeeBackData.setFeeBackTipNum = function (self, num )
	-- body
	self.m_tipNum = num or 0;
end

FeeBackData.getFeeBackTipNum = function (self )
	-- body
	return self.m_tipNum or 0;
end