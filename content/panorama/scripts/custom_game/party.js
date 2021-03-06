"use strict"
var Heroes = [];
var HeroesInitialized = [];
var HP_BAR = 0,
    HP_BAR_VALUE = 1,
    HP_BAR_REG_VALUE = 2,
    MP_BAR = 3,
    MP_BAR_VALUE = 4,
    MP_BAR_REG_VALUE = 5,
    EXP_BAR = 6,
    EXP_BAR_VALUE = 7,
    LEVEL_BAR_VALUE = 8,
    HERO_ENTITY = 9,
    HERO_PORTRAIT = 10,
	HERO_PANEL = 11,
	PLAYER_ID = 12,
	PLAYER_PORTRAIT_FIXED = 13,
	DEATH_TIMER = 14,
	HERO_OWNER_NAME = 15;

var MAX_PLAYERS = 5;

function OnPortraitClick(id) {
	var IsAltDown = GameUI.IsAltDown();
    var hero = Heroes[id][HERO_ENTITY];
    Players.PlayerPortraitClicked(Heroes[id][PLAYER_ID], false, false );
	if(IsAltDown) {
		var player = Players.GetLocalPlayer();
		var message;
		var IsDead = (Entities.GetHealth(hero) < 1);
		var message = "Ally " + $.Localize("#" + Entities.GetUnitName(hero)) + " is " + (IsDead ? "dead and will ressurect in " + Players.GetRespawnSeconds(Entities.GetPlayerOwnerID(hero)) + " seconds" : "still alive") + ".";
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
	}
}


function OnHPBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
		var currentHp = Entities.GetHealth(hero);
		var maxHp = Entities.GetMaxHealth(hero);
		var hpPercent = (currentHp / maxHp) * 100;
		hpPercent = Math.round(hpPercent * 100) / 100;
		var message = "Ally " + $.Localize("#" + Entities.GetUnitName(hero)) + " have " + currentHp + " (" + hpPercent + "%) health left.";
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
	}
}

function OnMPBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
		var currentMp = Entities.GetMana(hero);
		var maxMp = Entities.GetMaxMana(hero);
		var mpPercent = (currentMp / maxMp) * 100;
		mpPercent = Math.round(mpPercent * 100) / 100;
		var message = "Ally " + $.Localize("#" + Entities.GetUnitName(hero)) + " have " + currentMp + " (" + mpPercent + "%) mana left.";
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
	}
}

function OnExpBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
        var currentExp = Entities.GetCurrentXP(hero);
        var maxExp = Entities.GetNeededXPToLevel(hero);
        var expPercent = (currentExp / maxExp) * 100;
		expPercent = Math.round((100-expPercent) * 100) / 100;
		var message;
		if(maxExp == 0) {
			message = "Ally " + $.Localize("#" + Entities.GetUnitName(hero)) + " have maximum level.";
		} else {
			message = "Ally " + $.Localize("#" + Entities.GetUnitName(hero)) + " need " + (maxExp-currentExp) + " (" + expPercent + "%) XP for next level.";
		}
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
	}
}

function OnLvlBarClick(id) {
	var IsAltDown = GameUI.IsAltDown();
	if(IsAltDown) {
        var hero = Heroes[id][HERO_ENTITY];
		var player = Players.GetLocalPlayer();
        var currentLevel = Entities.GetLevel(hero);
        var maxExp = Entities.GetNeededXPToLevel(hero);
		var message;
		if(maxExp == 0) {
			message = "Ally " + $.Localize("#" + Entities.GetUnitName(hero)) + " have maximum level.";
		} else {
			message = "Ally " + $.Localize("#" + Entities.GetUnitName(hero)) + " have " + currentLevel + " level.";
		}
		GameEvents.SendCustomGameEventToServer("rpg_say_chat_message", { "player_id" : player, "msg" : message});
	}
}

function UpdateValues() {
	var IsAltDown = GameUI.IsAltDown();
    for (var i = 0; i < Heroes.length; i++) {
        var hero = Heroes[i][HERO_ENTITY];
		var IsPlayerLoaded = (hero > -1);
		Heroes[i][HERO_PANEL].style.visibility = IsPlayerLoaded ? "visible" : "collapse";
        if (IsPlayerLoaded) {
            var currentHp = Entities.GetHealth(hero);
            var maxHp = Entities.GetMaxHealth(hero);
            var hpPercent = (currentHp / maxHp) * 100;
            var hpReg = Entities.GetHealthThinkRegen(hero);
            var currentMp = Entities.GetMana(hero);
            var maxMp = Entities.GetMaxMana(hero);
            var mpPercent = (currentMp / maxMp) * 100;
            var mpReg = Entities.GetManaThinkRegen(hero);
            var currentExp = Entities.GetCurrentXP(hero);
            var maxExp = Entities.GetNeededXPToLevel(hero);
            var expPercent = (currentExp / maxExp) * 100;
            var currentLevel = Entities.GetLevel(hero);
			var IsDead = (currentHp < 1);
			Heroes[i][HERO_PORTRAIT].SetHasClass("is_dead", IsDead);
			Heroes[i][DEATH_TIMER].style.visibility = IsDead ? "visible" : "collapse";
			if(IsDead) {
				var respawnTime = Players.GetRespawnSeconds(Entities.GetPlayerOwnerID(hero));
				if(respawnTime > 9999) {
					respawnTime = "";
				}
				Heroes[i][DEATH_TIMER].text = respawnTime;
			}
            Heroes[i][HP_BAR].style.width = Math.floor(hpPercent) + "%";
			if(IsAltDown) {
				Heroes[i][HP_BAR_VALUE].text = (Math.round(hpPercent * 100) / 100) + "%";
			} else {
				Heroes[i][HP_BAR_VALUE].text = currentHp + " / " + maxHp;
			}
            Heroes[i][HP_BAR_REG_VALUE].text = "+" + (Math.round(hpReg * 100) / 100);
            Heroes[i][MP_BAR].style.width = Math.floor(mpPercent) + "%";
			if(IsAltDown) {
				Heroes[i][MP_BAR_VALUE].text = (Math.round(mpPercent * 100) / 100) + "%";
			} else {
				Heroes[i][MP_BAR_VALUE].text = currentMp + " / " + maxMp;
			}
            Heroes[i][MP_BAR_REG_VALUE].text = "+" + (Math.round(mpReg * 100) / 100);
			if(maxExp == 0) {
				expPercent = 100;
			}
            Heroes[i][EXP_BAR].style.width = Math.floor(expPercent) + "%";
            if (IsAltDown) {
                Heroes[i][EXP_BAR_VALUE].text = currentExp + " / " + maxExp;
            } else {
                Heroes[i][EXP_BAR_VALUE].text = Math.floor(expPercent) + "%";
            }
            if (IsAltDown && Heroes[i][HERO_PANEL].BHasClass("Small")) {
				Heroes[i][LEVEL_BAR_VALUE].text = Math.floor(expPercent) + "%";
			} else {
				Heroes[i][LEVEL_BAR_VALUE].text = currentLevel;
			}
			Heroes[i][HERO_OWNER_NAME].text = Players.GetPlayerName(Heroes[i][PLAYER_ID]);
			Heroes[i][HERO_OWNER_NAME].style.color = GetHEXPlayerColor(Heroes[i][PLAYER_ID]);
			if(!Heroes[i][PLAYER_PORTRAIT_FIXED]) {
				Heroes[i][HERO_PORTRAIT].SetUnit(Entities.GetUnitName(hero), "1", true);
				Heroes[i][PLAYER_PORTRAIT_FIXED] = true;
			}
        } else {
			Heroes[i][HERO_ENTITY] = Players.GetPlayerHeroEntityIndex(Heroes[i][PLAYER_ID]);
		}
    }
}

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}


function AutoUpdateValues() {
    UpdateValues();
    $.Schedule(0.1, function() {
        AutoUpdateValues();
    });
}

function ChangePanelSize() {
	var IsSmall = Heroes[0][HERO_PANEL].BHasClass("Small");
	for(var i = 0; i < Heroes.length; i++) {
		Heroes[i][HERO_PANEL].SetHasClass("Small", !IsSmall);
	}		
}

function Init() {
    var root = $.GetContextPanel();
	var localPlayerId = Players.GetLocalPlayer();
	var IsFirstTime = true;
	Heroes = [];
    for (var i = 0; i < MAX_PLAYERS; i++) {
        var isValidPlayer = Players.IsValidPlayerID(i) && !Players.IsSpectator(i);
        if (isValidPlayer && localPlayerId != i) {
            var heroPanel = $.CreatePanel("Panel", root, "Hero" + (i-1));
            heroPanel.BLoadLayout("file://{resources}/layout/custom_game/party_member.xml", false, false);
			heroPanel.Data().ChangePanelSize = ChangePanelSize;
			heroPanel.Data().OnHPBarClick = OnHPBarClick;
			heroPanel.Data().OnMPBarClick = OnMPBarClick;
			heroPanel.Data().OnExpBarClick = OnExpBarClick;
			heroPanel.Data().OnPortraitClick = OnPortraitClick;
			if(IsFirstTime) {
				var changeSizeBtn = heroPanel.FindChildTraverse("ChangePanelSizeButton");
				if(changeSizeBtn != null) {
					changeSizeBtn.style.visibility = "visible";
				}
				IsFirstTime = false;
			}
            var heroEntityIndex = Players.GetPlayerHeroEntityIndex(i);
            var hero = heroPanel.GetChild(0);
			var heroOwnerName = hero.GetChild(0);
            var hpBarPanel = hero.GetChild(1);
            var hpBar = hpBarPanel.GetChild(0);
            var hpBarCurrentValue = hpBarPanel.GetChild(1);
            var hpBarRegValue = hpBarPanel.GetChild(2);
            var mpBarPanel = hero.GetChild(2);
            var mpBar = mpBarPanel.GetChild(0);
            var mpBarCurrentValue = mpBarPanel.GetChild(1);
            var mpBarRegValue = mpBarPanel.GetChild(2);
            var expBarPanel = hero.GetChild(3);
            var expBar = expBarPanel.GetChild(0);
            var expBarCurrentValue = expBarPanel.GetChild(1);
            var heroPortrait = hero.GetChild(4);
            var levelBarPanel = hero.GetChild(5);
            var levelBarValue = levelBarPanel.GetChild(0);
			var playerPortraitFixed = false;
			var deathTimer = hero.GetChild(7).GetChild(0);
            Heroes.push([hpBar, hpBarCurrentValue, hpBarRegValue, mpBar, mpBarCurrentValue, mpBarRegValue, expBar, expBarCurrentValue, levelBarValue, heroEntityIndex, heroPortrait, hero, i, playerPortraitFixed, deathTimer, heroOwnerName]);
        }
    }
    AutoUpdateValues();
}

(function() {
    Init();
})();