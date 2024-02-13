require("StationUtil.nut");
require("TownHelper.nut");
require("IntersectionHelper.nut");

class Shortcuts {
    static function Process(intCompanyID) {
        StationUtil.Process(intCompanyID);
        TownHelper.Process(intCompanyID);
        IntersectionHelper.Process(intCompanyID);
    }
}