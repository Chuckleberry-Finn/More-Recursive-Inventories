require "Hotbar/ISHotbar"
--lua/client/Hotbar/ISHotbar.lua

---plugs into getAllEvalRecurse
function ISHotbar.isValidForHotbar(item)
	if not item then return false end
	if item:getAttachmentType() and item:getCondition() > 0 then return true end
	return false
end

ISHotbar.onKeyKeepPressed = function(key)
	local playerObj = getSpecificPlayer(0)
	if not getPlayerHotbar(0) or not playerObj or playerObj:isDead() then
		return
	end
	if UIManager.getSpeedControls() and (UIManager.getSpeedControls():getCurrentGameSpeed() == 0) then
		return
	end
	if JoypadState.players[1] then
		return
	end
	if playerObj:isAttacking() then
		return
	end
	local queue = ISTimedActionQueue.queues[playerObj]
	if queue and #queue.queue > 0 then
		return
	end
	if getPlayerHotbar(0).radialWasVisible then
		return
	end
	local self = getPlayerHotbar(0);
	local slotToCheck = self:getSlotForKey(key)
	if slotToCheck == -1 then
		return
	end
	local radialMenu = getPlayerRadialMenu(0)
	if self.availableSlot[slotToCheck] and (getTimestampMs() - self.keyPressedMS > 500) and not radialMenu:isReallyVisible() then
		radialMenu:clear()

		----// Changes for recursive checks here
		local inv = playerObj:getInventory():getAllEvalRecurse(ISHotbar.isValidForHotbar)--getItems()

		for i=1,inv:size() do
			local item = inv:get(i-1)
			if (not self:isItemAttached(item)) and self.replacements[item:getAttachmentType()] ~= "null" then
				local slot = self.availableSlot[slotToCheck]
				local slotDef = slot.def
				for type,v in pairs(slotDef.attachments) do
					if item:getAttachmentType() == type then
						radialMenu:addSlice(item:getDisplayName(), item:getTex(), ISHotbar.onRadialAttach, self, item, slotToCheck, v)
						break
					end
				end
			end
		end
		if self.attachedItems[slotToCheck] then
			local item = self.attachedItems[slotToCheck]
			radialMenu:addSlice(getText("ContextMenu_HotbarRadialRemove", item:getDisplayName()), getTexture("media/ui/ZoomOut.png"), ISHotbar.onRadialRemove, self, item)
		end
		radialMenu:setX(getPlayerScreenLeft(0) + getPlayerScreenWidth(0) / 2 - radialMenu:getWidth() / 2)
		radialMenu:setY(getPlayerScreenTop(0) + getPlayerScreenHeight(0) / 2 - radialMenu:getHeight() / 2)
		radialMenu:addToUIManager()
	end
end