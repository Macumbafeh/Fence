if Fence:HasModule('Browse') then return end

local L = AceLibrary("AceLocale-2.2"):new("Fence_Browse")
local l = AceLibrary("AceLocale-2.2"):new("Fence")
local abc = AceLibrary("Abacus-2.0")

-- Localization
L:RegisterTranslations("enUS", function() return {
		["Browse"] = true,
		["Displays price per item."] = true,
		["Show Bid"] = true,
		["Show price per item"] = true,
		["Price per item style"] = true,
		['Show price for single items'] = true,
		['Toggles whether prices are shown for items in stacks of 1'] = true,
		["Changes price per item style."] = true,
		["Bid"] = true,
		["Changes bid style."] = true,
		["Bid Style"] = true,
		["short"] = true,
		["full"] = true,
		["condensed"] = true,
		["text"] = true,
		["fade"] = true,
	}
end)

L:RegisterTranslations("deDE", function() return {
		["Browse"] = "Browse",
		["Displays price per item."] = "Zeigt den Einzelpreis eines Gegenstands an.",
		["Show Bid"] = "Gebotanzeige",
		["Show price per item"] = "Einzelpreis-Anzeige",
		["Price per item style"] = "Einzelpreis-Stil",
		["Changes price per item style."] = "Stil f\195\188r Einzelpreis anpassen.",
		["Bid"] = "Gebot",
		["Changes bid style."] = "Stil f\195\188r Gebote anpassen.",
		["Bid Style"] = "Gebot-Stil",
	}
end)

L:RegisterTranslations("zhTW", function() return {
		["Browse"] = "瀏覽",
		["Displays price per item."] = "顯示每件物品價格。",
		["Show Bid"] = "顯示競標狀態",
		["Show price per item"] = "顯示每件物品價格",
		["Price per item style"] = "每件物品價格樣式",
		['Show price for single items'] = "顯示單一物品價格",
		['Toggles whether prices are shown for items in stacks of 1'] = "總是顯示單一物品價格",
		["Changes price per item style."] = "改變每件物品價格樣式。",
		["Bid"] = "有競標",
		["Changes bid style."] = "改變競標狀態樣式。",
		["Bid Style"] = "競標狀態樣式",
		["short"] = "簡短",
		["full"] = "完整",
		["condensed"] = "扼要",
		["text"] = "文字",
		["fade"] = "漸暗",
	}
end)

L:RegisterTranslations("zhCN", function() return {
		["Browse"] = "浏览",
		["Displays price per item."] = "显示物品单价。",
		["Show Bid"] = "显示竞标状态",
		["Show price per item"] = "显示物品单价",
		["Price per item style"] = "物品单价显示样式",
		["Changes price per item style."] = "改变物品单价显示样式。",
		["Bid"] = "竞标状态",
		["Changes bid style."] = "改变竞标状态显示样式。",
		["Bid Style"] = "竞标状态显示样式",
	}
end)

local mod = Fence:NewModule("Browse")

Fence:RegisterDefaults('Browse', 'profile', {
	ShowPrice = true,
    ShowBid = true,
    PriceStyle = "short",
    BidStyle = "fade",
    ShowPriceForSingle = false,
})

mod.db = Fence:AcquireDBNamespace("Browse")

	function mod:OnInitialize()
		Fence.options.args.browse = {
			type = 'group',
			name = L["Browse"], aliases='br',
			desc = L["Displays price per item."],
				args = {
					toggle = {
						type = 'toggle',
						name = L["Browse"],
						desc = string.format(l["Toggles %s function."], L["Browse"]),
						get = function() return Fence:IsModuleActive("Browse") end,
						set = function(v) Fence:ToggleModuleActive("Browse", v) end
					},
					showprice = {
						order	= 200,
						type = 'toggle',
						name = L["Show price per item"], aliases='sp',
						desc = string.format(l["Toggles %s function."], L["Show price per item"]),
						get = function() return self.db.profile.ShowPrice end,
						set = function(v)
							self.db.profile.ShowPrice = v
							Fence.options.args.browse.args.showpriceforsingle.disabled = not v
						      end
					},
					showpriceforsingle = {
						order	= 220,
						disabled = not self.db.profile.ShowPrice,
						type	= 'toggle',
						name	= L['Show price for single items'],
						desc	= L['Toggles whether prices are shown for items in stacks of 1'],
						get	= function() return self.db.profile.ShowPriceForSingle end,
						set	= function(v) self.db.profile.ShowPriceForSingle = v end,
					},
					pricestyle= {
						type = 'text',
						name = L["Price per item style"], aliases='ps',
						desc = L["Changes price per item style."],
						get = function() return self.db.profile.PriceStyle end,
						set = function(v) self.db.profile.PriceStyle= v end,
						validate = {short = L["short"], full = L["full"], condensed = L["condensed"]}
					},
					showbid = {
						type = 'toggle',
						name = L["Show Bid"], aliases='sb',
						desc = string.format(l["Toggles %s function."], L["Show Bid"]),
						get = function() return self.db.profile.ShowBid end,
						set = function(v) self.db.profile.ShowBid = v end
					},
  					bidstyle = {
						type = 'text',
						name = L["Bid Style"], aliases='bs',
						desc = L["Changes bid style."],
						get = function() return self.db.profile.BidStyle end,
						set = function(v) self.db.profile.BidStyle = v end,
						validate = {text = L["text"], fade = L["fade"]}
					}
				}
			}
	end

	function mod:OnEnable()
		self:RegisterEvent("AH_LOADED")
	end

	function mod:OnDisable()
		if self:IsHooked("AuctionFrameBrowse_Update") then self:Unhook("AuctionFrameBrowse_Update") end
	end

	function mod:AH_LOADED()
		self:Hook("AuctionFrameBrowse_Update", true)
		self:UnregisterEvent("AH_LOADED")
	end

	function mod:AuctionFrameBrowse_Update()
		self.hooks["AuctionFrameBrowse_Update"]()

		if not self.db.profile.ShowPrice and not self.db.profile.ShowBid then return end

		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
		if numBatchAuctions == 0 then return end

		local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
		local index, button, itemName, moneyFrame

		for i=1, NUM_BROWSE_TO_DISPLAY do
			index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)

			local name, _, count, _, _, _, minBid, minIncrement, buyoutPrice, bidAmount, _, _ =  GetAuctionItemInfo("list", offset + i)
			if not name then return end
			button = "BrowseButton"..i
			itemName = getglobal(button.."Name")
			moneyFrame = getglobal(button.."MoneyFrame")
			moneyFrame:SetAlpha(1)

			local sM, spMoney, bidText, bT

			if self.db.profile.ShowPrice then
				local bidPrice = bidAmount > 0 and bidAmount or minBid
				if (buyoutPrice > 0 or bidPrice > 0) and (self.db.profile.ShowPriceForSingle or count > 1) then
					local epbp = floor(bidPrice/count)
					local epbo = buyoutPrice > 0 and floor(buyoutPrice/count) or 0
					local ps = self.db.profile.PriceStyle
					if ps == "short" then
						spMoney = abc:FormatMoneyShort(epbp, true)
						sM = strlen(abc:FormatMoneyShort(epbp)) + 4

						if epbo > 0 then
							spMoney = spMoney.."/"..abc:FormatMoneyShort(epbo, true)
							sM = sM + strlen(abc:FormatMoneyShort(epbo)) + 1
						end
					elseif ps == "full" then
						spMoney = abc:FormatMoneyFull(epbp, true)
						sM = strlen(abc:FormatMoneyFull(epbp)) + 4

						if epbo > 0 then
							spMoney = spMoney.."/"..abc:FormatMoneyFull(epbo, true)
							sM = sM + strlen(abc:FormatMoneyFull(epbo)) + 1
						end
					elseif ps == "condensed" then
						spMoney = abc:FormatMoneyCondensed(epbp, true)
						sM = strlen(abc:FormatMoneyCondensed(epbp)) + 4

						if epbo > 0 then
							spMoney = spMoney.."/"..abc:FormatMoneyCondensed(epbo, true)
							sM = sM + strlen(abc:FormatMoneyCondensed(epbo)) + 1
						end
					end
					if spMoney then spMoney = " ("..spMoney..") " end
				end
			end

			if self.db.profile.ShowBid then
				if bidAmount > 0 then
					if self.db.profile.BidStyle == "text" then
						bidText = " - |cffffff00" .. L["Bid"] .. "|r"
						bT = strlen(L["Bid"]) + 3
					elseif self.db.profile.BidStyle == "fade" then
						moneyFrame:SetAlpha(.4)
					end
				end
			end

			if not sM then
				sM = 0
				spMoney = ""
			end

			if not bT then
				bT = 0
				bidText = ""
			end

			if strlen(name)+(sM+bT) > 40 then
				name = strsub(name,0,(strlen(name) - (sM+bT))).."..."
			end

			itemName:SetText(name..spMoney..bidText)

		end
	end
