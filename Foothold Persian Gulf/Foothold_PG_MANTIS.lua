mysamPG = MANTIS:New("Persian Golf","Red SAM","Red EWR",nil,"red",true,nil)
mysamPG:SetSAMRange(110)
mysamPG:SetDetectInterval(10)

ZoneTable_Mantis = SET_ZONE:New():FilterPrefixes("Scoot"):FilterStart()
mysamPG:AddScootZones(ZoneTable_Mantis, 3, true, "Cone")

--mysamPG:Debug(true)
--BASE:TraceOn()
--BASE:TraceClass("SHORAD")
mysamPG:Start()

 