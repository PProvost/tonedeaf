--[[
ToneDeaf/ToneDeaf.lua

Copyright 2008 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local addonName = "ToneDeaf"

local function Print(...) 
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", "|cFF33FF99"..addonName.."|r:", ...)) 
end

local class = select(2, _G.UnitClass("player"))
if class ~= "ROGUE" and class ~= "DRUID" then
	DisableAddOn(addonName)
	Print("This class is not supported. Addon disabled")
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

function f:UNIT_COMBO_POINTS()
	if arg1 == "player" then
		local points = GetComboPoints("player")
		PlaySoundFile("Interface\\Addons\\"..addonName.."\\Sounds\\S"..points..".wav")
	end
end

function f:PLAYER_LOGIN()
	LibStub("tekKonfig-AboutPanel").new(nil, addonName)
	self:RegisterEvent("UNIT_COMBO_POINT")
end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end
f:RegisterEvent("UNIT_COMBO_POINTS")

--[[ TODO - Play the sound when the main spell cools down

Basically call IsSpellUsable("spellname") on a timer.

Here's Mikma's simple timer code:

local total,desired,myfunc
local function onUpdate(self,elapsed)
    total = total + elapsed
    if total >= desired then
        pcall(myfunc)
        self:SetScript("OnUpdate", nil)
    end
end

local timer = CreateFrame("Frame")

local function SetTimer(time,func)
    desired,myfunc,total = time,func,0
    timer:SetScript("OnUpdate", onUpdate)
end

And here's the IsReady code from ComboSounds:

	-- See if the spell is ready.
	local _, cooldown, _ = GetSpellCooldown(spellID, BOOKTYPE_SPELL);
	local spellReady =	IsUsableSpell(usableSpell) and 
						(1 == IsSpellInRange(usableSpell, "target")) and
						cooldown <= 0;



--
--]]
