if Fence then return end

local MAJOR_VERSION = "1.0"
local MINOR_VERSION = tonumber((string.gsub("$Revision: 46401 $", "^.-(%d+).-$", "%1")))

local L = AceLibrary("AceLocale-2.2"):new("Fence")

L:RegisterTranslations("enUS", function() 
	return {
		["%s options"] = true,
		["Toggles %s function."] = true,
        ["All settings have been reset! Sorry, it was absolutely necessary."] = true,
	}
end)

L:RegisterTranslations("deDE", function() 
	return {
		["%s options"] = "%s Optionen",
		["Toggles %s function."] = "Schaltet %s Funktion ein/aus.",
        ["All settings have been reset! Sorry, it was absolutely necessary."] = 
            "Alle Einstellungen wurden zur\195\188ckgesetzt! Sorry, es war absolut n\195\182tig.",
	}
end)

L:RegisterTranslations("zhTW", function() 
	return {
		["%s options"] = "%s選項",
		["Toggles %s function."] = "切換%s功能。",
        ["All settings have been reset! Sorry, it was absolutely necessary."] = "已重設所有設定! 對不起，但這是必須的。",
	}
end)

L:RegisterTranslations("zhCN", function() 
	return {
		["%s options"] = "%s设置",
		["Toggles %s function."] = "开启/关闭%s功能。",
        ["All settings have been reset! Sorry, it was absolutely necessary."] = "所有设置已重置为默认！对不起，但这是必须的。",
	}
end)

Fence = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0", "AceModuleCore-2.0", "AceHook-2.1")
Fence:SetModuleMixins("AceEvent-2.0", "AceHook-2.1", "AceConsole-2.0", "AceDebug-2.0")

Fence.version = MAJOR_VERSION .. "." .. MINOR_VERSION
Fence.date = string.gsub("$Date: 2007-08-12 22:43:37 -0400 (Sun, 12 Aug 2007) $", "^.-(%d%d%d%d%-%d%d%-%d%d).-$", "%1")

Fence.options = {
	type = 'group',
	args = {},
}

Fence:RegisterChatCommand({"/Fence"}, Fence.options)
Fence:RegisterDB("FenceDB")
Fence:RegisterDefaults('profile', {
    Version = {}
})

	function Fence:OnInitialize()
        self:RegisterEvent("AUCTION_HOUSE_SHOW", function() 
            if IsAddOnLoaded("Blizzard_AuctionUI") then self:TriggerEvent("AH_LOADED") end 
        end)


	-- we have to delete saved variables, because we can! Only will happen for this or older versions
        if not self.db.profile.Version.Minor or self.db.profile.Version.Minor < MINOR_VERSION then
            if self.db.profile.Version.Update then 
                if self.db.profile.Version.Minor <= 24112
                    then Fence:AcquireDBNamespace("AutoFill").profile.Prices = {}
                end
                self.db.profile.Version.Minor = MINOR_VERSION
                    return 
            end
            self:Print(L["All settings have been reset! Sorry, it was absolutely necessary."])
            self:ResetDB('profile')
            self.db.profile.Version = {
					Minor = MINOR_VERSION,
					Update = true
			}
        end
	end
      
