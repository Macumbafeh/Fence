if Fence:HasModule('AutoFill') then return end

local L = AceLibrary("AceLocale-2.2"):new("Fence_AutoFill")
local l = AceLibrary("AceLocale-2.2"):new("Fence")

-- Localization
L:RegisterTranslations("enUS", function() 
	return {
		["Auto-Fill"] = true,
		["Auto-Fill - automatically inserts known auction prices"] = true,
		["Auction Runtime"] = true,
		["Sets default auction runtime."] = true,
		["Remembers last used auction runtime."] = true,
		["%s now set to %s hours."] = true,
		["Type in 12, 24 or 48"] = true,
		["Duration"] = true,
		["Auto-Buyout"] = true,
		["Markup"] = true,
		["Sets markup for auto-buy function."] = true,
		["Auto-fills buyout * customized markup if no price informations are available."] = true,
		["Auto-Search"] = true,
		["Performs auto-search on items you want to sell."] = true,
	}
end)

L:RegisterTranslations("deDE", function() 
	return {
		["Auto-Fill"] = "Auto-Ausf\195\188llen",
		["Auto-Fill - automatically inserts known auction prices"] = "Auto-Ausf\195\188llen - f\195\188gt automatisch bekannte Auktionspreise ein",
		["Auction Runtime"] = "Auktionslaufzeit",
		["Sets default auction runtime."] = "Legt Standard-Auktionslaufzeit fest.",
		["Remembers last used auction runtime."] = "Merkt sich zuletzt benutzte Auktionslaufzeit.",
		["%s now set to %s hours."] = "%s auf %s Stunden ge\195\164ndert.",
		["Type in 12, 24 or 48"] = "12, 24 oder 48 eingeben",
		["Duration"] = "Dauer",
		["Auto-Buyout"] = "Auto-Sofortkauf",
		["Markup"] = "Zuschlag",
		["Sets markup for auto-buy function."] = "Legt Zuschlag für Sofortkauf fest.",
		["Auto-fills buyout * customized markup if no price informations are available."] = 
			"F\195\188llt automatisch den Sofortkauf + festgelegten Aufschlag aus, wenn keine Preisinformationen vorliegen.",
		["Auto-Search"] = "Auto-Suche",
		["Performs auto-search on items you want to sell."] = "Automatische Suche f\195\188r Gegenst\195\164nde, die verkauft werden sollen." ,
	}
end)

L:RegisterTranslations("zhTW", function() 
	return {
		["Auto-Fill"] = "自動填寫",
		["Auto-Fill - automatically inserts known auction prices"] = "自動填寫 - 自動填寫上已知的拍賣價格",
		["Auction Runtime"] = "拍賣時限",
		["Sets default auction runtime."] = "設定預設拍賣時限。",
		["Remembers last used auction runtime."] = "記住前次使用的拍賣時限。",
		["%s now set to %s hours."] = "%s現在設定為%s小時。",
		["Type in 12, 24 or 48"] = "輸入12，24或48",
		["Duration"] = "時限",
		["Auto-Buyout"] = "自動填寫直購價",
		["Markup"] = "標高比率",
		["Sets markup for auto-buy function."] = "設定自動填寫直購價的標高比率。",
		["Auto-fills buyout * customized markup if no price informations are available."] = "當沒有價格資訊時，自動填寫直購價為起始價格乘以標高比率。",
		["Auto-Search"] = "自動搜尋",
		["Performs auto-search on items you want to sell."] = "自動搜尋想拍賣的物品。",
	}
end)

L:RegisterTranslations("zhCN", function() 
	return {
		["Auto-Fill"] = "自动填写",
		["Auto-Fill - automatically inserts known auction prices"] = "自动填写 - 自动填写入上次该物品的拍卖价格",
		["Auction Runtime"] = "拍卖时限",
		["Sets default auction runtime."] = "设定默认拍卖时限。",
		["Remembers last used auction runtime."] = "保存上次所使用的拍卖时限。",
		["%s now set to %s hours."] = "%s现在设定为%s小时。",
		["Type in 12, 24 or 48"] = "输入12，24或48",
		["Duration"] = "时限",
		["Auto-Buyout"] = "自动填写一口价",
		["Markup"] = "一口价系数",
		["Sets markup for auto-buy function."] = "设定自动填写一口价功能的一口价系数。",
		["Auto-fills buyout * customized markup if no price informations are available."] = "当缺乏一口价信息历史记录时，自动填写入相当于起始价格乘以一口价系数的一口价数额。",
		["Auto-Search"] = "自动搜索",
		["Performs auto-search on items you want to sell."] = "自动搜索你想拍卖的物品。",
	}
end)

local mod = Fence:NewModule("AutoFill")
Fence:RegisterDefaults('AutoFill', 'profile', {
    Prices = {},
    LastDuration = 720,
    Duration = 48,
    Markup = 1.5,
    AutoBuy = true
})

mod.db = Fence:AcquireDBNamespace("AutoFill")

	function mod:OnInitialize()
		self:SetDebugging(false)

		Fence.options.args.autofill = {
			type = 'group',
			name = L["Auto-Fill"], aliases = "af",
            desc = L["Auto-Fill - automatically inserts known auction prices"],
				args = {
					toggle = {
						type = 'toggle',
						name = L["Auto-Fill"],
						desc = string.format(l["Toggles %s function."], L["Auto-Fill"]),
						get = function() return Fence:IsModuleActive("AutoFill") end,
						set = function(v) Fence:ToggleModuleActive("AutoFill", v) end
					},
					duration = {
						type = 'text',
						name = L["Duration"], aliases = "dur",
						desc = L["Sets default auction runtime."],
						usage = L["Type in 12, 24 or 48"],
						message = L["%s now set to %s hours."],
						get	= function() return self.db.profile.Duration end,
						set =	function(v) self.db.profile.Duration = v end,
						validate = {"12", "24", "48"}
					},
					last = {
						type = 'toggle',
						name = L["Auction Runtime"],
						desc = L["Remembers last used auction runtime."],
						get	= function() return self.db.profile.Last end,
						set =	function(v) self.db.profile.Last = v end
					},
					autosearch = {
						type = 'toggle', aliases = "as",
						name = L["Auto-Search"],
						desc = L["Performs auto-search on items you want to sell."],
						get	= function() return self.db.profile.AutoSearch end,
						set =	function(v) self.db.profile.AutoSearch = v end
					},
					autobuyout = {
						type = 'group',
						name = L["Auto-Buyout"], aliases = "ab",
						desc = L["Auto-fills buyout * customized markup if no price informations are available."],
							args = {
								toggle = {
									type = 'toggle',
									name = L["Auto-Buyout"],
									desc = string.format(l["Toggles %s function."], L["Auto-Buyout"]),
									get	= function() return self.db.profile.AutoBuy end,
									set =	function(v) self.db.profile.AutoBuy = v end
								},
								markup = {
									type = 'range', aliases = "mu",
									name = L["Markup"],
									desc = L["Sets markup for auto-buy function."],
									get	= function() return self.db.profile.Markup end,
									set =	function(v) self.db.profile.Markup = v end,
									min = 1,
									max = 100
								}
							}
					}
				}
		}
	end
	
	function mod:OnEnable()
        if IsAddOnLoaded("Blizzard_AuctionUI") and AuctionFrame:IsVisible() then self:AH_LOADED() end
        self:RegisterEvent("AH_LOADED")
	end
	
	function mod:AH_LOADED()
  		if self:IsEventRegistered("AH_LOADED") then self:UnregisterEvent("AH_LOADED") end
		self:Hook("StartAuction", true)
        self:SecureHook("PickupContainerItem")
		self:RegisterEvent("NEW_AUCTION_UPDATE")
		self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
        self:RegisterEvent("AUCTION_HOUSE_CLOSED", "AH_CLOSED")
	end

   	function mod:AH_CLOSED()
        self:UnregisterEvent("AUCTION_HOUSE_CLOSED")
		if self:IsHooked("StartAuction") then self:Unhook("StartAuction") end
   		if self:IsHooked("PickupContainerItem") then self:Unhook("PickupContainerItem") end
		self:UnregisterEvent("NEW_AUCTION_UPDATE")
		self:UnregisterEvent("AUCTION_OWNED_LIST_UPDATE")
		self:RegisterEvent("AH_LOADED")
	end

	function mod:AUCTION_OWNED_LIST_UPDATE() -- check & update auction runtime
		local d, s, m, l, dur
		if self.db.profile.Last then
			dur = self.db.profile.LastDuration or (self.db.profile.Duration * 60)
			if dur == 720 then 
				s, m, l  = 1, 0, 0
			elseif dur == 1440 then
				s, m, l = 0, 1, 0
			elseif dur == 2880 then
				s, m, l  = 0, 0, 1
			end
		else 
			dur = tonumber(self.db.profile.Duration) or 48
			if dur == 12 then
				s, m, l, dur  = 1, 0, 0, 720
			elseif dur == 24 then
				s, m, l, dur  = 0, 1, 0, 1440
			elseif dur == 48 then
				s, m, l, dur  = 0, 0, 1, 2880
			end
		end
		AuctionsShortAuctionButton:SetChecked(s)
		AuctionsMediumAuctionButton:SetChecked(m)
		AuctionsLongAuctionButton:SetChecked(l)
		AuctionFrameAuctions.duration = dur
			return
	end
	
	function mod:NEW_AUCTION_UPDATE() -- read data when auction is being updated
        self:ScheduleEvent(function()
            local name, _, count, _, _, _ = GetAuctionSellItemInfo()
            
            if not name then 
                self:Debug("NEW_AUCTION_UPDATE(): No name found.")
                    return 
            end
            
            local startPrice = MoneyInputFrame_GetCopper(StartPrice)
            self:Debug("NEW_AUCTION_UPDATE(): self.itemID, self.suffixID = ", self.itemID, self.suffixID)

            local data = tostring(self:CreateData())
            self:Debug("NEW_AUCTION_UPDATE(): Data = ", data)
            
            local db = self.db.profile.Prices[data]
            self:Debug("db = ", db)
            if not db then 
                if self.db.profile.AutoBuy then 
                    MoneyInputFrame_SetCopper(BuyoutPrice, max(100, floor(startPrice * self.db.profile.Markup))) 
                        return
                end
                    return
            else
                local s,b = strsplit(":", db)
                self:Debug("NEW_AUCTION_UPDATE(): StartPrice = ",s,"|BuyoutPrice = ",b)		
                MoneyInputFrame_SetCopper(StartPrice, s * count)
                MoneyInputFrame_SetCopper(BuyoutPrice, b * count)
                    return
            end
        end, 0.1)
	end
	
	function mod:StartAuction(start, buyout, duration) -- start auction & save data
		local name, _, count, _, _, _ = GetAuctionSellItemInfo()
		self:Debug("StartAuction(): self.itemID, self.suffixID = ", self.itemID or 0, self.suffixID or 0)
        
		local data = tostring(self:CreateData())

        self:Debug("StartAuction(): Data = ", data)

		self.db.profile.Prices[data] = floor(tonumber(start/count))..":"..floor(tonumber(buyout/count))
		if self.db.profile.Last then self.db.profile.LastDuration = duration end
		self.hooks["StartAuction"](start, buyout, duration)
	end
    
    function mod:LinkSplit(iLink) -- split link to itemID & suffixID
        self:Debug("LinkSplit: ",iLink)
        
        local _, _, iString = string.find(iLink, "^|%x+|H(.+)|h%[.+%]")
        local _,_,itemID, _,_,_,_,_,suffixID,_ = string.find(iString, "^item:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)")

        self:Debug("LinkSplit: ", itemID, suffixID)
        self.itemID, self.suffixID = itemID, suffixID
            return self.itemID or 0, self.suffixID or 0
    end
    
    
    function mod:CreateData()
        if self.suffixID and tonumber(self.suffixID) > 0 then
            return (self.itemID..":"..self.suffixID)
        else
            return self.itemID
        end
    end

        
    function mod:PickupContainerItem(bag, item)
        local _,_,iLink = GetCursorInfo()
        if self.itemID then 
            self.itemID = nil 
            self.suffixID = nil 
        end
        if not iLink then self:Debug("return because iLink = nil") return end
        self:LinkSplit(iLink)
    end
  
    function mod:ClickAuction(bag, item, shiftclick) -- Alt-Click from Clicks module
        self:Debug("ClickAuction(): bag, item = ", bag, item)
        PickupContainerItem(bag, item)
        local iLink = GetContainerItemLink(bag, item)
        ClickAuctionSellItemButton()
	    if shiftclick then 
			StartAuction(MoneyInputFrame_GetCopper(StartPrice), MoneyInputFrame_GetCopper(BuyoutPrice), AuctionFrameAuctions.duration)
            if not AuctionFrameAuctions:IsVisible() then AuctionFrameTab3:Click() end
                return
		end
        if not self.db.profile.AutoSearch then 
			if not AuctionFrameAuctions:IsVisible() then AuctionFrameTab3:Click() end
		elseif self.db.profile.AutoSearch and Fence:HasModule('Search') and Fence:IsModuleActive('Search') then
            Fence:GetModule('Search'):Search(iLink)
        end
    end
