local Http = game:GetService("HttpService")

local module = {
	Flag = {
		["NyanCat"] = 99,
		["DancingBanana"] = 99,
		["Alex"] = 49,
		["Corl"] = 49,
		["DanTDM"] = 49,
		["Denis"] = 49,
		["Flamingo"] = 49,
		["InquisitorMaster"] = 49,
		["ItsFunneh"] = 49,
		["Poke"] = 49,
		["Sketch"] = 49,
		["Sub"] = 49,
		["Thinknoodles"] = 49,
		["Tofuu"] = 49,
		["ZephPlayz"] = 49,
		["Ban"] = 999999
	},
	Colour = {
		["Red"] = 199,
		["Orange"] = 199,
		["GreyLight"] = 99,
		["GreyDark"] = 99,
		["Blue"] = 149,
		["Purple"] = 149,
		["Yellow"] = 199,
		["Black"] = 149,
		["Green"] = 199,
		["GreenDark"] = 149,
		["BlueGreen"] = 149,
		["Gold"] = 249,
		["YellowLight"] = 149,
		["Brown"] = 149,
		["Pink"] = 199
	},
	Skin = {
		["Carbon"] = 599,
		["Leopard"] = 699,
		["Marble"] = 249,
		["Missing"] = 1299,
		["Space"] = 249,
		["Sparkle"] = 2499,
		["Checker"] = 249,
		["Ice"] = 299,
		["Camo"] = 899,
		["BlueCamo"] = 999,
		["Donut"] = 899,
		["Hearts"] = 599,
		["Emoji"] = 1099,
		["Wood"] = 399,
		["Binary"] = 1499,
		["Rainbow"] = 599,
		["Ban"] = 999999,
		["Circuit"] = 499,
	}
}

for i, v in pairs(Http:JSONDecode(([[{"Nepal":{"Asset":"2659801598","Decal":"2659801601"},"Kyrgyzstan":{"Asset":"2659796154","Decal":"2659796156"},"Canada":{"Asset":"2659781542","Decal":"2659781544"},"South Korea":{"Asset":"2659814538","Decal":"2659814541"},"Japan":{"Asset":"2659795132","Decal":"2659795139"},"Pakistan":{"Asset":"2659806203","Decal":"2659806208"},"Myanmar":{"Asset":"2659801274","Decal":"2659801282"},"Chile":{"Asset":"2659781820","Decal":"2659781825"},"Zimbabwe":{"Asset":"2659819360","Decal":"2659819363"},"Malaysia":{"Asset":"2659798533","Decal":"2659798537"},"Bahrain":{"Asset":"2659779582","Decal":"2659779585"},"Uganda":{"Asset":"2659817621","Decal":"2659817624"},"Sri Lanka":{"Asset":"2659814971","Decal":"2659814976"},"Italy":{"Asset":"2659794680","Decal":"2659794687"},"Yemen":{"Asset":"2659819137","Decal":"2659819140"},"Papua New Guinea":{"Asset":"2659807372","Decal":"2659807377"},"Russia":{"Asset":"2659812079","Decal":"2659812081"},"Ecuador":{"Asset":"2659787243","Decal":"2659787247"},"Dominican Republic":{"Asset":"2659786724","Decal":"2659786728"},"Mali":{"Asset":"2659799181","Decal":"2659799183"},"South Africa":{"Asset":"2659814367","Decal":"2659814372"},"Peru":{"Asset":"2659807677","Decal":"2659807681"},"Spain":{"Asset":"2659814822","Decal":"2659814826"},"Romania":{"Asset":"2659809038","Decal":"2659809040"},"Madagascar":{"Asset":"2659797643","Decal":"2659797646"},"Turkmenistan":{"Asset":"2659817452","Decal":"2659817458"},"Indonesia":{"Asset":"2659793879","Decal":"2659793882"},"Central African Republic":{"Asset":"2659781667","Decal":"2659781670"},"Denmark":{"Asset":"2659786212","Decal":"2659786216"},"Burundi":{"Asset":"2659781128","Decal":"2659781131"},"Chad":{"Asset":"2659781757","Decal":"2659781762"},"Belgium":{"Asset":"2659780073","Decal":"2659780078"},"Trinidad and Tobago":{"Asset":"2659816772","Decal":"2659816779"},"Nicaragua":{"Asset":"2659802068","Decal":"2659802074"},"United States":{"Asset":"2659818279","Decal":"2659818284"},"Eritrea":{"Asset":"2659789062","Decal":"2659789065"},"Azerbaijan":{"Asset":"2659779431","Decal":"2659779434"},"Malawi":{"Asset":"2659797782","Decal":"2659797783"},"Mozambique":{"Asset":"2659801114","Decal":"2659801117"},"Austria":{"Asset":"2659779298","Decal":"2659779301"},"Bosnia and Herzegovina":{"Asset":"2659780401","Decal":"2659780404"},"Angola":{"Asset":"2659778571","Decal":"2659778574"},"Serbia":{"Asset":"2659813310","Decal":"2659813314"},"Palestine":{"Asset":"2659806356","Decal":"2659806361"},"Albania":{"Asset":"2659778369","Decal":"2659778371"},"Turkey":{"Asset":"2659817329","Decal":"2659817333"},"Germany":{"Asset":"2659790655","Decal":"2659790660"},"Brazil":{"Asset":"2659780660","Decal":"2659780664"},"Equatorial Guinea":{"Asset":"2659788783","Decal":"2659788787"},"Bulgaria":{"Asset":"2659780766","Decal":"2659780769"},"Lebanon":{"Asset":"2659796675","Decal":"2659796677"},"Bolivia":{"Asset":"2659780268","Decal":"2659780271"},"Democratic Republic of the Congo":{"Asset":"2659786008","Decal":"2659786011"},"Guinea Bissau":{"Asset":"2659791912","Decal":"2659791913"},"Lesotho":{"Asset":"2659796994","Decal":"2659796997"},"Ghana":{"Asset":"2659790868","Decal":"2659790869"},"Cuba":{"Asset":"2659784131","Decal":"2659784133"},"Zambia":{"Asset":"2659819258","Decal":"2659819261"},"Hong Kong":{"Asset":"2659793108","Decal":"2659793109"},"Swaziland":{"Asset":"2659815283","Decal":"2659815285"},"Colombia":{"Asset":"2659782124","Decal":"2659782126"},"Libya":{"Asset":"2659797323","Decal":"2659797326"},"Iran":{"Asset":"2659794149","Decal":"2659794150"},"Togo":{"Asset":"2659816601","Decal":"2659816606"},"Slovenia":{"Asset":"2659813958","Decal":"2659813960"},"Sudan":{"Asset":"2659815137","Decal":"2659815140"},"India":{"Asset":"2659793681","Decal":"2659793687"},"Liberia":{"Asset":"2659797161","Decal":"2659797165"},"Norway":{"Asset":"2659805693","Decal":"2659805698"},"Australia":{"Asset":"2659778878","Decal":"2659778880"},"Cyprus":{"Asset":"2659784253","Decal":"2659784254"},"Iraq":{"Asset":"2659794265","Decal":"2659794269"},"Puerto Rico":{"Asset":"2659808651","Decal":"2659808654"},"Estonia":{"Asset":"2659789242","Decal":"2659789244"},"Mauritania":{"Asset":"2659799856","Decal":"2659799861"},"Belarus":{"Asset":"2659779944","Decal":"2659779949"},"Bangladesh":{"Asset":"2659779789","Decal":"2659779793"},"United Arab Emirates":{"Asset":"2659817924","Decal":"2659817930"},"Mauritius":{"Asset":"2659799991","Decal":"2659799993"},"Tunisia":{"Asset":"2659817136","Decal":"2659817141"},"Hungary":{"Asset":"2659793334","Decal":"2659793337"},"Argentina":{"Asset":"2659778699","Decal":"2659778700"},"Georgia":{"Asset":"2659790367","Decal":"2659790371"},"Honduras":{"Asset":"2659792876","Decal":"2659792882"},"Uruguay":{"Asset":"2659818420","Decal":"2659818424"},"Macedonia":{"Asset":"2659797522","Decal":"2659797527"},"Qatar":{"Asset":"2659808849","Decal":"2659808856"},"South Sudan":{"Asset":"2659814679","Decal":"2659814681"},"Ethiopia":{"Asset":"2659789383","Decal":"2659789385"},"Egypt":{"Asset":"2659787732","Decal":"2659787735"},"Rwanda":{"Asset":"2659812238","Decal":"2659812242"},"Nijer":{"Asset":"2659803470","Decal":"2659803475"},"Cambodia":{"Asset":"2659781248","Decal":"2659781256"},"Jamaica":{"Asset":"2659794985","Decal":"2659794987"},"Panama":{"Asset":"2659806517","Decal":"2659806520"},"Botswana":{"Asset":"2659780525","Decal":"2659780527"},"Gambia":{"Asset":"2659790177","Decal":"2659790181"},"Mexico":{"Asset":"2659800197","Decal":"2659800200"},"Ivory Coast":{"Asset":"2659794839","Decal":"2659794846"},"China":{"Asset":"2659782038","Decal":"2659782040"},"Fiji":{"Asset":"2659789537","Decal":"2659789539"},"Philippines":{"Asset":"2659807840","Decal":"2659807846"},"Benin":{"Asset":"2659780168","Decal":"2659780169"},"Algeria":{"Asset":"2659778467","Decal":"2659778470"},"Sweden":{"Asset":"2659815410","Decal":"2659815412"},"Vietnam":{"Asset":"2659818810","Decal":"2659818816"},"Finland":{"Asset":"2659789685","Decal":"2659789686"},"Iceland":{"Asset":"2659793534","Decal":"2659793537"},"Jordan":{"Asset":"2659795546","Decal":"2659795550"},"Senegal":{"Asset":"2659813181","Decal":"2659813184"},"France":{"Asset":"2659789774","Decal":"2659789775"},"El Salvador":{"Asset":"2659787995","Decal":"2659787998"},"Morocco":{"Asset":"2659800924","Decal":"2659800926"},"Namibia":{"Asset":"2659801417","Decal":"2659801421"},"Guinea":{"Asset":"2659791715","Decal":"2659791718"},"Burkina Faso":{"Asset":"2659781009","Decal":"2659781013"},"Netherlands":{"Asset":"2659801757","Decal":"2659801760"},"East Timor":{"Asset":"2659787045","Decal":"2659787048"},"Greece":{"Asset":"2659791088","Decal":"2659791089"},"Latvia":{"Asset":"2659796449","Decal":"2659796454"},"New Zealand":{"Asset":"2659801914","Decal":"2659801918"},"Singapore":{"Asset":"2659813584","Decal":"2659813589"},"Slovakia":{"Asset":"2659813769","Decal":"2659813770"},"Nigeria":{"Asset":"2659805436","Decal":"2659805437"},"Kuwait":{"Asset":"2659796028","Decal":"2659796029"},"Kenya":{"Asset":"2659795889","Decal":"2659795894"},"Congo":{"Asset":"2659783703","Decal":"2659783705"},"Uzbekistan":{"Asset":"2659818550","Decal":"2659818553"},"Sierra Leone":{"Asset":"2659813485","Decal":"2659813487"},"Cameroon":{"Asset":"2659781370","Decal":"2659781372"},"Kazakhstan":{"Asset":"2659795751","Decal":"2659795756"},"Taiwan":{"Asset":"2659816073","Decal":"2659816076"},"Malta":{"Asset":"2659799717","Decal":"2659799719"},"Costa Rica":{"Asset":"2659783865","Decal":"2659783872"},"Tanzania":{"Asset":"2659816330","Decal":"2659816333"},"Guatemala":{"Asset":"2659791297","Decal":"2659791301"},"Afghanistan":{"Asset":"2659778173","Decal":"2659778175"},"Gabon":{"Asset":"2659789931","Decal":"2659789935"},"Haiti":{"Asset":"2659792072","Decal":"2659792075"},"Ukraine":{"Asset":"2659817773","Decal":"2659817776"},"United Kingdom":{"Asset":"2659818158","Decal":"2659818160"},"Venezuela":{"Asset":"2659818681","Decal":"2659818684"},"Laos":{"Asset":"2659796306","Decal":"2659796311"},"Tajikistan":{"Asset":"2659816189","Decal":"2659816191"},"Somalia":{"Asset":"2659814230","Decal":"2659814232"},"Czech Republic":{"Asset":"2659784895","Decal":"2659784900"},"Moldova":{"Asset":"2659800322","Decal":"2659800323"},"Croatia":{"Asset":"2659783981","Decal":"2659783985"},"Djibouti":{"Asset":"2659786373","Decal":"2659786378"},"Switzerland":{"Asset":"2659815628","Decal":"2659815633"},"Mongolia":{"Asset":"2659800677","Decal":"2659800678"},"Ireland":{"Asset":"2659794393","Decal":"2659794396"},"Poland":{"Asset":"2659808070","Decal":"2659808073"},"Portugal":{"Asset":"2659808510","Decal":"2659808514"},"Thailand":{"Asset":"2659816448","Decal":"2659816452"},"Israel":{"Asset":"2659794550","Decal":"2659794552"},"Saudi Arabia":{"Asset":"2659813007","Decal":"2659813013"},"Paraguay":{"Asset":"2659807530","Decal":"2659807533"}}]]))) do
	module["Flag"][i] = 49
end

return module
