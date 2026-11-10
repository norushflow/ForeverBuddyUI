local addonName, ns = ...

-- Based on the Retail design. Each addon loads its own style without a dependency.
local Style = {}
ns.Style = Style

local Color = {
    background = {.048, .035, .024, .96},
    inset = {.026, .021, .016, .93},
    header = {.20, .12, .055, .44},
    border = {.56, .40, .22, .83},
    bronze = {.68, .49, .28, 1},
    gold = {1, .82, .44, 1},
    text = {.96, .91, .81, 1},
    muted = {.76, .70, .61, 1},
    disabled = {.58, .54, .48, 1},
    button = {.31, .24, .16, 1},
    highlight = {1, .74, .35, .18},
    selected = {1, .75, .37, .9},
    success = {.51, .84, .44, 1},
    danger = {1, .45, .36, 1},
    info = {.55, .80, .94, 1},
    transparent = {0, 0, 0, 0},
}
Style.Color = Color
Style.Spacing = {small = 4, gap = 8, inset = 12, panel = 16}
Style.WHITE = "Interface\\Buttons\\WHITE8X8"
local ROCK = "Interface\\FrameGeneral\\UI-Background-Rock"
local NAMEPLATE_BAR = "UI-HUD-CoolDownManager-Bar"
local CLASSIC_BAR = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
local sizes = {title = 20, heading = 15, body = 13, small = 11, button = 13, hud = 12, tooltip = 13}
local expressway = "Interface\\AddOns\\" .. addonName .. "\\Media\\Expressway.ttf"
local fontPath

local function hasBarAtlas()
    return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(NAMEPLATE_BAR)
end

function Style.Bar(bar)
    if not hasBarAtlas() or not bar:SetStatusBarTexture(NAMEPLATE_BAR) then
        bar:SetStatusBarTexture(CLASSIC_BAR)
    end
end

function Style.BarTexture(texture)
    if hasBarAtlas() then
        texture:SetAtlas(NAMEPLATE_BAR)
    else
        texture:SetTexture(CLASSIC_BAR)
    end
end

function Style.Hex(color)
    local r, g, b = unpack(color)
    return ("|cff%02x%02x%02x"):format(math.floor(r * 255 + .5), math.floor(g * 255 + .5), math.floor(b * 255 + .5))
end

function Style.Font(region, role, flags, color)
    if not region then return end
    local size = type(role) == "number" and role or sizes[role] or sizes.body
    flags = flags or ""
    if not fontPath then
        local locale = GetLocale and GetLocale()
        if locale ~= "koKR" and locale ~= "zhCN" and locale ~= "zhTW" then
            -- Font objects have no success return. A missing font can raise.
            local ok, loaded = pcall(region.SetFont, region, expressway, size, flags)
            if ok and loaded ~= false then fontPath = expressway end
        end
        if not fontPath then
            fontPath = (GameFontNormal and GameFontNormal:GetFont()) or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
            region:SetFont(fontPath, size, flags)
        end
    else
        region:SetFont(fontPath, size, flags)
    end
    if color then region:SetTextColor(unpack(color)) end
    return region
end

function Style.Text(parent, role, color, flags)
    local text = parent:CreateFontString(nil, "OVERLAY")
    local heading = role == "title" or role == "heading"
    Style.Font(text, role, flags, color or (heading and Color.gold or Color.text))
    text:SetShadowColor(0, 0, 0, .9)
    text:SetShadowOffset(1, -1)
    return text
end

local function fill(frame, layer, subLevel, color)
    local texture = frame:CreateTexture(nil, layer, nil, subLevel)
    texture:SetAllPoints(frame)
    texture:SetColorTexture(unpack(color))
    return texture
end

local function stone(frame, path)
    local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
    texture:SetAllPoints(frame)
    texture:SetTexture(path)
    if texture.SetHorizTile then texture:SetHorizTile(true) end
    if texture.SetVertTile then texture:SetVertTile(true) end
    return texture
end

function Style.Divider(frame, color)
    local edge = frame:CreateTexture(nil, "BORDER")
    edge:SetHeight(1)
    edge:SetColorTexture(unpack(color or Color.border))
    return edge
end

function Style.Border(frame, color, layer, subLevel)
    local borders = {}
    for _, side in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
        local edge = frame:CreateTexture(nil, layer or "BORDER", nil, subLevel)
        if side == "TOP" or side == "BOTTOM" then
            edge:SetPoint(side .. "LEFT", frame, side .. "LEFT")
            edge:SetPoint(side .. "RIGHT", frame, side .. "RIGHT")
            edge:SetHeight(1)
        else
            edge:SetPoint("TOP" .. side, frame, "TOP" .. side, 0, -1)
            edge:SetPoint("BOTTOM" .. side, frame, "BOTTOM" .. side, 0, 1)
            edge:SetWidth(1)
        end
        edge:SetColorTexture(unpack(color or Color.border))
        borders[#borders + 1] = edge
    end
    return borders
end

local function setPanelColor(frame, r, g, b, a)
    frame.background:SetColorTexture(r, g, b, a)
end

local function setBorderColor(frame, r, g, b, a)
    for _, edge in ipairs(frame.borders) do edge:SetColorTexture(r, g, b, a) end
end

function Style.Panel(frame)
    -- Fixed edge anchors also work on HUD frames whose dimensions can be secret.
    frame.background = fill(frame, "BACKGROUND", -5, Color.background)
    frame.borders = Style.Border(frame)
    frame.SetBackdropColor = setPanelColor
    frame.SetBackdropBorderColor = setBorderColor
    return frame
end

function Style.Window(frame, headerHeight, opacity)
    if frame.SetBackdrop then frame:SetBackdrop(nil) end
    headerHeight = headerHeight or 38
    local rock = stone(frame, ROCK)
    local background = Color.background
    local tint = fill(frame, "BACKGROUND", -5, background)
    tint:SetColorTexture(background[1], background[2], background[3], opacity or .86)
    local left, top, right, bottom = 1, 1, -1, 1
    local layout = NineSliceUtil and NineSliceUtil.GetLayout
        and NineSliceUtil.GetLayout("ButtonFrameTemplateNoPortrait")
    if layout then
        NineSliceUtil.ApplyLayout(frame, layout)
        -- Use the same background insets as Blizzard's DefaultPanelTemplate.
        left, top, right, bottom = 6, 21, -2, 2
    else
        Style.Border(frame)
    end
    for _, texture in ipairs({rock, tint}) do
        texture:ClearAllPoints()
        texture:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -top)
        texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", right, bottom)
    end
    local header = frame:CreateTexture(nil, "BACKGROUND", nil, -4)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -top)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", right, -top)
    header:SetHeight(headerHeight - top)
    header:SetColorTexture(unpack(Color.header))
    local divider = Style.Divider(frame)
    divider:SetPoint("TOPLEFT", frame, "TOPLEFT", Style.Spacing.inset, -headerHeight)
    divider:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -Style.Spacing.inset, -headerHeight)
    return frame
end

local buttonFonts
local function nameplateFill(button, texture, r, g, b)
    if not texture then return end
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", button, "TOPLEFT", 5, -4)
    texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -5, 4)
    texture:SetDrawLayer("BACKGROUND", 1)
    texture:SetVertexColor(r, g, b)
end

function Style.Button(button)
    if CreateFont and button.SetNormalFontObject then
        if not buttonFonts then
            buttonFonts = {}
            for _, state in ipairs({"Normal", "Highlight", "Disabled"}) do
                local font = CreateFont(addonName .. "ButtonFont" .. state)
                local color = state == "Disabled" and Color.disabled or (state == "Highlight" and Color.gold or Color.text)
                Style.Font(font, "button", "OUTLINE", color)
                buttonFonts[state] = font
            end
        end
        button:SetNormalFontObject(buttonFonts.Normal)
        button:SetHighlightFontObject(buttonFonts.Highlight)
        button:SetDisabledFontObject(buttonFonts.Disabled)
    elseif button.GetFontString then
        Style.Font(button:GetFontString(), "button", "OUTLINE", Color.text)
    end
    -- Keep the panel template's rim and hover while replacing the red fill.
    for _, key in ipairs({"Left", "Middle", "Right"}) do
        local piece = button[key]
        if piece and type(piece) ~= "function" then
            piece:SetVertexColor(.84, .72, .57)
            piece:SetDesaturated(true)
        end
    end
    if hasBarAtlas() and button.SetNormalAtlas and button.SetPushedAtlas and button.SetDisabledAtlas then
        button:SetNormalAtlas(NAMEPLATE_BAR)
        button:SetPushedAtlas(NAMEPLATE_BAR)
        button:SetDisabledAtlas(NAMEPLATE_BAR)
        nameplateFill(button, button:GetNormalTexture(), unpack(Color.button, 1, 3))
        nameplateFill(button, button:GetPushedTexture(), .23, .17, .11)
        nameplateFill(button, button:GetDisabledTexture(), .19, .18, .17)
    end
    return button
end

function Style.Close(button)
    -- The glyph is part of Blizzard's close-button atlas. Keep its shape and native states.
    for _, method in ipairs({"GetNormalTexture", "GetPushedTexture", "GetDisabledTexture", "GetHighlightTexture"}) do
        local texture = button[method] and button[method](button)
        if texture and type(texture) ~= "function" then
            texture:SetDesaturated(true)
            texture:SetVertexColor(.84, .72, .57)
        end
    end
    return button
end
