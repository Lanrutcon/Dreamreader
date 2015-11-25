local Addon = CreateFrame("FRAME", "DreamreaderAddon");

-- Database will all reported quests from Bugtracker. Will be filled when the addon starts
local database;

-- TODO list
-- get item/npc link by name
-- bug: when sliding the bar on questlog, imgs don't move to where they belong

-------------------------------------
--
-- Check/Select button's function.
-- If the button's text is "Check", it will check if the title is OK and look for links. Then change the text to "Select All".
-- If the button's text is "Select All", it means everything is OK and will select all the text.
--
-------------------------------------
function checkSelectFunction()
	if (_G["dreamreader".."CheckSelect"]:GetText() == "Check") then
		local hasLink = string.find(_G["FrameScrollText"]:GetText(), "www.");
		if(checkTitle() and hasLink) then
			_G["dreamreader".."CheckSelect"]:SetText("Select All");
		elseif(checkTitle() and not hasLink) then
			RaidNotice_AddMessage(RaidWarningFrame, "There are no WoWHead links!", {r = 1, g = 0, b = 0})
			PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
		elseif(not checkTitle() and hasLink) then
			RaidNotice_AddMessage(RaidWarningFrame, "Wrong title!", {r = 1, g = 0, b = 0})
			PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
		else
			RaidNotice_AddMessage(RaidWarningFrame, "Wrong title and no WoWHead links!", {r = 1, g = 0, b = 0})
			PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
		end
	else	
		_G["FrameScrollText"]:HighlightText()
	end
end

-------------------------------------
--
-- Returns the language
-- Example: getLanguage("[EN][Quest][Orgrimmar] Speak with Garrosh") --> [EN] 
-- @return string
--
-------------------------------------
local function getLanguage(title)
	return string.sub(title,1,4);
end

-------------------------------------
--
-- Returns the quest section
-- Example: getQuestSection("[EN][Quest][Orgrimmar] Speak with Garrosh") --> [Quest]
-- @param #string title Title
-- @return string
--
-------------------------------------
local function getQuestSection(title)
	--remove language
	title = string.sub(title, 4);
	title = string.sub(title, string.find(title, "]") + 1, string.find(title, "]") + 7);
	return title;
end

-------------------------------------
--
-- Returns the zone
-- Example: getZone("[EN][Quest][Orgrimmar] Speak with Garrosh") --> [Orgrimmar]
-- @param #string title Title
-- @return string 
--
-------------------------------------
local function getZone(title)
	--remove [EN]/[PL] and [Quest]
	title = string.sub(title, 12);
	local cut = string.find(title, "]");
	return string.sub(title, 0, cut);
end

-------------------------------------
--
-- Returns the quest's name
-- Example: getLanguage("[EN][Quest][Orgrimmar] Speak with Garrosh") --> Speak with Garrosh
-- @param #string title Title
-- @return string
--
-------------------------------------
local function getQuestName(title)
	--remove language+[quest]+zone
	title = string.sub(title, 12);								--remove lang + [quest]
	title = string.sub(title, string.find(title, "]") + 1, -1);	--remove zone
	return title;
end

-------------------------------------
--
-- Checks the title with the help of the above functions.
-- @return boolean
--
-------------------------------------
function checkTitle()
	local title = _G["dreamreader".."Title"]:GetText();
	--local exampleTitle = "[XX][Zone][Quest] QuestName";

	if(getLanguage(title) ~= "[EN]" and getLanguage(title) ~= "[PL]") then
		--print("Bad language")
		return false;
		
	elseif(getQuestSection(title) ~= "[Quest]") then
		--print("Bad quest")
		return false;

	elseif(string.sub(getZone(title), 1, 1) ~= "[" or string.sub(getZone(title), -1, -1) ~= "]") then
		--print("Bad Zone")
		return false;

	elseif(string.reverse(getQuestName(title)) == getQuestName(title) ) then		--using reverse to detect empty spaces --strtrim
		--print("Bad quest name")
		return false;

	else
		return true;
	end
end


-------------------------------------
--
-- Sets the title in the editbox.
-- It gets the info from the selected quest in the QuestLog. 
--
-------------------------------------
function setAutoTitle()
	local title = GetQuestLogTitle(GetQuestLogSelection())
	local questID = select(9, GetQuestLogTitle(GetQuestLogSelection()))
	local mapName = GetMapNameByID(GetQuestWorldMapAreaID(questID))

	_G["dreamreader".."Title"]:SetText("[EN][Quest]["..mapName.."] "..title);
end

-------------------------------------
--
-- Receives a WoW Link, returns a WoWHead link (already ready for Bugtracker/Github)
-- It will be used when players shift-click on items/npc/quests/etc...
-- @param #string hyperLink: World of Warcraft link
-- @return #string WoWHead link
--
-------------------------------------
function replaceWoWLinks(hyperLink)

	local _, _, Color, Ltype, Id =
		string.find(hyperLink,
			"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

	local i = string.find(hyperLink, "|h") + 3;
	local j = string.find(hyperLink, "]") - 1;
	local name = string.sub(hyperLink, i, j);

	if(Ltype == "quest") then
		return "["..name.."](http://www.wowhead.com/quest="..Id..")";
	elseif (Ltype == "item") then
		return "["..name.."](http://www.wowhead.com/item="..Id..")";
	elseif (Ltype == "npc") then
		return "["..name.."](http://www.wowhead.com/npc="..Id..")";
	elseif (Ltype == "spell") then
		return "["..name.."](http://www.wowhead.com/spell="..Id..")";
	end

	return hyperLink;

end


-- Button which is displayed in the quest log.
questLogButton = CreateFrame("BUTTON", "Dreamreader", QuestLogFrame, "UIPanelButtonTemplate");
questLogButton:SetText("Dreamreader");
questLogButton:SetSize(100,23);
questLogButton:SetScript("OnClick", function(self, button)
	if(questLogButton:GetText() == "Reported") then
		local questName = GetQuestLogTitle(GetQuestLogSelection())
		local questID = select(9, GetQuestLogTitle(GetQuestLogSelection()))
		local mapName = GetMapNameByID(GetQuestWorldMapAreaID(questID))
		
		local lang, zone, name = database[questID][1], database[questID][2], database[questID][3];
		local title = "[" .. lang .. "]" .. "[Quest]" .. "[" .. zone .. "]" .. " " .. name;
		RaidNotice_AddMessage(RaidWarningFrame, "A report already exists for this quest with the following title:", {r = 1, g = 1, b = 1} );
		--if the title issue is correct (good zones+title) then print green warning with title
		if(zone == mapName and name == questName) then
			RaidNotice_AddMessage(RaidWarningFrame, title, {r = 0.2, g = 1, b = 0.2})		
		else	--else prints red warning with title
			RaidNotice_AddMessage(RaidWarningFrame, title, {r = 1, g = 0, b = 0})
		end
		PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
	end
	if(dreamreader:IsVisible()) then
		dreamreader:Hide();
	else
		dreamreader:Show();
		setAutoTitle();
	end
end);
questLogButton:SetPoint("LEFT", QuestLogFrameCancelButton, "LEFT", -100, 0);
questLogButton:Show();


-----------------
--RULES FRAME
-----------------
local rulesFrame = CreateFrame("FRAME", "RulesFrame", UIParent);
rulesFrame:Hide();
rulesFrame:SetFrameStrata("DIALOG")
rulesFrame:SetWidth(700);
rulesFrame:SetHeight(325);
rulesFrame:SetPoint("TOP", 0, -230)
rulesFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
	insets = {left = 11, right = 12, top = 12, bottom = 11},
})
rulesFrame:SetMovable(true)
rulesFrame:SetScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		self:StartMoving()
	end
end)
rulesFrame:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing();
end)

local fontString = rulesFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
fontString:SetWidth(650)
fontString:SetHeight(0)
fontString:SetPoint("TOP", 0, -16)
fontString:SetText([[|cffee4400Atlantiss Core 4|r

|cffee4400How to use?|r

On the Bugtracker all titles of reports must be written in English so that everyone, no matter which language they use everyday, could search and check if the problem already has been reported by another player. When describing the problem you can use English as well as Polish and in nearest future - others. It is important to determine at the beginning of a title in which language it is written by using symbols [EN] or [PL].
Use the search engine to find out if a similar problem has been already reported. If so, check if it's already been fixed and waits for update.
Make sure, that what you report is actually a bug.

Enclose links to things related to the bug using |cff0066FFhttp://wowhead.com|r or |cff0066FFhttp://cata.openwow.com|r

|cff00FF00Write your tickets according to the format:|r
[EN][Quest][Zone] A Vision of the Past
[EN][NPC] Thoralius the Wise
[EN][Spell][Class] Frostfire Bolt
[PL][Talent][Class] Brain Freeze
[EN][Glyph][Class] Glyph of Frostfire Bolt
[EN][Npc][Drop] Thoralius the Wise
[EN][Web] Armory doesnt work
]]);


-----------------
--CODES FRAME
-----------------
local codesFrame = CreateFrame("FRAME", "CodesFrame", UIParent);
codesFrame:Hide();
codesFrame:SetFrameStrata("DIALOG")
codesFrame:SetWidth(700);
codesFrame:SetHeight(450);
codesFrame:SetPoint("TOP", 0, -230)
codesFrame:SetBackdrop({
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
	insets = {left = 11, right = 12, top = 12, bottom = 11},
})
codesFrame:SetMovable(true)
codesFrame:SetScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		self:StartMoving()
	end
end)
codesFrame:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing();
end)
fontString = codesFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
fontString:SetWidth(650)
fontString:SetHeight(0)
fontString:SetPoint("TOP", 0, -16)
fontString:SetText([[
|cffee4400Github Codes|r

|cff00ff00Italic:|r *italic text*
|cff00ff00Bold:|r **bold text**
|cff00ff00Crossed:|r ~~crossed text~~
|cff00ff00Link:|r [Click Here!](http://atlantiss.eu/)
|cff00ff00List:|r
* Item List #1
* Item List #2
* ...

or

1. Item List #1
2. Item List #2
3. ...

|cff00ff00Headers:|r
# h1
## h2
### h3
...

|cff00ff00Horizontal Lines:|r Using 3 or more of the following symbols ('-', '*' and '_') will create a sort of separator. Example:

Quest Title

------

This quest is bugged because the mob is missing.


|cffee4400These are the basics, use these codes to make your report easier to read.|r
]]);


-------------------------------------
--
-- Toggles Rule's frame
--
-------------------------------------
function showRules()
	if(rulesFrame:IsShown()) then
		rulesFrame:Hide();
	else
		rulesFrame:Show();
	end
end

-------------------------------------
--
-- Toggles Codes' frame
--
-------------------------------------
function showCodes()
	if(codesFrame:IsShown()) then
		codesFrame:Hide();
	else
		codesFrame:Show();
	end
end


-- Bugtracker's Link frame
local bugtrackerLinkFrame;

-------------------------------------
--
-- RipOff from DBM (DeadlyBossModes)
-- Creates a frame with a editbox. Inside there's a link for players to copy.
--
-------------------------------------
function showBugtrackerLink()
	if(bugtrackerLinkFrame and bugtrackerLinkFrame:IsShown()) then
		bugtrackerLinkFrame:Hide();
		return;
	end
	bugtrackerLinkFrame = CreateFrame("Frame", nil, UIParent)
	bugtrackerLinkFrame:SetFrameStrata("DIALOG")
	bugtrackerLinkFrame:SetWidth(430)
	bugtrackerLinkFrame:SetHeight(125)
	bugtrackerLinkFrame:SetPoint("TOP", 0, -230)
	bugtrackerLinkFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
		insets = {left = 11, right = 12, top = 12, bottom = 11},
	})
	local fontstring = bugtrackerLinkFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontstring:SetWidth(410)
	fontstring:SetHeight(0)
	fontstring:SetPoint("TOP", 0, -16)
	fontstring:SetText("Atlantiss Bugtracker Link")
	local editBox = CreateFrame("EditBox", nil, bugtrackerLinkFrame)
	do
		local editBoxLeft = editBox:CreateTexture(nil, "BACKGROUND")
		local editBoxRight = editBox:CreateTexture(nil, "BACKGROUND")
		local editBoxMiddle = editBox:CreateTexture(nil, "BACKGROUND")
		editBoxLeft:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left")
		editBoxLeft:SetHeight(32)
		editBoxLeft:SetWidth(32)
		editBoxLeft:SetPoint("LEFT", -14, 0)
		editBoxLeft:SetTexCoord(0, 0.125, 0, 1)
		editBoxRight:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		editBoxRight:SetHeight(32)
		editBoxRight:SetWidth(32)
		editBoxRight:SetPoint("RIGHT", 6, 0)
		editBoxRight:SetTexCoord(0.875, 1, 0, 1)
		editBoxMiddle:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		editBoxMiddle:SetHeight(32)
		editBoxMiddle:SetWidth(1)
		editBoxMiddle:SetPoint("LEFT", editBoxLeft, "RIGHT")
		editBoxMiddle:SetPoint("RIGHT", editBoxRight, "LEFT")
		editBoxMiddle:SetTexCoord(0, 0.9375, 0, 1)
	end
	editBox:SetHeight(32)
	editBox:SetWidth(350)
	editBox:SetPoint("TOP", fontstring, "BOTTOM", 0, -4)
	editBox:SetFontObject("GameFontHighlight")
	editBox:SetTextInsets(0, 0, 0, 1)
	editBox:SetFocus()
	editBox:SetText("https://github.com/Atlantiss/BugTracker/issues?page=1&q=is%3Aissue+is%3Aopen+quest&utf8=%E2%9C%93")
	editBox:HighlightText()
	editBox:SetScript("OnTextChanged", function(self)
		editBox:SetText("https://github.com/Atlantiss/BugTracker/issues?page=1&q=is%3Aissue+is%3Aopen+quest&utf8=%E2%9C%93")
		editBox:HighlightText()
	end)
	local fontstring = bugtrackerLinkFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontstring:SetWidth(410)
	fontstring:SetHeight(0)
	fontstring:SetPoint("TOP", editBox, "BOTTOM", 0, 0)
	fontstring:SetText("Ctrl-C to copy link then Ctrl-V to paste into your browser")
	local button = CreateFrame("Button", nil, bugtrackerLinkFrame)
	button:SetHeight(24)
	button:SetWidth(150)
	button:SetPoint("BOTTOM", 0, 13)
	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")
	button:SetNormalTexture(button:CreateTexture(nil, nil, "UIPanelButtonUpTexture"))
	button:SetPushedTexture(button:CreateTexture(nil, nil, "UIPanelButtonDownTexture"))
	button:SetHighlightTexture(button:CreateTexture(nil, nil, "UIPanelButtonHighlightTexture"))
	button:SetText("Open Browser")
	button:SetScript("OnClick", function(self)
		bugtrackerLinkFrame:Hide()
		LoadURLIndex(0);
	end)
end

-------------------------------------
--
-- Function that will be hooked in the Target's frame.
-- When the player shift-clicks on the frame, it adds a WoWHead link into the report.
--
-------------------------------------
local TargetFrame_OnClick = function( self, button )
    if(not UnitIsPlayer("target") and IsShiftKeyDown() and button == "LeftButton") then
		local npcID = tonumber((UnitGUID("target")):sub(7, 10), 16);		
		_G["FrameScrollText"]:Insert("["..UnitName("target").."](http://www.wowhead.com/npc="..npcID..")");
	end
end

_G["TargetFrame"]:HookScript("OnClick", TargetFrame_OnClick)


-- Save Blizz functions
Blizz_QuestLog_SetSelection = QuestLog_SetSelection;
Blizz_ChatEdit_InsertLink = ChatEdit_InsertLink;

-------------------------------------
--
-- Replaces Blizzard's ChatLink function, in order to send links to report's editbox.
--
-------------------------------------
function replaceBlizzFunc()
	function dreamreader_ChatEdit_InsertLink(link)
		if(not _G["FrameScrollText"]:HasFocus()) then
			Blizz_ChatEdit_InsertLink(link);
		else
			_G["FrameScrollText"]:Insert(replaceWoWLinks(link));
		end
	end
	ChatEdit_InsertLink = dreamreader_ChatEdit_InsertLink;
end

-------------------------------------
--
-- Overrides Blizzard's QuestLog_SetSelection function, to changed Dreamreader's button.
-- From privstat addon
--
-------------------------------------
function QuestLog_SetSelection(questIndex)
    local questID = select(9, GetQuestLogTitle(questIndex));
    if (database[questID]) then
        questLogButton:SetText("Reported");
    else
    	questLogButton:SetText("Dreamreader");
    end
    Blizz_QuestLog_SetSelection(questIndex)
end


-------------------------------------
--
-- Function that will be hooked in "Loaded" event. Sets images on the questLog for reported quests.
-- From privstat addon
--
-------------------------------------
local function QuestLog_Update()
    local buttons = QuestLogScrollFrame.buttons;
	local numButtons = #buttons;
	for i = 1, numButtons do
		local isHeader = select(5, GetQuestLogTitle(i));
		local questID = select(9, GetQuestLogTitle(i));
		if (not isHeader and database[questID]) then
			buttons[i]:SetNormalTexture("Interface\\AddOns\\Dreamreader\\Imgs\\reported");
			buttons[i]:SetHighlightTexture("Interface\\AddOns\\Dreamreader\\Imgs\\reported");
		end
	end
end


Addon:SetScript("OnEvent", function(self, event)
	if(event == "VARIABLES_LOADED") then
		database = dbIssue;										--db is a table in database.lua
	elseif(event == "PLAYER_LOGIN") then
		print("|cff333333Dr|cff666666ea|cff999999mr|cffccccccea|cffffffffde|cffccccccr L|cff999999oa|cff666666de|cff333333d|r")
		local diff = date("*t").yday - lastUpdate;
		if(diff > 7 or diff < 0) then
			print("|cff999999Issue database is |cffff2222+7 days old|r, please update it by using the jar file inside Dreamreader's folder|r");
		end
		--hook here to overwrite any textures (e.g.: PrivStats)
		hooksecurefunc("QuestLog_Update", QuestLog_Update);
		hooksecurefunc(QuestLogScrollFrame, "update", QuestLog_Update);
	end
end)

Addon:RegisterEvent("VARIABLES_LOADED");
Addon:RegisterEvent("PLAYER_LOGIN");