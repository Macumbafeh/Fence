if Fence:HasModule('Search') then return end

local L = AceLibrary("AceLocale-2.2"):new("Fence_Search")
local l = AceLibrary("AceLocale-2.2"):new("Fence")

-- Localization
L:RegisterTranslations("enUS", function() 
	return {
		["Search"] = true,
        ["Automatically search the AH for the clicked item."] = true,
        ["Auto-show browse tab"] = true,
	}
end)

L:RegisterTranslations("deDE", function()
	return {
		["Search"] = "Suche",
        ["Automatically search the AH for the clicked item."] = "Durchsucht automatisch das AH nach dem angeklickten Gegenstand.",
        ["Auto-show browse tab"] = "Suchfenster automatisch anzeigen",
	}
end)

L:RegisterTranslations("zhTW", function() 
	return {
		["Search"] = "搜尋",
        ["Automatically search the AH for the clicked item."] = "為點擊的物品自動搜尋拍賣場。",
        ["Auto-show browse tab"] = "自動顯示瀏覽框架",
	}
end)

L:RegisterTranslations("zhCN", function() 
	return {
		["Search"] = "搜索",
        ["Automatically search the AH for the clicked item."] = "在拍卖行中搜索你所点击的物品。",
        ["Auto-show browse tab"] = "自动显示“浏览”标签页",
	}
end)

local mod = Fence:NewModule("Search")
Fence:RegisterDefaults('Search', 'profile', {
    BrowseTab = true
 })

 mod.db = Fence:AcquireDBNamespace("Search")

   function mod:OnInitialize()
        
      Fence.options.args.search = {
         type = 'group',
         name = L["Search"],
         desc = L["Automatically search the AH for the clicked item."],
         args = {
            toggle = {
               type = 'toggle',
               name = L["Search"],
               desc = string.format(l["Toggles %s function."], L["Search"]),
               get = function() return Fence:IsModuleActive('Search') end,
               set = function(v) Fence:ToggleModuleActive('Search', v) end
            },
            browsetab = {
               type = 'toggle',
               name = L["Auto-show browse tab"], aliases = 'bt',
               desc = string.format(l["Toggles %s function."], L["Auto-show browse tab"]),
               get = function() return self.db.profile.BrowseTab end,
               set = function(v) self.db.profile.BrowseTab = v end
            }
         }
      }
   end


    function mod:Search(link) -- modified
		if link and not strfind(link,"item:") then return end
		local _,_,name = strfind(link,"%[(.+)%]")
        
        UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
        AuctionFrameFilters_Update()
        IsUsableCheckButton:SetChecked(false)
        AuctionFrameBrowse.selectedClass = nil
        AuctionFrameBrowse.selectedClassIndex = nil
        AuctionFrameBrowse.selectedSubclassIndex = nil
        AuctionFrameBrowse.selectedInvtype = nil
        AuctionFrameBrowse.selectedInvtypeIndex = nil
        BrowseMinLevel:SetText('');
        BrowseMaxLevel:SetText('');
        BrowseName:SetText(name)
        BrowseName:SetFocus()
        BrowseName:HighlightText(0,-1)
        if self.db.profile.BrowseTab and not AuctionFrameBrowse:IsVisible() then AuctionFrameTab1:Click() end

        AuctionFrameBrowse_Search()
        BrowseNoResultsText:SetText(BROWSE_NO_RESULTS)
        
	end
    
