mysamCa = MANTIS:New("CAUCASUS", "Red SAM", "Red EWR", nil, "red", true, "Red EWR Awacs")
mysamCa:SetSAMRange(110)
mysamCa:SetDetectInterval(10)

ZoneTable_Mantis = SET_ZONE:New():FilterPrefixes("Scoot"):FilterStart()
mysamCa:AddScootZones(ZoneTable_Mantis, 3, true, "Cone")

--mymysamCasamPG:Debug(true)
--BASE:TraceOn()
--BASE:TraceClass("SHORAD")
mysamCa:Start()
