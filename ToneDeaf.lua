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

assert(DongleStub, "DongleStub Not Found!")

local addonName = "ToneDeaf"
local freq = 0.1

--[[ Only for druids and rogues ]]
local class = select(2, _G.UnitClass("player"))
if class ~= "ROGUE" and class ~= "DRUID" then
	DisableAddOn(addonName)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99"..addonName.."|r: This class is not supported. Addon disabled")
	return
end

--[[ Functions called in OnUpdate made local for perf ]]
local tostring = _G.tostring
local GetComboPoints = _G.GetComboPoints
local GetSpellCooldown = _G.GetSpellCooldown
local IsUsableSpell = _G.IsUsableSpell
local IsSpellInRange = _G.IsSpellInRange
local PlaySoundFile = _G.PlaySoundFile

--[[ Main addon declaration ]]
ToneDeaf = DongleStub("Dongle-1.1"):New(addonName)

function ToneDeaf:Initialize()
	if tekDebug then self:EnableDebug(1, tekDebug:GetFrame(addonName)) end
	self.inCombat = false
	self.soundPlayed = false
end

local function CheckCooldownsAndPoints(name, self)
	self:Debug(1, "Checking cooldowns and points")

	if not self.inCombat then return end 
	local points = GetComboPoints("player")

	-- TODO: Pick the right spell
	-- Spells
	--   Rogues: Backstab/Mutil/SS and Rupture
	--   Druids: Mangle and Rip

	if self:IsSpellReady("Mangle - Cat") and not self.soundPlayed then
		self:Debug(1, "Playing sound. CP="..tostring(points))
		self.soundPlayed = true
		PlaySoundFile("Interface\\Addons\\"..addonName.."\\Sounds\\S"..points..".wav")
	else
		self:Debug(1, "Spell not ready. CP="..tostring(points))
	end
end

function ToneDeaf:Enable()
	LibStub("tekKonfig-AboutPanel").new(nil, addonName)

	self:RegisterEvent("UNIT_COMBO_POINTS")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	self:Debug(1, "ToneDeaf enabled")
end

function ToneDeaf:IsSpellReady(spellname)
	local cd = select(2, GetSpellCooldown(spellname, BOOKTYPE_SPELL))
	return IsUsableSpell(spellname) and (IsSpellInRange(spellname,"target") == 1) and (cd <= 0)
end

--[[ Combo points handler ]]
function ToneDeaf:UNIT_COMBO_POINTS()
	self.soundPlayed = false
end

--[[ Entering combat ]]
function ToneDeaf:PLAYER_REGEN_DISABLED()
	self.inCombat = true
	self:ScheduleRepeatingTimer("TONEDEAF_TIMER", CheckCooldownsAndPoints, freq, self)
	self:Debug(1, "Entering combat.")
end

--[[ Leaving combat ]]
function ToneDeaf:PLAYER_REGEN_ENABLED()
	self.inCombat = false
	self.soundPlayed = false
	self:CancelTimer("TONEDEAF_TIMER")
	self:Debug(1, "Leaving combat.")
end

