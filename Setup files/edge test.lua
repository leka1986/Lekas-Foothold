local areaName = "CVN72_AREA_SOCHI"
local removeSiteName = "CVN72_AREA_SOCHI-4-Edge"

local area = bc:_findCarrierNavigationAreaByName(areaName)
if not area then
	return "NO_AREA " .. areaName
end

local kept = {}
for _, site in ipairs(area.overlaySites or {}) do
	if site.name ~= removeSiteName then
		kept[#kept + 1] = site
	end
end

area.overlaySites = kept
area.overlaySiteSet = {}
for _, site in ipairs(area.overlaySites) do
	area.overlaySiteSet[site.name] = true
end

bc:_refreshCarrierNavigationAreaState()
bc:RefreshTerritoryOverlays(true)

return "REMOVED " .. removeSiteName