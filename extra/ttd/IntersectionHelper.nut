class IntersectionHelper
{

    intersectionWaypointSearchPrefix = "clover";
    intersectionSize = 26;

    constructor()
    {
        // this.intersectionSize = 26;
    }

}


function IntersectionHelper::PlaceSignal(signalTile, frontTile, signalType = GSRail.SIGNALTYPE_NORMAL, leaveExisting = false) {
    if (!leaveExisting) {
        GSRail.RemoveSignal(signalTile, frontTile);    
    }
    return GSRail.BuildSignal(signalTile, frontTile, signalType);
}


function IntersectionHelper::BuildIntersectionSignals(zeroX, zeroY) {
    local startX = (zeroX + (IntersectionHelper.intersectionSize / 2)) - 1;

    local deltaY = 1;
    local deltaX = 1;

    local signalY = zeroY;
    local signalX = startX;

    local type = GSRail.SIGNALTYPE_NORMAL;
    local gt = GSMap.GetTileIndex;

    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));

    signalY = zeroY + 1;
    signalX = startX - 1;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    signalY = zeroY + 2;
    signalX = startX;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    
    signalY = zeroY + 6;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    signalY = zeroY + 8;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    signalY = zeroY + 7;
    signalX = startX - 1;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX + deltaX, signalY));

    signalY = zeroY + 17;
    signalX = startX;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    signalY = zeroY + 19;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    signalY = zeroY + 18;
    signalX = startX - 1;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));

    signalY = zeroY + 23;
    signalX = startX;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    signalY = zeroY + 25;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX, signalY + deltaY));
    signalY = zeroY + 24;
    signalX = startX - 1;
    IntersectionHelper.PlaceSignal(gt(signalX, signalY), gt(signalX + deltaX, signalY));


    signalX = startX + 1;
    signalY = zeroY;
    deltaY = -1;

    IntersectionHelper.PlaceSignal(gt(signalX, zeroY), gt(signalX, zeroY-1));
    IntersectionHelper.PlaceSignal(gt(signalX, zeroY + 2), gt(signalX, zeroY + 1));
    IntersectionHelper.PlaceSignal(gt(signalX + 1, zeroY + 1), gt(signalX, zeroY + 1));

    IntersectionHelper.PlaceSignal(gt(signalX, zeroY + 6), gt(signalX, zeroY + 5));
    IntersectionHelper.PlaceSignal(gt(signalX, zeroY + 8), gt(signalX, zeroY + 7));
    IntersectionHelper.PlaceSignal(gt(signalX + 1, zeroY + 7), gt(signalX + 1, zeroY + 6));

    IntersectionHelper.PlaceSignal(gt(signalX, zeroY + 17), gt(signalX, zeroY + 16));
    IntersectionHelper.PlaceSignal(gt(signalX, zeroY + 19), gt(signalX, zeroY + 18));
    IntersectionHelper.PlaceSignal(gt(signalX + 1, zeroY + 18), gt(signalX, zeroY + 18));

    IntersectionHelper.PlaceSignal(gt(signalX, zeroY + 23), gt(signalX, zeroY + 22));
    IntersectionHelper.PlaceSignal(gt(signalX, zeroY + 25), gt(signalX, zeroY + 24));
    IntersectionHelper.PlaceSignal(gt(signalX + 1, zeroY + 24), gt(startX+2, zeroY + 23));



    local rail_v_1_x = startX + 13;
    local rail_v_1_y = zeroY + 12;
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x, rail_v_1_y), gt(rail_v_1_x - 1, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 2, rail_v_1_y), gt(rail_v_1_x - 3, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 1, rail_v_1_y - 1), gt(rail_v_1_x - 2, rail_v_1_y - 1));

    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 6, rail_v_1_y), gt(rail_v_1_x - 7, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 8, rail_v_1_y), gt(rail_v_1_x - 9, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 7, rail_v_1_y - 1), gt(rail_v_1_x - 7, rail_v_1_y));

    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 17, rail_v_1_y), gt(rail_v_1_x - 18, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 19, rail_v_1_y), gt(rail_v_1_x - 20, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 18, rail_v_1_y - 1), gt(rail_v_1_x - 19, rail_v_1_y - 1));

    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 23, rail_v_1_y), gt(rail_v_1_x - 24, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 25, rail_v_1_y), gt(rail_v_1_x - 26, rail_v_1_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_1_x - 24, rail_v_1_y - 1), gt(rail_v_1_x - 24, rail_v_1_y));

    local rail_v_2_x = startX + 13;
    local rail_v_2_y = zeroY + 13;
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x, rail_v_2_y), gt(rail_v_2_x + 1, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 2, rail_v_2_y), gt(rail_v_2_x - 1, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 1, rail_v_2_y + 1), gt(rail_v_2_x - 1, rail_v_2_y));

    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 6, rail_v_2_y), gt(rail_v_2_x - 5, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 8, rail_v_2_y), gt(rail_v_2_x - 7, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 7, rail_v_2_y + 1), gt(rail_v_2_x - 6, rail_v_2_y + 1));

    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 17, rail_v_2_y), gt(rail_v_2_x - 16, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 19, rail_v_2_y), gt(rail_v_2_x - 18, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 18, rail_v_2_y + 1), gt(rail_v_2_x - 18, rail_v_2_y));

    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 23, rail_v_2_y), gt(rail_v_2_x - 22, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 25, rail_v_2_y), gt(rail_v_2_x - 24, rail_v_2_y));
    IntersectionHelper.PlaceSignal(gt(rail_v_2_x - 24, rail_v_2_y + 1), gt(rail_v_2_x - 23, rail_v_2_y + 1));
}
function IntersectionHelper::BuildClover_1(zeroX, zeroY) {
    local startX = (zeroX + (IntersectionHelper.intersectionSize / 2)) - 1;

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 13), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 14), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 14), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 15), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 7, zeroY + 15), GSRail.RAILTRACK_SW_SE);

    local startTile = GSMap.GetTileIndex(startX - 4, zeroY + 13);
    local fromTile = GSMap.GetTileIndex(startX - 5, zeroY + 13);
    local endTile = GSMap.GetTileIndex(startX - 7, zeroY + 16);
    GSRail.BuildRail(startTile, fromTile, endTile);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 7, zeroY + 16), GSRail.RAILTRACK_NW_SE);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 7, zeroY + 17), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 17), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 18), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 18), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 19), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 4, zeroY + 19), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 4, zeroY + 20), GSRail.RAILTRACK_NW_SW);

    startTile = GSMap.GetTileIndex(startX - 7, zeroY + 16);
    fromTile = GSMap.GetTileIndex(startX - 7, zeroY + 17);
    endTile = GSMap.GetTileIndex(startX - 3, zeroY + 20);
    GSRail.BuildRail(startTile, fromTile, endTile);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 3, zeroY + 20), GSRail.RAILTRACK_NE_SW);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 2, zeroY + 20), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 2, zeroY + 19), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 1, zeroY + 19), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 1, zeroY + 18), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX,     zeroY + 18), GSRail.RAILTRACK_NW_NE);

    startTile = GSMap.GetTileIndex(startX - 3, zeroY + 20);
    fromTile = GSMap.GetTileIndex(startX - 2, zeroY + 20);
    endTile = GSMap.GetTileIndex(startX, zeroY + 17);
    GSRail.BuildRail(startTile, fromTile, endTile);



}


function IntersectionHelper::BuildClover_2(zeroX, zeroY) {
    local startX = (zeroX + (IntersectionHelper.intersectionSize / 2)) - 1;

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 12), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 11), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 11), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 10), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 7, zeroY + 10), GSRail.RAILTRACK_NW_SW);
    local startTile = GSMap.GetTileIndex(startX - 4, zeroY + 12);
    local fromTile = GSMap.GetTileIndex(startX - 5, zeroY + 12);
    local endTile = GSMap.GetTileIndex(startX - 7, zeroY + 9);
    GSRail.BuildRail(startTile, fromTile, endTile);


    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 7, zeroY + 9), GSRail.RAILTRACK_NW_SE);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 7, zeroY + 8), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 8), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 6, zeroY + 7), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 7), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 5, zeroY + 6), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 4, zeroY + 6), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 4, zeroY + 5), GSRail.RAILTRACK_SW_SE);

    startTile = GSMap.GetTileIndex(startX - 7, zeroY + 9);
    fromTile = GSMap.GetTileIndex(startX - 7, zeroY + 8);
    endTile = GSMap.GetTileIndex(startX - 3, zeroY + 5);
    GSRail.BuildRail(startTile, fromTile, endTile);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 3, zeroY + 5), GSRail.RAILTRACK_NE_SW);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 2, zeroY + 5), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 2, zeroY + 6), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 1, zeroY + 6), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX - 1, zeroY + 7), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX, zeroY + 7), GSRail.RAILTRACK_NE_SE);

    startTile = GSMap.GetTileIndex(startX - 3, zeroY + 5);
    fromTile = GSMap.GetTileIndex(startX - 2, zeroY + 5);
    endTile = GSMap.GetTileIndex(startX, zeroY + 8);
    GSRail.BuildRail(startTile, fromTile, endTile);

}




function IntersectionHelper::BuildClover_3(zeroX, zeroY) {
    local startX = (zeroX + (IntersectionHelper.intersectionSize / 2)) - 1;

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 1, zeroY + 7), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 2, zeroY + 7), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 2, zeroY + 6), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 3, zeroY + 6), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 3, zeroY + 5), GSRail.RAILTRACK_SW_SE);

    local startTile = GSMap.GetTileIndex(startX + 1, zeroY + 8);
    local fromTile = GSMap.GetTileIndex(startX + 1, zeroY + 7);
    local endTile = GSMap.GetTileIndex(startX + 4, zeroY + 5);
    GSRail.BuildRail(startTile, fromTile, endTile);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 4, zeroY + 5), GSRail.RAILTRACK_NE_SW);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 5, zeroY + 5), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 5, zeroY + 6), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 6), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 7), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 7), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 8), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 8, zeroY + 8), GSRail.RAILTRACK_NE_SE);

    startTile = GSMap.GetTileIndex(startX + 4, zeroY + 5);
    fromTile = GSMap.GetTileIndex(startX + 5, zeroY + 5);
    endTile = GSMap.GetTileIndex(startX + 8, zeroY + 9);
    GSRail.BuildRail(startTile, fromTile, endTile);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 8, zeroY + 9), GSRail.RAILTRACK_NW_SE);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 8, zeroY + 10), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 10), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 11), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 11), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 12), GSRail.RAILTRACK_NW_NE);

    startTile = GSMap.GetTileIndex(startX + 8, zeroY + 9);
    fromTile = GSMap.GetTileIndex(startX + 8, zeroY + 10);
    endTile = GSMap.GetTileIndex(startX + 5, zeroY + 12);
    GSRail.BuildRail(startTile, fromTile, endTile);

}


function IntersectionHelper::BuildClover_4(zeroX,  zeroY) {
    local startX = (zeroX + (IntersectionHelper.intersectionSize / 2)) - 1;

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 13), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 14), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 14), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 15), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 8, zeroY + 15), GSRail.RAILTRACK_NE_SE);


    local startTile = GSMap.GetTileIndex(startX + 5, zeroY + 13);
    local fromTile = GSMap.GetTileIndex(startX + 6, zeroY + 13);
    local endTile = GSMap.GetTileIndex(startX + 8, zeroY + 16);
    GSRail.BuildRail(startTile, fromTile, endTile);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 8, zeroY + 16), GSRail.RAILTRACK_NW_SE);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 8, zeroY + 17), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 17), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 7, zeroY + 18), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 18), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 6, zeroY + 19), GSRail.RAILTRACK_NW_NE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 5, zeroY + 19), GSRail.RAILTRACK_SW_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 5, zeroY + 20), GSRail.RAILTRACK_NW_NE);

    startTile = GSMap.GetTileIndex(startX + 8, zeroY + 16);
    fromTile = GSMap.GetTileIndex(startX + 8, zeroY + 17);
    endTile = GSMap.GetTileIndex(startX + 4, zeroY + 20);
    GSRail.BuildRail(startTile, fromTile, endTile);

    GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 4, zeroY + 20), GSRail.RAILTRACK_NE_SW);

    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 3, zeroY + 20), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 3, zeroY + 19), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 2, zeroY + 19), GSRail.RAILTRACK_NW_SW);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 2, zeroY + 18), GSRail.RAILTRACK_NE_SE);
    // GSRail.BuildRailTrack(GSMap.GetTileIndex(startX + 1, zeroY + 18), GSRail.RAILTRACK_NW_SW);

    startTile = GSMap.GetTileIndex(startX + 4, zeroY + 20);
    fromTile = GSMap.GetTileIndex(startX + 3, zeroY + 20);
    endTile = GSMap.GetTileIndex(startX + 1, zeroY + 17);
    GSRail.BuildRail(startTile, fromTile, endTile);

}





function IntersectionHelper::BuildIntersectionTunnels(zeroX, zeroY) {
    local gt = GSMap.GetTileIndex;
    local size = IntersectionHelper.intersectionSize;

    local tunnelTopX = (zeroX + (size / 2)) - 2;
    local tunnelBottomX = tunnelTopX + 4;
    local tunnelsCenterY = zeroY + (size / 2);

    local tunnelSlopeTiles = GSList();
    local railsAboveTunnel = GSList();

    local canBuildTunnel = GSTile.IsBuildableRectangle(gt(tunnelTopX - 1, tunnelsCenterY - 1), 2, 3) && GSTile.IsBuildableRectangle(gt(tunnelBottomX - 1, tunnelsCenterY - 1), 2, 3);
    if (!canBuildTunnel) {
        for(local b=tunnelsCenterY - 1;b<tunnelsCenterY + 1;b+=1) {
            for(local a=tunnelTopX - 1;a<tunnelTopX + 1;a+=1) {
                tunnelSlopeTiles.AddItem(gt(a, b), -1);
            }
            for(local a=tunnelTopX + 1;a<tunnelTopX + 3;a+=1) {
                GSRail.RemoveRailTrack(gt(a, b), GSRail.RAILTRACK_NE_SW);
            }
            for(local a_2=tunnelBottomX - 1;a_2<tunnelBottomX + 1;a_2+=1) {
                tunnelSlopeTiles.AddItem(gt(a_2, b), -1);
            }
        }
        for (local t = tunnelSlopeTiles.Begin(); !tunnelSlopeTiles.IsEnd(); t = tunnelSlopeTiles.Next()) {
            GSTile.DemolishTile(t);
        }
    }

    local lowerTile1_1 = gt(tunnelTopX, tunnelsCenterY - 1);
    local lowerTile1_2 = gt(tunnelTopX, tunnelsCenterY);
    local lowerTile1_3 = gt(tunnelTopX, tunnelsCenterY + 1);

    local lowerTile2_1 = gt(tunnelBottomX, tunnelsCenterY - 1);
    local lowerTile2_2 = gt(tunnelBottomX, tunnelsCenterY);
    local lowerTile2_3 = gt(tunnelBottomX, tunnelsCenterY + 1);

    GSTile.LowerTile(lowerTile1_1, GSTile.SLOPE_N);
    GSTile.LowerTile(lowerTile1_2, GSTile.SLOPE_N);
    GSTile.LowerTile(lowerTile1_3, GSTile.SLOPE_N);

    GSTile.LowerTile(lowerTile2_1, GSTile.SLOPE_N);
    GSTile.LowerTile(lowerTile2_2, GSTile.SLOPE_N);
    GSTile.LowerTile(lowerTile2_3, GSTile.SLOPE_N);

    GSTunnel.BuildTunnel(GSVehicle.VT_RAIL, lowerTile1_1);
    GSTunnel.BuildTunnel(GSVehicle.VT_RAIL, lowerTile1_2);
}




function IntersectionHelper::BuildIntersectionBridges(zeroX, zeroY) {
    local gt = GSMap.GetTileIndex;
    local size = IntersectionHelper.intersectionSize;

    local tunnelTopX = (zeroX + (size / 2)) - 2;
    local tunnelBottomX = tunnelTopX + 4;
    local tunnelsCenterY = zeroY + (size / 2);


    local minBridgeX = tunnelTopX - 1;
    local maxBridgeX = tunnelBottomX;

    local bridge_1_start = gt(minBridgeX, tunnelsCenterY - 1);
    local bridge_1_end = gt(maxBridgeX, tunnelsCenterY - 1);

    local bridge_2_start = gt(minBridgeX, tunnelsCenterY);
    local bridge_2_end = gt(maxBridgeX, tunnelsCenterY);

    local bridgeLength = GSMap.DistanceMax(bridge_1_start, bridge_1_end);
    
    local bridgeIds = GSBridgeList_Length(bridgeLength);
    local bestBridgeType = 0;
    if (bridgeIds.Count() > 0) {
        bestBridgeType = bridgeIds.Begin(); // sorted so best / most expensive bridge types are at the beginning
        if (!GSBridge.IsBridgeTile(bridge_1_start)) {
            GSBridge.BuildBridge(GSVehicle.VT_RAIL, bestBridgeType, bridge_1_start, bridge_1_end);
        }
        if (!GSBridge.IsBridgeTile(bridge_2_start)) {
            GSBridge.BuildBridge(GSVehicle.VT_RAIL, bestBridgeType, bridge_2_start, bridge_2_end);
        }
    }
    
}



function IntersectionHelper::BuildAxisRails(zeroX, zeroY) {
}


function IntersectionHelper::BuildStraightXAxisRails(zeroX, zeroY) {
    local gt = GSMap.GetTileIndex;
    local midX = zeroX + (IntersectionHelper.intersectionSize / 2);

    local minY = zeroY - 1;
    local maxY = zeroY + IntersectionHelper.intersectionSize;
    
    local startTile = gt(midX - 1, minY - 1);
    local fromTile = gt(midX - 1, minY);
    local endTile = gt(midX - 1, maxY);
    if (!GSRail.BuildRail(startTile, fromTile, endTile)){
        startTile = gt(midX - 1, minY);
        fromTile = gt(midX - 1, minY + 1);
        GSRail.BuildRail(startTile, fromTile, endTile);
    }

    // railX = startX + 1;
    local startTile2 = gt(midX, minY - 1); // -1 because second track does not have waypoint so it might not have rail at all
    local fromTile2 = gt(midX, minY);
    local endTile2 = gt(midX, maxY);
    if (!GSRail.BuildRail(startTile2, fromTile2, endTile2)) {
        startTile2 = gt(midX, minY); // -1 because second track does not have waypoint so it might not have rail at all
        fromTile2 = gt(midX, minY + 1);
        endTile2 = gt(midX, maxY);
        GSRail.BuildRail(startTile2, fromTile2, endTile2);
    }
}





function IntersectionHelper::BuildStraightYAxisRails(zeroX, zeroY) {
    local gt = GSMap.GetTileIndex;
    local size = IntersectionHelper.intersectionSize;
    local midX = zeroX + (size / 2);
    local midY = zeroY + (size / 2);
    local startX = midX - 1;
    local startY = midY - 1;
    local minY = zeroY - 1;
    local maxY = zeroY + size;


    // local useBridges = GetSetting("cloverleaf_bridges");
    local useBridges = false;


    // build NE part of SWNE rails
    // local rail_2_y = zeroY + (size / 2);
    // local rail_1_y = rail_2_y - 1;

    local partSize = (size / 2) - 2; // one tile for tunnel, one for track above it
    local railStartX = zeroX;
    local railEndX = railStartX + partSize;


    // because of the tunnels, these are built in 4 parts (2 for each track)
    local aboveTileStart = gt(zeroX - 1, startY);
    local aboveTileFrom = gt(zeroX, startY);
    local aboveTileEnd = gt(midX - 2, startY);
    if (useBridges) {
        aboveTileEnd = gt(midX - 3, startY);
    }
    GSRail.BuildRail(aboveTileStart, aboveTileFrom, aboveTileEnd);

    local aboveTileStart2 = gt(zeroX - 1, startY + 1);
    local aboveTileFrom2 = gt(zeroX, startY + 1);
    local aboveTileEnd2 = gt(railEndX, startY + 1);
    if (useBridges) {
        aboveTileEnd2 = gt(railEndX - 1, startY + 1);
    }
    GSRail.BuildRail(aboveTileStart2, aboveTileFrom2, aboveTileEnd2);

    // build SW part of SWNE rails

    local railStartX = (zeroX + size) - partSize;
    local railEndX = railStartX + partSize + 1;

    local belowTileStart = gt(railStartX - 1, startY);
    local belowTileFrom = gt(railStartX, startY);
    local belowTileEnd = gt(railEndX, startY);
    if (useBridges) {
        belowTileStart = gt(railStartX, startY);
        belowTileFrom = gt(railStartX + 1, startY);
    }
    GSRail.BuildRail(belowTileStart, belowTileFrom, belowTileEnd);

    local belowTileStart2 = gt(railStartX - 1, startY + 1);
    local belowTileFrom2 = gt(railStartX, startY + 1);
    local belowTileEnd2 = gt(railEndX, startY + 1);
    if (useBridges) {
        belowTileStart2 = gt(railStartX, startY + 1);
        belowTileFrom2 = gt(railStartX + 1, startY + 1);
    }
    GSRail.BuildRail(belowTileStart2, belowTileFrom2, belowTileEnd2);


}

function IntersectionHelper::BuildStraightIntersectionRails(zeroX, zeroY) {
    local gt = GSMap.GetTileIndex;
    local size = IntersectionHelper.intersectionSize;
    local midX = zeroX + (size / 2);
    local midY = zeroY + (size / 2);
    local startX = midX - 1;
    local startY = midY - 1;
    local minY = zeroY - 1;
    local maxY = zeroY + size;

    IntersectionHelper.BuildStraightXAxisRails(zeroX, zeroY);
    IntersectionHelper.BuildStraightYAxisRails(zeroX, zeroY);





    // Building outer ring starts from one that connects NE to N and then builds others (clockwise)

    local leftTurnStart = gt(startX, zeroY);
    local leftTurnFrom = gt(startX, zeroY + 1);
    local leftTurnEnd = gt(zeroX, startY);
    GSRail.BuildRail(leftTurnStart, leftTurnFrom, leftTurnEnd);



    local turn_3_start = gt(zeroX, startY);
    local turn_3_from = gt(zeroX, startY + 1);
    local turn_3_end = gt(startX, zeroY + 25);
    GSRail.BuildRail(turn_3_start, turn_3_from, turn_3_end);

    GSRail.RemoveRailTrack(turn_3_from, GSRail.RAILTRACK_NW_SW);


    local rightTurnStart = gt(startX + 1, zeroY);
    local rightTurnFrom = gt(startX + 1, zeroY + 1);
    local rightTurnEnd = gt(startX + 13, startY);
    GSRail.BuildRail(rightTurnStart, rightTurnFrom, rightTurnEnd);




    local turn_4_start = gt(startX + 13, zeroY + 12);
    local turn_4_from = gt(startX + 13, zeroY + 13);
    local turn_4_end = gt(startX + 1, zeroY + 25);
    GSRail.BuildRail(turn_4_start, turn_4_from, turn_4_end);

    GSRail.RemoveRailTrack(turn_4_from, GSRail.RAILTRACK_NW_NE);

}
function IntersectionHelper::Ind(intCompanyID) {
    local signs = GSWaypointList(GSWaypoint.WAYPOINT_RAIL);
    if (signs.Count() > 0) {
        for (local sign = signs.Begin(); !signs.IsEnd(); sign = signs.Next()) {
            local tile = GSWaypoint.GetLocation(sign);
            if (!GSWaypoint.IsValidWaypoint(sign) || GSTile.GetOwner(tile) != intCompanyID) {
                continue;
            }
            local signText = GSWaypoint.GetName(sign);
            if (signText == "_ind_") {
                local indWpX = GSMap.GetTileX(tile);
                local indWpY = GSMap.GetTileY(tile);
                local indTile = GSMap.GetTileIndex(indWpX + 1, indWpY + 1);
                local ind = GSIndustry.GetIndustryID(indTile);
                if (GSIndustry.IsValidIndustry(ind)) {
                    GSIndustry.SetProductionLevel(ind, 128);
                    // GSLog.Warning(GSIndustry.SetText(ind, "indo"));
                    // GSLog.Warning(GSIndustry.GetName(ind));
                }
            }
        }
    }
}
function IntersectionHelper::Process(intCompanyID) {
    // IntersectionHelper.Ind(intCompanyID);
    local signs = GSWaypointList(GSWaypoint.WAYPOINT_RAIL);
    local size = IntersectionHelper.intersectionSize;
    // Log.Info("Processing " + signs.Count() + " intersection waypoints.");
    if (signs.Count() > 0) {
        // Log.Debug("Found " + signs.Count() + " waypoints.");

        // local driveOnLeft = GetSetting("drive_side") == 2;
        local driveOnLeft = false;

        for (local sign = signs.Begin(); !signs.IsEnd(); sign = signs.Next()) {
            local tile = GSWaypoint.GetLocation(sign);
            if (!GSWaypoint.IsValidWaypoint(sign) || GSTile.GetOwner(tile) != intCompanyID) {
                continue;
            }
            local signText = GSWaypoint.GetName(sign);
            local found = signText.find(IntersectionHelper.intersectionWaypointSearchPrefix + "_", 0);
            if (found != null) {

                local orientation = "horizontal";
                local wpX = GSMap.GetTileX(tile);
                local wpY = GSMap.GetTileY(tile);
                local railTrack = GSRail.GetRailTracks(tile);
                
                local railType = GSRail.GetRailType(tile);


                // Log.Info("Processing intersection waypoint #" + sign + "(" + wpX + "x" + wpY + ", '" + GSRail.GetName(railType) + "')");


                local zeroX = (wpX - (size / 2)) + 1; // we have parallel rails, hence "+1"
                local zeroY = wpY + 1; // build starts right after waypoint (y axis)



                if (railTrack == GSRail.RAILTRACK_NE_SW) { // rail is on x axis
                    zeroX = wpX + 1;
                    zeroY =  (wpY - (size / 2)) + 1; // we have parallel rails, hence "+1"
                }

                local startX = (zeroX + (size / 2)) - 1;
                local startY = zeroY;

                // local useBridges = GetSetting("cloverleaf_bridges");
                local useBridges = false;
                
                local gsm = GSCompanyMode(intCompanyID);
                GSRail.SetCurrentRailType(railType);
                if (!GSRail.IsRailTile(GSMap.GetTileIndex(startX, startY))) {
                    if (useBridges) {
                        IntersectionHelper.BuildIntersectionBridges(zeroX, zeroY);
                    } else {
                        IntersectionHelper.BuildIntersectionTunnels(zeroX, zeroY);
                    }
                    IntersectionHelper.BuildStraightIntersectionRails(zeroX, zeroY)

                    IntersectionHelper.BuildClover_1(zeroX, zeroY);
                    IntersectionHelper.BuildClover_2(zeroX, zeroY);
                    IntersectionHelper.BuildClover_3(zeroX, zeroY);
                    IntersectionHelper.BuildClover_4(zeroX, zeroY);

                    IntersectionHelper.BuildIntersectionSignals(zeroX, zeroY);
                    

                    GSWaypoint.SetName(sign, IntersectionHelper.intersectionWaypointSearchPrefix + ":" + sign);
                    GSRail.RemoveRailWaypointTileRectangle(GSMap.GetTileIndex(zeroX - 2, zeroY - 2), GSMap.GetTileIndex(zeroX + size, zeroY + size), true);

                } else {
                    GSWaypoint.SetName(sign, "HAS_RAIL " + IntersectionHelper.intersectionWaypointSearchPrefix + " " + sign);
                }
                gsm = null;
            }
        }
    }
}

