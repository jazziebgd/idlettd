class StationUtil
{
    constructor() {
    }
}


function StationUtil::BuildAccessRails(stationID, pathSignals = true, driveOnLeft = false) {
    local entrySignalType = GSRail.SIGNALTYPE_ENTRY;
    local stationSignalType = GSRail.SIGNALTYPE_EXIT_TWOWAY;
    local exitSignalType = GSRail.SIGNALTYPE_NORMAL;
    if (pathSignals) {
        entrySignalType = GSRail.SIGNALTYPE_PBS_ONEWAY;
        stationSignalType = GSRail.SIGNALTYPE_PBS;
        exitSignalType = GSRail.SIGNALTYPE_NONE;
    }

    local tile = GSStation.GetLocation(stationID);
    local stationX = GSMap.GetTileX(tile);
    local stationY = GSMap.GetTileY(tile);
    local direction = GSRail.GetRailStationDirection(tile);
    local railType = GSRail.GetRailType(tile);
    GSRail.SetCurrentRailType(railType);

    local stationTracks = 1;
    local stationLength = 1;
    local sizeX = 1;
    local sizeY = 1;

    local maxSize = 10;
    // local maxSize = GSGameSettings.GetValue("station_spread") - 4;

    for (local a = 0; a < maxSize; a += 1) {
        local nextTile = GSMap.GetTileIndex(stationX + (1 + a), stationY);
        if (GSRail.IsRailStationTile(nextTile) && GSStation.GetStationID(nextTile) == stationID) {
            sizeX += 1;
        }
    }

    for (local a = 0; a < maxSize; a += 1) {
        local nextTile = GSMap.GetTileIndex(stationX, stationY + (1 + a));
        if (GSRail.IsRailStationTile(nextTile) && GSStation.GetStationID(nextTile) == stationID) {
            sizeY += 1;
        }
    }
    if (direction == GSRail.RAILTRACK_NW_SE) { // "station built on the Y axis
        stationTracks = sizeX;
        stationLength = sizeY;
        if (stationTracks > 1) {
            StationUtil.BuildYAxisMainAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType);
            StationUtil.BuildYAxisAdditionalAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType);
        }
    } else if (direction == GSRail.RAILTRACK_NE_SW) { // "station built on the Y axis
        stationTracks = sizeY;
        stationLength = sizeX;
        if (stationTracks > 1) {
            StationUtil.BuildXAxisMainAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType);
            StationUtil.BuildXAxisAdditionalAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType);
        }
    } else {
        GSLog.Warning("Invalid rail direction");
    }
}

function StationUtil::BuildXAxisAdditionalAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType) {
    local accessLength = 5;
    local tile = GSStation.GetLocation(stationID);
    local stationX = GSMap.GetTileX(tile);
    local stationY = GSMap.GetTileY(tile);

    local rail_1_y = -1;
    local rail_2_y = -1;
    local rail_start_x = -1;
    local rail_end_x = -1;
    local intersectTileX = -1;

    if (stationTracks > 2) {
        rail_1_y = (stationY + (stationTracks / 2)) - 2;
        rail_2_y = rail_1_y + 3;
        rail_start_x = stationX - (accessLength - 3);
        rail_end_x = stationX;
        intersectTileX = stationX - (accessLength - 2);

        local startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_1_y);
        local fromTile = GSMap.GetTileIndex(rail_start_x, rail_1_y);
        local endTile = GSMap.GetTileIndex(rail_end_x, rail_1_y);
        GSRail.BuildRail(startTile, fromTile, endTile);

        startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_2_y);
        fromTile = GSMap.GetTileIndex(rail_start_x, rail_2_y);
        endTile = GSMap.GetTileIndex(rail_end_x, rail_2_y);
        GSRail.BuildRail(startTile, fromTile, endTile);

        // intersect parts
        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_SW_SE);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y + 1), GSRail.RAILTRACK_NW_NE);

        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_SW);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y - 1), GSRail.RAILTRACK_NE_SE);

        // signals (station ones only)
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x - 1, rail_1_y), GSMap.GetTileIndex(rail_end_x, rail_1_y), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x - 1, rail_2_y), GSMap.GetTileIndex(rail_end_x, rail_2_y), stationSignalType);



        rail_start_x = stationX + stationLength + (accessLength - 4);
        rail_end_x = stationX + stationLength - 1;
        intersectTileX = stationX + stationLength + (accessLength - 3);

        startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_1_y);
        fromTile = GSMap.GetTileIndex(rail_start_x, rail_1_y);
        endTile = GSMap.GetTileIndex(rail_end_x, rail_1_y);
        GSRail.BuildRail(startTile, fromTile, endTile);
        startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_2_y);
        fromTile = GSMap.GetTileIndex(rail_start_x, rail_2_y);
        endTile = GSMap.GetTileIndex(rail_end_x, rail_2_y);
        GSRail.BuildRail(startTile, fromTile, endTile);
        
        // intersect parts
        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_NE_SE);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y + 1), GSRail.RAILTRACK_NW_SW);

        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_NE);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y - 1), GSRail.RAILTRACK_SW_SE);


        // signals (station ones only)
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x + 1, rail_1_y), GSMap.GetTileIndex(rail_end_x, rail_1_y), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x + 1, rail_2_y), GSMap.GetTileIndex(rail_end_x, rail_2_y), stationSignalType);


        if (stationTracks > 4) {
            rail_1_y = (stationY + (stationTracks / 2)) - 3;
            rail_2_y = rail_1_y + 5;

            rail_start_x = stationX - (accessLength - 4);
            rail_end_x = stationX;
            intersectTileX = stationX - (accessLength - 3);

            local startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_1_y);
            local fromTile = GSMap.GetTileIndex(rail_start_x, rail_1_y);
            local endTile = GSMap.GetTileIndex(rail_end_x, rail_1_y);
            GSRail.BuildRail(startTile, fromTile, endTile);

            startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_2_y);
            fromTile = GSMap.GetTileIndex(rail_start_x, rail_2_y);
            endTile = GSMap.GetTileIndex(rail_end_x, rail_2_y);
            GSRail.BuildRail(startTile, fromTile, endTile);

            // intersect parts
            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_SW_SE);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y + 1), GSRail.RAILTRACK_NW_NE);

            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_SW);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y - 1), GSRail.RAILTRACK_NE_SE);

            // signals (station ones only)
            GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x - 1, rail_1_y), GSMap.GetTileIndex(rail_end_x, rail_1_y), stationSignalType);
            GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x - 1, rail_2_y), GSMap.GetTileIndex(rail_end_x, rail_2_y), stationSignalType);






            rail_start_x = stationX + stationLength + (accessLength - 5);
            rail_end_x = stationX + stationLength - 1;
            intersectTileX = stationX + stationLength + (accessLength - 4);

            startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_1_y);
            fromTile = GSMap.GetTileIndex(rail_start_x, rail_1_y);
            endTile = GSMap.GetTileIndex(rail_end_x, rail_1_y);
            GSRail.BuildRail(startTile, fromTile, endTile);
            startTile = GSMap.GetTileIndex(rail_start_x - 1, rail_2_y);
            fromTile = GSMap.GetTileIndex(rail_start_x, rail_2_y);
            endTile = GSMap.GetTileIndex(rail_end_x, rail_2_y);
            GSRail.BuildRail(startTile, fromTile, endTile);
            
            // intersect parts
            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_NE_SE);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y + 1), GSRail.RAILTRACK_NW_SW);

            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_NE);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y - 1), GSRail.RAILTRACK_SW_SE);


            // signals (station ones only)
            GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x + 1, rail_1_y), GSMap.GetTileIndex(rail_end_x, rail_1_y), stationSignalType);
            GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x + 1, rail_2_y), GSMap.GetTileIndex(rail_end_x, rail_2_y), stationSignalType);

        }
    }
}









function StationUtil::BuildYAxisAdditionalAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType) {
    local accessLength = 5;
    local tile = GSStation.GetLocation(stationID);
    local stationX = GSMap.GetTileX(tile);
    local stationY = GSMap.GetTileY(tile);

    local rail_1_x = -1;
    local rail_2_x = -1;
    local rail_start_y = -1;
    local rail_end_y = -1;
    local intersectTileY = -1;

    if (stationTracks > 2) {
        rail_1_x = (stationX + (stationTracks / 2)) - 2;
        rail_2_x = rail_1_x + 3;
        rail_start_y = stationY - (accessLength - 3);
        rail_end_y = stationY;
        intersectTileY = stationY - (accessLength - 2);

        local startTile = GSMap.GetTileIndex(rail_1_x, rail_start_y - 1);
        local fromTile = GSMap.GetTileIndex(rail_1_x, rail_start_y);
        local endTile = GSMap.GetTileIndex(rail_1_x, rail_end_y);
        GSRail.BuildRail(startTile, fromTile, endTile);

        startTile = GSMap.GetTileIndex(rail_2_x, rail_start_y - 1);
        fromTile = GSMap.GetTileIndex(rail_2_x, rail_start_y);
        endTile = GSMap.GetTileIndex(rail_2_x, rail_end_y);
        GSRail.BuildRail(startTile, fromTile, endTile);

        // intersect parts
        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_SW_SE);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x + 1, intersectTileY), GSRail.RAILTRACK_NW_NE);

        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NE_SE);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x - 1, intersectTileY), GSRail.RAILTRACK_NW_SW);


        // signals (station ones only)
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_end_y-1), GSMap.GetTileIndex(rail_1_x, rail_end_y), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_end_y-1), GSMap.GetTileIndex(rail_2_x, rail_end_y), stationSignalType);





        rail_start_y = stationY + stationLength;
        rail_end_y = stationY + stationLength + (accessLength - 3);
        intersectTileY = stationY + stationLength + (accessLength - 3);

        startTile = GSMap.GetTileIndex(rail_1_x, rail_start_y - 1);
        fromTile = GSMap.GetTileIndex(rail_1_x, rail_start_y);
        endTile = GSMap.GetTileIndex(rail_1_x, rail_end_y);
        GSRail.BuildRail(startTile, fromTile, endTile);

        startTile = GSMap.GetTileIndex(rail_2_x, rail_start_y - 1);
        fromTile = GSMap.GetTileIndex(rail_2_x, rail_start_y);
        endTile = GSMap.GetTileIndex(rail_2_x, rail_end_y);
        GSRail.BuildRail(startTile, fromTile, endTile);

        // intersect parts
        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_NW_SW);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x + 1, intersectTileY), GSRail.RAILTRACK_NE_SE);

        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NW_NE);
        GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x - 1, intersectTileY), GSRail.RAILTRACK_SW_SE);


        // signals (station ones only)
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_start_y), GSMap.GetTileIndex(rail_1_x, rail_start_y - 1), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_start_y), GSMap.GetTileIndex(rail_2_x, rail_start_y - 1), stationSignalType);
        
        
        if (stationTracks > 4) {
            rail_1_x = (stationX + (stationTracks / 2)) - 3;
            rail_2_x = rail_1_x + 5;
            rail_start_y = stationY - (accessLength - 4);
            rail_end_y = stationY;
            intersectTileY = stationY - (accessLength - 3);

            local startTile = GSMap.GetTileIndex(rail_1_x, rail_start_y - 1);
            local fromTile = GSMap.GetTileIndex(rail_1_x, rail_start_y);
            local endTile = GSMap.GetTileIndex(rail_1_x, rail_end_y);
            GSRail.BuildRail(startTile, fromTile, endTile);

            startTile = GSMap.GetTileIndex(rail_2_x, rail_start_y - 1);
            fromTile = GSMap.GetTileIndex(rail_2_x, rail_start_y);
            endTile = GSMap.GetTileIndex(rail_2_x, rail_end_y);
            GSRail.BuildRail(startTile, fromTile, endTile);

            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_SW_SE);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x + 1, intersectTileY), GSRail.RAILTRACK_NW_NE);

            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NE_SE);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x - 1, intersectTileY), GSRail.RAILTRACK_NW_SW);

            GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_end_y-1), GSMap.GetTileIndex(rail_1_x, rail_end_y), stationSignalType);
            GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_end_y-1), GSMap.GetTileIndex(rail_2_x, rail_end_y), stationSignalType);

    

            rail_1_x = (stationX + (stationTracks / 2)) - 3;
            rail_2_x = rail_1_x + 5;
            rail_start_y = stationY + stationLength;
            rail_end_y = stationY + stationLength + (accessLength - 4);
            intersectTileY = stationY + stationLength + (accessLength - 4);

            startTile = GSMap.GetTileIndex(rail_1_x, rail_start_y - 1);
            fromTile = GSMap.GetTileIndex(rail_1_x, rail_start_y);
            endTile = GSMap.GetTileIndex(rail_1_x, rail_end_y);
            GSRail.BuildRail(startTile, fromTile, endTile);

            startTile = GSMap.GetTileIndex(rail_2_x, rail_start_y - 1);
            fromTile = GSMap.GetTileIndex(rail_2_x, rail_start_y);
            endTile = GSMap.GetTileIndex(rail_2_x, rail_end_y);
            GSRail.BuildRail(startTile, fromTile, endTile);

            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_NW_SW);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x + 1, intersectTileY), GSRail.RAILTRACK_NE_SE);

            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NW_NE);
            GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x - 1, intersectTileY), GSRail.RAILTRACK_SW_SE);

            GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_start_y), GSMap.GetTileIndex(rail_1_x, rail_start_y - 1), stationSignalType);
            GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_start_y), GSMap.GetTileIndex(rail_2_x, rail_start_y - 1), stationSignalType);

        }
    }
}


function StationUtil::BuildXAxisMainAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType) {
    local accessLength = 5;
    local tile = GSStation.GetLocation(stationID);
    local stationX = GSMap.GetTileX(tile);
    local stationY = GSMap.GetTileY(tile);

    local rail_1_y = (stationY + (stationTracks / 2)) - 1;
    local rail_2_y = rail_1_y + 1;

    local rail_start_x = stationX - accessLength;
    local rail_end_x = stationX;
    
    local intersectTileX = stationX - (accessLength - 1);
    // main two straight rails
    local startTile = GSMap.GetTileIndex(rail_start_x - 2, rail_1_y);
    local fromTile = GSMap.GetTileIndex(rail_start_x - 1, rail_1_y);
    local endTile = GSMap.GetTileIndex(rail_end_x, rail_1_y);
    GSRail.BuildRail(startTile, fromTile, endTile);

    startTile = GSMap.GetTileIndex(rail_start_x - 2, rail_2_y);
    fromTile = GSMap.GetTileIndex(rail_start_x - 1, rail_2_y);
    endTile = GSMap.GetTileIndex(rail_end_x, rail_2_y);
    GSRail.BuildRail(startTile, fromTile, endTile);

    
    // intersection rails
    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_SW_SE);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_NE);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_NE_SE);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_SW);

    
    // signals
    GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x - 1, rail_1_y), GSMap.GetTileIndex(rail_end_x, rail_1_y), stationSignalType);
    GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x - 1, rail_2_y), GSMap.GetTileIndex(rail_end_x, rail_2_y), stationSignalType);

    if (!driveOnLeft) {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x, rail_1_y), GSMap.GetTileIndex(rail_start_x - 1, rail_1_y), entrySignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x, rail_2_y), GSMap.GetTileIndex(rail_start_x + 1, rail_2_y), exitSignalType);
    } else {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x, rail_1_y), GSMap.GetTileIndex(rail_start_x + 1, rail_1_y), exitSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x, rail_2_y), GSMap.GetTileIndex(rail_start_x - 1, rail_2_y), entrySignalType);
    }

    rail_start_x = stationX + stationLength + (accessLength + 1);
    rail_end_x = stationX + stationLength - 1;
    intersectTileX = stationX + stationLength + (accessLength - 2);

    // main two straight rails
    startTile = GSMap.GetTileIndex(rail_start_x - 2, rail_1_y);
    fromTile = GSMap.GetTileIndex(rail_start_x - 1, rail_1_y);
    endTile = GSMap.GetTileIndex(rail_end_x, rail_1_y);
    GSRail.BuildRail(startTile, fromTile, endTile);

    startTile = GSMap.GetTileIndex(rail_start_x - 2, rail_2_y);
    fromTile = GSMap.GetTileIndex(rail_start_x - 1, rail_2_y);
    endTile = GSMap.GetTileIndex(rail_end_x, rail_2_y);
    GSRail.BuildRail(startTile, fromTile, endTile);

    
    // intersection rails
    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_SW_SE);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_NE);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_1_y), GSRail.RAILTRACK_NE_SE);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(intersectTileX, rail_2_y), GSRail.RAILTRACK_NW_SW);

    
    // signals
    GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x + 1, rail_1_y), GSMap.GetTileIndex(rail_end_x, rail_1_y), stationSignalType);
    GSRail.BuildSignal(GSMap.GetTileIndex(rail_end_x + 1, rail_2_y), GSMap.GetTileIndex(rail_end_x, rail_2_y), stationSignalType);

    if (!driveOnLeft) {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x - 2, rail_1_y), GSMap.GetTileIndex(rail_start_x - 3, rail_1_y), exitSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x - 2, rail_2_y), GSMap.GetTileIndex(rail_start_x - 1, rail_2_y), entrySignalType);
    } else {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x - 1, rail_1_y), GSMap.GetTileIndex(rail_start_x, rail_1_y), entrySignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_start_x - 1, rail_2_y), GSMap.GetTileIndex(rail_start_x - 2, rail_2_y), exitSignalType);
    }
}

function StationUtil::BuildYAxisMainAccessRails(stationID, stationTracks, stationLength, driveOnLeft, entrySignalType, stationSignalType, exitSignalType) {
    local accessLength = 5;
    local tile = GSStation.GetLocation(stationID);
    local stationX = GSMap.GetTileX(tile);
    local stationY = GSMap.GetTileY(tile);

    local rail_1_x = (stationX + (stationTracks / 2)) - 1;
    local rail_2_x = rail_1_x + 1;

    local rail_start_y = stationY - accessLength;
    local rail_end_y = stationY;

    // main two straight rails
    local startTile = GSMap.GetTileIndex(rail_1_x, rail_start_y - 1);
    local fromTile = GSMap.GetTileIndex(rail_1_x, rail_start_y);
    local endTile = GSMap.GetTileIndex(rail_1_x, rail_end_y);
    GSRail.BuildRail(startTile, fromTile, endTile);

    startTile = GSMap.GetTileIndex(rail_2_x, rail_start_y - 1);
    fromTile = GSMap.GetTileIndex(rail_2_x, rail_start_y);
    endTile = GSMap.GetTileIndex(rail_2_x, rail_end_y);
    GSRail.BuildRail(startTile, fromTile, endTile);


    // intersection rails
    local intersectTileY = stationY - (accessLength - 1);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_NW_SW);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_SW_SE);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NE_SE);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NW_NE);
    
    // signals



    if (!driveOnLeft) {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_start_y), GSMap.GetTileIndex(rail_1_x, rail_start_y + 1), exitSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_start_y), GSMap.GetTileIndex(rail_2_x, rail_start_y - 1), entrySignalType);

        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_end_y-1), GSMap.GetTileIndex(rail_1_x, rail_end_y), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_end_y-1), GSMap.GetTileIndex(rail_2_x, rail_end_y), stationSignalType);
    } else {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_start_y), GSMap.GetTileIndex(rail_2_x, rail_start_y + 1), exitSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_start_y), GSMap.GetTileIndex(rail_1_x, rail_start_y - 1), entrySignalType);

        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_end_y-1), GSMap.GetTileIndex(rail_2_x, rail_end_y), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_end_y-1), GSMap.GetTileIndex(rail_1_x, rail_end_y), stationSignalType);
    }

    rail_start_y = stationY + stationLength + (accessLength - 1);
    rail_end_y = rail_start_y - accessLength;

    startTile = GSMap.GetTileIndex(rail_1_x, rail_start_y + 1);
    fromTile = GSMap.GetTileIndex(rail_1_x, rail_start_y + 2);
    endTile = GSMap.GetTileIndex(rail_1_x, rail_end_y);
    GSRail.BuildRail(startTile, fromTile, endTile);

    

    startTile = GSMap.GetTileIndex(rail_2_x, rail_start_y + 1);
    fromTile = GSMap.GetTileIndex(rail_2_x, rail_start_y + 2);
    endTile = GSMap.GetTileIndex(rail_2_x, rail_end_y);
    GSRail.BuildRail(startTile, fromTile, endTile);


    intersectTileY = stationY + stationLength + (accessLength - 2);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_NW_SW);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_1_x, intersectTileY), GSRail.RAILTRACK_SW_SE);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NE_SE);
    GSRail.BuildRailTrack(GSMap.GetTileIndex(rail_2_x, intersectTileY), GSRail.RAILTRACK_NW_NE);

    // signals
    if (!driveOnLeft) {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_start_y), GSMap.GetTileIndex(rail_1_x, rail_start_y + 1), entrySignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_start_y), GSMap.GetTileIndex(rail_2_x, rail_start_y - 1), exitSignalType);

        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_end_y + 1), GSMap.GetTileIndex(rail_1_x, rail_end_y), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_end_y + 1), GSMap.GetTileIndex(rail_2_x, rail_end_y), stationSignalType);
    } else {
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_start_y), GSMap.GetTileIndex(rail_2_x, rail_start_y + 1), entrySignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_start_y), GSMap.GetTileIndex(rail_1_x, rail_start_y - 1), exitSignalType);

        GSRail.BuildSignal(GSMap.GetTileIndex(rail_2_x, rail_end_y + 1), GSMap.GetTileIndex(rail_2_x, rail_end_y), stationSignalType);
        GSRail.BuildSignal(GSMap.GetTileIndex(rail_1_x, rail_end_y + 1), GSMap.GetTileIndex(rail_1_x, rail_end_y), stationSignalType);
    }
} 


function StationUtil::GetCompanyStations(companyID = -1, type = GSStation.STATION_TRAIN) {
    local items = GSList();
    if (companyID != -1) {
        local stations = GSStationList(type);
        for (local station = stations.Begin(); !stations.IsEnd(); station = stations.Next()) {
            local built = false;
            if (!GSStation.IsValidStation(station)) {
                continue;
            } else if (GSStation.GetOwner(station) != companyID) {
                continue;
            }
            items.AddItem(station, items.GetValue(station));
        }
    }
    return items;

}


function StationUtil::Process(companyID) {
	local stations = StationUtil.GetCompanyStations(companyID);
	if (stations.IsEmpty()){
		return;
	}

	local driveOnLeft = false
    local gsm = GSCompanyMode(companyID);
	local processedStations = 0;
	for (local station = stations.Begin(); !stations.IsEnd(); station = stations.Next()) {
		local built = false;
		local stationName = GSStation.GetName(station);

		local found = stationName.find("build", 0);
		if (found != null) {

			local originalStationName = stationName.slice(0, found);
			local startDate = GSDate.GetCurrentDate();
			local startDateString = GSDate.GetDayOfMonth(startDate) + "." + GSDate.GetMonth(startDate) + "." + GSDate.GetYear(startDate);

			
			StationUtil.BuildAccessRails(station);
			built = true;


			local nowDate = GSDate.GetCurrentDate();
			local nowDateString = GSDate.GetDayOfMonth(nowDate) + "." + GSDate.GetMonth(nowDate) + "." + GSDate.GetYear(nowDate);

			if (built) {
				processedStations += 1;
				GSStation.SetName(station, originalStationName);
			}
		}
	}
	gsm = null;
}


