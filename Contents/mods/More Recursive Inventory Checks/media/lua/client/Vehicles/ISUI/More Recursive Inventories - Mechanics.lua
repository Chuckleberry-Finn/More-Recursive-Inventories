require "Vehicles/ISUI/ISVehicleMechanics"

--- Unfortunately I had to overwrite these functions this way. May cause problems.
---Overwritten Functions: ISVehicleMechanics:doPartContextMenu, ISVehicleMechanics:doMenuTooltip

function ISVehicleMechanics:doMenuTooltip(part, option, lua, name)
    local vehicle = part:getVehicle();
    local tooltip = ISToolTip:new();
    tooltip:initialise();
    tooltip:setVisible(false);
    tooltip.description = getText("Tooltip_craft_Needs") .. " : <LINE>";
    option.toolTip = tooltip;
    local keyvalues = part:getTable(lua);

    -- repair engines tooltip
    if lua == "takeengineparts" then
        local rgb = " <RGB:1,1,1>";
        local addedTxt = "";
        if part:getCondition() < 10 then
            rgb = " <RGB:1,0,0>";
            addedTxt = "/10";
            tooltip.description = tooltip.description .. rgb .. " " .. getText("Tooltip_Vehicle_EngineCondition", part:getCondition() .. addedTxt) .. " <LINE>";
        end
        rgb = " <RGB:1,1,1>";
        if self.chr:getPerkLevel(Perks.Mechanics) < part:getVehicle():getScript():getEngineRepairLevel() then
            rgb = " <RGB:1,0,0>";
        end
        tooltip.description = tooltip.description .. rgb .. getText("IGUI_perks_Mechanics") .. " " .. self.chr:getPerkLevel(Perks.Mechanics) .. "/" .. part:getVehicle():getScript():getEngineRepairLevel() .. " <LINE>";
        rgb = " <RGB:1,1,1>";
        local item = InventoryItemFactory.CreateItem("Base.Wrench");

        if not self.chr:getInventory():contains("Wrench", true) then
            tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. item:getDisplayName() .. " 0/1 <LINE>";
        else
            tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. item:getDisplayName() .. " 1/1 <LINE>";
        end

        tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_TakeEnginePartsWarning");
    end
    if lua == "repairengine" then
        local rgb = " <RGB:1,1,1>";
        local addedTxt = "";
        if part:getCondition() >= 100 then
            tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_Vehicle_EngineCondition", part:getCondition()) .. " <LINE>";
        end
        rgb = " <RGB:1,1,1>";
        if self.chr:getPerkLevel(Perks.Mechanics) < part:getVehicle():getScript():getEngineRepairLevel() then
            rgb = " <RGB:1,0,0>";
        end
        tooltip.description = tooltip.description .. rgb .. getText("IGUI_perks_Mechanics") .. " " .. self.chr:getPerkLevel(Perks.Mechanics) .. "/" .. part:getVehicle():getScript():getEngineRepairLevel() .. " <LINE>";
        rgb = " <RGB:1,1,1>";
        local item = InventoryItemFactory.CreateItem("Base.Wrench");
        if not self.chr:getInventory():contains("Wrench", true) then
            tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. item:getDisplayName() .. " 0/1 <LINE>";
        else
            tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. item:getDisplayName() .. " 1/1 <LINE>";
        end
        local item = InventoryItemFactory.CreateItem("Base.EngineParts");
        if not self.chr:getInventory():contains("EngineParts", true) then
            tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. item:getDisplayName() .. " 0/1 <LINE>";
        else
            tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. item:getDisplayName() .. " <LINE>";
        end
    end
    if lua == "configheadlight" then
        local rgb = " <RGB:1,1,1>";
        tooltip.description = tooltip.description .. " <RGB:1,1,1> " .. getText("IGUI_HeadlightFocusing") .. ": " .. part:getLight():getFocusing() .. " <LINE>";
        --tooltip.description = tooltip.description .. " <RGB:1,0,0> Destination: " .. part:getLight():getDistanization() .. " <LINE>";
        --tooltip.description = tooltip.description .. " <RGB:1,0,0> Intensity: " .. part:getLight():getIntensity() .. " <LINE>";
        --rgb = " <RGB:1,1,1>";
        --local item = InventoryItemFactory.CreateItem("Base.Spanner");
        --if not self.chr:getInventory():contains("Spanner", true) then
        --	tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. item:getDisplayName() .. " 0/1 <LINE>";
        --else
        --	tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. item:getDisplayName() .. " 1/1 <LINE>";
        --end
        rgb = " <RGB:1,1,1>";
        if self.chr:getPerkLevel(Perks.Mechanics) < part:getVehicle():getScript():getHeadlightConfigLevel() then
            rgb = " <RGB:1,0,0>";
        end
        tooltip.description = tooltip.description .. rgb .. " Mechanic Skill: " .. self.chr:getPerkLevel(Perks.Mechanics) .. "/" .. part:getVehicle():getScript():getHeadlightConfigLevel() .. " <LINE>";
    end

    -- do you need the key to operate
    if VehicleUtils.RequiredKeyNotFound(part, self.chr) then
        tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_keyRequired") .. " <LINE>";
    end

    if not keyvalues then return; end
    --	if not part:getInventoryItem() then return; end
    if not part:getItemType() then return; end
    local typeToItem = VehicleUtils.getItems(self.playerNum);
    -- first do items required
    if name then
        local item = InventoryItemFactory.CreateItem(name);
        if not typeToItem[name] then
            tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. item:getDisplayName() .. " 0/1 <LINE>";
        else
            tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. item:getDisplayName() .. " 1/1 <LINE>";
        end
    end
    if keyvalues.items then
        for i,v in pairs(keyvalues.items) do
            local itemName = InventoryItemFactory.CreateItem(v.type);
            if itemName then
                itemName = itemName:getName();
            else
                itemName = v.type;
            end
            local keep = "";
            --		if v.keep then keep = "Keep "; end
            if not typeToItem[v.type] then
                tooltip.description = tooltip.description .. " <RGB:1,0,0>" .. keep .. itemName .. " 0/1 <LINE>";
            else
                tooltip.description = tooltip.description .. " <RGB:1,1,1>" .. keep .. itemName .. " 1/1 <LINE>";
            end
        end
    end
    -- recipes
    if keyvalues.recipes and keyvalues.recipes ~= "" then
        for _,recipe in ipairs(keyvalues.recipes:split(";")) do
            if not self.chr:isRecipeKnown(recipe) then
                tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireRecipe", getRecipeDisplayName(recipe)) .. " <LINE>";
            else
                tooltip.description = tooltip.description .. " <RGB:1,1,1> " .. getText("Tooltip_vehicle_requireRecipe", getRecipeDisplayName(recipe)) .. " <LINE>";
            end
        end
    end
    -- uninstall stuff
    if keyvalues.requireUninstalled and (vehicle:getPartById(keyvalues.requireUninstalled) and vehicle:getPartById(keyvalues.requireUninstalled):getInventoryItem()) then
        tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireUnistalled", getText("IGUI_VehiclePart" .. keyvalues.requireUninstalled)) .. " <LINE>";
    end
    local seatNumber = part:getContainerSeatNumber()
    local seatOccupied = (seatNumber ~= -1) and vehicle:isSeatOccupied(seatNumber)
    if keyvalues.requireEmpty and (round(part:getContainerContentAmount(), 3) > 0 or seatOccupied) then
        tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_needempty", getText("IGUI_VehiclePart" .. part:getId())) .. " <LINE> ";
    end
    -- install stuff
    if keyvalues.requireInstalled then
        local split = keyvalues.requireInstalled:split(";");
        for i,v in ipairs(split) do
            if not vehicle:getPartById(v) or not vehicle:getPartById(v):getInventoryItem() then
                tooltip.description = tooltip.description .. " <RGB:1,0,0> " .. getText("Tooltip_vehicle_requireInstalled", getText("IGUI_VehiclePart" .. v)) .. " <LINE>";
            end
        end
    end
    -- now required skill
    local perks = keyvalues.skills;
    if perks and perks ~= "" then
        for _,perk in ipairs(perks:split(";")) do
            local name,level = VehicleUtils.split(perk, ":")
            local rgb = " <RGB:1,1,1> ";
            tooltip.description = tooltip.description .. rgb .. getText("Tooltip_vehicle_recommendedSkill", getText("IGUI_perks_" .. name), self.chr:getPerkLevel(Perks.FromString(name)) .. "/" .. level) .. " <LINE> <LINE>";
        end
    end
    -- install/uninstall success/failure chances
    local perks = keyvalues.skills;
    local success, failure = VehicleUtils.calculateInstallationSuccess(perks, self.chr);
    if success < 100 and failure > 0 then
        local colorSuccess = "<GREEN>";
        if success < 65 then
            colorSuccess = "<ORANGE>";
        end
        if success < 25 then
            colorSuccess = "<RED>";
        end
        local colorFailure = "<GREEN>";
        if failure > 30 then
            colorFailure = "<ORANGE>";
        end
        if failure > 60 then
            colorFailure = "<RED>";
        end
        tooltip.description = tooltip.description .. colorSuccess .. getText("Tooltip_chanceSuccess") .. " " .. success .. "% <LINE> " .. colorFailure .. getText("Tooltip_chanceFailure") .. " " .. failure .. "%";
    end
    if part:getItemType() and not part:getItemType():isEmpty() then
        if part:getInventoryItem() then
            local fixingList = FixingManager.getFixes(part:getInventoryItem());
            if not part:getScriptPart():isRepairMechanic() and not fixingList:isEmpty() then
                tooltip.description = tooltip.description .. " <LINE> <RGB:1,1,1>" .. getText("Tooltip_RepairableUninstalled");
            end
        end
    end
end


function ISVehicleMechanics:doPartContextMenu(part, x,y)
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then return; end

    local playerObj = getSpecificPlayer(self.playerNum);
    self.context = ISContextMenu.get(self.playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
    local option;

    if part:getItemType() and not part:getItemType():isEmpty() then
        if part:getInventoryItem() then
            local fixingList = FixingManager.getFixes(part:getInventoryItem());
            if part:getScriptPart():isRepairMechanic() and not fixingList:isEmpty() then
                local fixOption = self.context:addOption(getText("ContextMenu_Repair"), nil, nil);
                local subMenuFix = ISContextMenu:getNew(self.context);
                self.context:addSubMenu(fixOption, subMenuFix);
                for i=0,fixingList:size()-1 do
                    ISInventoryPaneContextMenu.buildFixingMenu(part:getInventoryItem(), playerObj:getPlayerNum(), fixingList:get(i), fixOption, subMenuFix, part)
                end
            end

            if part:getTable("uninstall") then
                option = self.context:addOption(getText("IGUI_Uninstall"), playerObj, ISVehiclePartMenu.onUninstallPart, part)
                self:doMenuTooltip(part, option, "uninstall");
                if not ISVehicleMechanics.cheat and not part:getVehicle():canUninstallPart(playerObj, part) then
                    option.notAvailable = true;
                end
            end
        else
            if part:getTable("install") then
                option = self.context:addOption(getText("IGUI_Install"), playerObj, nil)
                if not ISVehicleMechanics.cheat and not part:getVehicle():canInstallPart(playerObj, part) then
                    option.notAvailable = true;
                    self:doMenuTooltip(part, option, "install", nil);
                else
                    local subMenu = ISContextMenu:getNew(self.context);
                    self.context:addSubMenu(option, subMenu);
                    local typeToItem = VehicleUtils.getItems(self.chr:getPlayerNum())
                    -- display all possible item that can be installed
                    for i=0,part:getItemType():size() - 1 do
                        local name = part:getItemType():get(i);
                        local item = InventoryItemFactory.CreateItem(name);
                        if item then name = item:getName(); end
                        local itemOpt = subMenu:addOption(name, playerObj, nil);
                        self:doMenuTooltip(part, itemOpt, "install", part:getItemType():get(i));
                        if not typeToItem[part:getItemType():get(i)] then
                            itemOpt.notAvailable = true;
                        else
                            -- display every item the player posess
                            local subMenuItem = ISContextMenu:getNew(subMenu);
                            self.context:addSubMenu(itemOpt, subMenuItem);
                            for j,v in ipairs(typeToItem[part:getItemType():get(i)]) do
                                local itemOpt = subMenuItem:addOption(v:getDisplayName() .. " (" .. v:getCondition() .. "%)", playerObj, ISVehiclePartMenu.onInstallPart, part, v);
                                self:doMenuTooltip(part, itemOpt, "install", part:getItemType():get(i));
                            end
                        end
                    end
                end
            end
        end
    end

    if part:getWindow() and (not part:getItemType() or part:getInventoryItem()) then
        local window = part:getWindow()
        if window:isOpenable() and not window:isDestroyed() and playerObj:getVehicle() then
            if window:isOpen() then
                option = self.context:addOption(getText("ContextMenu_Close_window"), playerObj, ISVehiclePartMenu.onOpenCloseWindow, part, false)
            else
                option = self.context:addOption(getText("ContextMenu_Open_window"), playerObj, ISVehiclePartMenu.onOpenCloseWindow, part, true)
            end
        end
        if not window:isDestroyed() then
            option = self.context:addOption(getText("ContextMenu_Smash_window"), playerObj, ISVehiclePartMenu.onSmashWindow, part)
        end
    end

    if part:isContainer() and part:getContainerContentType() == "Air" and part:getInventoryItem() then
        option = self.context:addOption(getText("IGUI_InflateTire"), playerObj, ISVehiclePartMenu.onInflateTire, part)
        if part:getContainerContentAmount() >= part:getContainerCapacity() + 5 then
            option.notAvailable = true
        end
        local tirePump = InventoryItemFactory.CreateItem("Base.TirePump");
        if not self.chr:getInventory():contains("TirePump", true) then
            option.notAvailable = true
            local tooltip = ISToolTip:new();
            tooltip:initialise();
            tooltip:setVisible(false);
            tooltip.description = "<RGB:1,0,0> " .. getText("Tooltip_craft_Needs") .. ": <LINE> " .. tirePump:getDisplayName() .. " 0/1";
            option.toolTip = tooltip;
        else
            local tooltip = ISToolTip:new();
            tooltip:initialise();
            tooltip:setVisible(false);
            tooltip.description = "<RGB:1,1,1> " .. getText("Tooltip_craft_Needs") .. ":  <LINE> " .. tirePump:getDisplayName() .. " 1/1";
            option.toolTip = tooltip;
        end
        option = self.context:addOption(getText("IGUI_DeflateTire"), playerObj, ISVehiclePartMenu.onDeflateTire, part)
        if part:getContainerContentAmount() == 0 then
            option.notAvailable = true
        end
    end
    local condInfo = getTextOrNull("IGUI_Vehicle_CondInfo" .. part:getId());
    if condInfo then
        option = self.context:addOption(getText("ContextMenu_PartInfo"), playerObj, nil)
        local tooltip = ISToolTip:new();
        tooltip:initialise();
        tooltip:setVisible(false);
        tooltip.description = condInfo;
        option.toolTip = tooltip;
    end

    if part:getId() == "Engine" then

        if VehicleUtils.RequiredKeyNotFound(part, self.chr) then
            option = self.context:addOption(getText("GameSound_VehicleDoorIsLocked"), nil, nil);
            self:doMenuTooltip(part, option, "takeengineparts");
            option.notAvailable = true;

        else
            if part:getCondition() > 10 and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getEngineRepairLevel() and self.chr:getInventory():contains("Wrench", true) then
                option = self.context:addOption(getText("IGUI_TakeEngineParts"), playerObj, ISVehicleMechanics.onTakeEngineParts, part);
                self:doMenuTooltip(part, option, "takeengineparts");
            else
                option = self.context:addOption(getText("IGUI_TakeEngineParts"), nil, nil);
                self:doMenuTooltip(part, option, "takeengineparts");
                option.notAvailable = true;
            end
            if part:getCondition() < 100 and self.chr:getInventory():getNumberOfItem("EngineParts", false, true) > 0 and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getEngineRepairLevel() and self.chr:getInventory():contains("Wrench", true) then
                local option = self.context:addOption(getText("IGUI_RepairEngine"), playerObj, ISVehicleMechanics.onRepairEngine, part);
                self:doMenuTooltip(part, option, "repairengine");
            else
                local option = self.context:addOption(getText("IGUI_RepairEngine"), playerObj, ISVehicleMechanics.onRepairEngine, part);
                self:doMenuTooltip(part, option, "repairengine");
                option.notAvailable = true;
            end
        end
    end
    --[[
        if ((part:getId() == "HeadlightLeft") or (part:getId() == "HeadlightRight")) and part:getInventoryItem() then
            if part:getLight():canFocusingUp() and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getHeadlightConfigLevel() then
            --if part:getLight():canFocusingUp() and self.chr:getInventory():contains("Spanner") then
                option = self.context:addOption(getText("IGUI_HeadlightFocusingUp"), playerObj, ISVehicleMechanics.onConfigHeadlight, part, 1);
                self:doMenuTooltip(part, option, "configheadlight");
            else
                option = self.context:addOption(getText("IGUI_HeadlightFocusingUp"), nil, nil);
                self:doMenuTooltip(part, option, "configheadlight");
                option.notAvailable = true;
            end
            if part:getLight():canFocusingDown() and self.chr:getPerkLevel(Perks.Mechanics) >= part:getVehicle():getScript():getHeadlightConfigLevel() then
            --if part:getLight():canFocusingDown() and self.chr:getInventory():contains("Spanner") then
                option = self.context:addOption(getText("IGUI_HeadlightFocusingDown"), playerObj, ISVehicleMechanics.onConfigHeadlight, part, -1);
                self:doMenuTooltip(part, option, "configheadlight");
            else
                option = self.context:addOption(getText("IGUI_HeadlightFocusingDown"), nil, nil);
                self:doMenuTooltip(part, option, "configheadlight");
                option.notAvailable = true;
            end
        end
    --]]
    if ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= "None" then
        if self.vehicle:getPartById("Engine") then
            option = self.context:addOption("CHEAT: Get Key", playerObj, ISVehicleMechanics.onCheatGetKey, self.vehicle)
            if self.vehicle:isHotwired() then
                self.context:addOption("CHEAT: Remove Hotwire", playerObj, ISVehicleMechanics.onCheatHotwire, self.vehicle, false, false)
                --[[
                if self.vehicle:isHotwiredBroken() then
                    self.context:addOption("CHEAT: Fix Broken Hotwire", playerObj, ISVehicleMechanics.onCheatHotwire, self.vehicle, true, false)
                else
                    self.context:addOption("CHEAT: Break Hotwire", playerObj, ISVehicleMechanics.onCheatHotwire, self.vehicle, true, true)
                end
                --]]
            else
                self.context:addOption("CHEAT: Hotwire", playerObj, ISVehicleMechanics.onCheatHotwire, self.vehicle, true, false)
            end
        end
        option = self.context:addOption("CHEAT: Repair Part", playerObj, ISVehicleMechanics.onCheatRepairPart, part)
        option = self.context:addOption("CHEAT: Repair Vehicle", playerObj, ISVehicleMechanics.onCheatRepair, self.vehicle)
        option = self.context:addOption("CHEAT: Set Rust", playerObj, ISVehicleMechanics.onCheatSetRust, self.vehicle)
        option = self.context:addOption("CHEAT: Set Part Condition", playerObj, ISVehicleMechanics.onCheatSetCondition, part)
        if part:isContainer() and part:getContainerContentType() then
            option = self.context:addOption("CHEAT: Set Content Amount", playerObj, ISVehicleMechanics.onCheatSetContentAmount, part)
        end
        option = self.context:addOption("CHEAT: Remove Vehicle", playerObj, ISVehicleMechanics.onCheatRemove, self.vehicle)
    end
    if getDebug() then
        if ISVehicleMechanics.cheat then
            self.context:addOption("DBG: ISVehicleMechanics.cheat=false", playerObj, ISVehicleMechanics.onCheatToggle)
        else
            self.context:addOption("DBG: ISVehicleMechanics.cheat=true", playerObj, ISVehicleMechanics.onCheatToggle)
        end
    end

    if self.context.numOptions == 1 then self.context:setVisible(false) end

    if JoypadState.players[self.playerNum+1] and self.context:getIsVisible() then
        self.context.mouseOver = 1
        self.context.origin = self
        JoypadState.players[self.playerNum+1].focus = self.context
        updateJoypadFocus(JoypadState.players[self.playerNum+1])
    end
end