MobileBaseCheck = {};

-- 1审核状态，其他值表示非审核状态
MobileBaseCheck.isChecking=1;

function MobileBaseCheck.setCheckState()
	if DEBUGMODE == 1 then
		MobileBaseCheck.isChecking=0;
	end
	local params = {};
	params.isChecking = MobileBaseCheck.isChecking;
	native_to_java( kSetMobileBaseCheck, json.encode(params) );
end
