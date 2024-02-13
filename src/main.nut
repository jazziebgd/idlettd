/**
    @file main.nut Main game script file for IdleTTD 
*/

require("version.nut");
require("config.nut");
require("IdleStory.nut");
require("IdleUtil.nut");
require("Logger.nut");

/**
    @class MainClass
    @brief IdleTTD GSController instance
    @details IdleTTD game script controller class that runs script main loop. Waits for valid company id first to set up an instance of #IdleStory 
*/ 
class MainClass extends GSController {
    
    /** 
        @name Persistent members
        These members are used to store #ScriptSavedData with game save and are restored on load. They remain persistent through game sessopms.
        @{
    */

    /**
        @property    PlayerCompanyID
        @brief   Company ID of the player
        @details Although initially set to GSCompany.COMPANY_INVALID, this value gets populated in first couple of ticks in #HandleEvents function.
    */
    PlayerCompanyID = GSCompany.COMPANY_INVALID;
    /**
        @property IdleStoryPageID
        @brief Idle story page ID
        @details Temporary internal storage for company ids loaded with saved games
    */
    IdleStoryPageID = GSStoryPage.STORY_PAGE_INVALID;
    
    /**
        @property LastActiveTime
        @brief Time of the latest game save
        @details Unix timestamp that keeps track when the game was saved last time
    */
    LastActiveTime = 0;
    /**
        @property LastYearBalance
        @brief How much money did company lose or earn last year
        @details Value that keeps track of last year balance changes
    */
    LastYearBalance = 0;

    /**
        @property PrevCurrentCash
        @brief Company cash in previous year
        @details How much money did company have at the start of current year
    */
    PrevCurrentCash = 0;
    
    /**
        @property SecondToLastYearBalance
        @brief How much money did company lose or earn in the second to last year
        @details Value that keeps track of second to last year balance changes
    */
    SecondToLastYearBalance = 0;

    /**
        @property SavedScriptVersion
        @brief Version of the script in saved game
        @details Version of the game script that is being loaded with saved game
    */
    SavedScriptVersion = 0;
    
    /**
    @}
    */
     /// \privatesection
    /** 
        @name Internal referencess
        Properties that are used internally to store and retrieve current script context/state
        @{
    */

    /**
        @property Enabled
        @brief Idling enabled/disabled
        @details "Master" enabled flag, used to disable IdleTTD for multiplayer.
    */
    Enabled = true;
    
    /**
        @property StartedIdle
        @brief Has IdleTTD been started
        @details Flag that indicates whether IdleStory instance for this session has been initialized and started up.
    */
    StartedIdle = false;

    /**
        @property IdleStoryInstance
        @brief IdleStory instance reference
        @details Instance of current session IdleStory class (might be `null` in first few ticks)
    */
    IdleStoryInstance = null;

    /**
        @property _CloseAttempts
        @brief Number of times report got reopened
        @details Number of times user tried to close report without accepting idle balance, prompting it to reopen
    */
    _CloseAttempts = 0;

    /// @}


    /**
        @brief Constructor

        @details Class constructor - initializes internal instance properties to default values
    */
    constructor() {
        this.Enabled = true;
        this.LastActiveTime = 0;
        this.LastYearBalance = 0;
        this.SecondToLastYearBalance = 0;
        this.IdleStoryPageID = GSStoryPage.STORY_PAGE_INVALID;
        this.StartedIdle = false;
        this.IdleStoryInstance = null;
        this.SavedScriptVersion = 0;
        
    }
    /// \publicsection


    /** 
        @name IdleTTD functions
        These functions might be called from main `while` loop in #Start, depending on game state.
        @{
    */


    /**
        @brief Function that processes all game events

        @details Iterates through eventual waiting events from <a href="https://docs.openttd.org/gs-api/classGSEventController" target="_blank">GSEventController</a> and handles them if needed.
        Two types of events are handled in IdleTTD:
        - Function first awaits for event with type <a href="https://docs.openttd.org/gs-api/classGSEvent" target="_blank">GSEvent.ET_COMPANY_NEW</a> and valid company id to set required property [this.PlayerCompanyID](#PlayerCompanyID).
        - Function will pass click events of type <a href="https://docs.openttd.org/gs-api/classGSEvent" target="_blank">GSEvent.ET_STORYPAGE_BUTTON_CLICK</a> originating from idle story boook page to [IdleStory.HandleButtonClick()](#IdleStory.HandleButtonClick) for handling.

        @return bool
        @retval false Script should skip next loop iteration in order for game to react faster to state changes, clicks etc.
        @retval true  Script loop should be processed normally
    */
    function HandleEvents() {
        local result = true;
        while (GSEventController.IsEventWaiting()) {
            local ev = GSEventController.GetNextEvent();
            local ev_type = ev.GetEventType();
            if (ev_type == GSEvent.ET_STORYPAGE_BUTTON_CLICK) {
                local event = GSEventStoryPageButtonClick.Convert(ev);
                local pageId = event.GetStoryPageID();
                if (GSStoryPage.IsValidStoryPage(pageId) && pageId == this.IdleStoryInstance.GetPageID()) {
                    local buttonId = event.GetElementID();
                    this.IdleStoryInstance.HandleButtonClick(buttonId, event);
                    result = false;
                }
            } else if (ev_type == GSEvent.ET_COMPANY_NEW) {
                local company_event = GSEventCompanyNew.Convert(ev);
                local company_id = company_event.GetCompanyID();
                if (this.PlayerCompanyID == GSCompany.COMPANY_INVALID && company_id != GSCompany.COMPANY_INVALID) {
                    this.PlayerCompanyID = company_id;
                    result = false;
                }
            }
        }
        return result;
    }

    /**
        @brief Starts up IdleTTD game script for current game session
        @details Sets up game script data and idle story book page. Shows story book page with intro (based on settings) when new game starts or with idle report when save game is loaded.
        
        @returns void
    */
    function StartIdle() {
        this.IdleStoryInstance = IdleStory(this.PlayerCompanyID, this.IdleStoryPageID);
        this.IdleStoryPageID = this.IdleStoryInstance.GetPageID();
        this.IdleStoryInstance.Initialize(this.LastActiveTime, this.LastYearBalance, this.SecondToLastYearBalance, this.PrevCurrentCash);
    }


 /**
    @}
    */




    /** 
        @name Script controller lifecycle
        These functions are called by OpenTTD and are part of game script lifecycle
        @{
    */

    
    /**
        @brief Script "main thread" start
        @details This function is called by OpenTTD upon starting new or loading saved game with IdleTTD enabled.
        
        Function will first set up everything:
        
        1. Wait for valid company
        2. initialize IdleTTD
          - If game was loaded, apply saved data
          - If new game was started initialize defaults data

        and then start running its standard tick loop.
        
        @attention OpenTTD will consider that script had crashed if this function ever returns. The `while` loop in this function should never stop iterating.
        
        @returns void
    */
    function Start() {
        if (this.SavedScriptVersion != 0 && this.SavedScriptVersion < SELF_VERSION) {
            this.UpgradeScriptVersion(this.SavedScriptVersion, SELF_VERSION);
        }
        if (GSGame.IsMultiplayer()) {
            Logger.Warning("IdleTTD game script is disabled because it does not support multiplayer.");
            this.Enabled = false;
        } else {
            GSController.Sleep(5);
            while (true) {
                local loop_start_tick = GSController.GetTick();
                local idleEnabled = GetSetting("idle_enabled");
                local sleep_ticks = ::ScriptConfig.MinSleepTime;
                local dayInterval = (74 * GetSetting("day_interval"));
                local process = this.HandleEvents();
                local companyExists = (this.PlayerCompanyID >= 0 && GSCompany.ResolveCompanyID(this.PlayerCompanyID) == this.PlayerCompanyID);
                if (this.Enabled && idleEnabled) {
                    if (companyExists) {
                        if (!this.StartedIdle) {
                            this.StartIdle();
                            this.StartedIdle = true;
                            GSController.Sleep(::ScriptConfig.MinSleepTime);
                            continue;
                        } else {
                            if (process) {
                                if (!GSGame.IsPaused()) {
                                    if (this.IdleStoryInstance != null) {
                                        this.IdleStoryInstance.runIdleLoop();
                                    }
                                }

                                sleep_ticks = dayInterval;
                            }
                            if (this.IdleStoryInstance != null && this.IdleStoryInstance.IdlePagesInstance != null) {
                                local hasReport = this.IdleStoryInstance.IsIdleReportVisible();
                                local idlePageOpen = this.IdleStoryInstance.IsAnyScreenOpen();
                                
                                if (hasReport) {
                                    this.IdleStoryInstance.ScrollToCompanyHQ();
                                }

                                if (idlePageOpen) {
                                    sleep_ticks = ::ScriptConfig.ShortestSleepTime;
                                } else {
                                    if (hasReport) {
                                        this._CloseAttempts = this._CloseAttempts + 1;
                                        if (this._CloseAttempts == ::ScriptConfig.WarnAfterCloseAttempts) {
                                            this.IdleStoryInstance.UpdateReportCloseWarning(true);
                                        }
                                        Logger.Debug("Reopening idle report story book page window.");
                                        IdleUtil.DisplayPage(this.IdleStoryInstance.IdleStoryPageID);
                                        GSController.Sleep(::ScriptConfig.MinSleepTime);
                                        continue;
                                    }
                                        
                                }
                            }

                        }
                    } else {
                        sleep_ticks = ::ScriptConfig.ShortestSleepTime;
                    }
                } else {
                    sleep_ticks = dayInterval;
                    if (this.IdleStoryInstance != null) {
                        GSStoryPage.RemoveStoryPage(this.IdleStoryInstance.IdleStoryPageID);
                    }
                }



                local ticks_used = GSController.GetTick() - loop_start_tick;
                sleep_ticks = max(::ScriptConfig.MinSleepTime, (sleep_ticks - ticks_used));
                Logger.Verbose("Loop started on tick " + loop_start_tick + " used " + ticks_used + " ticks, will sleep for " + sleep_ticks + " ticks.");
                GSController.Sleep(sleep_ticks);
            }
        }
    }

    /**
        @brief Stores script data with saves game
        @details Prepares data desribing current game script state and returns it for storing in saves games.

        Returned data is a table in the format defined by #ScriptSavedData.

        - `PlayerCompanyID` 				Id of current company
        - `IdleStoryPageID` 				Id of current idle story page
        - `LastActiveTime`  				Unix timestamp that stores exact save game time
        - `LastYearBalance` 				Amount of money company earned or lost last year
        - `SecondToLastYearBalance` 		Amount of money company earned or lost in second to last year
        - `PrevCurrentCash` 		        Amount of money company had at the beginning of current year
        - `SavedScriptVersion` 				IdleTTD version that game is being saved with

        @returns ScriptSavedData Script state data for saving
    */
    function Save() {
        local lastActiveTime = GSDate.GetSystemTime();
        local pageId = this.IdleStoryPageID;
        local lastYearBalance = 0;
        local currentCash = 0;
        local secondToLastYearBalance = 0;

        if (this.IdleStoryInstance != null) {
            pageId = this.IdleStoryInstance.GetPageID();
            lastYearBalance = this.IdleStoryInstance.LastYearBalance;
            secondToLastYearBalance = this.IdleStoryInstance.SecondToLastYearBalance;
            currentCash = this.IdleStoryInstance.CurrentCash;
            /* 
                prevent players from overriding previous idle balances by saving and reloading the game
                by preserving old timestamp if player didn't accept the previous one already
                yearly balances aren't preserved, playing long enough to change them will save new ones
            */
            if (this.IdleStoryInstance.IdleBalance != 0 && this.LastActiveTime != 0){
                lastActiveTime = this.LastActiveTime;
            }
        }
        local scriptData = {
            PlayerCompanyID = this.PlayerCompanyID,
            IdleStoryPageID = pageId,
            LastActiveTime = lastActiveTime,
            LastYearBalance = lastYearBalance,
            SecondToLastYearBalance = secondToLastYearBalance,
            PrevCurrentCash = currentCash,
            SavedScriptVersion = SELF_VERSION,
        };

        Logger.Table(scriptData, "IdleTTD savegame data", ::ScriptLogLevels.LOG_LEVEL_VERBOSE);

        return scriptData;
    }

    /**
        @brief Restores saved script data on game load
        @details Called just before #Start, used to restore saved IdleTTD data.
        @note Values for `PlayerCompanyID` and `IdleStoryPageId` are always present, other two can be uninitialized if game has been saved within first couple of years after start.

        @param version 	integer 		    Script version
        @param tbl 		ScriptSavedData 	Stored data

        @returns void
    */
    function Load(version, tbl) {
        foreach(key, val in tbl) {
            if (key == "PlayerCompanyID") {
                this.PlayerCompanyID = val.tointeger();
            } else if (key == "LastActiveTime") {
                this.LastActiveTime = val.tointeger();
            } else if (key == "LastYearBalance") {
                this.LastYearBalance = val.tointeger();
            } else if (key == "SecondToLastYearBalance") {
                this.SecondToLastYearBalance = val.tointeger();
            } else if (key == "PrevCurrentCash") {
                this.PrevCurrentCash = val.tointeger();
            } else if (key == "IdleStoryPageID") {
                this.IdleStoryPageID = val.tointeger();
            } else if (key == "SavedScriptVersion") {
                this.SavedScriptVersion = val.tointeger();
            }
        }

        Logger.Table({ 
            PlayerCompanyID = this.PlayerCompanyID,
            IdleStoryPageID = this.IdleStoryPageID,
            LastActiveTime = this.LastActiveTime,
            LastYearBalance = this.LastYearBalance,
            SecondToLastYearBalance = this.SecondToLastYearBalance,
            PrevCurrentCash = this.PrevCurrentCash
            SavedScriptVersion = this.SavedScriptVersion
        }, "IdleTTD data loaded with saved game", ::ScriptLogLevels.LOG_LEVEL_DEBUG);
    }

    /**
        @brief Upgrades data stored in saved games that ran an older version of IdleTTD
        @details  Currently it doesn't do pretty much anything. Function is called as soon as [this.Start()](#Start) starts executing. This is the place to reconcile (future eventual) differences across different script versions.


        @param fromVersion 	integer Version to upgrade from (script version from the saved game)
        @param toVersion 	integer Version to upgrade to (latest game script version)

        @returns bool
        @retval true    Data upgraded to new version successfully
        @retval false   Failed upgrading data to new script version
    */
    function UpgradeScriptVersion(fromVersion, toVersion) {
        local result = false;
        if (fromVersion < toVersion && fromVersion != 0 && toVersion != 0) {
            Logger.Warning("IdleTTD version upgrade from " + fromVersion + " to " + toVersion);
            result = true;
        }
        return result;
    }

    /**
    @}
    */
}