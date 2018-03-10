--require("common/animFactory");
--require("common/uiFactory");
require("particle/particleSystem");
require("particle/particleMoney");

--金币掉落动画
AnimationDropCoins = class();

AnimationDropCoins.isPlaying = false;
AnimationDropCoins.durTime = 4;
AnimationDropCoins.coinNum = 36;	--金币数




AnimationDropCoins.play = function()
	DebugLog("【socket通知所有界面更新金币】");
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent);
	local coinRainPin_map = require("qnPlist/coinRainPin")

	local particleMoney = ParticleSystem.getInstance():create(coinRainPin_map,
		ParticleMoney,0,0,nil,kParticleTypeBlast,30,
		{["h"] = System.getScreenHeight()/3*2,
		["w"] = System.getScreenWidth();["rotation"]=4;["scale"]=1;["maxIndex"]=7;});
    Clock.instance():schedule_once(function()
        particleMoney:resume();
        GameEffect.getInstance():play("AudioGetGold");
    end)
	
    particleMoney:setPos(-50,-50);
	particleMoney:addToRoot();
	
end


-----------旧动画接口(已停用)-------------------
AnimationDropCoins.ctor = function()
	
end

AnimationDropCoins.stop = function()

end

AnimationDropCoins.dtor = function()
	
end

