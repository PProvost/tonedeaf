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

ToneDeaf = DongleStub("Dongle-1.1"):New(addonName)

function ToneDeaf:Initialize()
	if tekDebug then self:EnableDebug(1, tekDebug:GetFrame(addonName)) end
	self.inCombat = false
	self.soundPlayed = false
	local cmd = self:InitializeSlashCommand(addonName, string.upper(addonName), string.lower(addonName))
	cmd:RegisterSlashHandler("points <spell_link> - set the combo points spell", "^points (.+)$", "SetComboSpell")
	cmd:RegisterSlashHandler("closing <spell_link> - set the closing spell", "^closing (.+)$", "SetClosingSpell")
end

function ToneDeaf:Enable()
	LibStub("tekKonfig-AboutPanel").new(nil, addonName)
	self:RegisterEvent("UNIT_COMBO_POINTS")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function ToneDeaf:SetComboSpell(spell_link)
	local found, _, itemString = string.find(itemLink, "^|c%x+|H(.+)|h%[.*%]")
	if found then
		self:Debug("SetComboSpell: " .. itemString)
	else
		self:Print("ERROR - Please provide a spell link")
	end
end

function ToneDeaf:SetClosingSpell(spell_link)
	self:DebugF(1, "SetClosingSpell: %s", spell_link or "Nothing")
end

function ToneDeaf:GetConfiguredSpell(points)
	if points == 5 then
		return "Rip"
	else
		return "Mangle - Cat"
	end
end

function ToneDeaf.CheckCooldownsAndPoints(name, self)
	if not self.inCombat then return end 

	local points = GetComboPoints("player")
	local spell = self:GetConfiguredSpell(points)

	if self:IsSpellReady(spell) and not self.soundPlayed then
		self.soundPlayed = true
		PlaySoundFile("Interface\\Addons\\"..addonName.."\\Sounds\\S"..points..".wav")
	else
		self:Debug(1, "Spell not ready. CP="..tostring(points))
	end
end

function ToneDeaf:IsSpellReady(spellname)
	local isUsable = select(1, IsUsableSpell(spellname))
	local inRange = IsSpellInRange(spellname)
	local cd = select(2, GetSpellCooldown(spellname))

	self:DebugF(1, "isUsable=%d, inRange=%d, cd=%d", isUsable or -1, inRange or -1 , cd or -1)
	return (isUsable==1) and (inRange==1) and (cd == 0)
end

function ToneDeaf:UNIT_COMBO_POINTS()
	self.soundPlayed = false
end

function ToneDeaf:PLAYER_REGEN_DISABLED()
	self.inCombat = true
	self:ScheduleRepeatingTimer("TONEDEAF_TIMER", self.CheckCooldownsAndPoints, freq, self)
end

function ToneDeaf:PLAYER_REGEN_ENABLED()
	self.inCombat = false
	self.soundPlayed = false
	self:CancelTimer("TONEDEAF_TIMER")
end

