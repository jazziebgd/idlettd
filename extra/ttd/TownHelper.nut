class TownHelper
{

}


function TownHelper::GetTownsWithValidCompanyRating(playerCompanyID) {
    local companyTowns = GSList();
	local townId = 0;
    if (playerCompanyID >= 0 && GSCompany.ResolveCompanyID(playerCompanyID) == playerCompanyID) {
		local towns = GSTownList();
		for (local t = towns.Begin(); !towns.IsEnd(); t = towns.Next()) {
			if (GSTown.IsValidTown(t)) {
				local cur_rating_class = GSTown.GetRating(t, playerCompanyID);
				if (cur_rating_class != GSTown.TOWN_RATING_NONE && cur_rating_class != GSTown.TOWN_RATING_INVALID) {
					companyTowns.AddItem(t, townId);
				}
			}
			townId = townId + 1;
		}
	}
    return companyTowns;
}


function TownHelper::GetTownsForAllStations(playerCompanyID) {
	local stationTowns = GSList();
	local stations = GSStationList(GSStation.STATION_ANY);
	local allTowns = GSTownList();
	for (local station = stations.Begin(); !stations.IsEnd(); station = stations.Next()) {
		if (GSStation.IsValidStation(station) && GSStation.GetOwner(station) == playerCompanyID) {
			local stationTownId = GSStation.GetNearestTown(station);
			if (!stationTowns.HasItem(stationTownId)) {
				stationTowns.AddItem(stationTownId, allTowns.GetValue(stationTownId));
			}
		}
	}
	return stationTowns;
}



function TownHelper::SetOutstandingAuthorityRatings(playerCompanyID) {
    local processedTowns = GSList();
    if (playerCompanyID >= 0 && GSCompany.ResolveCompanyID(playerCompanyID) == playerCompanyID) {
		local allTowns = GSTownList();
		local towns = TownHelper.GetTownsWithValidCompanyRating(playerCompanyID);
		for (local t = towns.Begin(); !towns.IsEnd(); t = towns.Next()) {
			if (!GSTown.IsValidTown(t)) {
				continue;
			}
			local cur_rating_class = GSTown.GetRating(t, playerCompanyID);
			if (cur_rating_class == GSTown.TOWN_RATING_NONE) {
				continue;
			} else if (cur_rating_class == GSTown.TOWN_RATING_INVALID) {
				continue;
			} else if (cur_rating_class == GSTown.TOWN_RATING_OUTSTANDING) {
				continue;
			} else {
				GSTown.ChangeRating(t, playerCompanyID, 2000);
				// processedTowns += 1;
				processedTowns.AddItem(t, towns.GetValue(t));
			}
		}
	}
    return processedTowns;
}

function TownHelper::Process(playerCompanyID) {
	TownHelper.ExpandTownsForCompany(playerCompanyID);
}
function TownHelper::ExpandTownsForCompany(playerCompanyID) {
    local eligibleTowns = GSList();
    if (playerCompanyID >= 0 && GSCompany.ResolveCompanyID(playerCompanyID) == playerCompanyID) {
		local allTowns = GSTownList();
		for (local t = allTowns.Begin(); !allTowns.IsEnd(); t = allTowns.Next()) {
			if (!GSTown.IsValidTown(t)) {
				continue;
			}
			local townName = GSTown.GetName(t);
			local shouldExpand = townName.find("_expand_", 0) != null;
			if (shouldExpand) {
				local expandBy = 25;
				if (townName.find("_expand_2_", 0) != null) {
					expandBy = 100;
				}
				eligibleTowns.AddItem(t, allTowns.GetValue(t));
				GSTown.ExpandTown(t, expandBy);
			}
			local found2 = townName.find(" _money_", 0);
			if (found2 != null) {
				GSCompany.ChangeBankBalance(PlayerCompanyID, 100000000, GSCompany.EXPENSES_SHIP_INC, -1);
				GSTown.SetName(t, townName.slice(0, found2));
			}


		}
	}
    return eligibleTowns;
}