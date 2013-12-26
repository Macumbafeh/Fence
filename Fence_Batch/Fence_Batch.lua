--------------------------------------------------------------------------------
-- Fence (c) 2013 by Siarkowy
-- Released under the terms of BSD 2.0 license.
--------------------------------------------------------------------------------

if Fence:HasModule('Batch') then return end

local mod = Fence:NewModule("Batch", "AceEvent-2.0")

local box

-- some flags
local batchBidPrice
local batchBuyoutPrice
local batchItemName
local batchItemLink
local batchRepeatCount
local batchStackSize
local isBatchInProgress

local SPLIT_DELAY = 0.5 -- seems to be not too fast and not too slow

function mod:OnInitialize()
    self:RegisterEvent("AUCTION_HOUSE_SHOW", "CreateUI")
    self:RegisterEvent("AUCTION_HOUSE_CLOSED")
end

-- Event handlers --------------------------------------------------------------

function mod:CreateUI() -- do it only once
    self:UnregisterEvent("AUCTION_HOUSE_SHOW")

    local create = AuctionsCreateAuctionButton
    create:SetWidth(create:GetWidth() - 40)

    box = CreateFrame("EditBox", "AuctionFrameAuctionsBatchCount", AuctionFrameAuctions, "InputBoxTemplate")
    box:EnableMouseWheel(true)
    box:SetAutoFocus(false)
    box:SetWidth(40)
    box:SetHeight(16)
    box:SetText(1)
    box:SetPoint("TOPLEFT", create, "TOPRIGHT", 1, -2)

    box:SetScript("OnEnterPressed", function(this)
        this:ClearFocus()
    end)

    box:SetScript("OnMouseWheel", function(this, delta)
        local min = 1
        local max = self:GetCurrentItemMaxCount() or 1
        local count = tonumber(this:GetText()) or (delta > 0 and max or min)

        this:SetText(delta > 0 and (count < max and count + 1 or max) or delta <= 0 and (count > min and count - 1 or min))
    end)

    local create_OnClick = AuctionsCreateAuctionButton:GetScript("OnClick")
    create:SetScript("OnClick", function(this, btn)
        local count = tonumber(box:GetText()) or self:GetCurrentItemMaxCount()

        if count > 1 then
            local name, _, size = GetAuctionSellItemInfo()

            self:StartBatch(name, size, count,
                MoneyInputFrame_GetCopper(StartPrice),
                MoneyInputFrame_GetCopper(BuyoutPrice))
        end

        create_OnClick()
    end)
end

function mod:AUCTION_HOUSE_CLOSED()
    if self:IsBatchInProgress() then
        self:StopBatch()
    end
end

function mod:AUCTION_OWNED_LIST_UPDATE()
    self:UnregisterEvent("AUCTION_OWNED_LIST_UPDATE")

    if self:IsBatchInProgress() then
        self:ProceedBatch()
    end
end

function mod:ITEM_LOCK_CHANGED(bag, slot)
    self:UnregisterEvent("ITEM_LOCK_CHANGED")

    local type, _, itemlink = GetCursorInfo()
    if type == "item" and itemlink == batchItemLink then
        self:RegisterEvent("NEW_AUCTION_UPDATE")
        ClickAuctionSellItemButton()
    end
end

function mod:NEW_AUCTION_UPDATE()
    self:UnregisterEvent("NEW_AUCTION_UPDATE")

    local name, _, count = GetAuctionSellItemInfo()

    if name and (name ~= batchItemName or count ~= batchStackSize) then
        return self:StopBatch()
    end

    MoneyInputFrame_SetCopper(StartPrice,  batchBidPrice)
    MoneyInputFrame_SetCopper(BuyoutPrice, batchBuyoutPrice)

    self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
    AuctionsCreateAuctionButton_OnClick()
end

-- Core functions --------------------------------------------------------------

function mod:GetCurrentItemMaxCount()
    local name, _, size = GetAuctionSellItemInfo()

    if name then
        return floor(GetItemCount(name) / size)
    end
end

function mod:CreateItemStack(link, stacksize)
    local hasItem

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if not hasItem and GetContainerItemLink(bag, slot) == link then
                if select(2, GetContainerItemInfo(bag, slot)) > stacksize then
                    SplitContainerItem(bag, slot, stacksize)
                    hasItem = true
                end
            elseif hasItem and not GetContainerItemLink(bag, slot) then
                PickupContainerItem(bag, slot)
                self:ScheduleEvent(function() self:ProceedBatch(true) end, SPLIT_DELAY)
                return true
            end
        end
    end

    return false
end

function mod:PickupItemStack(link, stacksize)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            if GetContainerItemLink(bag, slot) == link and select(2, GetContainerItemInfo(bag, slot)) == stacksize then
                self:RegisterEvent("ITEM_LOCK_CHANGED")
                PickupContainerItem(bag, slot)
                return true
            end
        end
    end

    return false
end

function mod:StartBatch(item, stacksize, count, bid, buyout)
    if isBatchInProgress
    or not item or not GetItemInfo(item)
    or not stacksize or (tonumber(stacksize) or 0) < 1
    or not count or (tonumber(count) or 0) < 2
    then
        return false
    end

    self.autofill = Fence:IsModuleActive("AutoFill")
    Fence:ToggleModuleActive("AutoFill", false)

    batchBidPrice       = bid
    batchBuyoutPrice    = buyout
    batchItemName,
    batchItemLink       = GetItemInfo(item)
    batchRepeatCount    = count
    batchStackSize      = stacksize
    isBatchInProgress   = true

    self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
end

function mod:ProceedBatch(dontDecrement)
    if not isBatchInProgress then
        return
    end

    if not dontDecrement then
        batchRepeatCount = batchRepeatCount - 1
    end

    if batchRepeatCount <= 0 then
        return self:StopBatch(true)
    end

    box:SetText(batchRepeatCount)

    if not self:PickupItemStack(batchItemLink, batchStackSize) then
        if not self:CreateItemStack(batchItemLink, batchStackSize) then
            ClearCursor()
            self:StopBatch()
            self:Print("No free space after splitted stack.")
        end
    end
end

function mod:StopBatch(success)
    box:SetText(1)

    Fence:ToggleModuleActive("AutoFill", self.autofill)

    batchBidPrice       = nil
    batchBuyoutPrice    = nil
    batchItemName       = nil
    batchItemLink       = nil
    batchRepeatCount    = nil
    batchStackSize      = nil
    isBatchInProgress   = nil

    self:Print(success and "All auctions created successfully." or "Auction creation interrupted.")
end

function mod:IsBatchInProgress()
    return isBatchInProgress
end
