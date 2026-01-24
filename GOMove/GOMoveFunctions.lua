GOMove = {Frames = {}, Inputs = {}}

function GOMove:Update()
    for k, Frame in ipairs(GOMove.Frames) do
        if(Frame.Update) then
            Frame:Update()
        end
    end
end

function GOMove:CreateFrame(name, width, height, DataTable, both)
    local Frame = CreateFrame("Frame", name, UIParent)
    Frame:SetMovable(true)
    Frame:EnableMouse(true)
    Frame:SetClampedToScreen(true);
    Frame:RegisterForDrag("LeftButton")
    Frame:SetScript("OnDragStart", Frame.StartMoving)
    Frame:SetScript("OnDragStop", Frame.StopMovingOrSizing)
    Frame:SetScript("OnHide", Frame.StopMovingOrSizing)
    Frame:SetSize(width, height)
    Frame:SetPoint("CENTER")
    Frame.ButtonCount = math.floor((height-32)/16)
    Frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    local NameFrame = CreateFrame("Frame", name.."_Name", Frame)
    NameFrame:SetHeight(16)
    NameFrame:SetWidth(width-16)
    NameFrame.text = NameFrame:CreateFontString()
    NameFrame.text:SetFont("Fonts\\MORPHEUS.ttf", 14)
    NameFrame.text:SetTextColor(0.8, 0.2, 0.2)
    NameFrame.text:SetJustifyH("LEFT")
    NameFrame.text:SetAllPoints()
    NameFrame.text:SetText(name:gsub("_", " "))
    NameFrame:SetPoint("TOPLEFT", Frame, "TOPLEFT", 8, -8)
    NameFrame:Show()
    Frame.NameFrame = NameFrame
    local CloseButton = CreateFrame("Button", name.."_CloseButton", Frame)
    CloseButton:SetSize(25, 25)
    CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    CloseButton:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", 0, 0)
    CloseButton:SetScript("OnClick", function() Frame:Hide() end)

    if(DataTable) then
        Frame.DataTable = DataTable
        function Frame:Update()
            local maxValue = #DataTable
            FauxScrollFrame_Update(self.ScrollBar, maxValue, self.ButtonCount, 16, nil, nil, nil, nil, nil, nil, true)
            local offset = FauxScrollFrame_GetOffset(self.ScrollBar)
            for Button = 1, self.ButtonCount do
                local value = Button + offset
                if value <= maxValue then
                    local Button = self.Buttons[Button]
                    local Label = DataTable[value][1]
                    if(DataTable.NameWidth and strlen(DataTable[value][1]) > DataTable.NameWidth) then
                        Label = DataTable[value][1]:sub(0, DataTable.NameWidth-2)..".."
                    end
                    if(not both) then
                        Button:SetText(Label)
                    else
                        Button:SetText(DataTable[value][2].." "..Label)
                    end
                    Button.MiscButton:Show()
                    Button:Show()
                else
                    self.Buttons[Button]:Hide()
                    self.Buttons[Button].MiscButton:Hide()
                end
                if(Frame.UpdateScript) then
                    Frame:UpdateScript(Button)
                end
            end
        end

        local ScrollBar = CreateFrame("ScrollFrame", "$parent_ScrollBar", Frame, "FauxScrollFrameTemplate")
        ScrollBar:SetPoint("TOPLEFT", 0, -24) -- -8
        ScrollBar:SetPoint("BOTTOMRIGHT", -30, 8)

        ScrollBar:SetScript("OnVerticalScroll", function(self, offset)
            self.offset = math.floor(offset / 16 + 0.5)
            Frame:Update()
        end)

        ScrollBar:SetScript("OnShow", function()
            Frame:Update()
        end)

        Frame.ScrollBar = ScrollBar

        local Buttons = setmetatable({}, { __index = function(t, i)
            local Button = CreateFrame("Button", "$parent_Button"..i, Frame)
            Button:SetSize(width-55, 16)
            Button:SetNormalFontObject(GameFontHighlightLeft)
            if i == 1 then
                Button:SetPoint("TOPLEFT", ScrollBar, 8, 0)
            else
                Button:SetPoint("TOPLEFT", Frame.Buttons[i-1], "BOTTOMLEFT")
            end
            Button:SetScript("OnClick", function(self) if(Frame.ButtonOnClick) then Frame:ButtonOnClick(i) end end)
            local MiscButton = CreateFrame("Button", "$parent_Button"..i.."_Misc", Frame)
            MiscButton:SetSize(16, 16)
            MiscButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Disabled")
            MiscButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
            MiscButton:SetHighlightTexture("Interface\\Buttons\\UI-MinusButton-Up")
            MiscButton:SetNormalFontObject(GameFontHighlightLeft)
            MiscButton:SetPoint("TOPLEFT", Button, "TOPRIGHT", 0, 0)
            MiscButton:SetScript("OnClick", function(self) if(Frame.MiscOnClick) then Frame:MiscOnClick(i) end end)
            Button.MiscButton = MiscButton
            rawset(t, i, Button)
            return Button
        end })

        Frame.Buttons = Buttons
        Frame:Update()
    end
    function Frame:Position(FramePoint, Parent, ParentPoint, Ox, Oy)
        Frame.Default = {FramePoint, Parent, ParentPoint, Ox, Oy}
        Frame:SetPoint(FramePoint, Parent, ParentPoint, Ox, Oy)
    end
    table.insert(GOMove.Frames, Frame)
    return Frame
end

function GOMove:CreateButton(Frame, name, width, height, Ox, Oy)
    local Button = CreateFrame("Button", Frame:GetName().."_"..name, Frame, "UIPanelButtonTemplate")
    Button:SetSize(width, height)
    Button:SetText(name)
    Button:SetPoint("TOP", Frame, "TOP", Ox, Oy-10)
    Button:SetScript("OnClick", function(self) if(self.OnClick) then self:OnClick(Frame) end end)
    return Button
end

function GOMove:CreateInput(Frame, name, width, height, Ox, Oy, letters, default)
    local Input = CreateFrame("EditBox", Frame:GetName().."_"..name, Frame, "InputBoxTemplate")
    Input:SetSize(width, height)
    Input:SetPoint("TOP", Frame, "TOP", Ox+2.5, Oy-10)
    Input:SetAutoFocus(false)
    Input:SetNumeric(true)
    Input:SetMaxLetters(letters)
    Input:SetScript("OnEnterPressed", function() Input:ClearFocus() end)
    Input:SetScript("OnEscapePressed", function() Input:ClearFocus() end)
    if(default) then
        Input:SetNumber(default)
    end
    table.insert(GOMove.Inputs, Input)
    return Input
end

function GOMove:CreateSlider(Frame, name, width, Ox, Oy, minVal, maxVal, defaultVal)
    local Slider = CreateFrame("Slider", Frame:GetName().."_"..name, Frame, "OptionsSliderTemplate")
    Slider:SetSize(width, 17)
    Slider:SetPoint("TOP", Frame, "TOP", Ox, Oy-10)
    Slider:SetMinMaxValues(minVal, maxVal)
    Slider:SetValue(defaultVal or 0)
    Slider:SetValueStep(1)
    Slider:EnableMouseWheel(true)
    
    -- Set label text
    local sliderName = Slider:GetName()
    if _G[sliderName.."Text"] then
        _G[sliderName.."Text"]:SetText(name)
    end
    if _G[sliderName.."Low"] then
        _G[sliderName.."Low"]:SetText(minVal)
    end
    if _G[sliderName.."High"] then
        _G[sliderName.."High"]:SetText(maxVal)
    end
    
    -- Create value display
    Slider.ValueText = Slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Slider.ValueText:SetPoint("TOP", Slider, "BOTTOM", 0, 0)
    Slider.ValueText:SetText(defaultVal or 0)
    
    -- Track if we're dragging or silently updating
    Slider.isDragging = false
    Slider.isSilentUpdate = false
    
    -- Set value without triggering the callback
    function Slider:SetValueSilent(value)
        self.isSilentUpdate = true
        self:SetValue(value)
        self.isSilentUpdate = false
    end
    
    -- Update display on value change, but only execute callback on mouse up
    Slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        self:SetValue(value) -- Snap to integer
        self.ValueText:SetText(value)
        -- Only fire callback if not dragging and not a silent update
        if not self.isDragging and not self.isSilentUpdate and self.OnValueChanged then
            self:OnValueChanged(value)
        end
    end)
    
    Slider:SetScript("OnMouseDown", function(self)
        self.isDragging = true
    end)
    
    Slider:SetScript("OnMouseUp", function(self)
        self.isDragging = false
        local value = math.floor(self:GetValue() + 0.5)
        if self.OnValueChanged then
            self:OnValueChanged(value)
        end
    end)
    
    -- Mouse wheel support for fine control
    Slider:SetScript("OnMouseWheel", function(self, delta)
        local value = self:GetValue() + delta
        local min, max = self:GetMinMaxValues()
        if value < min then value = min end
        if value > max then value = max end
        self:SetValue(value)
    end)
    
    return Slider
end

local trinityID = {}
local TIDs = 0
local function TID(name, reqguid, onetime)
    trinityID[name] = {TIDs, reqguid, onetime}
    TIDs = TIDs+1
end

-- NEED to be in order(same as core)
TID("TEST"              ,   false   ,   true    ) -- unused
TID("SELECTNEAR"        ,   false   ,   true    )
TID("DELETE"            ,   true    ,   true    )
TID("X"                 ,   true    ,   false   )
TID("Y"                 ,   true    ,   false   )
TID("Z"                 ,   true    ,   false   )
TID("O"                 ,   true    ,   false   )
TID("GROUND"            ,   true    ,   false   )
TID("FLOOR"             ,   true    ,   false   )
TID("RESPAWN"           ,   true    ,   true    )
TID("GOTO"              ,   true    ,   true    )
TID("FACE"              ,   false   ,   true    )
TID("INFO"              ,   true    ,   true    )
--TID("SAVE"            ,   true    ,   true    )

TID("SPAWN"             ,   false   ,   true    )
TID("NORTH"             ,   true    ,   false   )
TID("EAST"              ,   true    ,   false   )
TID("SOUTH"             ,   true    ,   false   )
TID("WEST"              ,   true    ,   false   )
TID("NORTHEAST"         ,   true    ,   false   )
TID("NORTHWEST"         ,   true    ,   false   )
TID("SOUTHEAST"         ,   true    ,   false   )
TID("SOUTHWEST"         ,   true    ,   false   )
TID("UP"                ,   true    ,   false   )
TID("DOWN"              ,   true    ,   false   )
TID("LEFT"              ,   true    ,   false   )
TID("RIGHT"             ,   true    ,   false   )
TID("PHASE"             ,   true    ,   false   )
TID("SELECTALLNEAR"     ,   false   ,   true    )
TID("SPAWNSPELL"        ,   false   ,   true    )
TID("PITCHUP"           ,   true    ,   false   )
TID("PITCHDOWN"         ,   true    ,   false   )
TID("ROLLRIGHT"         ,   true    ,   false   )
TID("ROLLLEFT"          ,   true    ,   false   )
TID("SETPITCH"          ,   true    ,   false   )
TID("SETROLL"           ,   true    ,   false   )
TID("SETTURN"           ,   true    ,   false   )
--TID("COPYSEL"         ,   false   ,   false   )
--TID("COPY"            ,   false   ,   false   )
--TID("BIG"             ,   false   ,   false   )
--TID("SMALL"           ,   false   ,   false   )

function GOMove:Move(ID, input)
    if(UnitIsDeadOrGhost("player")) then
        NotWhileDeadError()
        return
    end
    for k, inputfield in ipairs(GOMove.Inputs) do
        inputfield:ClearFocus()
    end
    local ARG = 0
    if(input) then
        ARG = input
    end
    if(not trinityID[ID] or not tonumber(trinityID[ID][1])) then
        return
    end
    if(not trinityID[ID][2]) then
        SendChatMessage(".gomove "..trinityID[ID][1].." "..(0).." "..ARG)
    elseif(trinityID[ID][3] and tonumber(ARG) and tonumber(ARG) > 0) then
        SendChatMessage(".gomove "..trinityID[ID][1].." "..ARG.." "..(0))
    else
        local did = false
        for GUID, NAME in pairs(GOMove.Selected) do
            if(tonumber(GUID)) then
                SendChatMessage(".gomove "..trinityID[ID][1].." "..GUID.." "..ARG)
                if(ID == "GOTO") then
                    return
                end
                did = true
            end
        end
        if(not did) then
            UIErrorsFrame:AddMessage("No objects selected", 1.0, 0.0, 0.0, 53, 2)
            return
        end
    end
end
