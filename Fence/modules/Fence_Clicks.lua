if Fence:HasModule('Clicks') then return end

local L = AceLibrary("AceLocale-2.2"):new("Fence_Clicks")
local l = AceLibrary("AceLocale-2.2"):new("Fence")

-- Localization
L:RegisterTranslations("enUS", function() 
	return {
		["Clicks"] = true,
        ["Toggle click options for all available modules."] = true,
		["Fill"] = true,
		["Search"] = true,		
		["Split"] = true,
		["Trade"] = true,		
	}
end)

L:RegisterTranslations("deDE", function()
	return {
		["Clicks"] = "Klicks",
        ["Toggle click options for all available modules."] = "Mausklick Funktionen f\195\188r die verf\195\188gbaren Module.",
		["Fill"] = "Ausf\195\188llen",
		["Search"] = "Suchen",
		["Split"] = "Teilen",
		["Trade"] = "Trade",
	}
end)

L:RegisterTranslations("zhTW", function() 
	return {
		["Clicks"] = "點擊",
        ["Toggle click options for all available modules."] = "為所有模組切換點擊選項。\n|cffeda55fAlt-左擊: |r增加物品到拍賣視窗/交易視窗。\n|cffeda55fAlt-Shift-左擊: |r增加物品到拍賣視窗並開始拍賣。\n|cffeda55fCtrl-右擊: |r在拍賣場搜尋物品。\n|cffeda55fAlt-右擊: |r分開並拿起一件物品。\n|cffeda55fShift-右擊: |r分開並拿起一半物品。",
		["Fill"] = "填寫",
		["Search"] = "搜尋",		
		["Split"] = "分開",
		["Trade"] = "交易",		
	}
end)

L:RegisterTranslations("zhCN", function() 
	return {
		["Clicks"] = "点击",
        ["Toggle click options for all available modules."] = "为所有的模块开启/关闭点击设置。",
		["Fill"] = "填充",
		["Search"] = "搜索",		
		["Split"] = "分列",
		["Trade"] = "交易",		
	}
end)

local mod = Fence:NewModule("Clicks")
Fence:RegisterDefaults('Clicks', 'profile', {
    ['*'] = true
    })

mod.db = Fence:AcquireDBNamespace("Clicks")

    
	function mod:OnInitialize()

        Fence.options.args.clicks = {
			type = 'group',
			name = L["Clicks"],
			desc = L["Toggle click options for all available modules."],
				args = {
					toggle = {
						type = 'toggle',
						name = L["Clicks"],
						desc = string.format(l["Toggles %s function."], L["Clicks"]),
						get = function() return Fence:IsModuleActive("Clicks") end,
						set = function(v) Fence:ToggleModuleActive("Clicks", v) end
					},
					fill = {
                        hidden = function() return not self:ModCheck('AutoFill') end,
						type = 'toggle',
						name = L["Fill"],
						desc = string.format(l["Toggles %s function."], L["Fill"]),
						get = function() return self.db.profile.Fill end,
						set = function(v) self.db.profile.Fill = v end
					},
					search = {
                        hidden = function() return not self:ModCheck('Search') end,
						type = 'toggle',
						name = L["Search"],
						desc = string.format(l["Toggles %s function."], L["Search"]),
						get = function() return self.db.profile.Search end,
						set = function(v) self.db.profile.Search = v end
					},
					split = {
						type = 'toggle',
						name = L["Split"],
						desc = string.format(l["Toggles %s function."], L["Split"]),
						get = function() return self.db.profile.Split end,
						set = function(v) self.db.profile.Split = v end
					},
					trade = {
						type = 'toggle',
						name = L["Trade"],
						desc = string.format(l["Toggles %s function."], L["Trade"]),
						get = function() return self.db.profile.Trade end,
						set = function(v) self.db.profile.Trade = v end
					},
				}
		}
	end

	function mod:OnEnable()
		self:SecureHook("ContainerFrameItemButton_OnModifiedClick")

	end
	
	function mod:OnDisable()
		if self:IsHooked("ContainerFrameItemButton_OnModifiedClick") then self:Unhook("ContainerFrameItemButton_OnModifiedClick") end
	end

    function mod:ModCheck(mod)
        if Fence:HasModule(mod) and Fence:IsModuleActive(mod) then return true end
    end

	function mod:ContainerFrameItemButton_OnModifiedClick(...)
		local bag, item = this:GetParent():GetID(), this:GetID()
        if not CursorHasItem() and GetContainerItemLink(bag, item) then
            if AuctionFrame and AuctionFrame:IsVisible() then
                if (...) == "LeftButton" and IsAltKeyDown() and self:ModCheck('AutoFill') and self.db.profile.Fill then
                    if IsShiftKeyDown() then
                        Fence:GetModule('AutoFill'):ClickAuction(bag, item, true)
                    else
                        Fence:GetModule('AutoFill'):ClickAuction(bag, item)
                    end
                elseif (...) == "RightButton" then 
                    if IsControlKeyDown() and self:ModCheck('Search') and self.db.profile.Search then 
                        Fence:GetModule('Search'):Search(GetContainerItemLink(bag, item))
                    end
                    if IsAltKeyDown() and self.db.profile.Split then self:Splitter(bag, item, 1) end
                    if IsShiftKeyDown() and self.db.profile.Split then self:Splitter(bag, item) end
                end
            elseif TradeFrame:IsVisible() and (...) == "LeftButton" and IsAltKeyDown() and self.db.profile.Trade then
                PickupContainerItem(bag, item)
                local slot = TradeFrame_GetAvailableSlot()
                if slot then ClickTradeButton(slot) end
            elseif (...) == "RightButton" then 
                if IsAltKeyDown() and self.db.profile.Split then self:Splitter(bag, item, 1) end
                if IsShiftKeyDown() and self.db.profile.Split then self:Splitter(bag, item) end
            end
        end
	end
	 
	function mod:Splitter(bag, item, amount)
        if not amount then 
            local _, count =  GetContainerItemInfo(bag, item)
            amount = floor(count/2)
        end
		SplitContainerItem(bag, item, amount)
		for Bag=0,4 do
			for slot=1, GetContainerNumSlots(Bag) do
				if not GetContainerItemLink(Bag, slot) then	PickupContainerItem(Bag, slot) return end
			end
		end
	end