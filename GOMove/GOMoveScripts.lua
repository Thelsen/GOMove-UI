GOMove.FavL = {NameWidth = 17}
function GOMove.FavL:Add(name, guid)
    self:Del(guid)
    table.insert(self, 1, {name, guid})
    GOMoveSV.FavL = self
end
function GOMove.FavL:Del(guid)
    for k,v in ipairs(self) do
        if(v[2] == guid) then
            table.remove(self, k)
            break
        end
    end
    GOMoveSV.FavL = self
end

GOMove.SelL = {NameWidth = 17}
function GOMove.SelL:Add(name, guid, entry)
    table.insert(self, 1, {name, guid, entry})
end
function GOMove.SelL:Del(guid)
    for k,v in ipairs(self) do
        if(v[2] == guid) then
            table.remove(self, k)
            break
        end
    end
end

GOMove.Selected = {}
function GOMove.Selected:Add(name, guid)
    self[guid] = name
end
function GOMove.Selected:Del(guid)
    self[guid] = nil
end

-- Helper function to create section headers
local function CreateSectionHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOP", parent, "TOP", 0, yOffset)
    header:SetText("|cFFFFD100"..text.."|r")
    header:SetJustifyH("CENTER")
    return header
end

-- Helper function to create separator lines
local function CreateSeparator(parent, yOffset)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetSize(150, 1)
    sep:SetPoint("TOP", parent, "TOP", 0, yOffset)
    sep:SetTexture(0.4, 0.4, 0.4, 0.8)  -- Use SetTexture instead for 3.3.5a
    return sep
end

-- FAVOURITE LIST
local FavFrame = GOMove:CreateFrame("Favourite_List", 200, 280, GOMove.FavL, true)
FavFrame:Position("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
function FavFrame:ButtonOnClick(ID)
    GOMove.IsSpawning = true
    GOMove:Move("SPAWN", self.DataTable[FauxScrollFrame_GetOffset(self.ScrollBar) + ID][2])
end
function FavFrame:MiscOnClick(ID)
    self.DataTable:Del(self.DataTable[FauxScrollFrame_GetOffset(self.ScrollBar) + ID][2])
    self:Update()
end

-- SELECTION LIST
local SelFrame = GOMove:CreateFrame("Selection_List", 250, 280, GOMove.SelL, true)
SelFrame:Position("BOTTOMRIGHT", FavFrame, "TOPRIGHT", 0, 0)
function SelFrame:ButtonOnClick(ID)
    local DATAID = FauxScrollFrame_GetOffset(self.ScrollBar) + ID
    if(GOMove.Selected[self.DataTable[DATAID][2]]) then
        GOMove.Selected:Del(self.DataTable[DATAID][2])
    else
        GOMove.Selected:Add(self.DataTable[DATAID][1], self.DataTable[DATAID][2])
    end
    self:Update()
end
function SelFrame:MiscOnClick(ID)
    local DATAID = FauxScrollFrame_GetOffset(self.ScrollBar) + ID
    GOMove.Selected:Del(self.DataTable[DATAID][2])
    self.DataTable:Del(self.DataTable[DATAID][2])
    self:Update()
end
function SelFrame:UpdateScript(ID)
    local DATAID = FauxScrollFrame_GetOffset(self.ScrollBar) + ID
    if(self.DataTable[DATAID]) then
        if(GOMove.Selected[self.DataTable[DATAID][2]]) then
            self.Buttons[ID]:GetFontString():SetTextColor(1, 0.8, 0)
        else
            self.Buttons[ID]:GetFontString():SetTextColor(1, 1, 1)
        end
    end
end

local ClearButton = CreateFrame("Button", SelFrame:GetName().."_ToggleSelect", SelFrame)
ClearButton:SetSize(16, 16)
ClearButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
ClearButton:SetPushedTexture("Interface\\Buttons\\UI-GuildButton-OfficerNote-Up")
ClearButton:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
ClearButton:SetPoint("TOPRIGHT", SelFrame, "TOPRIGHT", -30, -5)
ClearButton:SetScript("OnClick", function()
    local empty = true
    for k,v in pairs(GOMove.Selected) do
        if(tonumber(k)) then
            empty = false
        end
    end
    if(empty) then
        for k, tbl in ipairs(SelFrame.DataTable) do
            GOMove.Selected:Add(tbl[1], tbl[2])
        end
    else
        for k,v in pairs(GOMove.Selected) do
            if(tonumber(k)) then
                GOMove.Selected:Del(k)
            end
        end
    end
    SelFrame:Update()
end)

for i = 1, SelFrame.ButtonCount do
    local Button = SelFrame.Buttons[i]
    local MiscButton = Button.MiscButton
    local FavButton = CreateFrame("Button", Button:GetName().."_Favourite", MiscButton)
    FavButton:SetSize(16, 16)
    FavButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
    FavButton:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
    FavButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilighted")
    FavButton:SetPoint("TOPRIGHT", MiscButton, "TOPLEFT", 0, 0)
    FavButton:SetScript("OnClick", function()
        local DATAID = FauxScrollFrame_GetOffset(SelFrame.ScrollBar) + i
        FavFrame.DataTable:Add(SelFrame.DataTable[DATAID][1], SelFrame.DataTable[DATAID][3])
        FavFrame:Update()
    end)
    local DeleteButton = CreateFrame("Button", Button:GetName().."_Delete", FavButton)
    DeleteButton:SetSize(16, 16)
    DeleteButton:SetNormalTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon5")
    DeleteButton:SetPushedTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon7")
    DeleteButton:SetHighlightTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon3")
    DeleteButton:SetPoint("TOPRIGHT", FavButton, "TOPLEFT", 0, 0)
    DeleteButton:SetScript("OnClick", function()
        GOMove:Move("DELETE", SelFrame.DataTable[FauxScrollFrame_GetOffset(SelFrame.ScrollBar) + i][2])
    end)
    local SpawnButton = CreateFrame("Button", Button:GetName().."_Spawn", DeleteButton)
    SpawnButton:SetSize(16, 16)
    SpawnButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    SpawnButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    SpawnButton:SetHighlightTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    SpawnButton:SetPoint("TOPRIGHT", DeleteButton, "TOPLEFT", 0, 0)
    SpawnButton:SetScript("OnClick", function()
        GOMove.IsSpawning = true
        GOMove:Move("RESPAWN", SelFrame.DataTable[FauxScrollFrame_GetOffset(SelFrame.ScrollBar) + i][2])
    end)
    local InfoButton = CreateFrame("Button", Button:GetName().."_Info", SpawnButton)
    InfoButton:SetSize(16, 16)
    InfoButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Disabled")
    InfoButton:SetPushedTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Down")
    InfoButton:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
    InfoButton:SetPoint("TOPRIGHT", SpawnButton, "TOPLEFT", 0, 0)
    InfoButton:SetScript("OnClick", function()
        GOMove:Move("INFO", SelFrame.DataTable[FauxScrollFrame_GetOffset(SelFrame.ScrollBar) + i][2])
    end)
end

local EmptyButton = CreateFrame("Button", SelFrame:GetName().."_EmptyButton", SelFrame)
EmptyButton:SetSize(30, 30)
EmptyButton:SetNormalTexture("Interface\\Buttons\\CancelButton-Up")
EmptyButton:SetPushedTexture("Interface\\Buttons\\CancelButton-Down")
EmptyButton:SetHighlightTexture("Interface\\Buttons\\CancelButton-Highlight")
EmptyButton:SetPoint("TOPRIGHT", SelFrame, "TOPRIGHT", -45, 0)
EmptyButton:SetHitRectInsets(9, 7, 7, 10)
EmptyButton:SetScript("OnClick", function()
    for k,v in pairs(GOMove.Selected) do
        if(tonumber(k)) then
            GOMove.Selected:Del(k)
        end
    end
    for i = #SelFrame.DataTable, 1, -1 do
        SelFrame.DataTable:Del(SelFrame.DataTable[i][2])
    end
    SelFrame:Update()
end)

-- ============================================================================
-- MAIN FRAME - Reorganized with cleaner layout
-- ============================================================================
local MainFrame = GOMove:CreateFrame("GOMove_UI", 180, 720)
GOMove.MainFrame = MainFrame
MainFrame:Position("LEFT", UIParent, "LEFT", 0, 50)

local yPos = -30

-- ============================================================================
-- SECTION: Position (Horizontal Movement)
-- ============================================================================
CreateSectionHeader(MainFrame, "— Position —", yPos)
yPos = yPos

local MOVEAMT = GOMove:CreateInput(MainFrame, "MOVEAMT", 45, 20, 0, yPos - 48, 4, 50)
yPos = yPos - 5

-- Compass layout
local NORTH = GOMove:CreateButton(MainFrame, "N", 36, 22, 0, yPos - 20)
function NORTH:OnClick() GOMove:Move("NORTH", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(NORTH, "Move North", "Move object north (+X) by the specified amount")

local SOUTH = GOMove:CreateButton(MainFrame, "S", 36, 22, 0, yPos - 64)
function SOUTH:OnClick() GOMove:Move("SOUTH", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(SOUTH, "Move South", "Move object south (-X) by the specified amount")

local EAST = GOMove:CreateButton(MainFrame, "E", 36, 22, 40, yPos - 42)
function EAST:OnClick() GOMove:Move("EAST", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(EAST, "Move East", "Move object east (-Y) by the specified amount")

local WEST = GOMove:CreateButton(MainFrame, "W", 36, 22, -40, yPos - 42)
function WEST:OnClick() GOMove:Move("WEST", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(WEST, "Move West", "Move object west (+Y) by the specified amount")

local NORTHEAST = GOMove:CreateButton(MainFrame, "NE", 32, 18, 35, yPos - 23)
function NORTHEAST:OnClick() GOMove:Move("NORTHEAST", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(NORTHEAST, "Move Northeast", "Move object diagonally northeast")

local NORTHWEST = GOMove:CreateButton(MainFrame, "NW", 32, 18, -35, yPos - 23)
function NORTHWEST:OnClick() GOMove:Move("NORTHWEST", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(NORTHWEST, "Move Northwest", "Move object diagonally northwest")

local SOUTHEAST = GOMove:CreateButton(MainFrame, "SE", 32, 18, 35, yPos - 61)
function SOUTHEAST:OnClick() GOMove:Move("SOUTHEAST", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(SOUTHEAST, "Move Southeast", "Move object diagonally southeast")

local SOUTHWEST = GOMove:CreateButton(MainFrame, "SW", 32, 18, -35, yPos - 61)
function SOUTHWEST:OnClick() GOMove:Move("SOUTHWEST", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(SOUTHWEST, "Move Southwest", "Move object diagonally southwest")

yPos = yPos - 90

-- Vertical movement (Up/Down)
local UP = GOMove:CreateButton(MainFrame, "Up", 60, 20, -35, yPos)
function UP:OnClick() GOMove:Move("UP", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(UP, "Move Up", "Move object up (+Z) by the specified amount")

local DOWN = GOMove:CreateButton(MainFrame, "Down", 60, 20, 35, yPos)
function DOWN:OnClick() GOMove:Move("DOWN", MOVEAMT:GetNumber()) end
GOMove:SetupTooltip(DOWN, "Move Down", "Move object down (-Z) by the specified amount")

yPos = yPos - 25

-- Snap to position buttons
local X = GOMove:CreateButton(MainFrame, "X", 32, 20, -55, yPos)
function X:OnClick() GOMove:Move("X") end
GOMove:SetupTooltip(X, "Snap X", "Set object X position to your current X position")

local Y = GOMove:CreateButton(MainFrame, "Y", 32, 20, -18, yPos)
function Y:OnClick() GOMove:Move("Y") end
GOMove:SetupTooltip(Y, "Snap Y", "Set object Y position to your current Y position")

local Z = GOMove:CreateButton(MainFrame, "Z", 32, 20, 18, yPos)
function Z:OnClick() GOMove:Move("Z") end
GOMove:SetupTooltip(Z, "Snap Z", "Set object Z position to your current Z position")

local O = GOMove:CreateButton(MainFrame, "O", 32, 20, 55, yPos)
function O:OnClick() GOMove:Move("O") end
GOMove:SetupTooltip(O, "Snap Orientation", "Set object orientation to your current facing direction")

yPos = yPos - 33
CreateSeparator(MainFrame, yPos)
yPos = yPos - 8

-- ============================================================================
-- SECTION: Rotation
-- ============================================================================
CreateSectionHeader(MainFrame, "— Rotation —", yPos)
yPos = yPos - 15

-- Pitch/Roll sliders
local PITCHSLIDER = GOMove:CreateSlider(MainFrame, "Pitch", 150, 0, yPos, -180, 180, 0)
GOMove.PITCHSLIDER = PITCHSLIDER
function PITCHSLIDER:OnValueChanged(value)
    local radians = math.floor(value * math.pi / 180 * 100 + 0.5)
    GOMove:Move("SETPITCH", radians + 18000)
end
yPos = yPos - 40

local ROLLSLIDER = GOMove:CreateSlider(MainFrame, "Roll", 150, 0, yPos, -180, 180, 0)
GOMove.ROLLSLIDER = ROLLSLIDER
function ROLLSLIDER:OnValueChanged(value)
    local radians = math.floor(value * math.pi / 180 * 100 + 0.5)
    GOMove:Move("SETROLL", radians + 18000)
end
yPos = yPos - 40

-- Turn/Orientation slider
local TURNSLIDER = GOMove:CreateSlider(MainFrame, "Turn", 150, 0, yPos, -180, 180, 0)
GOMove.TURNSLIDER = TURNSLIDER
function TURNSLIDER:OnValueChanged(value)
    local radians = math.floor(value * math.pi / 180 * 100 + 0.5)
    GOMove:Move("SETTURN", radians + 18000)
end
yPos = yPos - 40

-- Helper function to reset all sliders (rotation and scale) without triggering callbacks
function GOMove:ResetAllSliders()
    if self.PITCHSLIDER then self.PITCHSLIDER:SetValueSilent(0) end
    if self.ROLLSLIDER then self.ROLLSLIDER:SetValueSilent(0) end
    if self.TURNSLIDER then self.TURNSLIDER:SetValueSilent(0) end
    if self.SCALESLIDER then self.SCALESLIDER:SetValueSilent(100) end
end

-- Keep old function name for backwards compatibility
GOMove.ResetRotationSliders = GOMove.ResetAllSliders

CreateSeparator(MainFrame, yPos)
yPos = yPos - 8

-- ============================================================================
-- SECTION: Scale
-- ============================================================================
CreateSectionHeader(MainFrame, "— Scale —", yPos)
yPos = yPos - 15

local SCALESLIDER = GOMove:CreateSlider(MainFrame, "Scale", 150, 0, yPos, 10, 500, 100)
GOMove.SCALESLIDER = SCALESLIDER
function SCALESLIDER:OnValueChanged(value)
    -- Scale value: 100 = normal (1.0), 10 = 0.1, 500 = 5.0
    GOMove:Move("SETSCALE", value)
end
yPos = yPos - 40

-- Scale buttons for quick adjustments
local SCALEDOWN = GOMove:CreateButton(MainFrame, "-", 35, 22, -55, yPos)
function SCALEDOWN:OnClick()
    local current = SCALESLIDER:GetValue()
    local newVal = math.max(10, current - 10)
    SCALESLIDER:SetValue(newVal)
end
GOMove:SetupTooltip(SCALEDOWN, "Scale Down", "Decrease object scale by 10%")

local SCALERESET = GOMove:CreateButton(MainFrame, "100%", 50, 22, 0, yPos)
function SCALERESET:OnClick()
    SCALESLIDER:SetValue(100)
end
GOMove:SetupTooltip(SCALERESET, "Reset Scale", "Reset object scale to 100% (normal size)")

local SCALEUP = GOMove:CreateButton(MainFrame, "+", 35, 22, 55, yPos)
function SCALEUP:OnClick()
    local current = SCALESLIDER:GetValue()
    local newVal = math.min(500, current + 10)
    SCALESLIDER:SetValue(newVal)
end
GOMove:SetupTooltip(SCALEUP, "Scale Up", "Increase object scale by 10%")

yPos = yPos - 28

CreateSeparator(MainFrame, yPos)
yPos = yPos - 8

-- ============================================================================
-- SECTION: Tools
-- ============================================================================
CreateSectionHeader(MainFrame, "— Tools —", yPos)
yPos = yPos - 10

local SELECTNEAR = GOMove:CreateButton(MainFrame, "Select", 50, 22, -55, yPos)
function SELECTNEAR:OnClick() GOMove:Move("SELECTNEAR") end
GOMove:SetupTooltip(SELECTNEAR, "Select Nearest", "Select the nearest gameobject to your character")

local FACE = GOMove:CreateButton(MainFrame, "Snap", 50, 22, 0, yPos)
function FACE:OnClick() GOMove:Move("FACE") end
GOMove:SetupTooltip(FACE, "Snap Facing", "Snap your character's facing to the nearest 90-degree angle")

local DELETE = GOMove:CreateButton(MainFrame, "Delete", 50, 22, 55, yPos)
function DELETE:OnClick() GOMove:Move("DELETE") end
GOMove:SetupTooltip(DELETE, "Delete Object", "Delete the selected gameobject(s) from the world")

yPos = yPos - 26

local GROUND = GOMove:CreateButton(MainFrame, "Ground", 52, 22, -55, yPos)
function GROUND:OnClick() GOMove:Move("GROUND") end
GOMove:SetupTooltip(GROUND, "Snap to Ground", "Move object to ground level (terrain height)")

local FLOOR = GOMove:CreateButton(MainFrame, "Floor", 52, 22, 0, yPos)
function FLOOR:OnClick() GOMove:Move("FLOOR") end
GOMove:SetupTooltip(FLOOR, "Snap to Floor", "Move object to the floor below its current position")

local GOTO = GOMove:CreateButton(MainFrame, "Go To", 52, 22, 55, yPos)
function GOTO:OnClick() GOMove:Move("GOTO") end
GOMove:SetupTooltip(GOTO, "Teleport to Object", "Teleport your character to the selected object's location")

yPos = yPos - 26

local RESPAWN = GOMove:CreateButton(MainFrame, "Respawn", 52, 22, -55, yPos)
function RESPAWN:OnClick()
    GOMove.IsSpawning = true
    GOMove:Move("RESPAWN")
end
GOMove:SetupTooltip(RESPAWN, "Respawn Object", "Create a copy of the selected object at your current position")

local COPY = GOMove:CreateButton(MainFrame, "Copy", 52, 22, 0, yPos)
function COPY:OnClick()
    -- Copy the first selected object to clipboard
    for GUID, NAME in pairs(GOMove.Selected) do
        if tonumber(GUID) then
            -- Find the entry in SelL
            for k, tbl in ipairs(GOMove.SelL) do
                if tbl[2] == GUID then
                    GOMove:CopyToClipboard(tbl[3], tbl[1])
                    return
                end
            end
        end
    end
    UIErrorsFrame:AddMessage("No object selected to copy", 1.0, 0.0, 0.0, 53, 2)
end
GOMove:SetupTooltip(COPY, "Copy Object", "Copy selected object entry to clipboard for pasting")

local PASTE = GOMove:CreateButton(MainFrame, "Paste", 52, 22, 55, yPos)
function PASTE:OnClick()
    GOMove:PasteFromClipboard()
end
GOMove:SetupTooltip(PASTE, "Paste Object", "Spawn a copy of the copied object at your current position")

yPos = yPos - 26

local INFO = GOMove:CreateButton(MainFrame, "Info", 70, 22, -40, yPos)
function INFO:OnClick() GOMove:Move("INFO") end
GOMove:SetupTooltip(INFO, "Object Information", "Display detailed information about the selected object")

local GRIDSNAP = GOMove:CreateButton(MainFrame, "Grid", 70, 22, 40, yPos)
function GRIDSNAP:OnClick()
    GOMove:ToggleGridSnap()
    if GOMove.GridSnapEnabled then
        GRIDSNAP:SetText("|cFF00FF00Grid|r")
    else
        GRIDSNAP:SetText("Grid")
    end
end
GOMove:SetupTooltip(GRIDSNAP, "Toggle Grid Snap", "Enable/disable snapping object movements to a grid")

yPos = yPos - 35
CreateSeparator(MainFrame, yPos)
yPos = yPos - 8

-- ============================================================================
-- SECTION: Spawn
-- ============================================================================
CreateSectionHeader(MainFrame, "— Spawn —", yPos)
yPos = yPos - 10

local ENTRY = GOMove:CreateInput(MainFrame, "ENTRY", 70, 22, -25, yPos, 10)
local SPAWN = GOMove:CreateButton(MainFrame, "Spawn", 55, 22, 50, yPos)
function SPAWN:OnClick()
    GOMove.IsSpawning = true
    GOMove:Move("SPAWN", ENTRY:GetNumber())
end
GOMove:SetupTooltip(SPAWN, "Spawn Object", "Spawn a new gameobject with the specified entry ID")

yPos = yPos - 28

local RADIUS = GOMove:CreateInput(MainFrame, "RADIUS", 45, 22, -50, yPos, 4)
local SELECTALLNEAR = GOMove:CreateButton(MainFrame, "Select Radius", 90, 22, 35, yPos)
function SELECTALLNEAR:OnClick() GOMove:Move("SELECTALLNEAR", RADIUS:GetNumber()) end
GOMove:SetupTooltip(SELECTALLNEAR, "Select by Radius", "Select all gameobjects within the specified radius")

yPos = yPos - 28

local MASK = GOMove:CreateInput(MainFrame, "MASK", 70, 22, -25, yPos, 10)
local PHASE = GOMove:CreateButton(MainFrame, "Phase", 55, 22, 50, yPos)
function PHASE:OnClick() GOMove:Move("PHASE", MASK:GetNumber()) end
GOMove:SetupTooltip(PHASE, "Set Phase Mask", "Change the phase mask of selected object(s)")

yPos = yPos - 32

-- ============================================================================
-- SECTION: Lists
-- ============================================================================
local FAVOURITES = GOMove:CreateButton(MainFrame, "Favourites", 75, 24, -40, yPos)
function FAVOURITES:OnClick()
    if(FavFrame:IsVisible()) then FavFrame:Hide() else FavFrame:Show() end
end
GOMove:SetupTooltip(FAVOURITES, "Favourites List", "Show/hide your saved favourite gameobjects")

local SELECTIONS = GOMove:CreateButton(MainFrame, "Selections", 75, 24, 40, yPos)
function SELECTIONS:OnClick()
    if(SelFrame:IsVisible()) then SelFrame:Hide() else SelFrame:Show() end
end
GOMove:SetupTooltip(SELECTIONS, "Selection List", "Show/hide the list of currently selected objects")

-- ============================================================================
-- Slash Commands
-- ============================================================================
GOMove.SCMD = {}
function GOMove.SCMD.help()
    print("|cFF00FF00[GOMove] Commands:|r")
    for k, v in pairs(GOMove.SCMD) do
        if type(v) == "function" then
            print("  /gomove " .. k)
        end
    end
end

function GOMove.SCMD.reset()
    for k, inputfield in ipairs(GOMove.Inputs) do
        inputfield:ClearFocus()
    end
    print("|cFF00FF00[GOMove]|r Frames reset")
    for k, Frame in pairs(GOMove.Frames) do
        if(Frame.Default) then
            Frame:ClearAllPoints()
            Frame:SetPoint(Frame.Default[1], Frame.Default[2], Frame.Default[3], Frame.Default[4], Frame.Default[5])
        end
        Frame:Show()
    end
end

function GOMove.SCMD.invertselection()
    local sel = {}
    for GUID, NAME in pairs(GOMove.Selected) do
        if(tonumber(GUID)) then
            table.insert(sel, GUID)
        end
    end
    for k, tbl in ipairs(SelFrame.DataTable) do
        GOMove.Selected:Add(tbl[1], tbl[2])
    end
    for k,v in ipairs(sel) do
        GOMove.Selected:Del(v)
    end
    SelFrame:Update()
end

function GOMove.SCMD.resetsliders()
    PITCHSLIDER:SetValue(0)
    ROLLSLIDER:SetValue(0)
    TURNSLIDER:SetValue(0)
    SCALESLIDER:SetValue(100)
    print("|cFF00FF00[GOMove]|r Sliders reset to defaults")
end

function GOMove.SCMD.copy()
    -- Copy the first selected object to clipboard
    for GUID, NAME in pairs(GOMove.Selected) do
        if tonumber(GUID) then
            for k, tbl in ipairs(GOMove.SelL) do
                if tbl[2] == GUID then
                    GOMove:CopyToClipboard(tbl[3], tbl[1])
                    return
                end
            end
        end
    end
    print("|cFF00FF00[GOMove]|r No object selected to copy")
end

function GOMove.SCMD.paste()
    GOMove:PasteFromClipboard()
end

function GOMove.SCMD.clearundo()
    GOMove:ClearUndo()
    print("|cFF00FF00[GOMove]|r Undo history cleared")
end

function GOMove.SCMD.gridsize()
    print("|cFF00FF00[GOMove]|r Usage: /gomove gridsize <number>")
    print("|cFF00FF00[GOMove]|r Current grid size: " .. GOMove.GridSnapSize)
end

function GOMove.SCMD.grid()
    GOMove:ToggleGridSnap()
end

function GOMove.SCMD.scale()
    print("|cFF00FF00[GOMove]|r Current scale: " .. SCALESLIDER:GetValue() .. "%")
end

function GOMove.SCMD.selectall()
    for k, tbl in ipairs(GOMove.SelL) do
        GOMove.Selected:Add(tbl[1], tbl[2])
    end
    SelFrame:Update()
    print("|cFF00FF00[GOMove]|r All objects in selection list now selected")
end

function GOMove.SCMD.clearselection()
    for k,v in pairs(GOMove.Selected) do
        if tonumber(k) then
            GOMove.Selected:Del(k)
        end
    end
    SelFrame:Update()
    print("|cFF00FF00[GOMove]|r Selection cleared")
end

SLASH_GOMOVE1 = '/gomove'
function SlashCmdList.GOMOVE(msg, editBox)
    if(msg ~= '') then
        -- Check for gridsize with argument
        local cmd, arg = msg:match("^(%S+)%s*(.*)$")
        if cmd and cmd:lower() == "gridsize" and arg ~= "" then
            local size = tonumber(arg)
            if size and size > 0 then
                GOMove:SetGridSize(size)
            else
                print("|cFF00FF00[GOMove]|r Invalid grid size. Use a positive number.")
            end
            return
        end
        
        for k, v in pairs(GOMove.SCMD) do
            if(type(k) == "string" and string.find(k, msg:lower()) == 1 and type(v) == "function") then
                v()
                break;
            end
        end
        return
    end
    if(MainFrame:IsVisible()) then
        MainFrame:Hide()
    else
        MainFrame:Show()
    end
end

-- ============================================================================
-- Keyboard Shortcuts Handler (3.3.5a compatible)
-- ============================================================================
-- Note: In 3.3.5a, we use a workaround with key bindings instead of SetPropagateKeyboardInput
GOMove.KeybindsEnabled = false

-- Keybind settings (can be customized)
GOMove.Keybinds = {
    DELETE = "DELETE",      -- Delete selected objects
    SELECTNEAR = "INSERT",  -- Select nearest object
}

-- Enable/disable keybinds using SetBinding (3.3.5a compatible)
function GOMove:EnableKeybinds(enable)
    if enable then
        self.KeybindsEnabled = true
        print("|cFF00FF00[GOMove]|r Keyboard shortcuts enabled (use /gomove keybinds to disable)")
        print("|cFF00FF00[GOMove]|r  DELETE: Delete selected | INSERT: Select nearest | /gomove paste: Paste")
    else
        self.KeybindsEnabled = false
        print("|cFF00FF00[GOMove]|r Keyboard shortcuts disabled")
    end
end

-- Main frame OnKeyDown handler (attached to MainFrame)
MainFrame:EnableKeyboard(true)
MainFrame:SetScript("OnKeyDown", function(self, key)
    if not GOMove.KeybindsEnabled then return end
    if not GOMove.MainFrame:IsVisible() then return end
    
    -- Delete key for delete
    if key == "DELETE" and not IsControlKeyDown() and not IsShiftKeyDown() then
        GOMove:Move("DELETE")
    end
    
    -- Insert key for select nearest
    if key == "INSERT" then
        GOMove:Move("SELECTNEAR")
    end
end)

function GOMove.SCMD.keybinds()
    if GOMove.KeybindsEnabled then
        GOMove:EnableKeybinds(false)
    else
        GOMove:EnableKeybinds(true)
    end
end

-- ============================================================================
-- Event Handler
-- ============================================================================
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")

EventFrame:SetScript("OnEvent",
    function(self, event, MSG, MSG2, Type, Sender)
        if(event == "CHAT_MSG_ADDON" and Sender == UnitName("player")) then
            if MSG ~= "GOMOVE" then return end
            local ID, ENTRYORGUID, ARG2, ARG3 = MSG2:match("^(.+)|([%a%d]+)|(.*)|([%a%d]+)$")
            if(ID) then
                if(ID == "REMOVE") then
                    local guid = ENTRYORGUID
                    GOMove.Selected:Del(guid)
                    for k,tbl in ipairs(GOMove.SelL) do
                        if(tbl[2] == guid) then
                            GOMove.SelL:Del(guid)
                            break
                        end
                    end
                    GOMove:Update()
                elseif(ID == "ADD") then
                    local guid = ENTRYORGUID
                    -- If spawning, clear all existing selections first
                    if GOMove.IsSpawning then
                        for k,v in pairs(GOMove.Selected) do
                            if(tonumber(k)) then
                                GOMove.Selected:Del(k)
                            end
                        end
                        GOMove.IsSpawning = false
                    end
                    GOMove.Selected:Add(ARG2, guid)
                    local exists = false
                    for k, tbl in ipairs(GOMove.SelL) do
                        if(tbl[2] == guid) then
                            exists = true
                            break
                        end
                    end
                    if(not exists) then
                        GOMove.SelL:Add(ARG2, guid, ARG3)
                    end
                    -- Reset sliders to 0 when selecting a gameobject
                    GOMove:ResetRotationSliders()
                    GOMove:Update()
                elseif(ID == "SWAP") then
                    local oldGUID, newGUID = ENTRYORGUID, ARG3
                    GOMove.Selected:Add(GOMove.Selected[oldGUID], newGUID)
                    GOMove.Selected:Del(oldGUID)
                    for k,tbl in ipairs(GOMove.SelL) do
                        if(tbl[2] == oldGUID) then
                            tbl[2] = newGUID
                            break
                        end
                    end
                    GOMove:Update()
                elseif(ID == "INFO") then
                    local guid = ENTRYORGUID
                    local name = ARG2
                    local entry = ARG3
                    print("|cFF00FF00[GOMove]|r Object Info:")
                    print(string.format("  |cFFFFFFFFGUID:|r %s  |cFFFFFFFFEntry:|r %s", guid, entry))
                    print(string.format("  |cFFFFFFFFName:|r %s", name))
                end
            end
        elseif(MSG == "GOMove" and event == "ADDON_LOADED") then
            if(not GOMoveSV or type(GOMoveSV) ~= "table") then
                GOMoveSV = {}
            end
            if(GOMoveSV.FavL) then
                for k,v in ipairs(GOMoveSV.FavL) do
                    GOMove.FavL[k] = v
                end
            end
            GOMove:Update()
            print("|cFF00FF00[GOMove]|r Loaded. Type |cFFFFD100/gomove|r to toggle UI.")
        end
    end
)