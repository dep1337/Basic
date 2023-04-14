-----------------------------------------------------------------------------
--  World of Warcraft addon to provide rotation assistance for BM Hunters 
--
--  (c) April 2023 Duncan Baxter
--
--  License: All available rights reserved to the author
-----------------------------------------------------------------------------
-- SECTION 1: Constant/Variable definitions
-----------------------------------------------------------------------------
local addonName = "Gelily"

local iconSize = 128

local defaultSpells = {}

local defaultAuras = {}

-- Collect some text strings into a handy table
local text = {
	txtTooltip = addonName .. ":\nWhat a lovely tooltip!",
	txtLoaded = addonName .. ": Addon has loaded.",
	txtLogout = addonName .. ": Time for a break ...",
}

-----------------------------------------------------------------------------
-- SECTION 2: Create the parent frame
-----------------------------------------------------------------------------
-- Create our parent frame
local function createIcon()
	icon = CreateFrame("Frame", addonName, UIParent, "")

	if (icon:GetNumPoints() == 0) then -- No existing location found so position frame at CENTER of screen and reset its size to the default
		icon:SetPoint("CENTER")
		icon:SetSize(iconSize, iconSize)
	end

	-- Set the background to an Atlas texture
	icon.texBg = icon:CreateTexture(nil, "BACKGROUND", nil, -8) -- Sub-layers run from -8 to +7: -8 puts our background at the lowest level
	icon.texBg:SetPoint("TOPLEFT")
	icon.texBg:SetSize(iconSize, iconSize)
	icon.texBg:SetAtlas("spec-background", false)
	icon.texBg:SetAlpha(0.75)

	-- Make the frame movable
	icon:SetMovable(true)
	icon:SetScript("OnMouseDown", function(self, button) self:StartMoving() end)
	icon:SetScript("OnMouseUp", function(self, button) self:StopMovingOrSizing() end)
	
	-- Display the mouseover tooltip
	icon:SetScript("OnEnter", function(self, motion)
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE") -- Keeps the tooltip text in its default position
		GameTooltip:AddLine(text.txtTooltip)
		GameTooltip:Show()
	end)
	icon:SetScript("OnLeave", function(self, motion) GameTooltip:Hide() end)

end

-----------------------------------------------------------------------------
-- SECTION 3: Define and register OnEvent handlers for the parent frames
-----------------------------------------------------------------------------
-- SECTION 3.1: Callback and support functions for our event handlers
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- SECTION 3.2: Event handlers
-----------------------------------------------------------------------------
local events = {} -- Table of handlers for system events that the parent frame monitors

function events:ADDON_LOADED(name)
	if (name == addonName) then

		-- Initialise the "spells" and "auras" tables in Saved Variables
		spells = (spells or defaultSpells) -- If the "spells" table does not exist in Saved Variables then set it to the default
		auras = (auras or defaultAuras) -- If the "auras" table does not exist in Saved Variables then set it to the default
		
		icon:UnregisterEvent("ADDON_LOADED")
		print(text.txtLoaded)
	end
end

function events:PLAYER_LOGOUT()
	icon:UnregisterAllEvents()
	print(text.txtLogout) -- Could print anything here: the player will never see it
end

-----------------------------------------------------------------------------
-- SECTION 4: Set our slash commands
-----------------------------------------------------------------------------
local slash = {} -- Table of handlers for slash commands

-- Hide the parent frame
slash.hide = function () 
	icon:Hide()
end

-- Reset the position of the parent frame
slash.reset = function ()
	icon:ClearAllPoints()
	icon:SetPoint("CENTER")
	icon:SetSize(iconSize, iconSize)
end

-- Show the parent frame
slash.show = function ()
	icon:Show()
end

-- Define the callback handler for our slash commands
local function cbSlash(msg, editBox)
	local cmd = strlower(msg)
	slash[cmd]()
	print(addonName .. ": Processed (" .. msg .. ") command")
end

-- Add our slash commands and callback handler to the global table
local function setSlash()
	_G["SLASH_" .. strupper(addonName) .. "1"] = "/" .. strlower(strsub(addonName, 1, 2))
	_G["SLASH_" .. strupper(addonName) .. "2"] = "/" .. strupper(strsub(addonName, 1, 2))
	_G["SLASH_" .. strupper(addonName) .. "3"] = "/" .. strlower(addonName)
	_G["SLASH_" .. strupper(addonName) .. "4"] = "/" .. strupper(addonName)

	SlashCmdList[strupper(addonName)] = cbSlash
end

-----------------------------------------------------------------------------
-- SECTION 5: Create our UI
-----------------------------------------------------------------------------
-- Create the parent frame
createIcon()

-- Register all the events for which we provide a separate handling function
icon:SetScript("OnEvent", function(self, event, ...) events[event](self, ...) end)
for k, v in pairs(events) do icon:RegisterEvent(k) end

-- Set our slash commands
setSlash()


