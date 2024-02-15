/**
    @file IdleUtil.nut Contains class IdleUtil with IdleTTD static helper methods
*/

/**
    @class IdleUtil
    @brief Class with various utility helper methods for IdleTTD with `static prop @ref vehicle_type_details "Vehicle types" and functions by group | @ref util_vehicle_functions "Vehicles" | @ref util_storybook_functions "Pages" | @ref util_misc_functions "Misc" 
    @details Miscellaneous, utility and convenience static functions from this class are commonly used in IdleTTD.
*/ 
class IdleUtil {
    /** 
        @name Static predefined members
        Values for which constants or enums won't do
        @{
    */

    /**
        @property AllVehicleTypes
        @hideinitializer
        @static

        @brief   All vehicle types in OpenTTD
        @details An array of all vehicle type IDs in OpenTTD, convenient for iteration.
        
        Check out <a target="_blank" href="https://docs.openttd.org/gs-api/classGSVehicle">GSVehicle class documentation</a> for enum that is referenced.

        @anchor vehicle_type_details

        __Vehicle type details__
        | Index | Reference              | Value &sup1; | Description            |
        | :---: | ---------------------- | :----------------: | :--------------------  |
        | 0     | `GSVehicle.VT_RAIL`    | 0                  | Rail vehicles          |
        | 1     | `GSVehicle.VT_ROAD`    | 1                  | Road vehicles          |
        | 2     | `GSVehicle.VT_WATER`   | 2                  | Ships                  |
        | 3     | `GSVehicle.VT_AIR`     | 3                  | Airplanes              |

        > &sup1; __Values are just for reference and might change.__
	*/
    static AllVehicleTypes = [
        GSVehicle.VT_RAIL,
        GSVehicle.VT_ROAD,
        GSVehicle.VT_WATER,
        GSVehicle.VT_AIR,
    ];
 
    /**
        @}
    */

    /** 
        @name General purpose story book funtions
        Functions that handle story book pages on 'global' level (showing / closing etc.)

        @anchor util_storybook_functions
        @{
    */

    /**
        @brief Displays a story book page
        @details Opens story book window and displays story page with given ID, provided that the page is valid
        @static
        
        @param storyPageID Idle story book page ID
        
        \pre_param_story_page_valid{storyPageID}
        
        @returns bool
        @retval true    Story book page displayed
        @retval false   Failed displaying story book page
    */
    static function DisplayPage(storyPageID) {
        if (GSStoryPage.IsValidStoryPage(storyPageID)){
            return GSStoryPage.Show(storyPageID);
        }
        return false;
    };

    /**
        @brief   Removes all contents from story book page
        @details Removes all story book page elements and optionally updates the date.

        
        
        \pre_param_story_page_valid{storyPageID}
        \prethisstorypagevalid

        @param storyPageID Idle story book page ID
        @param updateDate Passing `false` value means that story book page date won't be updated to current date.

        @returns void
    */
    function ClearPage(storyPageID, updateDate = true) {
        if (GSStoryPage.IsValidStoryPage(storyPageID)) {
            local elements = GSStoryPageElementList(storyPageID);
            for (local el = elements.Begin(); !elements.IsEnd(); el = elements.Next()) {
                GSStoryPage.RemoveElement(el);
            }
            if (updateDate) {
                IdleUtil.SetPageDate(storyPageID);
            }
        }
    }


    /**
        @static
        @brief Closes story book window
        @details Closes story book window (if there is one that is opened) for the company whose ID is passed as an argument
        
        @param companyID     Player company ID
        
        @return void
    */
    static function CloseStoryBookWindow(companyID) {
        if (GSWindow.IsOpen(GSWindow.WC_STORY_BOOK, companyID)){
            GSWindow.Close(GSWindow.WC_STORY_BOOK, companyID);
        }
    }


    /**
        @static
        @brief              Sets idle story page date
        @details            Every story page has a date in top left and this is helper function to set them. 
        
        If no arguments are passed to the function current in-game date is used by default.

        @param  storyPageID Idle story book page ID
        @param  pageDate    Optional instance of GSDate, defaults to current date if `null` is passed or argument is omitted.

        \pre_param_story_page_valid{storyPageID}

        @returns    bool
        @retval     true    Date successfully updated
        @retval     false   Date update failed
    */
    static function SetPageDate(storyPageID, pageDate = null) {
        if (GSStoryPage.IsValidStoryPage(storyPageID)) {
            if (pageDate == null) {
                pageDate = GSDate.GetCurrentDate();
            }
            if (GSDate.IsValidDate(pageDate)) {
                return GSStoryPage.SetDate(storyPageID, pageDate);
            }
        }
        return false;
    }

    /**
        @}
    */


       
    /** 
        @name Vehicle related funtions
        Functions that calculate vehicle statistics and retrieve unfiltered or filtered lists od company vehicles

        @anchor util_vehicle_functions
        @{
    */

    /**
        @static
        @brief                      Gives a list of all running vehicles for given type
        @details                    Returns a list of all valid and running vehicles belonging to the player (even those currently stopped at stations) filtered by optional vehicle type.
        
        @param  companyID           Player company ID
        @param  vehicleType         Vehicle type ID
        @param  boolOnlyRunning     Filter running vehicles only (optional, defaults to `true`)

        \pre_resolved_company_valid{companyID}
        
        @returns #GSList    A list of company-owned valid vehicles

        @see static property [IdleUtil::AllVehicleTypes](#AllVehicleTypes) for details on `vehicleType` param values.
    */
    static function GetRunningCompanyVehicles(companyID, vehicleType = null, boolOnlyRunning = true) {
        local items = GSList();
        local vehicles = GSVehicleList();
        local key = -1;
        local resolvedID = GSCompany.ResolveCompanyID(companyID);
        if (resolvedID == companyID) {
            for (local vhc = vehicles.Begin(); !vehicles.IsEnd(); vhc = vehicles.Next()) {
                if (
                    GSVehicle.IsValidVehicle(vhc) 
                    && (vehicleType == null || GSVehicle.GetVehicleType(vhc) == vehicleType) 
                    && GSVehicle.GetOwner(vhc) == resolvedID 
                    && (!boolOnlyRunning || (GSVehicle.GetState(vhc) == GSVehicle.VS_RUNNING || GSVehicle.GetState(vhc) == GSVehicle.VS_AT_STATION))
                ) {
                    key++;
                    items.AddItem(key, vhc);
                }
            }
        }
        return items;
    }



    /**
        @static
        @brief              Returns statistics for all running vehicles of given vehicle type
        @details            Filters all running vehicles of given type for the company and returns their statistics.

        @param  companyID   Player company ID
        @param  vehicleType Vehicle type ID
        
        \pre_resolved_company_valid{companyID}

        @returns    StructVehicleTypeStatsItem  Table with statistics on vehicles of given type
    */
    static function GetVehicleTypeStatsData(companyID, vehicleType) {
        local multiplier = IdleUtil.GetIdleMultiplier();
        local vehicles = IdleUtil.GetRunningCompanyVehicles(companyID, vehicleType);
        local vtData = {
            count = 0,
            balance = 0,
            idleBalance = 0,
            type = vehicleType,
        };
        if (!vehicles.IsEmpty()) {
            local vehicleCount = vehicles.Count();
            local vehiclesEarnedLastYear = 0;
            for (local vehicleIndex = vehicles.Begin(); !vehicles.IsEnd(); vehicleIndex = vehicles.Next()) {
                local vehicle = vehicles.GetValue(vehicleIndex);
                local earnedLastYear = GSVehicle.GetProfitLastYear(vehicle);
                vehiclesEarnedLastYear += earnedLastYear
                
            }
            vtData.count = vehicleCount;
            vtData.balance = vehiclesEarnedLastYear;
            vtData.idleBalance = (multiplier * vehiclesEarnedLastYear);
        }
        return vtData;
    }



    /**
        @static
        @brief Returns statistics for all vehicles
        @details Filters all running vehicles of given type for the company and returns data about them

        \pre_resolved_company_valid{companyID}

        @param companyID    Player company ID

        @returns array<#StructVehicleTypeStatsItem, 4>     An array of vehicle stats tables

    */
    static function GetAllVehicleStatsData(companyID) {
        local results = [];
        foreach (typeIndex, vehicleType in IdleUtil.AllVehicleTypes) {
            results.push(IdleUtil.GetVehicleTypeStatsData(companyID, vehicleType));
        }
        return results;
    }


    /**
        @}
    */





    /** 
        @name Miscellaneous functions
        Common misc convenience and helper functions  

        @anchor util_misc_functions
        @{
    */

    /** 
        @static
        @brief Get company HQ tile index
        @details Returns tile index of company HQ if there is one

        @param companyID     Player company ID

        @returns int Tile index of Company HQ
        @retval GSMap::TILE_INVALID There is no Company HQ
        @retval n>=0    Company HQ tile index
        
    */
    static function GetHQTileIndex(companyID) {
        return GSCompany.GetCompanyHQ(companyID);
    }


    /**
        @static
        @brief Check if company HQ is built.
        @details Checks if there is HQ __and__ if it is valid before returning the result.
        
        @param companyID     Player company ID
        
        @return bool
        @retval true    Company HQ has been built
        @retval false   There is no Company HQ
    */
    static function HasHQ(companyID) {
        if (GSController.GetSetting("ignore_hq")) {
            return true;
        }
        local hasHQ = IdleUtil.GetHQTileIndex(companyID) != GSMap.TILE_INVALID;
        return hasHQ;
    }

    /**
        @static
        @brief Returns idle multiplier
        @details Returns float for applying to idle balance

        @returns float Idle multiplier value 
    */
    static function GetIdleMultiplier() {
        local setting = GSController.GetSetting("idle_multiplier").tofloat();
        local value = setting * 0.001;
        return value;
    }

    /**
        @}
    */
}