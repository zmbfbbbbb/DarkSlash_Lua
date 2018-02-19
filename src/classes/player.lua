
local player =class("player")

function player:ctor()
end
function player:init(node,game)
    self.game = game

    --添加事件监听
    self.node = node
    local function onSceneEvent(event)  
        if event == "enter" then
           self:enter(game)
        elseif event == "enterTransitionFinish" then

           self:entertransitionfinish()

        elseif event == "exit" then

           self:exit()

        elseif event == "exitTransitionStart" then

           self:exittransitionstart()

        elseif event == "cleanup" then

           self:cleanup()

        end
    end
    node:registerScriptHandler(onSceneEvent)
end
function player:enter()
    self:initData();
end
function player:entertransitionfinish()
    ----开启update函数 
    local function handler(interval)
         self:update(interval)
    end
    self.node:scheduleUpdateWithPriorityLua(handler,0)
end
function player:update(dt)
    
end
function player:exit()

end
function player:exittransitionstart()

end
function player:cleanup()

end
function player:initData(game)
    self.fxTrail = self.node:getChildByName("trail")
    self.spArrow = self.node:getChildByName("arrow")
    self.sfAtkDirs = {
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_u.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_66_up.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_45_up.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_22_up.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_r.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_22_down.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_45_down.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_45_down.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_66_down.png'),
        cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_attack_d.png'),
   }
    self.attachPoints = {
        cc.p(3.6,88.2),
        cc.p(23,89.6),
        cc.p(33.2,79.3),
        cc.p(38.3,64.2),
        cc.p(47.5,46.4),
        cc.p(34.8,15.8),
        cc.p(30.7,1.5),
        cc.p(20,0.9),
        cc.p(-3.5,1.9)
    }
    self.sfPostAtks = {cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_stand_u.png'),cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_stand_r.png'),cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_stand_d.png')}
    self.spPlayer = self.node:getChildByName("sprite")
    self.spSlash = self.node:getChildByName("sprite"):getChildByName("slash")
    self.hurtRadius = 30
    self.touchThreshold =  0.3
    self.touchMoveThreshold = 50
    self.atkDist =  300
    self.atkDuration = 0.2
    self.atkStun = 0.1
    self.invincible = false
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("creator/atlas/player.plist","creator/atlas/player.png")
    --local test = cc.SpriteFrameCache:getInstance():getSpriteFrame('p1_stand_u.png')
   -- print(11111)
    --print(test)
   -- print(self.sfPostAtks[1],self.sfPostAtks[2],self.sfPostAtks[3])

    self.anim = self.node:getChildByName("sprite")
    self.inputEnabled = false;
    self.isAttacking = false;
    self.isAlive = true;
    self.nextPoseSF = null;
    self:registerInput();
    
    self.spArrow:setVisible(false)
    self.atkTargetPos = cc.p(0,0);
    self.isAtkGoingOut = false;
    --待测试
    self.validAtkRect = cc.rect(25, 25, (self.node:getParent():getBoundingBox().width- 50), (self.node:getParent():getBoundingBox().height - 50));
    
    self.oneSlashKills = 0;
    --animationManager:playAnimationClip(menuAnim,"menuAnim")
end
function player:registerInput()
      local listener = cc.EventListenerTouchOneByOne:create(); 
      listener:registerScriptHandler(function(touch,event)
--       if self.inputEnabled == false
--       then
--          return false;
--       end
         local touchLoc = touch:getLocation()
         self.touchBeganLoc = touchLoc
         self.moveToPos = self.node:getParent():convertToNodeSpaceAR(touchLoc)
         self.touchStartTime = socket.gettime()
         return true
      end,cc.Handler.EVENT_TOUCH_BEGAN); 
      listener:registerScriptHandler(function(touch,event)
--         if self.inputEnabled == false
--         then
--             return
--         end
         local touchLoc = touch:getLocation()
         self.spArrow:setVisible(true)
         self.moveToPos = self.node:getParent():convertToNodeSpaceAR(touchLoc)
         if cc.pGetDistance(self.touchBeganLoc, touchLoc) > self.touchMoveThreshold
         then
              self.hasMoved = true
         end


      end,cc.Handler.EVENT_TOUCH_MOVED); 
      listener:registerScriptHandler(function(touch,event)
--         if self.inputEnabled == false 
--         then
--             return
--         end
           self.spArrow:setVisible(true)
           self.moveToPos = null;
           local isHold = self:isTouchHold()
           if not self.hasMoved and not isHold 
           then
              local touchLoc = touch:getLocation();
              local atkPos = self.node:getParent():convertToNodeSpaceAR(touchLoc)
              local atkDir = cc.pSub(atkPos, cc.p(self.node:getPosition()));
             
            
              self.atkTargetPos = cc.pAdd(cc.p(self.node:getPosition()), self:pMult(cc.pNormalize(atkDir), self.atkDist) );
              
              local atkPosWorld = self.node:getParent():convertToWorldSpaceAR(self.atkTargetPos);
                    if not cc.rectContainsPoint(self.validAtkRect, atkPosWorld) 
                    then
                        self.isAtkGoingOut = true;
                    else 
                        self.isAtkGoingOut = false;
                    end
                    --self.node.emit('freeze');
                    self.oneSlashKills = 0;
                    self:attackOnTarget(atkDir, self.atkTargetPos);
            end
            self.hasMoved = false;
      end,cc.Handler.EVENT_TOUCH_ENDED);
      listener:registerScriptHandler(function(touch,event)
      
      end,cc.Handler.EVENT_TOUCH_CANCELLED);
     
      cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self.node)
end
function player:pMult(point, floatVar)
    return cc.p(point.x * floatVar, point.y * floatVar)
end
function player:isTouchHold()
     local timeDiff = socket.gettime() - self.touchStartTime;
     return ( timeDiff >= self.touchThreshold);
end
--返回两个向量之间带正负号的弧度
function player:pAngleSigned(a, b)
    local a2 = cc.pNormalize(a)
    local b2 = cc.pNormalize(b)
    local angle = math.atan2(a2.x * b2.y - a2.y * b2.x, cc.pDot(a2, b2))
    if math.abs(angle) < tonumber('1.192092896e-07')
    then
        return 0.0
    end
    return angle
end
function player:radiansToDegrees(angle)
     return angle * (180 /math.pi)
end
function player:attackOnTarget (atkDir, targetPos)
       local deg = player:radiansToDegrees(self:pAngleSigned(cc.p(0, 1), cc.p(atkDir)))
       local angleDivider = {0, 12, 35, 56, 79, 101, 124, 146, 168, 180};
       local slashPos = null;
       local getAtkSF = function(mag, sfAtkDirs)
            local atkSF = null;
            for i = 1, table.getn(angleDivider),1 do
                local min = angleDivider[i - 1];
                local max = angleDivider[i];
                if mag <= max and mag > min
                then
                    atkSF = sfAtkDirs[i - 1];
                    self.nextPoseSF = self.sfPostAtks[math.floor(( i - 1 )/3)];
                    slashPos = self.attachPoints[i - 1];
                    return atkSF;
                end
            end
            if atkSF == null
            then
                print('cannot find correct attack pose sprite frame! mag: ' + mag);
                return null;
            end
        end

        local mag = math.abs(deg);
        if deg <= 0
        then
            self.spPlayer:setScaleX(1)
            self.spPlayer:setSpriteFrame(getAtkSF(mag, self.sfAtkDirs))
            --self.spPlayer.spriteFrame = getAtkSF(mag, self.sfAtkDirs);
         else 
            self.spPlayer:setScaleX(-1)
            self.spPlayer:setSpriteFrame(getAtkSF(mag, self.sfAtkDirs))
           -- self.spPlayer.spriteFrame = getAtkSF(mag, self.sfAtkDirs);
         end

        local moveAction = cc.moveTo(self.atkDuration, targetPos).easing(cc.easeQuinticActionOut());
        local delay = cc.delayTime(self.atkStun);
        local callback = cc.callFunc(self.onAtkFinished, self);
        self.node:runAction(cc.sequence(moveAction, delay, callback));
        self.spSlash:setPosition(slashPos)
        self.spSlash:setRotation(mag)
        self.spSlash.enabled = true;
        self.spSlash.getComponent(cc.Animation).play('slash');
        self.inputEnabled = false;
        self.isAttacking = true;
end

return player

