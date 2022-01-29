local Farmy = CreateFrame("Frame", "FarmyMeterWindow", UIParent, "BackdropTemplate")

local date = date
local pairs = pairs
local select = select
local max = math.max
local floor = floor
local format = format
local tonumber = tonumber
local match = string.match
local GetTime = GetTime
local GetItemInfo = GetItemInfo
local BreakUpLargeNumbers = BreakUpLargeNumbers
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LootMessage = LOOT_ITEM_SELF:gsub("%%.*", "")
local LootMatch = "([^|]+)|cff(%x+)|H([^|]+)|h%[([^%]]+)%]|h|r[^%d]*(%d*)"
local Locale = GetLocale()
local MaxWidgets = 11
local MaxSelections = 8
local BlankTexture = "Interface\\AddOns\\Farmy\\HydraUIBlank.tga"
local BarTexture = "Interface\\AddOns\\Farmy\\HydraUI4.tga"
local Font = "Interface\\Addons\\Farmy\\PTSans.ttf"
local GameVersion = select(4, GetBuildInfo())
local ReplicateItems, GetNumReplicateItems, GetReplicateItemInfo

if (GameVersion and GameVersion > 90000) then
	ReplicateItems = C_AuctionHouse.ReplicateItems
	GetNumReplicateItems = C_AuctionHouse.GetNumReplicateItems
	GetReplicateItemInfo = C_AuctionHouse.GetReplicateItemInfo
end

local WindowWidth = 195
local BarHeight = 22
local NumBarsToShow = 5

local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")

local Class = select(2, UnitClass("player"))
local ClassColor = RAID_CLASS_COLORS[Class]
local HeaderR, HeaderG, HeaderB = 0.25, 0.25, 0.25
local BarR, BarG, BarB = 0, 204/255, 106/255
local WindowR, WindowG, WindowB = 0.25, 0.25, 0.25
local WindowAlpha = 0.8

SharedMedia:Register("font", "PT Sans", Font)
SharedMedia:Register("statusbar", "HydraUI 4", BarTexture)

Farmy.Bars = {}
Farmy.FreeBars = {}
Farmy.Elapsed = 0
Farmy.Gained = 0

local Textures = SharedMedia:HashTable("statusbar")
local Fonts = SharedMedia:HashTable("font")

local Index = function(self, key)
	return key
end

local L = setmetatable({}, {__index = Index})

if (Locale == "deDE") then -- German
	L["Total Gathered:"] = "Gesammelt total:"
	L["Total Average Per Hour:"] = "Gesamtdurchschnitt pro Stunde:"
	L["Total Value:"] = "Gesamtwert:"
	L["Left click: Toggle timer"] = "Linksklick: Timer anhalten/fortsetzen"
	L["Right click: Reset data"] = "Rechtsklick: Daten zur\195\188cksetzen"
	L["Hr"] = "Std."

	L["You must wait %s until you can scan again."] = "Du musst %s warten bevor du wieder scannen kannst."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r scannt gerade die Marktpreise, dies sollte weniger als 10 Sekunden dauern."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r hat die Marktpreise aktualisiert"

	L["Ore"] = "Erz"
	L["Herbs"] = "Kr\195\164uter"
	L["Leather"] = "Leder"
	L["Cooking"] = "Kochen"
	L["Cloth"] = "Stoffe"
	L["Enchanting"] = "Verzaubern"
	L["Jewelcrafting"] = "Juwelen"
	L["Weapons"] = "Waffen"
	L["Armor"] = "R\195\188stung"
	L["Pets"] = "Haustiere"
	L["Mounts"] = "Reittiere"
	L["Consumables"] = "Verbrauchbares"
	L["Reagents"] = "Reagenzien"
	L["Ignore Bind on Pickup"] = "Ignoriere Items, welche beim aufheben Seelengebunden werden"
	L["%s is now being unignored."] = "%s wird nun nicht mehr ignoriert."
	L["Show tooltip data"] = "Zeige Tooltip Daten"
	L["Price per unit: %s"] = "Preis pro Einheit: %s"
elseif (Locale == "esES") then -- Spanish (Spain)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "esMX") then -- Spanish (Mexico)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "frFR") then -- French
	L["Total Gathered:"] = "Total recueilli:"
	L["Total Average Per Hour:"] = "Moyenne totale par heure:"
	L["Total Value:"] = "Valeur totale:"
	L["Left click: Toggle timer"] = "Clic gauche : Minuterie on/off"
	L["Right click: Reset data"] = "Clic droit : Réinitialisation des données"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "Vous devez attendre %s pour que vous puissiez à nouveau scanner."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r scrute les prix du marché. Cela devrait prendre moins de 10 secondes."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r a fini d'actualiser les prix du marché."
	
	L["Ore"] = "Minerai"
	L["Herbs"] = "Herbes"
	L["Leather"] = "Cuir"
	L["Cooking"] = "Cuisine"
	L["Cloth"] = "Tissu"
	L["Enchanting"] = "Enchanteur"
	L["Jewelcrafting"] = "Joaillerie"
	L["Weapons"] = "Armes"
	L["Armor"] = "Armure"
	L["Pets"] = "Mascottes"
	L["Mounts"] = "Montures"
	L["Consumables"] = "Consommables"
	L["Reagents"] = "Réactifs"
	L["Ignore Bind on Pickup"] = "Ignorer les objets liés au ramassage"
	L["%s is now being unignored."] = "%s n'est désormais plus ignorée."
	L["Show tooltip data"] = "Afficher les données de l'infobulle"
	L["Price per unit: %s"] = "Prix par unité: %s"
elseif (Locale == "itIT") then -- Italian
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "koKR") then -- Korean
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
	
	Font = "Fonts\\2002b.ttf"
elseif (Locale == "ptBR") then -- Portuguese (Brazil)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "ruRU") then -- Russian
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
elseif (Locale == "zhCN") then -- Chinese (Simplified)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
	
	Font = "Fonts\\ARHei.ttf"
elseif (Locale == "zhTW") then -- Chinese (Traditional/Taiwan)
	L["Total Gathered:"] = "Total Gathered:"
	L["Total Average Per Hour:"] = "Total Average Per Hour:"
	L["Total Value:"] = "Total Value:"
	L["Left click: Toggle timer"] = "Left click: Toggle timer"
	L["Right click: Reset data"] = "Right click: Reset data"
	L["Hr"] = "Hr"
	
	L["You must wait %s until you can scan again."] = "You must wait %s until you can scan again."
	L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."] = "|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."
	L["|cfff5b349Farmy|r updated market prices."] = "|cfff5b349Farmy|r updated market prices."
	
	L["Ore"] = "Ore"
	L["Herbs"] = "Herbs"
	L["Leather"] = "Leather"
	L["Cooking"] = "Cooking"
	L["Cloth"] = "Cloth"
	L["Enchanting"] = "Enchanting"
	L["Jewelcrafting"] = "Jewelcrafting"
	L["Weapons"] = "Weapons"
	L["Armor"] = "Armor"
	L["Pets"] = "Pets"
	L["Mounts"] = "Mounts"
	L["Consumables"] = "Consumables"
	L["Reagents"] = "Reagents"
	L["Ignore Bind on Pickup"] = "Ignore Bind on Pickup"
	L["%s is now being unignored."] = "%s is now being unignored."
	L["Show tooltip data"] = "Show tooltip data"
	L["Price per unit: %s"] = "Price per unit: %s"
	
	Font = "Fonts\\bLEI00D.ttf"
end

local Backdrop = {
	bgFile = BlankTexture,
	edgeFile = BlankTexture,
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local BackdropAndBorder = {
	bgFile = BlankTexture,
	edgeFile = BlankTexture,
	edgeSize = 1,
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

Farmy.DefaultSettings = {
	-- Tracking
	["track-ore"] = true,
	["track-herbs"] = true,
	["track-leather"] = true,
	["track-fish"] = true,
	["track-fish"] = true,
	["track-meat"] = true,
	["track-cloth"] = true,
	["track-enchanting"] = true,
	["track-reagents"] = true,
	["track-consumables"] = true,
	["track-quest"] = true,
	
	--[[
	self:CreateCheckbox("track-ore", L["Ore"], self.UpdateOreTracking)
	self:CreateCheckbox("track-herbs", L["Herbs"], self.UpdateHerbTracking)
	self:CreateCheckbox("track-leather", L["Leather"], self.UpdateLeatherTracking)
	self:CreateCheckbox("track-cooking", L["Cooking"], self.UpdateCookingTracking)
	self:CreateCheckbox("track-cloth", L["Cloth"], self.UpdateClothTracking)
	self:CreateCheckbox("track-enchanting", L["Enchanting"], self.UpdateEnchantingTracking)
	self:CreateCheckbox("track-jewelcrafting", L["Jewelcrafting"], self.UpdateJewelcraftingTracking)
	self:CreateCheckbox("track-weapons", L["Weapons"], self.UpdateWeaponTracking)
	self:CreateCheckbox("track-armor", L["Armor"], self.UpdateArmorTracking)
	self:CreateCheckbox("track-mounts", L["Mounts"], self.UpdateMountTracking)
	self:CreateCheckbox("track-consumables", L["Consumables"], self.UpdateConsumableTracking)
	self:CreateCheckbox("track-reagents", L["Reagents"], self.UpdateReagentTracking)
	--]]
	
	-- Functionality
	["ignore-bop"] = false, -- Ignore bind on pickup gear. IE: ignore BoP loot on a raid run, but show BoE's for the auction house
	["hide-idle"] = false, -- Hide the tracker frame while not running
	["show-tooltip"] = false, -- Show tooltip data about item prices
	
	-- Styling
	["window-font"] = "PT Sans", -- Set the font on the bars
	["bar-texture"] = "HydraUI 4", -- Set the statusbar texture of the bars
	["class-color-bars"] = false, -- Override the statusbar texture with class color
	
	["tracking-mode"] = "Gathered",
}

Farmy.Modes = {
	"Gathered", -- Compare collected number
	"Value", -- Compare item value or market price
	"PerHour", -- Compare collected per hour
	"GPH", -- Gold per hour
}

Farmy.ModeLabels = {
	["Gathered"] = "Gathered",
	["Value"] = "Value",
	["PerHour"] = "Per Hour",
	["GPH"] = "Gold / Hr",
}

Farmy.TrackedItemTypes = {
	[LE_ITEM_CLASS_CONSUMABLE] = {},
	[LE_ITEM_CLASS_WEAPON] = {},
	[LE_ITEM_CLASS_ARMOR] = {},
	[LE_ITEM_CLASS_TRADEGOODS] = {},
	[LE_ITEM_CLASS_MISCELLANEOUS] = {},
}

function Farmy:UpdateWeaponTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_AXE1H] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_AXE2H] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_BOWS] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_GUNS] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_MACE1H] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_MACE2H] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_POLEARM] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_SWORD1H] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_SWORD2H] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_WARGLAIVE] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_STAFF] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_BEARCLAW] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_CATCLAW] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_UNARMED] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_GENERIC] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_CROSSBOW] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_WAND] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_WEAPON][LE_ITEM_WEAPON_FISHINGPOLE] = value
end

function Farmy:UpdateArmorTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_GENERIC] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_CLOTH] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_LEATHER] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_MAIL] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_PLATE] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_COSMETIC] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_SHIELD] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_ARMOR][LE_ITEM_ARMOR_RELIC] = value
end

function Farmy:UpdateJewelcraftingTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][4] = value
end

function Farmy:UpdateClothTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][5] = value
end

function Farmy:UpdateLeatherTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][6] = value
end

function Farmy:UpdateOreTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][7] = value
end

function Farmy:UpdateWindowFont(value)
	local Font = SharedMedia:Fetch("font", value)
	
	self.Text:SetFont(Font, 12)
	self.Value:SetFont(Font, 12)
	
	for i = 1, #self.Bars do
		self.Bars[i].Name:SetFont(Font, 12)
		self.Bars[i].Value:SetFont(Font, 12)
	end

	if self.FreeBars[1] then
		for i = 1, #self.FreeBars do
			self.FreeBars[i].Name:SetFont(Font, 12)
			self.FreeBars[i].Value:SetFont(Font, 12)
		end
	end
	
	for i = 1, #self.Modes do
		self.List[i].Text:SetFont(Font, 12)
	end
end

function Farmy:UpdateWindowTexture(value)
	local Texture = SharedMedia:Fetch("statusbar", value)
	
	self.Bar:SetStatusBarTexture(Texture)
	
	for i = 1, #self.Bars do
		self.Bars[i].Status:SetStatusBarTexture(Texture)
	end

	if self.FreeBars[1] then
		for i = 1, #self.FreeBars do
			self.FreeBars[i].Status:SetStatusBarTexture(Texture)
		end
	end
end

function Farmy:UpdateCookingTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][8] = value
end

function Farmy:UpdateHerbTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][9] = value
end

function Farmy:UpdateEnchantingTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][12] = value
end

function Farmy:UpdateHolidayTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_HOLIDAY] = value
end

function Farmy:UpdateMountTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_MOUNT] = value
end

function Farmy:UpdateConsumableTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][0] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][1] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][2] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][3] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][4] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][5] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][6] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_CONSUMABLE][7] = value
end

function Farmy:UpdateReagentTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_REAGENT] = value
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_TRADEGOODS][10] = value
end

function Farmy:UpdateOtherTracking(value)
	Farmy.TrackedItemTypes[LE_ITEM_CLASS_MISCELLANEOUS][LE_ITEM_MISCELLANEOUS_OTHER] = value
end

function Farmy:AddIgnoredItem(text)
	if (text == "") then
		return
	end
	
	local ID = tonumber(text)
	
	if (not FarmyIgnore) then
		FarmyIgnore = {}
	end
	
	if ID then
		FarmyIgnore[ID] = true
		
		print(format(ERR_IGNORE_ADDED_S, GetItemInfo(ID)))
	else
		FarmyIgnore[text] = true
		
		print(format(ERR_IGNORE_ADDED_S, text))
	end
end

function Farmy:RemoveIgnoredItem(text)
	if ((not FarmyIgnore) or (text == "")) then
		return
	end
	
	local ID = tonumber(text)
	
	if ID then
		FarmyIgnore[ID] = nil
		
		print(format(L["%s is now being unignored."], GetItemInfo(ID)))
	else
		FarmyIgnore[text] = nil
		
		print(format(L["%s is now being unignored."], text))
	end
end

function Farmy:UpdateFont()
	self.Tooltip:SetBackdrop(nil)
	
	for i = 1, self.Tooltip:GetNumRegions() do
		local Region = select(i, self.Tooltip:GetRegions())
		
		if (Region:GetObjectType() == "FontString" and not Region.Handled) then
			Region:SetFont(Font, 12)
			Region:SetShadowColor(0, 0, 0)
			Region:SetShadowOffset(1, -1)
			Region.Handled = true
		end
	end
end

function Farmy:CopperToGold(copper)
	local Gold = floor(copper / (100 * 100))
	
	if (Gold > 0) then
		if (Gold > 999) then
			Gold = BreakUpLargeNumbers(Gold)
		end
		
		return Gold .. "|cffffe02eg|r"
	end
end

function Farmy:CopperToGoldFull(copper)
	local Gold = floor(copper / (100 * 100))
	local Silver = floor((copper - (Gold * 100 * 100)) / 100)
	local Copper = floor(copper % 100)
	local Separator = ""
	local String = ""
	
	if (Gold > 0) then
		if (Gold > 999) then
			Gold = BreakUpLargeNumbers(Gold)
		end
		
		String = Gold .. "|cffffe02eg|r"
		Separator = " "
	end
	
	if (Silver > 0) then
		String = String .. Separator .. Silver .. "|cffd6d6d6s|r"
		Separator = " "
	end
	
	if (Copper > 0 or String == "") then
		String = String .. Separator .. Copper .. "|cfffc8d2bc|r"
	end
	
	return String
end

function Farmy:FormatTime(seconds)
	if (seconds > 59) then
		return format("%dm", ceil(seconds / 60))
	else
		return format("%0.1fs", seconds)
	end
end

function Farmy:UpdateSettingValue(key, value)
	if (value == self.DefaultSettings[key]) then
		FarmySettings[key] = nil
	else
		FarmySettings[key] = value
	end
	
	self.Settings[key] = value
end

function Farmy:CreateHeader(text)
	local Header = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Header:SetSize(190, 20)
	
	Header.BG = Header:CreateTexture(nil, "BORDER")
	Header.BG:SetTexture(BlankTexture)
	Header.BG:SetVertexColor(0, 0, 0)
	Header.BG:SetPoint("TOPLEFT", Header, 0, 0)
	Header.BG:SetPoint("BOTTOMRIGHT", Header, 0, 0)
	
	Header.Tex = Header:CreateTexture(nil, "OVERLAY")
	Header.Tex:SetTexture(BarTexture)
	Header.Tex:SetPoint("TOPLEFT", Header, 1, -1)
	Header.Tex:SetPoint("BOTTOMRIGHT", Header, -1, 1)
	Header.Tex:SetVertexColor(0.2, 0.2, 0.2)
	
	Header.Text = Header:CreateFontString(nil, "OVERLAY")
	Header.Text:SetFont(Font, 12)
	Header.Text:SetPoint("LEFT", Header, 3, 0)
	Header.Text:SetJustifyH("LEFT")
	Header.Text:SetShadowColor(0, 0, 0)
	Header.Text:SetShadowOffset(1, -1)
	Header.Text:SetText(text)
	
	tinsert(self.GUI.Window.Widgets, Header)
end

function Farmy:CheckBoxOnMouseUp()
	if (Farmy.Settings[self.Setting] == true) then
		self.Tex:SetVertexColor(0.8, 0, 0)
		Farmy:UpdateSettingValue(self.Setting, false)
		
		if self.Hook then
			self:Hook(false)
		end
	else
		self.Tex:SetVertexColor(0, 0.8, 0)
		Farmy:UpdateSettingValue(self.Setting, true)
		
		if self.Hook then
			self:Hook(true)
		end
	end
end

function Farmy:CreateCheckbox(key, text, func)
	local Checkbox = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Checkbox:SetSize(20, 20)
	Checkbox:SetScript("OnMouseUp", self.CheckBoxOnMouseUp)
	Checkbox.Setting = key
	
	Checkbox.BG = Checkbox:CreateTexture(nil, "BORDER")
	Checkbox.BG:SetTexture(BlankTexture)
	Checkbox.BG:SetVertexColor(0, 0, 0)
	Checkbox.BG:SetPoint("TOPLEFT", Checkbox, 0, 0)
	Checkbox.BG:SetPoint("BOTTOMRIGHT", Checkbox, 0, 0)
	
	Checkbox.Tex = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Tex:SetTexture(BarTexture)
	Checkbox.Tex:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Tex:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	
	Checkbox.Text = Checkbox:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetFont(Font, 12)
	Checkbox.Text:SetPoint("LEFT", Checkbox, "RIGHT", 3, 0)
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetShadowColor(0, 0, 0)
	Checkbox.Text:SetShadowOffset(1, -1)
	Checkbox.Text:SetText(text)
	
	if self.Settings[key] then
		Checkbox.Tex:SetVertexColor(0, 0.8, 0)
	else
		Checkbox.Tex:SetVertexColor(0.8, 0, 0)
	end
	
	if func then
		Checkbox.Hook = func
	end
	
	tinsert(self.GUI.Window.Widgets, Checkbox)
end

function Farmy:EditBoxOnEnterPressed()
	local Text = self:GetText()
	
	self:SetAutoFocus(false)
	self:ClearFocus()
	
	if self.Hook then
		self:Hook(Text)
	end
	
	self:SetText(L["Ignore items"])
end

function Farmy:OnEscapePressed()
	self:SetAutoFocus(false)
	self:ClearFocus()
	self:SetText(L["Ignore items"])
end

function Farmy:EditBoxOnMouseDown()
	local Type, ID, Link = GetCursorInfo()
	
	self:SetAutoFocus(true)
	
	if (Type and Type == "item") then
		self:SetText(ID)
		self.Icon:SetTexture(C_Item.GetItemIconByID(ID))
	else
		self:SetText("")
	end
	
	ClearCursor()
end

function Farmy:OnEditFocusLost()
	self:SetText("")
	self.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	ClearCursor()
end

function Farmy:OnEditChar(text)
	local ID = tonumber(self:GetText())
	
	if (not ID) then
		self.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
		
		return
	end
	
	local IconID = C_Item.GetItemIconByID(ID)
	
	if (IconID and IconID ~= 134400) then
		self.Icon:SetTexture(IconID)
	else
		self.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	end
end

function Farmy:CreateEditBox(text, func)
	local EditBox = CreateFrame("EditBox", nil, self.GUI.ButtonParent)
	EditBox:SetSize(168, 20)
	EditBox:SetFont(Font, 12)
	EditBox:SetShadowColor(0, 0, 0)
	EditBox:SetShadowOffset(1, -1)
	EditBox:SetJustifyH("LEFT")
	EditBox:SetAutoFocus(false)
	EditBox:EnableKeyboard(true)
	EditBox:EnableMouse(true)
	EditBox:SetMaxLetters(255)
	EditBox:SetTextInsets(5, 0, 0, 0)
	EditBox:SetText(text)
	EditBox:SetScript("OnEnterPressed", self.EditBoxOnEnterPressed)
	EditBox:SetScript("OnEscapePressed", self.OnEscapePressed)
	EditBox:SetScript("OnMouseDown", self.EditBoxOnMouseDown)
	EditBox:SetScript("OnEditFocusLost", self.OnEditFocusLost)
	EditBox:SetScript("OnChar", self.OnEditChar)
	
	EditBox.BG = EditBox:CreateTexture(nil, "BORDER")
	EditBox.BG:SetTexture(BlankTexture)
	EditBox.BG:SetVertexColor(0, 0, 0)
	EditBox.BG:SetPoint("TOPLEFT", EditBox, 0, 0)
	EditBox.BG:SetPoint("BOTTOMRIGHT", EditBox, 0, 0)
	
	EditBox.Tex = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Tex:SetTexture(BarTexture)
	EditBox.Tex:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Tex:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Tex:SetVertexColor(0.4, 0.4, 0.4)
	
	EditBox.Icon = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Icon:SetPoint("LEFT", EditBox, "RIGHT", 3, 0)
	EditBox.Icon:SetSize(18, 18)
	EditBox.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	EditBox.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	EditBox.BG = EditBox:CreateTexture(nil, "BORDER")
	EditBox.BG:SetTexture(BlankTexture)
	EditBox.BG:SetVertexColor(0, 0, 0)
	EditBox.BG:SetPoint("TOPLEFT", EditBox.Icon, -1, 1)
	EditBox.BG:SetPoint("BOTTOMRIGHT", EditBox.Icon, 1, -1)
	
	if func then
		EditBox.Hook = func
	end
	
	tinsert(self.GUI.Window.Widgets, EditBox)
end

local ScrollSelections = function(self)
	local First = false
	
	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + MaxSelections - 1) then
			if (not First) then
				self[i]:SetPoint("TOPLEFT", self, 0, -1)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 1)
			end
			
			self[i]:Show()
		else
			self[i]:Hide()
		end
	end
end

local SelectionOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1
		
		if (self.Offset > (#self - (MaxSelections - 1))) then
			self.Offset = self.Offset - 1
		end
	end
	
	ScrollSelections(self)
	--self.ScrollBar:SetValue(self.Offset)
end

local FontListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()
	
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Key), 12)
	Selection.Current:SetText(self.Key)
	
	Selection.List:Hide()
	
	Farmy:UpdateSettingValue(Selection.Setting, self.Key)
	
	if Selection.Hook then
		Selection:Hook(self.Key)
	end
end

local FontSelectionOnMouseUp = function(self)
	if (not self.List) then
		self.List = CreateFrame("Frame", nil, self)
		self.List:SetSize(128, 20 * MaxSelections)
		self.List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		self.List.Offset = 1
		self.List:EnableMouseWheel(true)
		self.List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		self.List:Hide()
		
		for Key, Path in pairs(self.Selections) do
			local Selection = CreateFrame("Frame", nil, self.List)
			Selection:SetSize(128, 20)
			Selection.Key = Key
			Selection.Path = Path
			Selection:SetScript("OnMouseUp", FontListOnMouseUp)
			
			Selection.BG = Selection:CreateTexture(nil, "BORDER")
			Selection.BG:SetTexture(BlankTexture)
			Selection.BG:SetVertexColor(0, 0, 0)
			Selection.BG:SetPoint("TOPLEFT", Selection, 0, 0)
			Selection.BG:SetPoint("BOTTOMRIGHT", Selection, 0, 0)
			
			Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
			Selection.Tex:SetTexture(BarTexture)
			Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Selection.Tex:SetVertexColor(0.4, 0.4, 0.4)
			
			Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
			Selection.Text:SetFont(Path, 12)
			Selection.Text:SetPoint("LEFT", Selection, 3, 0)
			Selection.Text:SetJustifyH("LEFT")
			Selection.Text:SetShadowColor(0, 0, 0)
			Selection.Text:SetShadowOffset(1, -1)
			Selection.Text:SetText(Key)
			
			tinsert(self.List, Selection)
		end
		
		table.sort(self.List, function(a, b)
			return a.Key < b.Key
		end)
		
		ScrollSelections(self.List)
	end
	
	if self.List:IsShown() then
		self.List:Hide()
		self.Arrow:SetTexture("Interface\\AddOns\\Farmy\\HydraUIArrowDown.tga")
	else
		self.List:Show()
		self.Arrow:SetTexture("Interface\\AddOns\\Farmy\\HydraUIArrowUp.tga")
	end
end

function Farmy:CreateFontSelection(key, text, selections, func)
	local Selection = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Selection:SetSize(128, 20)
	Selection:SetScript("OnMouseUp", FontSelectionOnMouseUp)
	Selection.Selections = selections
	Selection.Setting = key
	
	Selection.BG = Selection:CreateTexture(nil, "BORDER")
	Selection.BG:SetTexture(BlankTexture)
	Selection.BG:SetVertexColor(0, 0, 0)
	Selection.BG:SetPoint("TOPLEFT", Selection, 0, 0)
	Selection.BG:SetPoint("BOTTOMRIGHT", Selection, 0, 0)
	
	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(BarTexture)
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.4, 0.4, 0.4)
	
	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture("Interface\\AddOns\\Farmy\\HydraUIArrowDown.tga")
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	Selection.Arrow:SetVertexColor(0, 204/255, 106/255)
	
	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(SharedMedia:Fetch("font", self.Settings[key]), 12)
	Selection.Current:SetPoint("LEFT", Selection, 3, 0)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(self.Settings[key])
	
	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(Font, 12)
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)
	
	if func then
		Selection.Hook = func
	end
	
	tinsert(self.GUI.Window.Widgets, Selection)
end

local TextureListOnMouseUp = function(self)
	local Selection = self:GetParent():GetParent()
	
	Selection.Tex:SetTexture(SharedMedia:Fetch("statusbar", self.Key))
	Selection.Current:SetText(self.Key)
	
	Selection.List:Hide()
	
	Farmy:UpdateSettingValue(Selection.Setting, self.Key)
	
	if Selection.Hook then
		Selection:Hook(self.Key)
	end
end

local TextureSelectionOnMouseUp = function(self)
	if (not self.List) then
		self.List = CreateFrame("Frame", nil, self)
		self.List:SetSize(128, 20 * MaxSelections)
		self.List:SetPoint("TOP", self, "BOTTOM", 0, -1)
		self.List.Offset = 1
		self.List:EnableMouseWheel(true)
		self.List:SetScript("OnMouseWheel", SelectionOnMouseWheel)
		self.List:Hide()
		
		for Key, Path in pairs(self.Selections) do
			local Selection = CreateFrame("Frame", nil, self.List)
			Selection:SetSize(128, 20)
			Selection.Key = Key
			Selection.Path = Path
			Selection:SetScript("OnMouseUp", TextureListOnMouseUp)
			
			Selection.BG = Selection:CreateTexture(nil, "BORDER")
			Selection.BG:SetTexture(BlankTexture)
			Selection.BG:SetVertexColor(0, 0, 0)
			Selection.BG:SetPoint("TOPLEFT", Selection, 0, 0)
			Selection.BG:SetPoint("BOTTOMRIGHT", Selection, 0, 0)
			
			Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
			Selection.Tex:SetTexture(Path)
			Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
			Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
			Selection.Tex:SetVertexColor(0.4, 0.4, 0.4)
			
			Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
			Selection.Text:SetFont(Font, 12)
			Selection.Text:SetPoint("LEFT", Selection, 3, 0)
			Selection.Text:SetJustifyH("LEFT")
			Selection.Text:SetShadowColor(0, 0, 0)
			Selection.Text:SetShadowOffset(1, -1)
			Selection.Text:SetText(Key)
			
			tinsert(self.List, Selection)
		end
		
		table.sort(self.List, function(a, b)
			return a.Key < b.Key
		end)
		
		ScrollSelections(self.List)
	end
	
	if self.List:IsShown() then
		self.List:Hide()
		self.Arrow:SetTexture("Interface\\AddOns\\Farmy\\HydraUIArrowDown.tga")
	else
		self.List:Show()
		self.Arrow:SetTexture("Interface\\AddOns\\Farmy\\HydraUIArrowUp.tga")
	end
end

function Farmy:CreateTextureSelection(key, text, selections, func)
	local Selection = CreateFrame("Frame", nil, self.GUI.ButtonParent)
	Selection:SetSize(128, 20)
	Selection:SetScript("OnMouseUp", TextureSelectionOnMouseUp)
	Selection.Selections = selections
	Selection.Setting = key
	
	Selection.BG = Selection:CreateTexture(nil, "BORDER")
	Selection.BG:SetTexture(BlankTexture)
	Selection.BG:SetVertexColor(0, 0, 0)
	Selection.BG:SetPoint("TOPLEFT", Selection, 0, 0)
	Selection.BG:SetPoint("BOTTOMRIGHT", Selection, 0, 0)
	
	Selection.Tex = Selection:CreateTexture(nil, "ARTWORK")
	Selection.Tex:SetTexture(SharedMedia:Fetch("statusbar", self.Settings[key]))
	Selection.Tex:SetPoint("TOPLEFT", Selection, 1, -1)
	Selection.Tex:SetPoint("BOTTOMRIGHT", Selection, -1, 1)
	Selection.Tex:SetVertexColor(0.4, 0.4, 0.4)
	
	Selection.Arrow = Selection:CreateTexture(nil, "OVERLAY")
	Selection.Arrow:SetTexture("Interface\\AddOns\\Farmy\\HydraUIArrowDown.tga")
	Selection.Arrow:SetPoint("RIGHT", Selection, -3, 0)
	--Selection.Arrow:SetVertexColor(0.4, 0.4, 0.4)
	Selection.Arrow:SetVertexColor(0, 204/255, 106/255)
	
	Selection.Current = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Current:SetFont(Font, 12)
	Selection.Current:SetPoint("LEFT", Selection, 3, 0)
	Selection.Current:SetJustifyH("LEFT")
	Selection.Current:SetShadowColor(0, 0, 0)
	Selection.Current:SetShadowOffset(1, -1)
	Selection.Current:SetText(self.Settings[key])
	
	Selection.Text = Selection:CreateFontString(nil, "OVERLAY")
	Selection.Text:SetFont(Font, 12)
	Selection.Text:SetPoint("LEFT", Selection, "RIGHT", 3, 0)
	Selection.Text:SetJustifyH("LEFT")
	Selection.Text:SetShadowColor(0, 0, 0)
	Selection.Text:SetShadowOffset(1, -1)
	Selection.Text:SetText(text)
	
	if func then
		Selection.Hook = func
	end
	
	tinsert(self.GUI.Window.Widgets, Selection)
end

local Scroll = function(self)
	local First = false
	
	for i = 1, #self.Widgets do
		if (i >= self.Offset) and (i <= self.Offset + MaxWidgets - 1) then
			if (not First) then
				self.Widgets[i]:SetPoint("TOPLEFT", Farmy.GUI.ButtonParent, 2, -2)
				First = true
			else
				self.Widgets[i]:SetPoint("TOPLEFT", self.Widgets[i-1], "BOTTOMLEFT", 0, -2)
			end
			
			self.Widgets[i]:Show()
		else
			self.Widgets[i]:Hide()
		end
	end
end

local WindowOnMouseWheel = function(self, delta)
	if (delta == 1) then
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else
		self.Offset = self.Offset + 1
		
		if (self.Offset > (#self.Widgets - (MaxWidgets - 1))) then
			self.Offset = self.Offset - 1
		end
	end
	
	Scroll(self)
	self.ScrollBar:SetValue(self.Offset)
end

local ScrollBarOnValueChanged = function(self, value)
	local Value = floor(value + 0.5)
	
	self.Parent.Offset = Value
	
	Scroll(self.Parent)
end

function Farmy:InitiateSettings()
	self.Settings = {}
	
	for Key, Value in pairs(self.DefaultSettings) do -- Add default values
		self.Settings[Key] = Value
	end
	
	if (not FarmySettings) then
		FarmySettings = {}
	else
		for Key, Value in pairs(FarmySettings) do -- Add stored values
			self.Settings[Key] = Value
		end
	end
	
	--self.Settings = setmetatable(FarmySettings, {__index = self.DefaultSettings})
	
	self:UpdateWeaponTracking(self.Settings["track-weapons"])
	self:UpdateArmorTracking(self.Settings["track-armor"])
	self:UpdateJewelcraftingTracking(self.Settings["track-jewelcrafting"])
	self:UpdateClothTracking(self.Settings["track-cloth"])
	self:UpdateLeatherTracking(self.Settings["track-leather"])
	self:UpdateOreTracking(self.Settings["track-ore"])
	self:UpdateCookingTracking(self.Settings["track-cooking"])
	self:UpdateHerbTracking(self.Settings["track-herbs"])
	self:UpdateEnchantingTracking(self.Settings["track-enchanting"])
	self:UpdateMountTracking(self.Settings["track-mounts"])
	self:UpdateConsumableTracking(self.Settings["track-consumables"])
	self:UpdateReagentTracking(self.Settings["track-reagents"])
	self:UpdateOtherTracking(self.Settings["track-other"])
end

function Farmy:SettingsLayout()
	self:CreateHeader("Appearance")
	
	self:CreateFontSelection("window-font", "Bar Font", Fonts, self.UpdateWindowFont)
	self:CreateTextureSelection("bar-texture", "Bar Texture", Textures, self.UpdateWindowTexture)
	
	-- Window width
	-- Window height
	-- bar height
	-- Show icon
	-- Bar color
	
	self:CreateHeader(TRACKING)
	
	self:CreateCheckbox("track-ore", L["Ore"], self.UpdateOreTracking)
	self:CreateCheckbox("track-herbs", L["Herbs"], self.UpdateHerbTracking)
	self:CreateCheckbox("track-leather", L["Leather"], self.UpdateLeatherTracking)
	self:CreateCheckbox("track-cooking", L["Cooking"], self.UpdateCookingTracking)
	self:CreateCheckbox("track-cloth", L["Cloth"], self.UpdateClothTracking)
	self:CreateCheckbox("track-enchanting", L["Enchanting"], self.UpdateEnchantingTracking)
	self:CreateCheckbox("track-jewelcrafting", L["Jewelcrafting"], self.UpdateJewelcraftingTracking)
	self:CreateCheckbox("track-weapons", L["Weapons"], self.UpdateWeaponTracking)
	self:CreateCheckbox("track-armor", L["Armor"], self.UpdateArmorTracking)
	self:CreateCheckbox("track-mounts", L["Mounts"], self.UpdateMountTracking)
	self:CreateCheckbox("track-consumables", L["Consumables"], self.UpdateConsumableTracking)
	self:CreateCheckbox("track-reagents", L["Reagents"], self.UpdateReagentTracking)
	
	self:CreateHeader(MISCELLANEOUS)
	
	self:CreateCheckbox("ignore-bop", L["Ignore Bind on Pickup"])
	self:CreateCheckbox("hide-idle", L["Hide while idle"], self.ToggleTimerPanel)
	self:CreateCheckbox("show-tooltip", L["Show tooltip data"])
	
	self:CreateHeader(IGNORE)
	
	self:CreateEditBox(L["Ignore items"], self.AddIgnoredItem)
	
	self:CreateHeader(UNIGNORE_QUEST)
	
	self:CreateEditBox(L["Unignore items"], self.RemoveIgnoredItem)
end

function Farmy:CreateGUI()
	-- Window
	self.GUI = CreateFrame("Frame", "Farmy Settings", UIParent)
	self.GUI:SetSize(420, 18) -- 420 dope as fuck yolo swag lit titties
	self.GUI:SetPoint("CENTER", UIParent, 0, 160)
	self.GUI:SetMovable(true)
	self.GUI:EnableMouse(true)
	self.GUI:SetUserPlaced(true)
	self.GUI:RegisterForDrag("LeftButton")
	self.GUI:SetScript("OnDragStart", self.GUI.StartMoving)
	self.GUI:SetScript("OnDragStop", self.GUI.StopMovingOrSizing)
	
	self.GUI.BG = self.GUI:CreateTexture(nil, "BORDER")
	self.GUI.BG:SetPoint("TOPLEFT", self.GUI, -1, 1)
	self.GUI.BG:SetPoint("BOTTOMRIGHT", self.GUI, 1, -1)
	self.GUI.BG:SetTexture(BlankTexture)
	self.GUI.BG:SetVertexColor(0, 0, 0)
	
	self.GUI.Texture = self.GUI:CreateTexture(nil, "OVERLAY")
	self.GUI.Texture:SetPoint("TOPLEFT", self.GUI, 0, 0)
	self.GUI.Texture:SetPoint("BOTTOMRIGHT", self.GUI, 0, 0)
	self.GUI.Texture:SetTexture(BarTexture)
	self.GUI.Texture:SetVertexColor(0.2, 0.2, 0.2)
	
	self.GUI.Text = self.GUI:CreateFontString(nil, "OVERLAY")
	self.GUI.Text:SetPoint("LEFT", self.GUI, 3, -0.5)
	self.GUI.Text:SetFont(Font, 12)
	self.GUI.Text:SetJustifyH("LEFT")
	self.GUI.Text:SetShadowColor(0, 0, 0)
	self.GUI.Text:SetShadowOffset(1, -1)
	self.GUI.Text:SetText("|cfff5b349Farmy|r " .. GetAddOnMetadata("Farmy", "Version"))
	
	self.GUI.CloseButton = CreateFrame("Frame", nil, self.GUI)
	self.GUI.CloseButton:SetPoint("TOPRIGHT", self.GUI, 0, 0)
	self.GUI.CloseButton:SetSize(18, 18)
	self.GUI.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	self.GUI.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	self.GUI.CloseButton:SetScript("OnMouseUp", function() self.GUI:Hide() end)
	
	self.GUI.CloseButton.Texture = self.GUI.CloseButton:CreateTexture(nil, "OVERLAY")
	self.GUI.CloseButton.Texture:SetPoint("CENTER", self.GUI.CloseButton, 0, -0.5)
	self.GUI.CloseButton.Texture:SetTexture("Interface\\AddOns\\Farmy\\HydraUIClose.tga")
	
	self.GUI.Window = CreateFrame("Frame", nil, self.GUI)
	self.GUI.Window:SetSize(420, 244)
	self.GUI.Window:SetPoint("TOPLEFT", self.GUI, "BOTTOMLEFT", 0, -4)
	self.GUI.Window.Offset = 1
	self.GUI.Window.Widgets = {}
	
	self.GUI.Window:EnableMouseWheel(true)
	self.GUI.Window:SetScript("OnMouseWheel", WindowOnMouseWheel)
	
	self.GUI.Backdrop = self.GUI.Window:CreateTexture(nil, "BORDER")
	self.GUI.Backdrop:SetPoint("TOPLEFT", self.GUI.Window, -1, 1)
	self.GUI.Backdrop:SetPoint("BOTTOMRIGHT", self.GUI.Window, 1, -1)
	self.GUI.Backdrop:SetTexture(BlankTexture)
	self.GUI.Backdrop:SetVertexColor(0, 0, 0)
	
	self.GUI.Inside = self.GUI.Window:CreateTexture(nil, "BORDER")
	self.GUI.Inside:SetAllPoints()
	self.GUI.Inside:SetTexture(BlankTexture)
	self.GUI.Inside:SetVertexColor(0.2, 0.2, 0.2)
	
	self.GUI.ButtonParent = CreateFrame("Frame", nil, self.GUI.Window)
	self.GUI.ButtonParent:SetAllPoints()
	self.GUI.ButtonParent:SetFrameLevel(self.GUI.Window:GetFrameLevel() + 4)
	self.GUI.ButtonParent:SetFrameStrata("HIGH")
	self.GUI.ButtonParent:EnableMouse(true)
	
	self.GUI.OuterBackdrop = CreateFrame("Frame", nil, self.GUI.Window, "BackdropTemplate")
	self.GUI.OuterBackdrop:SetPoint("TOPLEFT", self.GUI, -4, 4)
	self.GUI.OuterBackdrop:SetPoint("BOTTOMRIGHT", self.GUI.Window, 4, -4)
	self.GUI.OuterBackdrop:SetBackdrop(Backdrop)
	self.GUI.OuterBackdrop:SetBackdropColor(0.2, 0.2, 0.2)
	self.GUI.OuterBackdrop:SetBackdropBorderColor(0, 0, 0)
	self.GUI.OuterBackdrop:SetFrameStrata("LOW")
	
	self:SettingsLayout()
	
	-- Scroll bar
	self.GUI.Window.ScrollBar = CreateFrame("Slider", nil, self.GUI.ButtonParent, "BackdropTemplate")
	self.GUI.Window.ScrollBar:SetPoint("TOPRIGHT", self.GUI.Window, -2, -2)
	self.GUI.Window.ScrollBar:SetPoint("BOTTOMRIGHT", self.GUI.Window, -2, 2)
	self.GUI.Window.ScrollBar:SetWidth(14)
	self.GUI.Window.ScrollBar:SetThumbTexture(BlankTexture)
	self.GUI.Window.ScrollBar:SetOrientation("VERTICAL")
	self.GUI.Window.ScrollBar:SetValueStep(1)
	self.GUI.Window.ScrollBar:SetBackdrop(Backdrop)
	self.GUI.Window.ScrollBar:SetBackdropColor(0.2, 0.2, 0.2)
	self.GUI.Window.ScrollBar:SetBackdropBorderColor(0, 0, 0)
	self.GUI.Window.ScrollBar:SetMinMaxValues(1, (#self.GUI.Window.Widgets - (MaxWidgets - 1)))
	self.GUI.Window.ScrollBar:SetValue(1)
	self.GUI.Window.ScrollBar:EnableMouse(true)
	self.GUI.Window.ScrollBar:SetScript("OnValueChanged", ScrollBarOnValueChanged)
	self.GUI.Window.ScrollBar.Parent = self.GUI.Window
	
	self.GUI.Window.ScrollBar:SetFrameStrata("HIGH")
	self.GUI.Window.ScrollBar:SetFrameLevel(22)
	
	local Thumb = self.GUI.Window.ScrollBar:GetThumbTexture() 
	Thumb:SetSize(14, 20)
	Thumb:SetTexture(BarTexture)
	Thumb:SetVertexColor(0, 0, 0)
	
	self.GUI.Window.ScrollBar.NewTexture = self.GUI.Window.ScrollBar:CreateTexture(nil, "BORDER")
	self.GUI.Window.ScrollBar.NewTexture:SetPoint("TOPLEFT", Thumb, 0, 0)
	self.GUI.Window.ScrollBar.NewTexture:SetPoint("BOTTOMRIGHT", Thumb, 0, 0)
	self.GUI.Window.ScrollBar.NewTexture:SetTexture(BlankTexture)
	self.GUI.Window.ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	self.GUI.Window.ScrollBar.NewTexture2 = self.GUI.Window.ScrollBar:CreateTexture(nil, "OVERLAY")
	self.GUI.Window.ScrollBar.NewTexture2:SetPoint("TOPLEFT", self.GUI.Window.ScrollBar.NewTexture, 1, -1)
	self.GUI.Window.ScrollBar.NewTexture2:SetPoint("BOTTOMRIGHT", self.GUI.Window.ScrollBar.NewTexture, -1, 1)
	self.GUI.Window.ScrollBar.NewTexture2:SetTexture(BarTexture)
	self.GUI.Window.ScrollBar.NewTexture2:SetVertexColor(0.2, 0.2, 0.2)
	
	Scroll(self.GUI.Window)
end

function Farmy:ScanButtonOnClick()
	local TimeDiff = (GetTime() - (FarmyLastScan or 0))
	
	if (TimeDiff > 0) and (900 > TimeDiff) then -- 15 minute throttle
		print(format(L["You must wait %s until you can scan again."], Farmy:FormatTime(900 - TimeDiff)))
		return
	end
	
	if Farmy:IsEventRegistered("REPLICATE_ITEM_LIST_UPDATE") then -- Awaiting results already
		if (TimeDiff > 900) then
			self:UnregisterEvent("REPLICATE_ITEM_LIST_UPDATE")
		else
			return
		end
	end
	
	Farmy:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")
	
	ReplicateItems()
	
	print(L["|cfff5b349Farmy|r is scanning market prices. This should take less than 10 seconds."])
	
	FarmyLastScan = GetTime()
end

function Farmy:CHAT_MSG_LOOT(msg)
	if (not msg) then
		return
	end
	
	if (InboxFrame:IsVisible() or (GuildBankFrame and GuildBankFrame:IsVisible())) then -- Ignore useless info
		return
	end
	
	local PreMessage, _, ItemString, Name, Quantity = match(msg, LootMatch)
	
	if (not ItemString) then
		return
	end
	
	local LinkType, ID = match(ItemString, "^(%a+):(%d+)")
	
	if (PreMessage ~= LootMessage) then
		return
	end
	
	ID = tonumber(ID)
	Quantity = tonumber(Quantity) or 1
	
	local _, _, Quality, _, _, Type, SubType, _, _, Texture, _, ClassID, SubClassID, BindType = GetItemInfo(ID)
	
	if (self.Ignored[ID] or self.Ignored[Name] or ((not self.TrackedItemTypes[ClassID]) or (not self.TrackedItemTypes[ClassID][SubClassID]))) then
		return
	end
	
	if (BindType and ((BindType ~= 0) and self.Settings["ignore-bop"])) then
		return
	end
	
	self:AddData(ID, Name, Quantity)
end

function Farmy:REPLICATE_ITEM_LIST_UPDATE()
	if (not FarmyMarketPrices) then
		FarmyMarketPrices = {}
	end
	
	local Count, Buyout, ID, HasAllInfo, PerUnit, _
	
	for i = 0, (GetNumReplicateItems() - 1) do
		_, _, Count, _, _, _, _, _, _, Buyout, _, _, _, _, _, _, ID, HasAllInfo = GetReplicateItemInfo(i)
		
		if HasAllInfo then
			self.MarketPrices[ID] = Buyout / Count
			FarmyMarketPrices[ID] = self.MarketPrices[ID]
		elseif ID then
			Item:CreateFromItemID(ID):ContinueOnItemLoad(function()
				_, _, Count, _, _, _, _, _, _, Buyout, _, _, _, _, _, _, ID = GetReplicateItemInfo(i)
				PerUnit = Buyout / Count
				
				if self.MarketPrices[ID] then
					if (self.MarketPrices[ID] > PerUnit) then -- Collect lowest prices
						self.MarketPrices[ID] = PerUnit
						FarmyMarketPrices[ID] = self.MarketPrices[ID]
					end
				else
					self.MarketPrices[ID] = PerUnit
					FarmyMarketPrices[ID] = self.MarketPrices[ID]
				end
			end)
		end
	end
	
	self:UnregisterEvent("REPLICATE_ITEM_LIST_UPDATE")
	
	print(L["|cfff5b349Farmy|r updated market prices."])
end

function Farmy:OnTooltipSetItem()
	if (not Farmy.Settings["show-tooltip"]) then
		return
	end
	
	local Item, Link = self:GetItem()
	
	if Item then
		local ID = tonumber(match(Link, "^|cff%x+|Hitem:(%d+)"))
		local Price = Farmy:GetPrice(ID, Link)
		
		if (Price and Price > 0) then
			self:AddLine(" ")
			self:AddLine("|cfff5b349Farmy|r")
			self:AddLine(format(L["Price per unit: %s"], Farmy:CopperToGold(Price)), 1, 1, 1)
		end
	end
end

function Farmy:PLAYER_ENTERING_WORLD()
	self.MarketPrices = FarmyMarketPrices or {}
	self.Ignored = FarmyIgnore or {}
	
	self:InitiateSettings()
	
	if IsAddOnLoaded("TradeSkillMaster") then
		self.HasTSM = true
	end
	
	GameTooltip:HookScript("OnTooltipSetItem", self.OnTooltipSetItem)
	
	self:CreateWindow()
	
	if self.Settings["hide-idle"] then
		self:Hide()
	end
	
	self.Gold = GetMoney()
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Farmy:CHAT_MSG_MONEY()
	local Current = GetMoney()
	
	if (Current > self.Gold) then
		-- Add this value
		local Diff = Current - self.Gold
		
		self.Gained = self.Gained + Diff
		
		if (not self.InitialGold) then
			self.InitialGold = GetTime()
		end
		--print('do we be gettin gold')
		Farmy:AddGoldData(Diff) -- This is on the fly, double check this
	end
	
	self.Gold = Current
end

function Farmy:AUCTION_HOUSE_SHOW()
	if (not self.ScanButton and AuctionHouseFrame) then
		self.ScanButton = CreateFrame("Button", "Farmy Scan Button", AuctionHouseFrame.MoneyFrameBorder, "UIPanelButtonTemplate")
		self.ScanButton:SetSize(140, 24)
		self.ScanButton:SetPoint("LEFT", AuctionHouseFrame.MoneyFrameBorder, "RIGHT", 3, 0)
		self.ScanButton:SetText("Farmy Scan")
		self.ScanButton:SetScript("OnClick", self.ScanButtonOnClick)
	end
end

function Farmy:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Farmy:GetPrice(id, link)
	if self.HasTSM then
		return TSM_API.GetCustomPriceValue("dbMarket", TSM_API.ToItemString(link))
		--return TSM_API.GetCustomPriceValue("dbMinBuyout", TSM_API.ToItemString(link))
	elseif self.MarketPrices[id] then
		return self.MarketPrices[id]
	end
	
	return 0
end

local WindowOnEnter = function(self)
	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	--GameTooltip:AddLine(SecondsToTime(CombatTime > 0 and CombatTime or LastCombatTime))
	
	if (Farmy.Gained > 0) then
		GameTooltip:AddDoubleLine("Session", date("!%X", GetTime() - self.InitialGold), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddLine(" ")
		
		local Total = Farmy:CopperToGoldFull(Farmy.Gained)
		local CopperPerHour = (Farmy.Gained / max(GetTime() - Farmy.InitialGold, 1)) * 60 * 60
		
		if not CopperPerHour then
			return
		end
		
		local PerHour = Farmy:CopperToGold(CopperPerHour)
		
		GameTooltip:AddDoubleLine("|cfff5b349Farmy|r")
		GameTooltip:AddDoubleLine(" ")
		GameTooltip:AddDoubleLine(MONEY, format("%s (%s)", Total, PerHour), 1, 1, 1, 1, 1, 1)
	end
	
	GameTooltip:Show()
end

Farmy:RegisterEvent("CHAT_MSG_MONEY")
Farmy:RegisterEvent("CHAT_MSG_LOOT")
Farmy:RegisterEvent("AUCTION_HOUSE_SHOW")
Farmy:RegisterEvent("PLAYER_ENTERING_WORLD")
Farmy:SetScript("OnEvent", Farmy.OnEvent)
Farmy:SetScript("OnEnter", WindowOnEnter)

local BarShowTooltip = function(self)
	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	--GameTooltip:AddLine(SecondsToTime(CombatTime > 0 and CombatTime or LastCombatTime))
	
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(self.ID) 
	
	GameTooltip:AddLine(itemLink)
	GameTooltip:AddLine(" ")
	
	GameTooltip:AddDoubleLine("Collected", self.Collected, 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Value", Farmy:CopperToGold(self.MarketValue * self.Collected), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Per Hour", BreakUpLargeNumbers(floor((self.Collected / max(GetTime() - self.Initial, 1)) * 60 * 60)), 1, 1, 1, 1, 1, 1)
	--GameTooltip:AddDoubleLine("Per Hour", BreakUpLargeNumbers(self.PerHour), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine("Gold Per Hour", Farmy:CopperToGold(floor(((self.Collected * self.MarketValue) / max(GetTime() - self.Initial, 1)) * 60 * 60)), 1, 1, 1, 1, 1, 1)
	
	if IsShiftKeyDown() then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("Initially Gathered", date("!%X", GetTime() - self.Initial), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine("Recently Gathered", date("!%X", GetTime() - self.Last), 1, 1, 1, 1, 1, 1)
	end
	
	GameTooltip:Show()
end

local BarOnUpdate = function(self, elapsed)
	self.Elapsed = (self.Elapsed or 0) + elapsed
	
	if (self.Elapsed > 1) then
		BarShowTooltip(self)
		
		self.Elapsed = 0
	end
end

local BarOnEnter = function(self)
	self:SetScript("OnUpdate", BarOnUpdate)
	
	BarShowTooltip(self)
end

local BarOnLeave = function(self)
	self:SetScript("OnUpdate", nil)
	GameTooltip:Hide()
end

local WindowOnLeave = function(self)
	GameTooltip:Hide()
end

function Farmy:OnUpdate(elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 2) then
		local Now = GetTime()
		
		for i = 1, #self.Bars do
			self.Bars[i].PerHour = floor((self.Bars[i].Collected / max(Now - self.Bars[i].Initial, 1)) * 60 * 60)
			self.Bars[i].GPH = floor(((self.Bars[i].Collected * self.Bars[i].MarketValue) / max(GetTime() - self.Bars[i].Initial, 1)) * 60 * 60)
		end
		
		self:SortBars()
		self.Elapsed = 0
	end
end

function Farmy:NewBar()
	local Bar = CreateFrame("StatusBar", nil, self.BarParent)
	Bar:SetSize(WindowWidth - 2, BarHeight - 2)
	Bar:SetScript("OnEnter", BarOnEnter)
	Bar:SetScript("OnLeave", BarOnLeave)
	
	Bar.Status = CreateFrame("StatusBar", nil, Bar)
	Bar.Status:SetSize((WindowWidth - 2) - (BarHeight - 2) - 1, BarHeight - 2)
	Bar.Status:SetPoint("RIGHT", Bar, "RIGHT", 0, 0)
	Bar.Status:SetStatusBarTexture(SharedMedia:Fetch("statusbar", self.Settings["bar-texture"]))
	
	if self.Settings["class-color-bars"] then
		Bar.Status:SetStatusBarColor(ClassColor.r, ClassColor.g, ClassColor.b)
	else
		Bar.Status:SetStatusBarColor(BarR, BarG, BarB)
	end
	
	Bar.Icon = Bar.Status:CreateTexture(nil, "OVERLAY")
	Bar.Icon:SetSize(BarHeight - 2, BarHeight - 2)
	Bar.Icon:SetPoint("LEFT", Bar, 0, 0)
	Bar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	Bar.BG = Bar:CreateTexture(nil, "BACKGROUND")
	Bar.BG:SetPoint("TOPLEFT", Bar, -1, 1)
	Bar.BG:SetPoint("BOTTOMRIGHT", Bar.Status:GetStatusBarTexture(), 1, -1)
	Bar.BG:SetTexture(BlankTexture)
	Bar.BG:SetVertexColor(0, 0, 0)
	
	Bar.Name = Bar.Status:CreateFontString(nil, "OVERLAY")
	Bar.Name:SetPoint("LEFT", Bar.Status, 4, 0)
	Bar.Name:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	Bar.Name:SetJustifyH("LEFT")
	Bar.Name:SetShadowColor(0, 0, 0)
	Bar.Name:SetShadowOffset(1, -1)
	
	Bar.Value = Bar.Status:CreateFontString(nil, "OVERLAY")
	Bar.Value:SetPoint("RIGHT", Bar.Status, -4, 0)
	Bar.Value:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	Bar.Value:SetJustifyH("RIGHT")
	Bar.Value:SetShadowColor(0, 0, 0)
	Bar.Value:SetShadowOffset(1, -1)
	
	-- Data
	Bar.Quality = 0 -- Item Quality, or color
	Bar.Collected = 0 -- Value Collected
	Bar.MarketValue = 0 -- Collect any found data for a market price
	
	return Bar
end

function Farmy:GetFreeBar()
	local Bar
	
	if self.FreeBars[1] then
		Bar = table.remove(self.FreeBars, 1)
	else
		Bar = self:NewBar()
	end
	
	Bar:SetAlpha(0)
	
	return Bar
end

function Farmy:Reset()
	local Bar
	
	for i = #self.Bars, 1, -1 do
		Bar = self.Bars[i]
		Bar.ID = nil
		Bar.Initial = 0
		Bar.Last = 0
		Bar.Quality = 0
		Bar.Collected = 0
		Bar.MarketValue = 0
		Bar.PerHour = 0
		Bar:Hide()
		
		table.insert(self.FreeBars, table.remove(self.Bars, i))
	end
	
	self.Gained = 0
	self.InitialGold = 0
	
	if (self.Mode == "Gathered") then
		self.Text:SetText("Gathered: 0")
	elseif (self.Mode == "PerHour") then
		self.Text:SetText("Per Hour: 0")
	elseif (self.Mode == "Value") then
		self.Text:SetText("Value: 0")
	elseif (self.Mode == "GPH") then
		self.Text:SetText("Gold / Hr: 0")
	end
end

function Farmy:AddGoldData(quantity)
	local Bar = self:FetchBar("gold")
	local Now = GetTime()
	
	if (not Bar) then
		Bar = self:GetFreeBar()
		Bar.ID = "gold"
		Bar.Initial = Now
		Bar.Collected = 0
		Bar.Copper = 0
		
		Bar.Name:SetText(BONUS_ROLL_REWARD_MONEY)
		Bar.Icon:SetTexture("Interface\\ICONS\\Inv_misc_coin_01")
		Bar.Value:SetText(self:CopperToGoldFull(quantity))
		
		table.insert(self.Bars, Bar)
		
		UIFrameFadeIn(Bar, 0.15, 0, 1)
	end
	
	Bar.Copper = Bar.Copper + quantity
	
	--Bar.Collected = (Bar.Collected or 0) + quantity
	--Bar.PerHour = floor((Bar.Collected / max(Now - Bar.Initial, 1)) * 60 * 60)
	Bar.Last = Now
	
	self:SortBars()
	
	Bar.Value:SetText(self:CopperToGoldFull(Bar.Copper))
end

function Farmy:AddData(id, name, quantity)
	local Bar = self:FetchBar(id)
	local Now = GetTime()
	
	if (not Bar) then
		Bar = self:GetFreeBar()
		Bar.ID = id
		Bar.Initial = Now
		Bar.MarketValue = Farmy:GetPrice(id, select(2, GetItemInfo(id)))
		
		Bar.Name:SetText(name)
		Bar.Icon:SetTexture(GetItemIcon(id))
		
		table.insert(self.Bars, Bar)
		
		UIFrameFadeIn(Bar, 0.15, 0, 1)
	end
	
	Bar.Collected = (Bar.Collected or 0) + quantity
	Bar.PerHour = floor((Bar.Collected / max(Now - Bar.Initial, 1)) * 60 * 60)
	Bar.GPH = (Bar.MarketValue * Bar.PerHour) or 0
	Bar.Last = Now
	
	self:SortBars()
	
	local GoldBar = self:FetchBar("gold")
	
	if GoldBar then
		GoldBar.Value:SetText(self:CopperToGoldFull(GoldBar.Copper))
	end
end

function Farmy:FetchBar(id)
	for i = 1, #self.Bars do
		if (self.Bars[i].ID == id) then
			return self.Bars[i]
		end
	end
end

Farmy.Sorters = {
	["Gathered"] = function(self)
		table.sort(self.Bars, function(a, b)
			return a.Collected > b.Collected
		end)
		
		local Total = 0
		local First = false
		
		for i = 1, #self.Bars do
			self.Bars[i].Status:SetMinMaxValues(0, self.Bars[1].Collected)
			self.Bars[i].Status:SetValue(self.Bars[i].Collected)
			self.Bars[i].Value:SetText(self.Bars[i].Collected)
			self.Bars[i]:ClearAllPoints()
			
			if (i >= self.BarParent.Offset) and (i <= self.BarParent.Offset + (NumBarsToShow - 1)) then
				if (not First) then
					First = true
					self.Bars[i]:SetPoint("TOPLEFT", self.BarParent, 1, -1)
				else
					self.Bars[i]:SetPoint("TOPLEFT", self.Bars[i-1], "BOTTOMLEFT", 0, -1)
				end
				
				self.Bars[i]:Show()
			else
				self.Bars[i]:Hide()
			end
			
			Total = Total + self.Bars[i].Collected
		end
		
		self.Text:SetText(format("Gathered: %s", Total))
	end,
	
	["PerHour"] = function(self)
		table.sort(self.Bars, function(a, b)
			return a.PerHour > b.PerHour
		end)
		
		local PerHour = 0
		local First = false
		
		for i = 1, #self.Bars do
			self.Bars[i].Status:SetMinMaxValues(0, self.Bars[1].PerHour)
			self.Bars[i].Status:SetValue(self.Bars[i].PerHour)
			self.Bars[i].Value:SetText(self.Bars[i].PerHour)
			self.Bars[i]:ClearAllPoints()
			
			if (i >= self.BarParent.Offset) and (i <= self.BarParent.Offset + (NumBarsToShow - 1)) then
				if (not First) then
					First = true
					self.Bars[i]:SetPoint("TOPLEFT", self.BarParent, 1, -1)
				else
					self.Bars[i]:SetPoint("TOPLEFT", self.Bars[i-1], "BOTTOMLEFT", 0, -1)
				end
				
				self.Bars[i]:Show()
			else
				self.Bars[i]:Hide()
			end

			PerHour = PerHour + self.Bars[i].PerHour
		end
		
		self.Text:SetText(format("Per Hour: %s", BreakUpLargeNumbers(PerHour)))
	end,
	
	["Value"] = function(self)
		table.sort(self.Bars, function(a, b)
			return a.MarketValue * a.Collected > b.MarketValue * b.Collected
		end)
		
		local Value = 0
		local First = false
		
		for i = 1, #self.Bars do
			self.Bars[i].Status:SetMinMaxValues(0, self.Bars[1].MarketValue * self.Bars[1].Collected)
			self.Bars[i].Status:SetValue(self.Bars[i].MarketValue * self.Bars[i].Collected)
			self.Bars[i].Value:SetText(self:CopperToGold(self.Bars[i].MarketValue * self.Bars[i].Collected))
			self.Bars[i]:ClearAllPoints()
			
			if (i >= self.BarParent.Offset) and (i <= self.BarParent.Offset + (NumBarsToShow - 1)) then
				if (not First) then
					First = true
					self.Bars[i]:SetPoint("TOPLEFT", self.BarParent, 1, -1)
				else
					self.Bars[i]:SetPoint("TOPLEFT", self.Bars[i-1], "BOTTOMLEFT", 0, -1)
				end
				
				self.Bars[i]:Show()
			else
				self.Bars[i]:Hide()
			end
			
			Value = Value + (self.Bars[i].MarketValue * self.Bars[i].Collected)
		end
		
		self.Text:SetText(format("Value: %s", self:CopperToGold(Value)))
	end,
	
	["GPH"] = function(self)
		table.sort(self.Bars, function(a, b)
			return a.GPH > b.GPH
		end)
		
		local GPH = 0
		local First = false
		
		for i = 1, #self.Bars do
			self.Bars[i].Status:SetMinMaxValues(0, self.Bars[1].GPH)
			self.Bars[i].Status:SetValue(self.Bars[i].GPH)
			self.Bars[i].Value:SetText(self:CopperToGold(self.Bars[i].GPH))
			self.Bars[i]:ClearAllPoints()
			
			if (i >= self.BarParent.Offset) and (i <= self.BarParent.Offset + (NumBarsToShow - 1)) then
				if (not First) then
					First = true
					self.Bars[i]:SetPoint("TOPLEFT", self.BarParent, 1, -1)
				else
					self.Bars[i]:SetPoint("TOPLEFT", self.Bars[i-1], "BOTTOMLEFT", 0, -1)
				end
				
				self.Bars[i]:Show()
			else
				self.Bars[i]:Hide()
			end
			
			GPH = GPH + self.Bars[i].GPH
		end
		
		self.Text:SetText(format("Gold / Hr: %s", self:CopperToGold(GPH)))
	end,
}

function Farmy:SortBars()
	self.Sorters[self.Mode](self)
end

local OnModeSelect = function(self)
	if (Farmy.Modes[self.Mode] == Farmy.Mode) then
		return
	end
	
	Farmy.Mode = Farmy.Modes[self.Mode]
	
	Farmy.BarParent.Offset = 1
	
	if (Farmy.Mode == "PerHour" or Farmy.Mode == "GPH") then
		Farmy:SetScript("OnUpdate", Farmy.OnUpdate)
		Farmy:OnUpdate(3)
	else
		if Farmy:GetScript("OnUpdate") then
			Farmy:SetScript("OnUpdate", nil)
		end
		
		Farmy:SortBars()
	end
	
	Farmy:UpdateSettingValue("tracking-mode", Farmy.Mode)
	
	Farmy.List:Hide()
end

local OnModeEnter = function(self)
	self.Highlight:SetAlpha(0.5)
end

local OnModeLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ScrollOnMouseWheel = function(self, delta)
	if (delta == 1) then -- Up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- Down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (#Farmy.Bars - (NumBarsToShow - 1))) then
			self.Offset = self.Offset - 1
		end
	end
	
	Farmy:SortBars()
end

function Farmy:CreateWindow()
	if self.WindowCreated then
		return
	end
	
	self:SetSize(WindowWidth, 22)
	self:SetPoint("LEFT", UIParent, 400, 120)
	self:SetBackdrop(Backdrop)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:SetUserPlaced(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:SetScript("OnMouseUp", selfOnMouseUp)
	self:SetScript("OnEnter", WindowOnEnter)
	self:SetScript("OnLeave", WindowOnLeave)
	
	self.Bar = CreateFrame("StatusBar", nil, self)
	self.Bar:SetSize(WindowWidth - 2, 20)
	self.Bar:SetPoint("CENTER", self, 0, 0)
	self.Bar:SetMinMaxValues(0, 1)
	self.Bar:SetValue(1)
	self.Bar:SetStatusBarTexture(SharedMedia:Fetch("statusbar", self.Settings["bar-texture"]))
	self.Bar:SetStatusBarColor(HeaderR, HeaderG, HeaderB)
	
	self.BarParent = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.BarParent:SetSize(WindowWidth, 106) -- (NumBarsToShow * 22 - (NumBarsToShow - 1))
	self.BarParent:SetPoint("TOP", self, "BOTTOM", 0, 1)
	self.BarParent:SetBackdrop(Backdrop) -- BackdropAndBorder
	self.BarParent:SetBackdropColor(WindowR, WindowG, WindowB, WindowAlpha)
	self.BarParent:SetBackdropBorderColor(0, 0, 0)
	self.BarParent.Offset = 1
	self.BarParent:EnableMouseWheel(true)
	self.BarParent:SetScript("OnMouseWheel", ScrollOnMouseWheel)
	--self.BarParent:SetResizable(true)
	
	self.Text = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Text:SetPoint("LEFT", self.Bar, 4, -1)
	self.Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	self.Text:SetJustifyH("LEFT")
	self.Text:SetShadowColor(0, 0, 0)
	self.Text:SetShadowOffset(1, -1)
	
	self.Mode = self.Settings["tracking-mode"]
	
	if (self.Mode == "Gathered") then
		self.Text:SetText("Gathered: 0")
	elseif (self.Mode == "PerHour") then
		self.Text:SetText("Per Hour: 0")
	elseif (self.Mode == "Value") then
		self.Text:SetText("Value: 0")
	elseif (self.Mode == "GPH") then
		self.Text:SetText("Gold / Hr: 0")
	end
	
	self.Value = self.Bar:CreateFontString(nil, "OVERLAY")
	self.Value:SetPoint("RIGHT", self.Bar, -4, 0)
	self.Value:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
	self.Value:SetJustifyH("RIGHT")
	self.Value:SetShadowColor(0, 0, 0)
	self.Value:SetShadowOffset(1, -1)
	self.Value:SetText("")
	
	self.List = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.List:SetSize(100, 22 * #self.Modes)
	self.List:SetPoint("TOPRIGHT", self.Bar, "BOTTOMRIGHT", -1, -2)
	self.List:SetBackdrop(Backdrop)
	self.List:SetBackdropColor(0.25, 0.25, 0.25)
	self.List:SetBackdropBorderColor(0, 0, 0)
	self.List:SetFrameLevel(10)
	self.List:Hide()
	
	for i = 1, #self.Modes do
		self.List[i] = CreateFrame("Frame", nil, self.List)
		self.List[i]:SetSize(100, 22)
		self.List[i]:SetScript("OnMouseUp", OnModeSelect)
		self.List[i]:SetScript("OnEnter", OnModeEnter)
		self.List[i]:SetScript("OnLeave", OnModeLeave)
		self.List[i]:SetFrameLevel(11)
		self.List[i].Mode = i
		
		self.List[i].Highlight = self.List[i]:CreateTexture(nil, "ARTWORK")
		self.List[i].Highlight:SetSize(98, 20)
		self.List[i].Highlight:SetPoint("LEFT", self.List[i], 0, 0)
		self.List[i].Highlight:SetTexture(BlankTexture)
		self.List[i].Highlight:SetVertexColor(0, 204/255, 106/255) -- 1, 0.7, 0
		self.List[i].Highlight:SetAlpha(0)
		
		self.List[i].Text = self.List[i]:CreateFontString(nil, "OVERLAY")
		self.List[i].Text:SetPoint("LEFT", self.List[i], 4, 0)
		self.List[i].Text:SetFont(SharedMedia:Fetch("font", self.Settings["window-font"]), 12)
		self.List[i].Text:SetJustifyH("LEFT")
		self.List[i].Text:SetShadowColor(0, 0, 0)
		self.List[i].Text:SetShadowOffset(1, -1)
		self.List[i].Text:SetText(self.ModeLabels[self.Modes[i]])
		
		if (i == 1) then
			self.List[i]:SetPoint("TOPRIGHT", self.Bar, "BOTTOMRIGHT", 0, -2)
		else
			self.List[i]:SetPoint("TOP", self.List[i-1], "BOTTOM", 0, 0)
		end
	end
	
	self.CloseButton = CreateFrame("Frame", nil, self.Bar)
	self.CloseButton:SetPoint("RIGHT", self.Bar, -3, 0)
	self.CloseButton:SetSize(18, 18)
	self.CloseButton:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	self.CloseButton:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	self.CloseButton:SetScript("OnMouseUp", function() self:Reset() end) -- needs a confirmation
	
	self.CloseButton.Texture = self.CloseButton:CreateTexture(nil, "OVERLAY")
	self.CloseButton.Texture:SetPoint("CENTER", self.CloseButton, 0, 0)
	self.CloseButton.Texture:SetTexture("Interface\\AddOns\\Farmy\\HydraUIClose.tga")
	
	self.SelectMode = CreateFrame("Frame", nil, self.Bar)
	self.SelectMode:SetPoint("RIGHT", self.CloseButton, "LEFT", 0, 0)
	self.SelectMode:SetSize(18, 18)
	self.SelectMode:SetScript("OnEnter", function(self) self.Texture:SetVertexColor(1, 0, 0) end)
	self.SelectMode:SetScript("OnLeave", function(self) self.Texture:SetVertexColor(1, 1, 1) end)
	self.SelectMode:SetScript("OnMouseUp", function() 
		if self.List:IsShown() then
			self.List:Hide()
		else
			self.List:Show()
		end
	end)
	
	self.SelectMode.Texture = self.SelectMode:CreateTexture(nil, "OVERLAY")
	self.SelectMode.Texture:SetPoint("CENTER", self.SelectMode, 0, 0)
	self.SelectMode.Texture:SetTexture("Interface\\AddOns\\Farmy\\HydraUIArrowDown.tga")
	
	self.DragHandle = CreateFrame("Frame", nil, self.BarParent)
	self.DragHandle:SetSize(16, 16)
	self.DragHandle:SetPoint("BOTTOMRIGHT", self.BarParent, -3, 3)
	self.DragHandle:SetAlpha(0)
	--self.DragHandle:RegisterForDrag("LeftButton")
	self.DragHandle:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	self.DragHandle:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
	--self.DragHandle:SetScript("OnMouseDown", function(self) self:GetParent():StartSizing("BOTTOMRIGHT") end)
	--self.DragHandle:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)
	
	self.DragHandle.Texture = self.DragHandle:CreateTexture(nil, "OVERLAY")
	self.DragHandle.Texture:SetSize(16, 16)
	self.DragHandle.Texture:SetPoint("CENTER", self.DragHandle)
	self.DragHandle.Texture:SetTexture("Interface\\AddOns\\Farmy\\Handle.tga")
	self.DragHandle.Texture:SetVertexColor(0, 204/255, 106/255)
	
	self.WindowCreated = true
end

SLASH_FARMY1 = "/farmy"
SlashCmdList["FARMY"] = function(cmd)
	if (not Farmy.GUI) then
		Farmy:CreateGUI()
		
		return
	end
	
	if Farmy.GUI:IsShown() then
		Farmy.GUI:Hide()
	else
		Farmy.GUI:Show()
	end
end