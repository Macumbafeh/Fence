-- Credits: phyber
if Fence:HasModule('Fence_Bookmarks') then return end

local mod = Fence:NewModule("Fence_Bookmarks")
local _G = getfenv(0)
local dewdrop = AceLibrary("Dewdrop-2.0")
local L = AceLibrary("AceLocale-2.2"):new("Fence_Bookmarks")
local l = AceLibrary("AceLocale-2.2"):new("Fence")

L:RegisterTranslations("enUS", function() return {
	["Bookmarks"] = true,
	["Bookmark Current Search"] = true,
	["Add Bookmark"] = true,
	["Delete Bookmark"] = true,
} end)

L:RegisterTranslations("deDE", function() return {
	["Bookmarks"] = "Lesezeichen",
	["Bookmark Current Search"] = "Erstelle Lesezeichen f\195\188r aktuelle Suche",
	["Add Bookmark"] = "F\195\188ge Lesezeichen hinzu",
	["Delete Bookmark"] = "L\195\182sche Lesezeichen",
} end)

L:RegisterTranslations("zhTW", function() return {
	["Bookmarks"] = "書簽",
	["Bookmark Current Search"] = "為目前的搜尋加上書簽",
	["Add Bookmark"] = "增加書簽",
	["Delete Bookmark"] = "刪除書簽",
} end)

L:RegisterTranslations("zhCN", function() return {
	["Bookmarks"] = "书签",
	["Bookmark Current Search"] = "将目前的搜索加入书签",
	["Add Bookmark"] = "增加书签",
	["Delete Bookmark"] = "删除书签",
} end)

Fence:RegisterDefaults('Bookmarks', 'profile', {
    Bookmarks = {}
})

mod.db = Fence:AcquireDBNamespace("Bookmarks")

    function mod:OnInitialize()

        self.menu = {
            desc = L["Bookmarks"],
            type = 'group',
            args = {
                addbookmark = {
                    desc = L["Add Bookmark"],
                    name = L["Add Bookmark"],
                    type = 'text',
                    usage = "FIXME",
                    get = false,
                    set = function(v)
                        self.db.profile.Bookmarks[v] = true
                        dewdrop:Refresh(1)
                    end,
                    validate = function(v)
                        return string.find(v, "^%w+$")
                    end
                },
                delbookmark = {
                    desc = L["Delete Bookmark"],
                    name = L["Delete Bookmark"],
                    type = 'text',
                    usage = "FIXME",
                    get = false,
                    set = function(v)
                        self.db.profile.Bookmarks[v] = nil
                        self:UpdateValidateList()
                        dewdrop:Refresh()
                    end,
                    validate = self.db.profile.Bookmarks,
                    disabled = function()
                        return #self.menu.args.delbookmark.validate
                    end
                }
            }
        }

        -- Add some options to Fence
        Fence.options.args.bookmarks = {
            type = 'group',
            name = L["Bookmarks"], aliases = 'bm',
            desc = string.format(l["%s options"], L["Bookmarks"]),
            args = {
                toggle = {
                    type = 'toggle',
                    name = L["Bookmarks"],
                    desc = string.format(l["Toggles %s function."], L["Bookmarks"]),
                    get = function() return Fence:IsModuleActive("Fence_Bookmarks") end,
                    set = function(v) Fence:ToggleModuleActive("Fence_Bookmarks", v) end
                }
            }
        }
    end

    function mod:OnEnable()
        self:RegisterEvent("AH_LOADED", "CreateButton")
    end

    function mod:CreateButton()
        local BookmarkButton = CreateFrame("Button", "BookmarkButton", AuctionFrameBrowse)
        BookmarkButton:SetWidth(24)
        BookmarkButton:SetHeight(24)
        BookmarkButton:SetFrameStrata("HIGH")
        BookmarkButton:SetPoint("RIGHT", "BrowseName", "RIGHT", 6, 0)
        BookmarkButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
        BookmarkButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
        BookmarkButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        BookmarkButton:SetScript("OnClick", function()
            self:ToggleDropdown()
        end)

        dewdrop:Register(BookmarkButton, 'children', function() self:ToggleDropdown() end, 'dontHook', true)
        --dewdrop:Register(BookmarkButton, 'children', self.menu)

        self:UnregisterEvent("AH_LOADED")
    end

    function mod:UpdateValidateList()
        --for bm, _ in pairs(self.db.profile.Bookmarks) do 
        --	table.insert(self.menu.args.delbookmark.validate, bm)
        --end
        self.menu.args.delbookmark.validate = self.db.profile.Bookmarks
    end

    function mod:SetSearch(item)
        BrowseName:SetText(item)
        if CanSendAuctionQuery() then
            AuctionFrameBrowse_Search()
        end
    end

    function mod:BookmarkCurrent()
        local curSearch = BrowseName:GetText()
        if curSearch then
            self.db.profile.Bookmarks[curSearch] = true
        end
    end

    function mod:ToggleDropdown()
        if not dewdrop:IsOpen(_G["BookmarkButton"]) then
            dewdrop:AddLine(
                'text', L["Bookmarks"],
                'isTitle', true,
                'justifyH', "CENTER",
                'notCheckable', true,
                'textHeight', 14,
                'textR', 1,
                'textG', 1,
                'textB', 1
            )

            for item, _ in pairs(self.db.profile.Bookmarks) do
                dewdrop:AddLine(
                    'text', item,
                    'textHeight', 12,
                    'func', "SetSearch",
                    'arg1', item
                )
            end

            -- spacer
            dewdrop:AddLine()

            -- bookmark current search
            --[[dewdrop:AddLine(
                'text', L["Bookmark Current Search"],
                'textHeight', 12,
                'func', "BookmarkCurrent"
            )

            -- add bookmark manually
            dewdrop:AddLine(

            )

            -- delete bookmark
            dewdrop:AddLine(
                'text', L["Delete Bookmark"],
                'textHeight', 12,
                'func', function()
                end
            )]]
            dewdrop:InjectAceOptionsTable(self, self.menu)
        else
            dewdrop:Close(BookmarkButton)
        end
    end
