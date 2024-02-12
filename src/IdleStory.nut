/**
    @file IdleStory.nut Contains class IdleStory for IdleTTD 
*/
require("constants.nut");
require("Logger.nut");
require("IdleUtil.nut");
require("IdlePages.nut");

require("../extra/ttd/StationUtil.nut");
require("../extra/ttd/TownHelper.nut");
require("../extra/ttd/IntersectionHelper.nut");

/**
    @class IdleStory
    @brief Class that contains main IdleTTD code.
    @details Once created and started in MainClass.Start(), internally tracks all data and handles all relevant button click events.
*/ 
class IdleStory {
    



    /** 
        @name State variables
        Properties below represent the state of the current IdleTTD session
        @{
    */

    /**
        @property PlayerCompanyID

        @brief   Player company ID
        @details Although initially set to <a target="_blank" href="https://docs.openttd.org/gs-api/classGSCompany">GSCompany::COMPANY_INVALID</a>, this value gets populated in constructor so it can be regarded as always present.
	*/
    PlayerCompanyID = GSCompany.COMPANY_INVALID;
    
    /**
	    @property IdleStoryPageID

	    @brief   Idle story book page ID
	    @details Set to <a href="https://docs.openttd.org/gs-api/classGSStoryPage" target="_blank">GSStoryPage</a>.STORY_PAGE_INVALID by, gets created when new game starts and saved to be re-used on game load.
        @note Although this property is public and accesible from outside it shouldn't be changed directly, [this.GetPageID()](#GetPageID)  should be used instead.
	*/
    IdleStoryPageID = GSStoryPage.STORY_PAGE_INVALID;
    
    /**
	    @property IdleBalance

	    @brief Latest idle balance
	    @details Amount of money that player receives (or loses) upon loading saved game. This is basically last year balance multiplied by percent value derived from @ref config_sec "idle_multiplier" game setting.

        Value from this property is used when changing player bank balance, and is always reset to 0 afterwards.
	*/
    IdleBalance = 0;
    
    /**
	    @property _LastIdleBalance

	    @brief Previous idle balance
	    @details Amount of idle monay that company earned or lost upon last game load, stored in saves (and restored on load) via GSController
	*/
    _LastIdleBalance = 0;

    /**
	    @property _LastActiveTime
        @brief Last session timestamp
	    @details Unix timestamp that keeps track when the game was saved last time. Used to determine `lastActiveSeconds`.
	*/
	_LastActiveTime = 0;

    /**
	    @property _LastYearBalance
	    @brief Used for idle income caclulation
	    @details Balance that company had at the beggining of the year.
	*/
    _LastYearBalance = 0;

    /**
	    @property _SecondToLastYearBalance
	    @brief Used for idle income caclulation
	    @details Balance that company had at the beggining of the previous year.
	*/
    _SecondToLastYearBalance = 0;

    /**
	    @property _LastSessionYearlyBalance
	    @brief Yearly balance from last session
	    @details Balance that was used to calculate idle balance at the start of the session
	*/
    _LastSessionYearlyBalance = 0;
    
    /**
	    @property _LastInactiveSeconds
	    @brief Used for stats screen
	    @details Amount of seconds that passed since last save
	*/
	_LastInactiveSeconds = 0;

    /**
	    @property CurrentCash
        @brief Amount of cash company has
	    @details Amount of money the company had in the beginning of current year. Used internally for calulating idle balance
	*/
	CurrentCash = 0;

	/**
	    @property PreviousMonth
	    @brief Latest in-game month detected

        @details Used internally to detect new year and recalculate last year balance
	*/
	PreviousMonth = -1;

    /**
	    @property companyMode
        @brief Company mode (null if not active)
	
        @details Reference to active company mode, used internally by #EnterCompanyMode and #LeaveCompanyMode functions.
	*/
	companyMode = null;


    /**
	    @property _SaveWarningViewed
        @brief Player saw warning message
	
        @details Internally used in order to avoid reopening warning screen once closed
	*/
    _SaveWarningViewed = false;
    /**
        @}
    */


    /** 
        @name Local class instances
        Properties below reference instances of classes created here (currently only #IdlePages).
        @{
    */

    /**
        @property IdlePages    IdlePagesInstance

        @brief   Reference to idle pages class instance
        @details Gets created in #Initialize and lives throughout the session. Manages and renders story book page screens.
	*/
    IdlePagesInstance = null;
    
    /**
        @}
    */

    
    /** 
        @name Cached values
        Properties below hold cached values for faster access
        @{
    */

    /**
	    @property array   _CachedAllVehicleStats
	    @brief Cached vehicle stats 
	    @details Cached array of all vehicle stats, grouped by vehicle type
	*/
    _CachedAllVehicleStats = [];

    /**
	    @property _CachedSummaryVehicleStats
	    @brief Cached vehicle summary
	    @details Cached table with summarized vehicle stats, check out #SummaryVehicleStats for details.
	*/
    _CachedSummaryVehicleStats = {
        count = 0,
        balance = 0,
        idleBalance = 0,
    };

    /**
        @}
    */


    
    /**
        @brief Class constructor. Requires valid company id.
        @details Valid Company ID is required, but page ID is not. 
        - When new game starts constructor is called without page ID. Story book page gets created and its id is then stored with saved games to be reused.
        - If game was loaded, #MainClass will pass existing story book page ID to the constructor.

        
        @param companyID    Player company ID
        @param storyPageID  Idle story book page ID
    */
    constructor(companyID, storyPageID = GSStoryPage.STORY_PAGE_INVALID) {
        this.PlayerCompanyID = companyID;
        this.IdleStoryPageID = storyPageID;
        this._SaveWarningViewed = false;
        this.companyMode = null;
        
		this.PreviousMonth = -1;
        this.CurrentCash = 0;
        this.IdleBalance = 0;
        this._LastIdleBalance = 0;
        this._LastYearBalance = 0;
        this._LastInactiveSeconds = 0;
        this._LastActiveTime = 0;

        this._CachedAllVehicleStats = [];
        this._CachedSummaryVehicleStats = {
            count = 0,
            balance = 0,
            idleBalance = 0,
        };
        
        this.IdlePagesInstance = null;
    }


    /** 
        @name Initialization and lifecycle
        Functions below are setting up and starting base script functionality
        @{
    */

    /**
        @brief Initializes game session
        @details Called when all argument values are either loaded from saved game or set to default values (zeros) for new games. Shows idle report / missing hq / intro screen as needed.

        @param lastActiveTime Saved game timestamp, stored locally as #_LastActiveTime
        @param lastYearBalance Saved last year balance, stored locally as #_LastYearBalance
        @param secondToLastYearBalance Saved second to last year balance, stored locally as #_SecondToLastYearBalance
        @param intCurrentCash Amount of money (minus loan) that company had at the end of the last (complete) year

        @returns void
    */  
    function Initialize(lastActiveTime, lastYearBalance, secondToLastYearBalance, intCurrentCash) {
        this.IdlePagesInstance = IdlePages(this.PlayerCompanyID, this.IdleStoryPageID);
        if (secondToLastYearBalance != 0 && lastYearBalance != 0) {
            // set balance to 2nd last year first. It will be moved into place once last balance is set below
            this.SetLastYearBalance(secondToLastYearBalance);
        }
        if (lastYearBalance != 0) {
            this.SetLastYearBalance(lastYearBalance);
        }
        this._LastActiveTime = lastActiveTime;
        this.CurrentCash = intCurrentCash;
        if (lastActiveTime > 0) {
            local currentTime = GSDate.GetSystemTime();
            local inactiveSeconds = (currentTime - lastActiveTime).tointeger();
            this.SetLastInactiveSeconds(inactiveSeconds);
            this._LastSessionYearlyBalance = lastYearBalance;
        } else {
            this.SetLastInactiveSeconds(0);
            this._LastSessionYearlyBalance = 0;
        }
        if (!IdleUtil.HasHQ(this.PlayerCompanyID) && this.IdlePagesInstance != null) {
            if (this._LastActiveTime == 0) { // new game
                if (GSController.GetSetting("show_intro")) {
                    this.IdlePagesInstance.ShowIntroScreen();
                }
            } else { // loaded game without HQ built
                this.IdlePagesInstance.ShowMissingHQScreen();
            }
        } else { 
            local idleBalance = this.CalculateIdleBalance();
            this.ShowIdleReport(idleBalance);
        }
        Logger.Info("IdleTTD initialized - " + (lastActiveTime == 0 ? " (new game)." : " (loaded game)."));
    }

    /**
        @brief Executes one game script iteration

        @details This is the code that executes IdleTTD specific stuff whenever the game runs the script.

        First time in a year this gets called (preferably Jan 1st) it will store the amount of money company has. If there was a value stored for previous year, it is used to calculate balance for current year before it gets overwritten. This balance serves as a basis for idle balance calculations.
        @returns void
    */
    function runIdleLoop() {
        if (::_EnableCheats) {
            StationUtil.Process(this.PlayerCompanyID);
            TownHelper.Process(this.PlayerCompanyID);
            IntersectionHelper.Process(this.PlayerCompanyID);
        }

        local date = GSDate.GetCurrentDate();
        if (GSDate.IsValidDate(date)) {
            local month = GSDate.GetMonth(date);
            local day = GSDate.GetDayOfMonth(date);
            if (month != this.PreviousMonth) {
                if (this.PreviousMonth == 12) {
                    local newCash = this.GetCurrentCash();
                    local prevCash = this.CurrentCash;
                    this.CurrentCash = newCash;
                    local newBalance = this.CurrentCash - prevCash;
                    if (prevCash != 0) {
                        Logger.Table({newCash = newCash, prevCash = prevCash, newBalance = newBalance}, "Updated yearly balance", ::ScriptLogLevels.LOG_LEVEL_DEBUG);
                        this.SetLastYearBalance(newBalance);
                        if (this.IdlePagesInstance.StatsScreenVisible) {
                            Logger.Verbose("Updating stats screen");
                            this.CacheVehicleStats(true);
                            this.IdlePagesInstance.ClearPage();
                            this.RenderStatsScreen();
                        }
                    } else {

                    }
                }
                this.PreviousMonth = month;
            }
        }
    }

    /**
        @brief Handles button clicks
        @details Called for events of type GSEvent::ET_STORYPAGE_BUTTON_CLICK whenever a button on idle story book page is clicked.
        
        @note Handlers are called once per script iteration. This method can be called up to 7 in-game days (~15.5s) after the actual click itself.
        
        @param buttonId Button story page element ID
        @param event Converted event that triggered the handler
        
        @returns void
        
    */
    function HandleButtonClick(buttonId, event) {
        if (GSStoryPage.IsValidStoryPageElement(buttonId)) {
            if (buttonId == this.IdlePagesInstance.IdleReportButtonID) {
                Logger.Debug("Handling idle report button click.");
                if (this.ChangeBankBalance(this.IdleBalance)) {
                    this._LastIdleBalance = this.IdleBalance;
                    this.IdleBalance = 0;
                    this._SaveWarningViewed = true;

                    if (!::ScriptConfig.ShowStatsAfterReport) {
                        IdleUtil.CloseStoryBookWindow(this.PlayerCompanyID);
                    }
                    this.IdlePagesInstance.ClearPage();
                    this.RenderStatsScreen();
                }
            } else if (buttonId == this.IdlePagesInstance.RefreshButtonID) {
                Logger.Debug("Handling refresh button click.");
                this.CacheVehicleStats(true);
                this.IdlePagesInstance.ClearPage();
                this.RenderStatsScreen();
            } else if (buttonId == this.IdlePagesInstance.CloseButtonID) {
                Logger.Debug("Handling close button click.");
                IdleUtil.CloseStoryBookWindow(this.PlayerCompanyID);
                this.IdlePagesInstance.ClearPage();
                this.RenderStatsScreen();
            } else if (buttonId == this.IdlePagesInstance.ShowHelpButtonID) {
                Logger.Debug("Handling help button click.");
                this.IdlePagesInstance.ShowHelpScreen();
            } else if (buttonId == this.IdlePagesInstance.CloseSaveWarningButtonID) {
                Logger.Debug("Handling close save warning button click.");
                this._SaveWarningViewed = true;
                this.IdlePagesInstance.SavedWithNegativeBalance = false;
                IdleUtil.CloseStoryBookWindow(this.PlayerCompanyID);
                this.IdlePagesInstance.ClearPage();
                this.RenderStatsScreen();
            } else if (buttonId == this.IdlePagesInstance.IntroButtonID) {
                Logger.Debug("Handling intro button click.");
                IdleUtil.CloseStoryBookWindow(this.PlayerCompanyID);
                this.IdlePagesInstance.ClearPage();
                if (IdleUtil.HasHQ(this.PlayerCompanyID)) {
                    this.RenderStatsScreen();
                } else {
                    this.IdlePagesInstance.RenderMissingHQScreen();
                }
            } else if (buttonId == this.IdlePagesInstance._NavButtonNoHQID) {
                Logger.Debug("Handling (dev) nav noHQ button click.");
                this.IdlePagesInstance.ShowMissingHQScreen();
            } else if (buttonId == this.IdlePagesInstance._NavButtonStatsID) {
                Logger.Debug("Handling (dev) nav stats button click.");
                this.ShowStatsScreen();
            } else if (buttonId == this.IdlePagesInstance._NavButtonIdleReportID) {
                Logger.Debug("Handling (dev) nav idle report button click.");
                this.ShowIdleReport();
            }  else if (buttonId == this.IdlePagesInstance._NavButtonIntroID) {
                Logger.Debug("Handling (dev) nav intro button click.");
                this.IdlePagesInstance.ShowIntroScreen();
            }  else if (buttonId == this.IdlePagesInstance._NavButtonSaveWarningID) {
                Logger.Debug("Handling (dev) nav save warning button click.");
                this.ShowSaveWarningScreen();
            }  else if (buttonId == this.IdlePagesInstance._NavButtonShowHelpID) {
                Logger.Debug("Handling (dev) nav help button click.");
                this.IdlePagesInstance.ShowHelpScreen();
            }
        }
    }
    /**
        @} 
    */


    /** 
        @name Functions that manage story book pages
        These functions prepare data and call IdlePages instance to manage story book page screens
        @{
    */


    /**
        @brief Guaranteed to return (creates it if needed) valid current idle story page ID
        @details Makes sure there is a valid idle story page or creates it if there isn't and then returns its ID as <a href="https://docs.openttd.org/gs-api/classGSStoryPage" target="_blank">GSStoryPage.StoryPageID</a>.

        \prethiscompanyvalid

        @returns GSStoryPageID Idle story page ID
    */
    function GetPageID() {
        if (this.PlayerCompanyID != GSCompany.COMPANY_INVALID) {
            if (!GSStoryPage.IsValidStoryPage(this.IdleStoryPageID)) {
                local pageName = GSText(GSText.STR_REPORT_PAGE_NAME);
                local pageID = GSStoryPage.New(this.PlayerCompanyID, "");
                if (GSStoryPage.IsValidStoryPage(pageID)) {
                    this.IdleStoryPageID = pageID;
                    Logger.Verbose("Created new idle story book page " + this.IdleStoryPageID);
                } else {
                    Logger.Error("Failed creating idle story book page.");
                }
            } else {
                Logger.Verbose("Reusing idle story book page " + this.IdleStoryPageID);
            }
        }
        return this.IdleStoryPageID;
    }

    /**
        @brief Shows idle report screen for given idle balance value

        @attention Idle report page is \em quasi-persistent. If player closes story book without clicking the button within, script will open idle report story book page again and scroll main viewport so that Company HQ is in the center. Script will keep doing it again and again, until player clicks the button on the page.
        
        @details Calls [ShowIdleReportScreen()](#IdlePages.ShowIdleReportScreen) on [this.IdlePagesInstance](#IdlePagesInstance) to show idle report screen on idle story book page.

        @param intNewIdleBalance New idle balance

        @return bool
        @retval true    Idle report story book page is displayed
        @retval false   Failed opening idle report story book page
    */
    function ShowIdleReport(intNewIdleBalance = 0) {
        if (intNewIdleBalance != 0) {
            this.IdleBalance = intNewIdleBalance;
        } else {
            Logger.Warning("Idle report triggered with zero idle balance and " + this._LastInactiveSeconds + " inactive seconds.");
        }
        local vehicleSummary = this.GetSummaryVehicleStats();
        local vehicleTypeStats = this.GetAllVehicleTypeStats();
        this.ScrollToCompanyHQ();
        return this.IdlePagesInstance.ShowIdleReportScreen(intNewIdleBalance, this._LastInactiveSeconds, vehicleSummary, vehicleTypeStats, this._LastYearBalance);
    }

    /**
        @brief Shows stats screen
        @details Prepares required data and calls [ShowStatsScreen()](#IdlePages.ShowStatsScreen) on [this.IdlePagesInstance](#IdlePagesInstance) to show stats screen.

        @returns bool
        @retval true    Story book page displayed successfully
        @retval false   Failed displaying story book page
    */
    function ShowStatsScreen() {
        local vehicleSummary = this.GetSummaryVehicleStats();
        local allVehicleStats = this.GetAllVehicleTypeStats();
        return this.IdlePagesInstance.ShowStatsScreen(vehicleSummary, allVehicleStats, this._LastIdleBalance, this._LastInactiveSeconds, this._LastYearBalance);
    }

    /**
        @brief Shows save warning screen
        @details When player saves the game with negative balance show a warning notifying them of idle losses
        
        @returns bool
        @retval true    Story book page displayed successfully
        @retval false   Failed displaying story book page

        @deprecated OpenTTD 14 changed its autosave mechanism. This function will be removed with the next script version.
    */
    function ShowSaveWarningScreen() {
        if (!this._SaveWarningViewed && this.IdlePagesInstance != null) {
            this._SaveWarningViewed = true;
            return this.IdlePagesInstance.ShowSaveWarningScreen();
        }
        return false;
    }

    /**
        @brief Renders stats screen
        @details Prepares required data and calls [RenderStatsScreen()](#IdlePages.RenderStatsScreen) on [this.IdlePagesInstance](#IdlePagesInstance) to render stats screen without opening story book page.

        @returns void
    */
    function RenderStatsScreen() {
        local vehicleSummary = this.GetSummaryVehicleStats();
        local allVehicleStats = this.GetAllVehicleTypeStats();
        this.IdlePagesInstance.RenderStatsScreen(vehicleSummary, allVehicleStats, this._LastIdleBalance, this._LastInactiveSeconds, this._LastYearBalance);
    }

    
    /**
        @brief Updates duration text
        @details If [this.IdlePagesInstance.PreviousDurationElementID](#IdlePages.PreviousDurationElementID) is valid it gets updated with duration text formatted for current time - last active time

        @return bool
        @retval true    Duration story page element updated
        @retval false   Failed updating duration story page element
    */
    function UpdateDuration() {
        local currentTime = GSDate.GetSystemTime();
        local inactiveSeconds = (currentTime - this._LastActiveTime).tointeger();
        return this.IdlePagesInstance.UpdateDuration(inactiveSeconds);
    }

    /**
        @brief Updates warning text on idle report screen
        @details Shows or hides text warning player about closing idle report window via button only.

        @param boolShowWarning Controls whether to show the warning or not

        @return bool
        @retval true    Warning story page element updated
        @retval false   Failed updating warning story page element
    */
    function UpdateReportCloseWarning(boolShowWarning = true) {
        return this.IdlePagesInstance.UpdateReportCloseWarning(boolShowWarning);
    }

    /**
        @brief Updates save warning element on idle report screen
        @details Shows or hides text warning player about saving the game with negative balance

        @param boolShowWarning Controls whether to show save warning or not

        @return bool
        @retval true    Save warning story page element updated
        @retval false   Failed updating save warning story page element
    */
    function UpdateReportSaveWarning(boolShowWarning = true) {
        return this.IdlePagesInstance.UpdateReportSaveWarning(boolShowWarning);
    }
    /**
        @}
    */


    /** 
        @name News management functions
        Functions that show and manage in-game news
        @{
    */
    
    /**
        @brief      Displays news about idle balance
        @details    If script settings allow, creates and displays a news story about account balance changes caused by IdleTTD

        @param balanceChange Amount of money added or removed from company bank account

        @return bool
        @retval true    News created successfully
        @retval false   Failed creating news
    */
    function ShowIdleBalanceNews(balanceChange) {
        if (GSController.GetSetting("show_news") && balanceChange != 0){
            local newsTitle = GSText(GSText.STR_NEWS_TITLE_POSITIVE, balanceChange);
            local newsSecondParagraph = GSText(GSText.STR_NEWS_TEXT_POSITIVE, balanceChange, this.PlayerCompanyID);
            if (balanceChange < 0) {
                
                newsTitle = GSText(GSText.STR_NEWS_TITLE_NEGATIVE, balanceChange);
                newsSecondParagraph = GSText(GSText.STR_NEWS_TEXT_NEGATIVE, balanceChange, this.PlayerCompanyID);
            }
            local news = GSText(GSText.STR_NEWS_COMPLETE, newsTitle, newsSecondParagraph);
            return GSNews.Create(GSNews.NT_GENERAL, news, this.PlayerCompanyID, GSNews.NR_NONE, -1);
        }
        return false
    }

    /**
        @}
    */


    /** 
        @name Company and stats members
        Functions that calculate stats and perform company related tasks
        @{
    */

    /**
        @brief Stores last year balance
        @details Updates _SecondToLastYearBalance with previous value of _LastYearBalance before setting _LastYearBalance to new value

        @param value New balance

        @returns void
    */
    function SetLastYearBalance(value = 0) {
        if (this._LastYearBalance != 0) {
            this._SecondToLastYearBalance = this._LastYearBalance;
        }
        this._LastYearBalance = value;
    }

    /**
        @brief Stores last inactive seconds 
        @details Based on _LastActiveTime, this value is stored for using in strings and calculations

        @param value New value

        @returns void
    */
    function SetLastInactiveSeconds(value = 0) {
        this._LastInactiveSeconds = value;
    }

    /**
        @brief Calculates latest idle balance
        @details Based on latest year balance, idle multiplier setting and time passed since saving the game, function calculates and returns amount that should be added or subtracted from company bank balance.

        @returns integer Amount of money company earned or lost since last time game was saved.
    */
    function CalculateIdleBalance() {
        local idleMultiplier = IdleUtil.GetIdleMultiplier();
        local currentTime = GSDate.GetSystemTime();
        local inactiveSeconds = (currentTime - this._LastActiveTime).tointeger();
        this.SetLastInactiveSeconds(inactiveSeconds);

        // local passedDays = ((inactiveSeconds * 33.33) / 74).tointeger();
        local passedDays = (floor(inactiveSeconds.tofloat() / ::SecondsPerGameDay.tofloat())).tointeger();
        local idleBalance = (((this._LastYearBalance / 365.0) * passedDays) * idleMultiplier).tointeger();
        return idleBalance;
    }

    /**
        @brief Returns current bank balance for players company

        @details Determines total amount of money that players company currently has. By default takes loan amount into consideration too, but that can be changed via args passed to the function.

        @param boolIgnoreLoan Ignore loan
        @returns int Cash balance
    */
    function GetCurrentCash (boolIgnoreLoan = false) {
        local currentCash = 0;
        local currentLoan = 0;
        this.EnterCompanyMode();
        currentCash = GSCompany.GetBankBalance(this.PlayerCompanyID);
        if (!boolIgnoreLoan) {
            currentLoan = GSCompany.GetLoanAmount();
        }
        this.LeaveCompanyMode();
        return currentCash - currentLoan;
    }

    

    /**
        @brief Changes company bank balance
        @details Adds (or subtracts) balanceChange amount from company bank balance. Creates news with details if balance change was successful.

        \prethiscompanyvalid
        @pre __Argument precondition__
        @pre _balanceChange_ __!=__ `0`

        @param balanceChange Amount to add or subtract from company bank balance

        @return bool
        @retval true    Balance changed successfully
        @retval false   Balance change failed
    */
    function ChangeBankBalance(balanceChange = 0) {
        if (balanceChange != 0 && this.PlayerCompanyID != GSCompany.COMPANY_INVALID) {
            if (GSCompany.ChangeBankBalance(this.PlayerCompanyID, balanceChange, GSCompany.EXPENSES_OTHER, IdleUtil.GetHQTileIndex(this.PlayerCompanyID))) {
                Logger.Info("Bank balance changed by idle balance amount " + balanceChange);
                this.ShowIdleBalanceNews(balanceChange);
                return true;
            }
        }
        return false;
    }


    /**
        @brief Scrolls to HQ
        @details Centers viewport on company hq tile if hq is built

        @returns void
    */
    function ScrollToCompanyHQ() {
        local HQTile = IdleUtil.GetHQTileIndex(this.PlayerCompanyID);
        if (GSMap.IsValidTile(HQTile)) {
            GSViewport.ScrollTo(HQTile);
        }
    }

    /**
        @brief Returns summary stats for all vehicles
        @details Iterates through all vehicle types and summarizes stats (count, balance, idleBalance) for them. Values are per in-game year

        <!-- 
            \pre_resolved_company_valid{this.PlayerCompanyID}
        -->
        
        \prebase

        @param force Force refreshing cached stats


        @returns SQTable Summary stats table
    */
    function GetSummaryVehicleStats(force = false) {
        if (this.PlayerCompanyID != GSCompany.COMPANY_INVALID && GSCompany.ResolveCompanyID(this.PlayerCompanyID) == this.PlayerCompanyID) {
            if (force == true || this._CachedAllVehicleStats.len() == 0) {
                this.CacheVehicleStats(true);
            }
        }
        return this._CachedSummaryVehicleStats;

    }

    /**
        @brief Returns vehicle stats grouped by type
        @details Iterates through all vehicle types and summarizes stats (count, balance, idleBalance) for them (per type). Values are per in-game year.

        \prebase

        @param force Force refreshing cached stats

        @returns std::array<#VehicleTypeStatsItem, 4> An array of summary tables for all four vehicle types
    */
    function GetAllVehicleTypeStats(force = false) {
        if (this.PlayerCompanyID != GSCompany.COMPANY_INVALID && GSCompany.ResolveCompanyID(this.PlayerCompanyID) == this.PlayerCompanyID) {
            if (force == true || this._CachedAllVehicleStats.len() == 0) {
                this.CacheVehicleStats(true);
            }
        }
        return this._CachedAllVehicleStats;
    }

    /**
        @brief Returns summary stats vehicles of given type
        @details Iterates through all vehicles of the same type and summarizes stats (count, balance, idleBalance) for them. Values are per in-game year

        @param vehicleType `GSVehicle::VehicleType` Vehicle type ID
        @param force Force refreshing cached stats

        @returns SQTable Summary stats table (or null)
    */
    function GetVehicleTypeStats(vehicleType, force = false) {
        if (this.PlayerCompanyID != GSCompany.COMPANY_INVALID && GSCompany.ResolveCompanyID(this.PlayerCompanyID) == this.PlayerCompanyID) {
            if (force == true || this._CachedAllVehicleStats.len() == 0) {
                this.CacheVehicleStats(true);
            }
            foreach (index, value in this._CachedAllVehicleStats) {
                if (value.type == vehicleType) {
                    return value;
                }
            }
        }
        return null;
    }
    /**
        @}
    */


    /** 
        @name Utility members
        Common utility and helper functions that are too specific for util class
        @{
    */

    /**
        @brief Enters company mode

        @details Enters company mode and keeps local reference #companyMode to leave it later using #LeaveCompanyMode() function.

        Uses `GSCompanyMode`, see <a target="_blank" href="https://docs.openttd.org/gs-api/classGSCompanyMode">NoGO API documentation</a> for reference (_link will open a new window/tab_) .

        @return boolean
        @retval true		Entered company mode successfully
        @retval false	Failed entering company mode
    */
    function EnterCompanyMode() {
        if (this.companyMode == null) {
            if (this.PlayerCompanyID != GSCompany.COMPANY_INVALID && GSCompany.ResolveCompanyID(this.PlayerCompanyID) == this.PlayerCompanyID) {
                this.companyMode = GSCompanyMode(this.PlayerCompanyID);
            }
        }
        return this.companyMode != null;
    }

    /**
        @brief Leaves company mode

        @details Leaves company mode, resetting local reference #companyMode that was set in #EnterCompanyMode() function.

        @return boolean
        @retval true		Left company mode successfully
        @retval false	Failed leaving company mode
    */
    function LeaveCompanyMode() {
        if (this.companyMode != null) {
            this.companyMode = null;
        }
        return this.companyMode == null;
    }


    /**
        @brief Refreshes vehicle stats cache
        @details Retrieves fresh values for all stats and updates cache.

        @param force Force refreshing cached stats

        @returns void
    */
    function CacheVehicleStats(force = false) {
        if (this.PlayerCompanyID != GSCompany.COMPANY_INVALID && GSCompany.ResolveCompanyID(this.PlayerCompanyID) == this.PlayerCompanyID) {
            local typeCount = IdleUtil.AllVehicleTypes.len();
            if (force == true || this._CachedAllVehicleStats.len() < typeCount) {
                this._CachedAllVehicleStats = IdleUtil.GetAllVehicleStatsData(this.PlayerCompanyID);
            }
        } else {
            this._CachedAllVehicleStats = [];
        }
        local totalVehicles = 0;
        local totalVehiclesBalance = 0;
        local totalVehiclesIdleBalance = 0;
        
        foreach (index, vStats in this._CachedAllVehicleStats) {
            totalVehicles += vStats.count;
            totalVehiclesBalance += vStats.balance;
            totalVehiclesIdleBalance += vStats.idleBalance;
        }
        this._CachedSummaryVehicleStats.count = totalVehicles;
        this._CachedSummaryVehicleStats.balance = totalVehiclesBalance;
        this._CachedSummaryVehicleStats.idleBalance = totalVehiclesIdleBalance;
        if (totalVehicles > 0) {
            Logger.Info("Cached " + totalVehicles + " vehicle stats");
        }
    }

    /**
        @brief Check if idle report is visible
        @details If idle report is rendered returns true, even if story book window is closed

        @return bool
        @retval true Idle report is rendered
        @retval false Idle report is not rendered
    */
    function IsIdleReportVisible() {
        if (this.IdlePagesInstance != null) {
            return this.IdlePagesInstance.IdleReportVisible;
        }
        return false;
    }

    /**
        @brief Check if save warning screen is visible
        @details If save warning is rendered returns true, even if story book window is closed

        @return bool
        @retval true Save warning screen is rendered
        @retval false Save warning screen is not rendered
    */
    function IsSaveWarningScreenVisible() {
        if (this.IdlePagesInstance != null) {
            return this.IdlePagesInstance.SaveWarningScreenVisible;
        }
        return false;
    }

    /**
        @brief Check if save warning text is added to report
        @details If save warning text is added to report screen (and report screen is rendered) returns true

        @return bool
        @retval true Warning text is added to report screen and report screen is rendered
        @retval false Warning text is not added to report screen or report screen is not rendered
    */
    function IsSaveWarningTextDisplayed() {
        if (this.IdlePagesInstance != null) {
            return this.IdlePagesInstance.IdleReportVisible && this.IdlePagesInstance.SaveWarningDisplayed;
        }
        return false;
    }

    /**
        @brief Check if game was saved with negative balance
        @details This function determines if game was saved while having lost money in previous year. We need to inform the player if that's the case.

        @return bool
        @retval true Game was saved with negative balance and no warning was displayed
        @retval false Game was saved with positive balance __or__ it was saved with positive balance but the warning was/is already displayed to players
    */
    function GameSavedWithNegativeBalance() {
        if (this.IdlePagesInstance != null) {
            return this.IdlePagesInstance.SavedWithNegativeBalance;
        }
        return false;
    }

    /**
        @brief          Check if anything is visible
        @details        Check if story book window is open and that any of the screens is rendered

        @return bool
        @retval true    One of the screens is rendered and visible
        @retval false   No screen is visible
    */
    function IsAnyScreenOpen() {
        local idlePageOpen = GSWindow.IsOpen(GSWindow.WC_STORY_BOOK, this.PlayerCompanyID);
        if (idlePageOpen) {
            if (this.IdlePagesInstance != null) {
                return this.IdlePagesInstance.IdleReportVisible == true
                    || this.IdlePagesInstance.IntroVisible == true
                    || this.IdlePagesInstance.MissingHQScreenVisible == true
                    || this.IdlePagesInstance.StatsScreenVisible == true
                    || this.IdlePagesInstance.HelpScreenVisible == true
                    || this.IdlePagesInstance.SaveWarningScreenVisible == true;
            }
        }
        return false;
    }

    /**
        @}
    */
}