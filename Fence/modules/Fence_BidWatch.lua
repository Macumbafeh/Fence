if Fence:HasModule('BidWatch') then return end

local L = AceLibrary("AceLocale-2.2"):new("Fence_BidWatch")
local l = AceLibrary("AceLocale-2.2"):new("Fence")
local abc = AceLibrary("Abacus-2.0")

-- Localization
L:RegisterTranslations("enUS", function() return {
		["Bid Watch"] = true,
		["Set a price limit for bids and warns you about it when the limit has been reached."] = true,
		["Bid"] = true,
		["Set upper bid limit in copper."] = true,
		["WARNING!!!\n\nBid is greater than:\n"] = true,
		["\n\nAre you sure you wish to bid?"] = true,
		["Bid for %s detected."] = true,
	}
end)

L:RegisterTranslations("deDE", function() return {
		["Bid Watch"] = "Bid Watch",
    ["Set a price limit for bids and warns you about it when the limit has been reached."] = "Legt ein Preislimit f\195\188r Gebote fest und gibt eine Warnung aus, wenn das Limit erreicht wurde.", 
		["Bid"] = "Gebot",
		["Set upper bid limit in copper."] = "Legt Limit f\195\188r Gebote in Kupfer fest (Standard: 10000)",
		["WARNING!!!\n\nBid is greater than:\n"] = "WARNUNG!!!\n\nGebot ist gr\195\182\195\159er als:\n",
		["\n\nAre you sure you wish to bid?"] = "\n\nM\195\182chtest du trotzdem bieten?",
		["Bid for %s detected."] = "Gebot in H\195\182he von %s entdeckt.",
	}
end)

L:RegisterTranslations("zhTW", function() return {
		["Bid Watch"] = "出價監視",
		["Set a price limit for bids and warns you about it when the limit has been reached."] = "設定出價價格限制，並在出價超出價格限制時警告。",
		["Bid"] = "出價",
		["Set upper bid limit in copper."] = "以銅幣設定出價價格限制。",
		["WARNING!!!\n\nBid is greater than:\n"] = "警告!!!\n\n出價超出:\n",
		["\n\nAre you sure you wish to bid?"] = "\n\n你是否真的競標?",
		["Bid for %s detected."] = "發現出價: %s!",
	}
end)

L:RegisterTranslations("zhCN", function() return {
		["Bid Watch"] = "出价监视",
		["Set a price limit for bids and warns you about it when the limit has been reached."] = "设定出价价格限制，并在你出价超过该限制时发出警告。",
		["Bid"] = "出价",
		["Set upper bid limit in copper."] = "以铜币为单位设定出价价格限制。",
		["WARNING!!!\n\nBid is greater than:\n"] = "警告！\n\n出价价格已超过\n",
		["\n\nAre you sure you wish to bid?"] = "\n\n你是否真的打算出价？",
		["Bid for %s detected."] = "发现对“%s”的出价！",
	}
end)

local mod = Fence:NewModule("BidWatch")
Fence:RegisterDefaults('BidWatch', 'profile', {
    MaxBid = 100000
})

mod.db = Fence:AcquireDBNamespace("BidWatch")
	
	function mod:OnInitialize()
		
		Fence.options.args.bidwatch = {
			type = 'group',
			name = L["Bid Watch"], aliases='bw',
			desc = L["Set a price limit for bids and warns you about it when the limit has been reached."],
				args = {
					toggle = {
						type = 'toggle',
						name = L["Bid Watch"],
						desc = string.format(l["Toggles %s function."], L["Bid Watch"]),
						get = function() return Fence:IsModuleActive("BidWatch") end,
						set = function(v) Fence:ToggleModuleActive("BidWatch", v) end
					},
					bidGUI = {
						cmdHidden = true,
						name = L["Bid"], 
						desc = L["Set upper bid limit in copper."],
						type = "range",
						get = function() return self.db.profile.MaxBid end,
						set = function(v)	
										self.db.profile.MaxBid = v 
										self:CreatePopup()
									end,
						min = 1000,
						max = 990000,
						step = 1000
					},
					bid = {
					guiHidden = true,
						name = L["Bid"], 
						desc = L["Set upper bid limit in copper."],
						type = "range",
						get = function() return abc:FormatMoneyFull(self.db.profile.MaxBid, true) end,
						set = function(v)	
										self.db.profile.MaxBid = v 
										self:CreatePopup()
									end,
						min = 1000,
						max = 990000,
					}
				}
			}

		self:CreatePopup()
	end

	function mod:OnEnable()
		self:RegisterEvent("AH_LOADED")
	end

	function mod:OnDisable()
		if self:IsHooked("PlaceAuctionBid") then self:Unhook("PlaceAuctionBid") end
	end

	function mod:AH_LOADED()
		self:Hook("PlaceAuctionBid", true)
		self:UnregisterEvent("AH_LOADED")
	end
	
	function mod:CreatePopup()
		StaticPopupDialogs["BID_BIND"] = {
			text = TEXT(L["WARNING!!!\n\nBid is greater than:\n"]..abc:FormatMoneyFull(self.db.profile.MaxBid, true)..L["\n\nAre you sure you wish to bid?"]),
			button1 = TEXT(OKAY),
			button2 = TEXT(CANCEL),
			OnAccept = function()
				self.hooks["PlaceAuctionBid"](self.itemtype ,self.itemindex ,self.bidamount)
			end,
			showAlert = 1,
			timeout = 0,
			exclusive = 1,
			whileDead = 1,
			interruptCinematic = 1
		}	
	end
	
	function mod:PlaceAuctionBid(itemtype,itemindex,bidamount)
		self.itemtype = itemtype
		self.itemindex = itemindex
		self.bidamount = bidamount
		
		if bidamount >= self.db.profile.MaxBid then
			local dialog = StaticPopup_Show("BID_BIND")
			if dialog then 
				self:Print(L["Bid for %s detected."], abc:FormatMoneyFull(bidamount,true)) 
			else 
				self.hooks["PlaceAuctionBid"](itemtype, itemindex ,bidamount)			
			end
		else
			self.hooks["PlaceAuctionBid"](itemtype, itemindex ,bidamount)
		end
	end