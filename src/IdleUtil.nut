/**
    @file IdleUtil.nut Contains class IdleUtil with IdleTTD static helper methods
*/

/**
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
        @brief Sets idle story page date
        @details Every story page has a date in top left and this is helper function to set them. 
        
        If no arguments are passed to the function current in-game date is used by default.

        @param storyPageID    `[GSStoryPage::StoryPageID]` Idle story book page ID
        @param pageDate GSDate|null Optional instance of GSDate, defaults to current date if `null` is passed or argument is omitted.

        \pre_param_story_page_valid{storyPageID}

        @return bool
        @retval true    Date successfully updated
        @retval false   Date update failed
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
        @brief      Gives a list of all vehicles of given type
        @details    List of all valid and running vehicles belonging to the player (even those currently stopped at stations) filtered by optional vehicle type.
        
        @param companyID    Player company ID
        @param vehicleType  Vehicle type ID
        @param boolOnlyRunning  Filter running vehicles only (default `true`)

        \pre_resolved_company_valid{companyID}
        
        @returns GSList A list of company-owned valid vehicles

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
        @brief Renders vehicle type statistics row on story book page
        @details Creates, populates and adds story book page element for given vehicle type

        @param companyID    Player company ID
        @param vehicleType  Vehicle type ID
        
        \pre_resolved_company_valid{companyID}

        @returns bool
        @retval true Element added to story book page
        @retval false Failed adding element to story book page
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

        @param companyID     Player company ID

        @returns array An array of vehicle stats tables

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

        \pre_resolved_company_valid{companyID}

        @param companyID     Player company ID

        @returns integer
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
        @brief Returns label for event types
        @details Used for debugging
        
        @param intEventType     Event type id
        
        @return string
    */
    static function GetGSEventTypeName(intEventType) {
        local result = "";
        if (intEventType == GSEvent.ET_INVALID) {
            result = "ET_INVALID";
        }
        if (intEventType == GSEvent.ET_TEST) {
            result = "ET_TEST";
        }
        if (intEventType == GSEvent.ET_SUBSIDY_OFFER) {
            result = "ET_SUBSIDY_OFFER";
        }
        if (intEventType == GSEvent.ET_SUBSIDY_OFFER_EXPIRED) {
            result = "ET_SUBSIDY_OFFER_EXPIRED";
        }
        if (intEventType == GSEvent.ET_SUBSIDY_AWARDED) {
            result = "ET_SUBSIDY_AWARDED";
        }
        if (intEventType == GSEvent.ET_SUBSIDY_EXPIRED) {
            result = "ET_SUBSIDY_EXPIRED";
        }
        if (intEventType == GSEvent.ET_ENGINE_PREVIEW) {
            result = "ET_ENGINE_PREVIEW";
        }
        if (intEventType == GSEvent.ET_COMPANY_NEW) {
            result = "ET_COMPANY_NEW";
        }
        if (intEventType == GSEvent.ET_COMPANY_IN_TROUBLE) {
            result = "ET_COMPANY_IN_TROUBLE";
        }
        if (intEventType == GSEvent.ET_COMPANY_ASK_MERGER) {
            result = "ET_COMPANY_ASK_MERGER";
        }
        if (intEventType == GSEvent.ET_COMPANY_MERGER) {
            result = "ET_COMPANY_MERGER";
        }
        if (intEventType == GSEvent.ET_COMPANY_BANKRUPT) {
            result = "ET_COMPANY_BANKRUPT";
        }
        if (intEventType == GSEvent.ET_VEHICLE_CRASHED) {
            result = "ET_VEHICLE_CRASHED";
        }
        if (intEventType == GSEvent.ET_VEHICLE_LOST) {
            result = "ET_VEHICLE_LOST";
        }
        if (intEventType == GSEvent.ET_VEHICLE_WAITING_IN_DEPOT) {
            result = "ET_VEHICLE_WAITING_IN_DEPOT";
        }
        if (intEventType == GSEvent.ET_VEHICLE_UNPROFITABLE) {
            result = "ET_VEHICLE_UNPROFITABLE";
        }
        if (intEventType == GSEvent.ET_INDUSTRY_OPEN) {
            result = "ET_INDUSTRY_OPEN";
        }
        if (intEventType == GSEvent.ET_INDUSTRY_CLOSE) {
            result = "ET_INDUSTRY_CLOSE";
        }
        if (intEventType == GSEvent.ET_ENGINE_AVAILABLE) {
            result = "ET_ENGINE_AVAILABLE";
        }
        if (intEventType == GSEvent.ET_STATION_FIRST_VEHICLE) {
            result = "ET_STATION_FIRST_VEHICLE";
        }
        if (intEventType == GSEvent.ET_DISASTER_ZEPPELINER_CRASHED) {
            result = "ET_DISASTER_ZEPPELINER_CRASHED";
        }
        if (intEventType == GSEvent.ET_DISASTER_ZEPPELINER_CLEARED) {
            result = "ET_DISASTER_ZEPPELINER_CLEARED";
        }
        if (intEventType == GSEvent.ET_TOWN_FOUNDED) {
            result = "ET_TOWN_FOUNDED";
        }
        if (intEventType == GSEvent.ET_AIRCRAFT_DEST_TOO_FAR) {
            result = "ET_AIRCRAFT_DEST_TOO_FAR";
        }
        if (intEventType == GSEvent.ET_ADMIN_PORT) {
            result = "ET_ADMIN_PORT";
        }
        if (intEventType == GSEvent.ET_WINDOW_WIDGET_CLICK) {
            result = "ET_WINDOW_WIDGET_CLICK";
        }
        if (intEventType == GSEvent.ET_GOAL_QUESTION_ANSWER) {
            result = "ET_GOAL_QUESTION_ANSWER";
        }
        if (intEventType == GSEvent.ET_EXCLUSIVE_TRANSPORT_RIGHTS) {
            result = "ET_EXCLUSIVE_TRANSPORT_RIGHTS";
        }
        if (intEventType == GSEvent.ET_ROAD_RECONSTRUCTION) {
            result = "ET_ROAD_RECONSTRUCTION";
        }
        if (intEventType == GSEvent.ET_VEHICLE_AUTOREPLACED) {
            result = "ET_VEHICLE_AUTOREPLACED";
        }
        if (intEventType == GSEvent.ET_STORYPAGE_BUTTON_CLICK) {
            result = "ET_STORYPAGE_BUTTON_CLICK";
        }
        if (intEventType == GSEvent.ET_STORYPAGE_TILE_SELECT) {
            result = "ET_STORYPAGE_TILE_SELECT";
        }
        if (intEventType == GSEvent.ET_STORYPAGE_VEHICLE_SELECT) {
            result = "ET_STORYPAGE_VEHICLE_SELECT";
        }
        return result;
    }

    /**
        @static
        @brief Returns idle multiplier
        @details Returns float for applying to idle balance

        @returns float
    */
    static function GetIdleMultiplier() {
        local setting = GSController.GetSetting("idle_multiplier").tofloat();
        local value = setting * 0.001;
        return value;
    }



    /**
        @static
        @brief Returns true if current date corresponds to one of autosave dates.
        @details Depending on autosave setting, some dates are eligible as 'autosave' dates. This function returns true if current date corresponds to one of autosave dates based on game settings

        @param date In-game date to check

        @returns bool
        @retval true    Current date is an autosave date
        @retval false   Current date is not an autosave date __or__ autosave is disabled altogether
        @deprecated This method of autosave detection won't work properly starting with OpenTTD 14. In verision 14 autosave option has been changed to real-time minutes, it is no longer tied to in-game months. This function will be removed with the next script version.
    */
    static function IsAutosaveDate(date) {
        local asSetting = GSGameSettings.GetValue("gui.autosave");
        local isAuto = false;
        if (asSetting != 0) {
            // local date = GSDate.GetCurrentDate();
            local day = GSDate.GetDayOfMonth(date);
            local year = GSDate.GetYear(date);
            local month = GSDate.GetMonth(date);
            if (day == 1) {
                if (asSetting == 1) {
                    isAuto = true;
                } else if (asSetting == 2) {
                    if (
                        month == 1
                        || month == 4
                        || month == 7
                        || month == 10
                    ) {
                        isAuto == true;
                    }
                } else if (asSetting == 3) {
                    isAuto = month == 7 || month == 1;
                }
            }
        }
        return isAuto;
    }




    /**
        @}
    */
}