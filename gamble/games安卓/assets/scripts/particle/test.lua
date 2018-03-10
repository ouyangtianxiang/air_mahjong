local moneyNode = ParticleSystem.getInstance():create(money_pin_map,ParticleMoney,0,0,nil
    ,kParticleTypeBlast,(num or 1000),
    {["h"] = System.getScreenHeight()/2,
    ["w"] = System.getScreenWidth();["rotation"]=4;["scale"]=1;["maxIndex"]=7;});

local fireNode = ParticleSystem.getInstance():create("particle.png",ParticleFireWork,
    0,0,{{0}},kParticleTypeForever,200,{["h"] = parHeight,["w"] = parWidth;});
local flowerNode = ParticleSystem.getInstance():create("flower.png",ParticleFlower,
    0,0,nil,kParticleTypeForever,40,{["h"] = 240*System.getLayoutScale(),["w"] = 440*System.getLayoutScale();["rotation"]=3;});

ParticleSystem.getInstance():create("games/common/animation/messagefly/star.png", ParticleTail,
 0, 0,nil,kParticleTypeForever,100,{["h"] = 50,["w"] = 100;["scale"]=1;["direction"]=4});
AnimGameOver.winCountLightNode = ParticleSystem.getInstance():create("games/common/game_result/light_point.png",ParticleDrop,
    0,0,{{0}},kParticleTypeBlast,600,{["h"] = AnimGameOver.scaleHeight/2,["w"] = AnimGameOver.scaleWidth,["nodeW"]=AnimGameOver.scaleWidth;});
