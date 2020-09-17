local UI = game.Players.LocalPlayer.PlayerGui

local ToReverse = {
	["ur"] = true
}

local AvailableLanguages = {
	["en"] = {
		["gb"] = true,
		["us"] = true,
		Default = "en-us"
	},
	["fr"] = {
		Default = "fr-ca"
	},
	["es"] = {
		Default = "es"
	},
	["ko"] = {
		Default = "ko"
	},
	["ar"] = {
		Default = "ar-dz"
	},
	["de"] = {
		Default = "de"
	},
	["nl"] = {
		Default = "nl"
	},
	["no"] = {
		Default = "no"
	},
	["lv"] = {
		Default = "lv"
	},
	["fil"] = {
		Default = "fil"
	},
	["pl"] = {
		Default = "pl"
	},
	["ur"] = {
		Default = "ur"
	},
	["et"] = {
		Default = "et"
	}
}

local Translations = {
	["   "] = {
		["ko"] = "번역자: R_rudu",
		["fr-ca"] = "Traduit par ScriptAbyss",
		["ur"] = "ترجمہ kisty1 کی طرف سے ہے",
		["de"] = "Übersetzt von Michi",
		["no"] = "Oversatt av WhereAreTheLights",
		["lv"] = "Tulkoja daviskyLV",
		["et"] = "Tõlgitud kasutaja Aisopos poolt"
	},
	["Multiplayer"] = {
		["ko"] = "멀티플레어",
		["fr-ca"] = "Multijoueur",
		["ur"] = "لوگوں کے ساتھ کھیلیں ",
		["de"] = "Mehrspieler",
		["no"] = "Multispiller",
		["lv"] = "Daudzspēlētāju režīms",
		["et"] = "Mitmikmäng"
	},
	["Time Trials"] = {
		["ko"] = "타임 트라일",
		["fr-ca"] = "Temps Records",
		["ur"] = "ٹائم ٹرائلز",
		["de"] = "Zeitfahren",
		["no"] = "Tidsprøver",
		["lv"] = "Laika izmēģinājumi",
		["et"] = "Ajarünnak"
	},
	["Customise"] = {
		["en-us"] = "Customize",
		["en-gb"] = "Customise",
		["ko"] = "꾸미기",
		["fr-ca"] = "Modifier",
		["ur"] = "سجاوٹ",
		["de"] = "Anpassen",
		["no"] = "Tilpass",
		["lv"] = "Izskats",
		["et"] = "Kohanda"
	},
	["Please wait..."] = {
		["ko"] = "기다려주세요",
		["fr-ca"] = "Veuillez patienter...",
		["ur"] = "...برائے مہربانی انتظار کریں",
		["de"] = "Bitte warten...",
		["no"] = "Vennligst vent...",
		["lv"] = "Lūdzu uzgaidiet...",
		["et"] = "Palun oodake..."
	},
	["Back"] = {
		["ko"] = "이전",
		["fr-ca"] = "Retour",
		["ur"] = "واپس ",
		["de"] = "Zurück",
		["no"] = "Tilbake",
		["lv"] = "Atpakaļ",
		["et"] = "Tagasi"
	},
	["Flags"] = {
		["ko"] = "깃발",
		["fr-ca"] = "Drapeaux",
		["ur"] = "جھنڈے ",
		["de"] = "Flaggen",
		["no"] = "Flagg",
		["lv"] = "Karogi",
		["et"] = "Lipud"
	},
	["Colours"] = {
		["en-us"] = "Colors",
		["en-gb"] = "Colours",
		["ko"] = "색갈",
		["fr-ca"] = "Couleurs",
		["ur"] = "رنگ",
		["de"] = "Farben",
		["no"] = "Farger",
		["lv"] = "Krāsas",
		["et"] = "Värvid"
	},
	["Skins"] = {
		["ko"] = "스킨",
		["fr-ca"] = "Revêtements",
		["ur"] = "بناوٹ",
		["lv"] = "Skini",
		["et"] = "Disain"
	},
	["Accessories"] = {
		["ko"] = "악세사리",
		["fr-ca"] = "Accessoires",
		["ur"] = "مزید اشیاء",
		["de"] = "Zubehör",
		["no"] = "Tilbehør",
		["lv"] = "Aksesuāri",
		["et"] = "Tarvikud"
	},
	["Number Plate"] = {
		["en-us"] = "License Plate",
		["en-gb"] = "Number Plate",
		["ko"] = "번호판",
		["fr-ca"] = "Numéro de la plaque d'immatriculation",
		["ur"] = "نمبر پلیٹ",
		["no"] = "Registreringsnummer",
		["lv"] = "Numura zīme",
		["de"] = "Nummernschild",
		["et"] = "Numbrimärk"
	},
	["Take off"] = {
		["ko"] = "벗다",
		["fr-ca"] = "Débuter",
		["ur"] = "چلو",
		["no"] = "Ta av",
		["lv"] = "Noņemt",
		["de"] = "(Zubehör) abnehmen",
		["et"] = "Võta ära"
	},
	["Add"] = {
		["ko"] = "추가",
		["fr-ca"] = "Ajouter",
		["ur"] = "شامل کریں",
		["no"] = "Legg til",
		["lv"] = "Pielikt",
		["de"] = "Hinzufügen",
		["et"] = "Lisa"
	},
	["Buy"] = {
		["ko"] = "코인",
		["fr-ca"] = "Acheter",
		["ur"] = "خریدیں",
		["no"] = "Kjøp",
		["lv"] = "Nopirkt",
		["de"] = "Kaufen",
		["et"] = "Osta"
	},
	["Buy Coins"] = {
		["ko"] = "코인 구매",
		["fr-ca"] = "Acheter des pièces d'or",
		["ur"] = "سکے خریدیں",
		["no"] = "Kjøp penger",
		["lv"] = "Nopirkt monētas",
		["de"] = "Münzen Kaufen",
		["et"] = "Osta münte"
	},
	["Unlock this by following @scfJosh on Twitter"] = {
		["ko"] = "이 아이템을 엇기위해는 @scfJosh를 Twitter에서 팔로우해주세요!",
		["fr-ca"] = "Débloque cela en suivant @scfJosh sur Twitter!",
		["ur"] = "!کو فالو کیجئے @scfJosh پر Twitter اسے کھولنے کے لئے",
		["no"] = "Opplås denne ved å følge @scfJosh på Twitter!",
		["lv"] = "Iegūsti šo, sekojot @scfJosh Twitterī!",
		["de"] = "Schalte dies Item frei indem du @scfJosh auf Twitter folgst!",
		["et"] = "Avamiseks jälgi @scfJosh-i Twitteris!"
	},
	["Unfortunately, Roblox have censored this plate!"] = {
		["ko"] = "Roblox에 불가능한 번호판입나다",
		["fr-ca"] = "Malheureusement, Roblox a censuré cette plaque!",
		["ur"] = "!نے اس نمبر پلیٹ کو احتساب کردیا ہے Roblox بدقسمتی سے",
		["no"] = "Roblox har dessverre filtrert registreringsnummeret",
		["lv"] = "Diemžēl, Roblox neatļauj šo numura zīmi",
		["de"] = "Leider hat Roblox dieses Nummernschild zensiert!",
		["et"] = "Kahjuks Roblox ei luba sellist teksti sinu numbrimärgil."
	},
	--
	--
	["Your reward for being a member of the ScriptersCF group on Roblox!"] = {
		["ko"] = "ScriptersCF의 맴버용 보상입니다!",
		["fr"] = "Ta récompense pour être un membre du groupe ScriptersCF sur Roblox!",
		["ur"] = "!گروپ کے رکن ہونے کا انعام ScriptersCF پر Roblox اپکا",
		["no"] = "Din belønning for å vere et medlem av ScriptersCF-gruppen på Roblox!",
		["lv"] = "Tavs atalgojums par to, ka esi ScriptersCF Roblox grupā! ",
		["de"] = "Deine Belohnung dafür, das du ein Mitglied der ScriptersCF Gruppe auf Roblox bist!",
		["et"] = "Sinu tänu-auhind ScriptersCF-i ROBLOX grupi liikmeks olemise eest."
	},
	["Waiting for more players..."] = {
		["ko"] = "인원이 부족합니다, 대기중...",
		["fr-ca"] = "En attente de joueurs...",
		["ur"] = "...دوسرے کھلاڑیوں کا انتظار کیا جا رہا ہے",
		["no"] = "Venter på flere spillere...",
		["lv"] = "Gaida vēl spēlētājus...",
		["de"] = "Warte auf mehr Spieler...",
		["et"] = "Ootan mängijaid..."
	},
	["Controls"] = {
		["ko"] = "콘트롤",
		["fr-ca"] = "Contrôles",
		["ur"] = "کنٹرولز ",
		["no"] = "Kontroller",
		["lv"] = "Kontroles",
		["de"] = "Steuerung",
		["et"] = "Mängunupud"
	},
	["Leave Game"] = {
		["ko"] = "나가기",
		["fr-ca"] = "Quitter la partie",
		["ur"] = "گیم چھوڑدو",
		["no"] = "Forlat spillet",
		["lv"] = "Iziet no spēles",
		["de"] = "Spiel Verlassen",
		["et"] = "Lahku"
	},
	["Waiting..."] = {
		["ko"] = "기다리는 중...",
		["ur"] = "...برائے مہربانی انتظار کریں",
		["no"] = "Venter...",
		["lv"] = "Gaida...",
		["de"] = "Warten...",
		["et"] = "Ootan mängu..."
	},
	--
	--
	["Choose a Course"] = {
		["ko"] = "코스를 선택해주세요",
		["fr-ca"] = "Sélectionne une piste",
		["ur"] = "کورس چننے",
		["no"] = "Velg en bane",
		["lv"] = "Izvēlieties trasi",
		["de"] = "Wähle ein Kurs",
		["et"] = "Vali rada"
	},
	["You will be racing on..."] = {
		["ko"] = "...에서 레이스가 진행됩니다",
		["fr-ca"] = "Vous conduirez sur...",
		["ur"] = "پر جیپ ریس کرنے لگے ہیں",
		["no"] = "Du vil kjøre på...",
		["lv"] = "Jūs sacensīsieties",
		["de"] = "Du wirst auf",
		["et"] = "Sa võistled rajal..."
	}
}

local function Reverse(word)
    local utf8Words = {}
    local utf8Reversed = {}
    local utf8CurrentWord = ""
    for first, last in utf8.graphemes(word) do
        local Utf8char = word:sub(first,last)
        if string.find(Utf8char, "%s+") == nil then
            utf8CurrentWord = utf8CurrentWord .. Utf8char
        else
            table.insert(utf8Words, utf8CurrentWord)
            utf8CurrentWord = ""
        end
    end
    table.insert(utf8Words, utf8CurrentWord)
    
    for i = #utf8Words, 1, -1 do
        table.insert(utf8Reversed, utf8Words[i])
    end
    return table.concat(utf8Reversed, " ")
end

local function Translate(Lang)
	print(Lang)
	for i, v in pairs(UI:GetDescendants()) do
		if v.ClassName:find("Text") and not v:IsA("Texture") then
			local TextTrans = Translations[v.Text]
			if TextTrans then
				if TextTrans[Lang] then
					v.Text = ToReverse[Lang] and Reverse(TextTrans[Lang]) or TextTrans[Lang]
				end
			end
			
			v.Changed:Connect(function()
				local TextTrans = Translations[v.Text]
				if TextTrans then
					if TextTrans[Lang] then
						v.Text = ToReverse[Lang] and Reverse(TextTrans[Lang]) or TextTrans[Lang]
					end
				end
			end)
		end
	end
end

return function()
	if game.Players.LocalPlayer.Name == "Aisopos" then
		Translate("et")
	else
	local LanguageContent = {}
	for i in game.LocalizationService.SystemLocaleId:gmatch("([^-]+)") do
		LanguageContent[#LanguageContent + 1] = i
	end
	if AvailableLanguages[LanguageContent[1]] then
		if AvailableLanguages[LanguageContent[1]][LanguageContent[2]] then
			Translate(game.LocalizationService.SystemLocaleId)
		else
			Translate(AvailableLanguages[LanguageContent[1]].Default)
		end
	else
		Translate("en-us")
	end
	end
end