/**
    @file IdlePages.nut Contains class IdlePages for IdleTTD
*/
require("constants.nut");
require("Logger.nut");
require("IdleUtil.nut");

/**
    @class IdlePages
    @brief Handles story book pages for IdleTTD
    @details Renders and displays IdleTTS screens and keeps track of rendered elements (buttons) for click handling.
*/
class IdlePages {

    /**
        @name State variables
        Properties below represent the state of the current IdleTTD session
        @{
    */

    /**
	    @property _ElementCount
	    @brief Unique element id counter
	    @details Element id counter incremented on rendering page elements keeping their ids unique.
	*/
    _ElementCount = 0;

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
        @note Although this property is public and accesible from outside it shouldn't be changed directly, [IdleStory.GetPageID()](#IdleStory.GetPageID)  should be used instead.
	*/
    IdleStoryPageID = GSStoryPage.STORY_PAGE_INVALID;

    /**
    @}
    */



    /**
        @name Screens visible flags
        Keeps track of currently rendered screen
        @{
    */

    /**
	    @property IdleReportVisible
        @brief Idle report visibility flag
        @details If user action (clicking the button on idle report story book page) is required this will be set to `true`
        @attention Setting this to `true` will result in script taking as much resources as it can, possibly hampering the perfrmance.
    */
    IdleReportVisible = false;

    /**
	    @property IntroVisible
        @brief   Intro visibility flag
        @details Set to true to speed up handling button click (only if idle story book page is also visible).
        @note    If story book window is open `true` value here will result in script taking as much resources as it can, possibly hampering the perfrmance. Closing the story book window (without clicking on the button within) returns script performance to normal but won't reset the value to `false`.
    */
    IntroVisible = false;

    /**
	    @property MissingHQScreenVisible
        @brief   NoHQ screen visibility flag
        @details Set to true when no hq screen is rendered to idle story page
    */
    MissingHQScreenVisible = false;

    /**
	    @property StatsScreenVisible
        @brief   Stats screen visibility flag
        @details Set to true when stats screen is rendered to idle story page
    */
    StatsScreenVisible = false;

    /**
	    @property HelpScreenVisible
        @brief   Help screen visibility flag
        @details Set to true when help screen is rendered to idle story page
    */
    HelpScreenVisible = false;

    /**
    @}
    */



    /**
        @name Rendered element IDs
        References to story page elements (like button) ids, used to determine which button triggered a click event or update elements
        @{
    */

    /**
	    @property  PreviousDurationElementID
	    @brief Id of button element that refreshes story book page stats
	    @details Used internally to determine which button was pressed when handling clicks
	*/
    PreviousDurationElementID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  CloseReportWarningTextElementID
	    @brief Id of button element that refreshes story book page stats
	    @details Used internally to determine which button was pressed when handling clicks
	*/
    CloseReportWarningTextElementID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    
    /**
	    @property  RefreshButtonID
	    @brief Id of button element that refreshes story book page stats
	    @details Used internally to determine which button was pressed when handling clicks
	*/
    RefreshButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  CloseButtonID
	    @brief Id of button element that closes idle story book
	    @details Used internally to determine which button was pressed when handling clicks
	*/
    CloseButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  IdleReportButtonID
	    @brief Id of button element on idle report screen
	    @details Used internally to determine which button was pressed when handling clicks
	*/
    IdleReportButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  IntroButtonID
	    @brief Id of button element on intro screen
	    @details  Used internally to determine which button was pressed when handling clicks
	*/
    IntroButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  ShowHelpButtonID
	    @brief Id of help button element that leads to help screen
	    @details  Used internally to determine which button was pressed when handling clicks
	*/
    ShowHelpButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;

    /**
	    @property  _NavButtonIntroID
	    @brief Id of navigation button element for intro screen
	    @details Used for debugging / troubleshooting
	*/
    _NavButtonIntroID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  _NavButtonNoHQID
	    @brief Id of navigation button element for missing hq screen
	    @details Used for debugging / troubleshooting
	*/
    _NavButtonNoHQID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  _NavButtonStatsID
	    @brief Id of navigation button element for stats screen
	    @details Used for debugging / troubleshooting
	*/
    _NavButtonStatsID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  _NavButtonIdleReportID
	    @brief Id of navigation button element for idle report screen
	    @details Used for debugging / troubleshooting
	*/
    _NavButtonIdleReportID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    /**
	    @property  _NavButtonShowHelpID
	    @brief Id of navigation button element for help screen
	    @details Used for debugging / troubleshooting
	*/
    _NavButtonShowHelpID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    
    /**
        @}
    */

    /**
        @brief Class constructor
        @details Initializes class instance. Expects both companyID and storyPageID to be valid.

        @param companyID    `[GSCompany::CompanyID]` Player company ID
        @param storyPageID    `[GSStoryPage::StoryPageID]` Idle story book page ID

        \pre_resolved_company_valid{companyID}
        \pre_param_story_page_valid{storyPageID}

    */
    constructor(companyID, storyPageID) {
        this.PlayerCompanyID = companyID;
        this.IdleStoryPageID = storyPageID;


        this.IdleReportVisible = false;
        this.IntroVisible = false;
        this.MissingHQScreenVisible = false;
        this.StatsScreenVisible = false;
        this.HelpScreenVisible = false;


        this.PreviousDurationElementID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.CloseReportWarningTextElementID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.RefreshButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.CloseButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.IdleReportButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.IntroButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.ShowHelpButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;

        this._NavButtonIntroID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonNoHQID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonStatsID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonIdleReportID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonShowHelpID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;


        this._ElementCount = 0;
    }


    /**
        @name Base rendering functions
        These functions are base for rendering story book pages
        @{
    */

    /**
        @brief Adds story book page text element to current page
        @details Helper function that automatically ensures unique element ids for all text elements added through it.

        @param element GSText Text element to add

        @returns int                                        Added element ID
        @retval -1                                          Failed adding element to the page
        @retval any_other_value                             Id of the element that was added to the page
    */
    function AddPageTextElement(element) {
        this._ElementCount = this._ElementCount + 1
        return GSStoryPage.NewElement(this.IdleStoryPageID, GSStoryPage.SPET_TEXT, this._ElementCount, element);
    }

    /**
        @brief Renders story page push button
        @details Adds push button to story book page with custom text and/or button reference

        @param customText           GSText Optional custom string for the button (default GSText.STR_NAV_BUTTON_STATS)
        @param buttonReference      StoryPageButtonFormatting Reference for customizing button styles

        @returns int            New button ID
        @retval -1              Failed adding element to the page
        @retval any_other_value Id of the element that was added to the page
    */
    function AddNavButton(customText, buttonReference = null) {
        if (buttonReference == null) {
            buttonReference = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_ORANGE, GSStoryPage.SPBF_NONE);
        }
        return GSStoryPage.NewElement(this.IdleStoryPageID, GSStoryPage.SPET_BUTTON_PUSH, buttonReference, customText);
    }

    /**
        @brief   Removes all contents from idle story book page
        @details Removes add idle story book page elements and resets all relevant internal state vars and references to their initial values.

        \prethisstorypagevalid

        @param updateDate Passing `false` value means that story book page date won't be updated to current date.

        @returns void
    */
    function ClearPage(updateDate = true) {
        if (GSStoryPage.IsValidStoryPage(this.IdleStoryPageID)) {
            local elements = GSStoryPageElementList(this.IdleStoryPageID);
            for (local el = elements.Begin(); !elements.IsEnd(); el = elements.Next()) {
                GSStoryPage.RemoveElement(el);
            }
            if (updateDate) {
                IdleUtil.SetPageDate(this.IdleStoryPageID);
            }
        }
        this.ResetScreenVisibleFlags();
        this.ResetElementIDReferences();

    }


    /**
        @brief Resets all visible flags for all screens

        @details Used before setting any of the flags to ensure that only one flag is active

        @returns void
    */
    function ResetScreenVisibleFlags() {
        this.IdleReportVisible = false;
        this.IntroVisible = false;
        this.MissingHQScreenVisible = false;
        this.StatsScreenVisible = false;
        this.HelpScreenVisible = false;
    }

    /**
        @brief Resets all element and button ids
        @details Used before rendering any screen to ensure that element references are up-to-date

        @returns void
    */
    function ResetElementIDReferences() {
        this.PreviousDurationElementID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.CloseReportWarningTextElementID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.RefreshButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.CloseButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.IntroButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.IdleReportButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this.ShowHelpButtonID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;

        this._NavButtonIntroID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonNoHQID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonStatsID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonIdleReportID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
        this._NavButtonShowHelpID = GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    }
    /**
        @}
    */


    /**
        @name Story book page rendering
        Members that are managing and rendering complete story book page screens
        @{
    */

     /**
        @brief Shows idle report screen

        @details Clears idle story page, renders idle report elements with [this.RenderIdleReportScreen()](#RenderIdleReportScreen) and shows the page to the player. For details on idle report contents check out #RenderIdleReportScreen function.

        @note This will set #IdleReportVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run a lot more often than normal. It might slow the game down but ensures that script react promptly to clicks and other player actions.

        @attention Idle report page is \em quasi-persistent. If player closes story book without clicking the button within, script will open idle report story book page again and keep doing it until player clicks the button on the page.

        @param idleBalance Idle balance to use
        @param inactiveSeconds Inactive idle seconds
        @param vehicleSummary Summary of all vehicles
        @param allVehicleStats An array of vehicle stats for all vehicle types
        @param intLastYearBalance Last year balance for calculations

        @return bool
        @retval true    Idle report story book page is displayed
        @retval false   Failed opening idle report story book page
    */
    function ShowIdleReportScreen(idleBalance = 0, inactiveSeconds = 0, vehicleSummary = null, allVehicleStats = null, intLastYearBalance = 0) {
        local hasHQ = IdleUtil.HasHQ(this.PlayerCompanyID);
        if (hasHQ) {
            if (idleBalance == 0) {
                return this.ShowStatsScreen(vehicleSummary, allVehicleStats, idleBalance, inactiveSeconds, intLastYearBalance);
            }
            this.ClearPage();
            this.RenderIdleReportScreen(idleBalance, inactiveSeconds, vehicleSummary, allVehicleStats);
            return IdleUtil.DisplayPage(this.IdleStoryPageID);
        } else {
            this.ShowMissingHQScreen();
        }
        return false;
    }

    /**
        @brief Shows stats screen
        @details Clears story book page, sets new title, adds stats elements with [this.RenderStatsScreen()](#RenderStatsScreen) to it and then opens the story book window

        @note This will set #StatsScreenVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run a lot more often than normal. It might slow the game down but ensures that script react promptly to clicks and other player actions.

        @param vehicleSummary Summary of all vehicles
        @param allVehicleStats An array of vehicle stats for all vehicle types
        @param totalAmount      Last session idle balance
        @param totalSeconds     TIme since last save game
        @param intLastYearBalance Money earned / lost last year

        @returns bool
        @retval true    Story book page displayed successfully
        @retval false   Failed displaying story book page
    */
    function ShowStatsScreen(vehicleSummary, allVehicleStats, totalAmount, totalSeconds, intLastYearBalance) {
        this.ClearPage();
        this.RenderStatsScreen(vehicleSummary, allVehicleStats, totalAmount, totalSeconds, intLastYearBalance);
        return IdleUtil.DisplayPage(this.IdleStoryPageID);
    }

    /**
        @brief Shows intro screen
        @details Clears story book page, sets new title, adds intro screen elements via [this.RenderIntroScreen()](#RenderIntroScreen) to it and then opens the story book window.

        @note This will set #IntroVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run faster than normal.

        @returns bool
        @retval true    Story book page displayed successfully
        @retval false   Failed displaying story book page
    */
    function ShowIntroScreen() {
        this.ClearPage();
        this.RenderIntroScreen();
        return IdleUtil.DisplayPage(this.IdleStoryPageID);
    }




     /**
        @brief Shows help screen
        @details Clears story book page, sets new title, adds help screen elements via [this.RenderHelpScreen()](#RenderHelpScreen) to it and then opens the story book window.

        @note This will set #HelpScreenVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run a lot more often than normal. It might slow the game down but ensures that script react promptly to clicks and other player actions.

        @returns bool
        @retval true    Story book page displayed successfully
        @retval false   Failed displaying story book page
    */
    function ShowHelpScreen() {
        this.ClearPage();
        this.RenderHelpScreen();
        return IdleUtil.DisplayPage(this.IdleStoryPageID);
    }



    /**
        @brief Shows missing HQ screen
        @details Clears story book page, sets new title, adds missing HQ elements via [this.RenderMissingHQScreen()](#RenderMissingHQScreen) to it and then opens the story book window

        @note This will set #MissingHQScreenVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run a lot more often than normal. It might slow the game down but ensures that script react promptly to clicks and other player actions.

        @returns bool
        @retval true    Story book page displayed successfully
        @retval false   Failed displaying story book page
    */
    function ShowMissingHQScreen() {
        this.ClearPage();
        this.RenderMissingHQScreen();
        return IdleUtil.DisplayPage(this.IdleStoryPageID);
    }

    
    /**
        @brief Renders idle report screen
        @details Adds idle report elements to story book page without showing the page itself so that [this.ShowIdleReportScreen()](#ShowIdleReportScreen) can display it.

        @note This will set #IdleReportVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run a lot more often than normal. It might slow the game down but ensures that script react promptly to clicks and other player actions.

        @attention Idle report page is \em quasi-persistent. If player closes story book without clicking the button within, script will open idle report story book page again and keep doing it until player clicks the button on the page.

        @param idleBalance Idle balance to use
        @param inactiveSeconds Idle balance to use
        @param vehicleSummary Summary of all vehicles
        @param allVehicleStats An array of vehicle stats for all vehicle types

        @returns void
    */
    function RenderIdleReportScreen(idleBalance, inactiveSeconds, vehicleSummary = null, allVehicleStats = null) {
        GSStoryPage.SetTitle(this.IdleStoryPageID, GSText(GSText.STR_PAGE_TITLE_REPORT));
        local welcomeText = GSText(GSText.STR_WELCOME_MAN);
        if (GSCompany.GetPresidentGender(this.PlayerCompanyID) == GSCompany.GENDER_FEMALE) {
            welcomeText = GSText(GSText.STR_WELCOME_WOMAN);
        }
        this.AddPageTextElement(GSText(GSText.STR_REPORT_TITLE, welcomeText, this.PlayerCompanyID));
        this.AddPageTextElement(GSText(GSText.STR_REPORT_ABSENCE, this.GetDurationText(inactiveSeconds)));
        this.AddPageTextElement(this.GetIdleReportTextElement(idleBalance, inactiveSeconds));

        if (vehicleSummary != null && vehicleSummary.count > 1) {
            local avgEl = this.GetVehicleAverageTextElement(idleBalance, inactiveSeconds, vehicleSummary);
            if (avgEl != null) {
                this.AddPageTextElement(avgEl);
            }
        }

        this.CloseReportWarningTextElementID = this.AddPageTextElement(GSText(GSText.STR_EMPTY));
        this.RenderIdleReportButton(idleBalance);
        this._RenderDebugNavButtons();
        this.IdleReportVisible = true;
    }

      /**
        @brief Renders stats screen
        @details Adds stats elements to story book page so that [this.ShowStatsScreen()](#ShowStatsScreen) has something to show

        @note This will set #StatsScreenVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run a lot more often than normal. It might slow the game down but ensures that script react promptly to clicks and other player actions.

        @param vehicleSummary Summary of all vehicles
        @param allVehicleStats An array of vehicle stats for all vehicle types
        @param totalAmount      Last session idle balance
        @param totalSeconds     TIme since last save game
        @param intLastYearBalance Money earned / lost last year

        @returns void
    */
    function RenderStatsScreen(vehicleSummary, allVehicleStats, totalAmount, totalSeconds, intLastYearBalance) {
        if (!IdleUtil.HasHQ(this.PlayerCompanyID)) {
            return this.RenderMissingHQScreen();
        } else {
            local idleMultiplier = IdleUtil.GetIdleMultiplier();
            local idleMultiplierLabel = this.GetIdleMultiplierLabel();
            local secondsInGameYear = (365 * ::SecondsPerGameDay).tointeger();
            local totalVehicles = vehicleSummary.count;
            local prognosedIdleBalance = (intLastYearBalance * idleMultiplier).tointeger();
            
            GSStoryPage.SetTitle(this.IdleStoryPageID, GSText(GSText.STR_PAGE_TITLE_STATS));
            if (totalVehicles > 0) {
                local willEarn = GSText(GSText.STR_STATS_GENERAL_INFO_WILL_BE_EARNING);
                if (prognosedIdleBalance < 0) {
                    willEarn = GSText(GSText.STR_STATS_GENERAL_INFO_WILL_BE_LOSING);
                }
                local amountInTime = this.GetBalancePerTimeUnit(prognosedIdleBalance, secondsInGameYear, ::TimeUnits.TIME_UNIT_SECOND, 3);

                local minusMessage = GSText(GSText.STR_EMPTY);
                if (prognosedIdleBalance < 0) {
                    minusMessage = GSText(GSText.STR_STATS_MINUS_NOTE);
                }

                this.AddPageTextElement(GSText(GSText.STR_STATS_GENERAL_INFO, GSText(GSText.STR_SCRIPT_NAME_GOLD), totalVehicles, idleMultiplierLabel, willEarn, amountInTime, minusMessage));

                if (allVehicleStats != null) {
                    this.AddPageTextElement(GSText(GSText.STR_SECTION_TITLE_VEHICLE_STATS));
                    foreach (typeIndex, typeStats in allVehicleStats) {
                        this.RenderVehicleTypeStats(typeStats);
                    }
                }
                this.RenderCloseStoryBookButton();

                if (totalSeconds > 0 && totalAmount != 0) {
                    this.PreviousDurationElementID = this.AddPageTextElement(GSText(GSText.STR_STATS_LAST_IDLE_SESSION_TEXT, this.GetDurationText(totalSeconds)));
                }
                this.RenderLastIdleSummaryElements(totalAmount, totalSeconds);
            } else {
                this.AddPageTextElement(GSText(GSText.STR_STATS_GENERAL_INFO_NO_VEHICLES, idleMultiplierLabel));
                this.RenderCloseStoryBookButton();
            }
            this.RenderHelpButton();
            this.RenderRefreshButton();

            this._RenderDebugNavButtons();
            this.StatsScreenVisible = true;
        }

    }

    /**
        @brief Adds intro screen elements to story page and updates the title
        @details Adds intro screen elements to story book page so that [this.ShowIntroScreen()](#ShowIntroScreen) has something to show

        @note This will set #IntroVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run faster than normal.

        @returns void
    */
    function RenderIntroScreen() {
        GSStoryPage.SetTitle(this.IdleStoryPageID, GSText(GSText.STR_PAGE_TITLE_INTRO));
        this.AddPageTextElement(GSText(GSText.STR_INTRO_TEXT, GSText(GSText.STR_SCRIPT_NAME_GOLD), GSText(GSText.STR_SCRIPT_NAME_GOLD)));
        this.IntroButtonID = this.AddNavButton(GSText(GSText.STR_BUTTON_TEXT_START));
        this.RenderHelpButton();

        this.AddPageTextElement(GSText(GSText.STR_INTRO_NOTE));

        this._RenderDebugNavButtons();
        this.IntroVisible = true
    }

    /**
        @brief Adds help screen elements to story page and updates the title
        @details Adds help screen elements to story book page so that [this.ShowHelpScreen()](#ShowHelpScreen) has something to show

        @note This will set #HelpScreenVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run faster than normal.

        @returns void
    */
    function RenderHelpScreen() {
        GSStoryPage.SetTitle(this.IdleStoryPageID, GSText(GSText.STR_PAGE_TITLE_HELP));
        this.AddPageTextElement(GSText(GSText.STR_HELP_PAGE_INTRO, GSText(GSText.STR_SCRIPT_NAME_GOLD)));
        this.RenderRefreshButton(GSText(GSText.STR_BUTTON_TEXT_STATS), GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_YELLOW, GSStoryPage.SPBF_NONE));
        this.AddPageTextElement(GSText(GSText.STR_HELP_PAGE_TEXT, GSText(GSText.STR_SCRIPT_NAME_GOLD)));
        this.AddPageTextElement(GSText(GSText.STR_HELP_PAGE_NOTES, GSText(GSText.STR_SCRIPT_NAME_GOLD)));
        this.AddPageTextElement(GSText(GSText.STR_HELP_PAGE_SETTINGS, GSText(GSText.STR_SCRIPT_NAME_GOLD)));

        this.RenderCloseStoryBookButton();
        this._RenderDebugNavButtons();

        this.HelpScreenVisible = true
    }


    /**
        @brief Adds missing HQ screen elements to story page and updates the title
        @details Adds missing HQ screen elements to story book page so that [this.ShowMissingHQScreen()](#ShowMissingHQScreen) has something to show.

        @note This will set #MissingHQScreenVisible flag to `true`, causing [MainClass.Start()](#MainClass.Start) `while` loop to run a lot more often than normal. It might slow the game down but ensures that script react promptly to clicks and other player actions.

        @returns void
    */
    function RenderMissingHQScreen() {
        GSStoryPage.SetTitle(this.IdleStoryPageID, GSText(GSText.STR_PAGE_TITLE_NOHQ));
        this.AddPageTextElement(GSText(GSText.STR_MISSING_HQ, GSText(GSText.STR_SCRIPT_NAME_GOLD)));

        this.RenderRefreshButton(GSText(GSText.STR_BUTTON_TEXT_FIND_HQ));
        this.RenderCloseStoryBookButton();
        this.RenderHelpButton();
        this._RenderDebugNavButtons();
        this.MissingHQScreenVisible = true;
    }

    
    /**
        @}
    */



    /**
        @name Partial rendering functions
        These functions render elements of relatively complex individual elements as partials for screens.
        @{
    */



    /**
        @brief Renders first paragraph of idle report
        @details Calculates duration and balance and displays that information as a text paragraph on idle report screen using `GSText.STR_REPORT_SUMMARY` from lang files.

        @param idleBalance      Idle balance (amount of money player got or lost)
        @param inactiveSeconds  Total number of seconds that idle balance took to accumulate

        @returns GSText Page story text element with data applied
    */
    function GetIdleReportTextElement(idleBalance, inactiveSeconds) {
        local idleMultiplierLabel = this.GetIdleMultiplierLabel();
        local idleDays = (inactiveSeconds / ::SecondsPerGameDay).tointeger();
        local idleForYears = (idleDays / 365).tointeger();
        local idleForDays = idleDays % 365;

        local idleReportTextElement = GSText(GSText.STR_REPORT_SUMMARY);

        local durationLabelYears = GSText(GSText.STR_EMPTY, 0, "");
        local durationLabelDays = GSText(GSText.STR_EMPTY, 0, "");
        if (idleForYears > 0) {
            durationLabelYears = GSText(GSText.STR_DURATION_TEXT_YEARS);
            durationLabelYears.AddParam(idleForYears);
            if (idleForDays > 0) {
                durationLabelYears.AddParam(GSText(GSText.STR_WORD_AND_SPACE));
            } else {
                durationLabelYears.AddParam(GSText(GSText.STR_EMPTY));
            }
        }
        if (idleForDays > 0) {
            durationLabelDays = GSText(GSText.STR_DURATION_TEXT_DAYS, idleForDays, GSText(GSText.STR_EMPTY));
        }

        local balanceText1 = GSText(GSText.STR_IDLE_REPORT_EARNED, idleBalance);
        local balanceText2 = GSText(GSText.STR_EMPTY, 0);
        local balanceText = GSText(GSText.STR_IDLE_REPORT_EARNED);
        if (idleBalance < 0) {
            balanceText1 = GSText(GSText.STR_EMPTY, 0);
            balanceText2 = GSText(GSText.STR_IDLE_REPORT_LOST, idleBalance);
            balanceText = GSText(GSText.STR_IDLE_REPORT_LOST);
        }

        idleReportTextElement.AddParam(this.PlayerCompanyID);
        idleReportTextElement.AddParam(GSText(GSText.STR_SCRIPT_NAME_GOLD));
        idleReportTextElement.AddParam(idleMultiplierLabel);
        idleReportTextElement.AddParam(durationLabelYears);
        idleReportTextElement.AddParam(durationLabelDays);
        idleReportTextElement.AddParam(balanceText);
        idleReportTextElement.AddParam(idleBalance);
        return idleReportTextElement;

    }


    /**
        @brief Renders idle report button
        @details Adds idle report button (collect $$$) with appropriate styling / colors to (idle report) story book page. Clicks are handled in [IdleStory.HandleButtonClick()](#IdleStory.HandleButtonClick) function.

        @param idleBalance Idle balance to use in button text

        @returns void
    */
    function RenderIdleReportButton(idleBalance = 0) {
        local ButtonReference = null;
        local buttonText = GSText(GSText.STR_BUTTON_APPLY_IDLE_BALANCE);
        if (idleBalance < 0) {
            ButtonReference = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_RED, GSStoryPage.SPBF_NONE);
            buttonText.AddParam(GSText(GSText.STR_BUTTON_TEXT_PAY));
        } else {
            ButtonReference = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_GREEN, GSStoryPage.SPBF_NONE);
            buttonText.AddParam(GSText(GSText.STR_BUTTON_TEXT_RECEIVE));
        }
        buttonText.AddParam(abs(idleBalance));
        this.IdleReportButtonID = GSStoryPage.NewElement(this.IdleStoryPageID, GSStoryPage.SPET_BUTTON_PUSH, ButtonReference, buttonText);
    }



    /**
        @brief Renders help button
        @details Adds help button to story book pages. Clicks are handled in [IdleStory.HandleButtonClick()](#IdleStory.HandleButtonClick) function.

        @returns void
    */
    function RenderHelpButton() {
        this.ShowHelpButtonID = this.AddNavButton(GSText(GSText.STR_BUTTON_TEXT_HELP));
    }

    /**
        @brief Renders refresh button with optional custom text
        @details Adds refresh button to story book page (used on idleReport and missing hq screens). Clicks are handled in [IdleStory.HandleButtonClick()](#IdleStory.HandleButtonClick) function.

        @param customText           Optional custom string for the button (default GSText.STR_NAV_BUTTON_STATS)
        @param buttonReference      Reference for customizing button styles

        @returns void
    */
    function RenderRefreshButton(customText = null, buttonReference = null) {
        if (customText == null) {
            customText = GSText(GSText.STR_BUTTON_TEXT_REFRESH);
        }
        if (buttonReference == null) {
            buttonReference = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_ORANGE, GSStoryPage.SPBF_NONE);
        }
        this.RefreshButtonID = this.AddNavButton(customText, buttonReference);
    }

    /**
        @brief Renders close button
        @details Adds close button to story book pages. Clicks are handled in [IdleStory.HandleButtonClick()](#IdleStory.HandleButtonClick) function.

        @returns void
    */
    function RenderCloseStoryBookButton() {
        this.CloseButtonID = this.AddNavButton(GSText(GSText.STR_BUTTON_TEXT_CLOSE), GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_ORANGE, GSStoryPage.SPBF_NONE));
    }

    /**
    @brief Renders vehicle type statistics row on story book page
    @details Creates, populates and adds story book page element for given vehicle type

    Sample result texts:
    > 6 ships running, earning $2 per second


    > 1 rail vehicle running, losing $123 every hour

    @param vehicleTypeStats SQTable Table with vehicle statistics for given type

    @returns int
    @retval -1                  Error adding element to the page (GSStoryPage.STORY_PAGE_ELEMENT_INVALID)!
    @retval any_other_value     ID of new, successfully rendered, element.
    */
    function RenderVehicleTypeStats(vehicleTypeStats = null) {
        if (vehicleTypeStats != null && vehicleTypeStats.count > 0) {
            local earned = vehicleTypeStats.idleBalance;
            local count = vehicleTypeStats.count;
            local vehicleType = vehicleTypeStats.type;

            local vehicleStatsRow = GSText(GSText.STR_VEHICLE_INFO_ROW);

            local countText = GSText(GSText.STR_EMPTY, 0);
            if (vehicleType == GSVehicle.VT_RAIL) {
                countText = GSText(GSText.STR_VEHICLE_COUNT_RAIL, count);
            } else if (vehicleType == GSVehicle.VT_ROAD) {
                countText = GSText(GSText.STR_VEHICLE_COUNT_ROAD, count);
            } else if (vehicleType == GSVehicle.VT_WATER) {
                countText = GSText(GSText.STR_VEHICLE_COUNT_WATER, count);
            } else if (vehicleType == GSVehicle.VT_AIR) {
                countText = GSText(GSText.STR_VEHICLE_COUNT_AIR, count);
            }
            vehicleStatsRow.AddParam(countText);

            local secondsInGameYear = (365 * ::SecondsPerGameDay).tointeger();
            local perSecond = earned / secondsInGameYear;

            local perDay = abs(((earned.tofloat() * ::SecondsInPeriod.DAY.tofloat()) / secondsInGameYear.tofloat()).tointeger());

            if (perDay < 1) {
                vehicleStatsRow.AddParam(GSText(GSText.STR_EMPTY));
                vehicleStatsRow.AddParam(GSText(GSText.STR_VEHICLE_INFO_ZERO_BALANCE, GSText(GSText.STR_EMPTY), GSText(GSText.STR_EMPTY), GSText(GSText.STR_EMPTY)));
            } else {
                if (earned < 0) {
                    vehicleStatsRow.AddParam(GSText(GSText.STR_VEHICLE_INFO_LOSING_BALANCE));
                } else {
                    vehicleStatsRow.AddParam(GSText(GSText.STR_VEHICLE_INFO_EARNING_BALANCE));
                }
                local amountInTime = this.GetBalancePerTimeUnit(earned, secondsInGameYear, ::TimeUnits.TIME_UNIT_SECOND, 3);
                vehicleStatsRow.AddParam(amountInTime);
            }
            return this.AddPageTextElement(vehicleStatsRow);
        }
        return GSStoryPage.STORY_PAGE_ELEMENT_INVALID;
    }

    /**
    @brief Renders idle summary text elements
    @details Adds summary text elements that show total number of vehicles and their approximate earnings/losses per time unit (day, h, m, s)

    @param totalAmount      Last session idle balance
    @param totalSeconds     TIme since last save game

    @returns void
    */
    function RenderLastIdleSummaryElements(totalAmount, totalSeconds) {
        if (totalSeconds > 0 && totalAmount != 0) {
            local idleSummaryText = GSText(GSText.STR_STATS_LAST_IDLE_SESSION_SUMMARY);
            local earnedTimeText = GSText(GSText.STR_EMPTY);
            local totalText = GSText(GSText.STR_TOTAL_POSITIVE);
            local amountText = GSText(GSText.STR_CURRENCY_POSITIVE, totalAmount);
            if (totalAmount != 0) {
                if (totalAmount > 0) {
                    idleSummaryText.AddParam(GSText(GSText.STR_STATS_LAST_IDLE_SESSION_SUMMARY_EARNING));
                } else {
                    idleSummaryText.AddParam(GSText(GSText.STR_STATS_LAST_IDLE_SESSION_SUMMARY_LOSING));
                    amountText = GSText(GSText.STR_CURRENCY_NEGATIVE, totalAmount);
                    totalText = GSText(GSText.STR_TOTAL_NEGATIVE);
                }
                local amountInTime = this.GetBalancePerTimeUnit(totalAmount, totalSeconds, ::TimeUnits.TIME_UNIT_SECOND, 3);
                idleSummaryText.AddParam(amountInTime);
                idleSummaryText.AddParam(totalText);
                idleSummaryText.AddParam(amountText);
                this.AddPageTextElement(idleSummaryText);
            }
        }
    }
    /**
        @brief Renders debug nav buttons
        @details Adds debug nav buttons to story book page if developer setting @ref config_sec "show_story_debug" is enabled

        @returns void
    */
    function _RenderDebugNavButtons() {
        if (GSController.GetSetting("show_story_debug")) {
            this.AddPageTextElement(GSText(GSText.STR_NAV_BUTTONS_TEXT));
            local ButtonReference1 = GSStoryPage.MakePushButtonReference(GSStoryPage.SPBC_WHITE, GSStoryPage.SPBF_NONE);
            this._NavButtonIntroID = this.AddNavButton(GSText(GSText.STR_NAV_BUTTON_INTRO), ButtonReference1);
            this._NavButtonStatsID = this.AddNavButton(GSText(GSText.STR_NAV_BUTTON_STATS), ButtonReference1);
            this._NavButtonNoHQID = this.AddNavButton(GSText(GSText.STR_NAV_BUTTON_NO_HQ), ButtonReference1);
            this._NavButtonIdleReportID = this.AddNavButton(GSText(GSText.STR_NAV_BUTTON_REPORT), ButtonReference1);
            this._NavButtonShowHelpID = this.AddNavButton(GSText(GSText.STR_NAV_BUTTON_HELP), ButtonReference1);
        }
    }




    /**
        @brief Updates duration text
        @details If [this.PreviousDurationElementID](#PreviousDurationElementID) is valid its text gets updated with up-to-date formatted duration text (works as time ticker).

        \prethisstorypagevalid

        @param intTotalSeconds Total duration seconds

        @return bool
        @retval true    Duration story page element updated
        @retval false   Failed updating duration story page element
    */
    function UpdateDuration(intTotalSeconds) {
        if (GSStoryPage.IsValidStoryPage(this.IdleStoryPageID) && GSStoryPage.IsValidStoryPageElement(this.PreviousDurationElementID)) {
            local durationText = this.GetDurationText(intTotalSeconds);
            return GSStoryPage.UpdateElement(this.PreviousDurationElementID, -1, GSText(GSText.STR_STATS_LAST_IDLE_SESSION_TEXT, durationText));
        }
        return false;
    }


    /**
        @brief Updates close warning text element
        @details Shows or hides text warning player about closing idle report window via button only.

        \prethisstorypagevalid

        @param boolShowWarning Controls whether to show close warning or not

        @return bool
        @retval true    Close warning story page element updated
        @retval false   Failed updating close warning story page element
    */
    function UpdateReportCloseWarning(boolShowWarning = true) {
        if (GSStoryPage.IsValidStoryPage(this.IdleStoryPageID) && GSStoryPage.IsValidStoryPageElement(this.CloseReportWarningTextElementID)) {
            local text = GSText(GSText.STR_EMPTY);
            if (boolShowWarning) {
                text = GSText(GSText.STR_REPORT_WAIT_WARNING);
            }
            return GSStoryPage.UpdateElement(this.CloseReportWarningTextElementID, -1, text);
        }
        return false;
    }

    /**
        @brief Returns average per vehicle text
        @details Returns text with average balance per one vehicle in last eyear


        @param totalAmount Total cash
        @param totalSeconds Total seconds
        @param vehicleSummary Summary of all vehicles

        @returns GSText Average balance per vehicle text element or null for none
    */
    function GetVehicleAverageTextElement(totalAmount, totalSeconds, vehicleSummary) {
        local totalVehicles = 0;
        if (vehicleSummary != null){
            totalVehicles = vehicleSummary.count;
        }
        local averageText = null;
        if (totalVehicles > 1) { // more than one because average
            


            local timeUnitText = GSText(GSText.STR_PER_SECOND);
            local ratio = ::SecondsInPeriod.SECOND;
            if (totalSeconds > 86400) {
                timeUnitText = GSText(GSText.STR_PER_DAY);
                ratio = ::SecondsInPeriod.DAY;
            } else if (totalSeconds > 3 * 3660) {
                timeUnitText = GSText(GSText.STR_PER_HOUR);
                ratio = ::SecondsInPeriod.HOUR;
            } else if (totalSeconds > 3 * 60) {
                timeUnitText = GSText(GSText.STR_PER_MINUTE);
                ratio = ::SecondsInPeriod.MINUTE;
            }

            
            local cashInTime = (this.CashInPeriod(totalAmount, totalSeconds, ratio) / totalVehicles).tointeger();
            if (cashInTime > 0) {
                local inTime = GSText(GSText.STR_CURRENCY_POSITIVE, cashInTime);
                averageText = GSText(GSText.STR_REPORT_AVERAGE);
                averageText.AddParam(totalVehicles);
                if (totalAmount > 0) {
                    averageText.AddParam(GSText(GSText.STR_STATS_LAST_IDLE_SESSION_SUMMARY_EARNING));
                } else {
                    inTime = GSText(GSText.STR_CURRENCY_NEGATIVE, cashInTime);
                    averageText.AddParam(GSText(GSText.STR_STATS_LAST_IDLE_SESSION_SUMMARY_LOSING));
                }
                averageText.AddParam(inTime);
                averageText.AddParam(timeUnitText);
            }
            
            return averageText;
            // this.AddPageTextElement(averageText);
        }
    }



    /**
        @brief Returns formatted duration text element
        @details Populates STR_DURATION_TEXT with data and returns it as STRING with 0-11 parametars. Always should be the last {STRING} variable.

        @param inactiveSeconds Total seconds to show duration for

        @returns GSText Text element with formatted duration
    */
    function GetDurationText(inactiveSeconds) {
        local remaining = inactiveSeconds.tointeger();
        local days = remaining / ::SecondsInPeriod.DAY;
        remaining = remaining % ::SecondsInPeriod.DAY;
        local hours = remaining / ::SecondsInPeriod.HOUR;
        remaining = remaining % ::SecondsInPeriod.HOUR;
        local minutes = remaining / ::SecondsInPeriod.MINUTE;
        remaining = remaining % ::SecondsInPeriod.MINUTE;
        local seconds = remaining;

        local titleText = GSText(GSText.STR_DURATION_HUMAN);

        local daysParam = null;
        local hoursParam = null;
        local minutesParam = null;
        local secondsParam = null;

        local maxCount = 2;
        local middleAdded = false;

        if (days > 0) {
            daysParam = GSText(GSText.STR_DURATION_TEXT_DAYS);
            daysParam.AddParam(days);

            if (hours + minutes + seconds > 0) {
                middleAdded = true;
                daysParam.AddParam(GSText(GSText.STR_WORD_AND_SPACE));
            } else {
                // days only, nothing to append as delimiter
                daysParam.AddParam(GSText(GSText.STR_EMPTY));
            }
        }
        if (hours > 0) {
            hoursParam = GSText(GSText.STR_DURATION_TEXT_HOURS);
            hoursParam.AddParam(hours);
            if (minutes + seconds > 0) {
                if (!middleAdded) {
                    hoursParam.AddParam(GSText(GSText.STR_WORD_AND_SPACE));
                    middleAdded = true;
                } else {
                    hoursParam.AddParam(GSText(GSText.STR_EMPTY));
                }
            } else {
                // hours are last, nothing left to add
                hoursParam.AddParam(GSText(GSText.STR_EMPTY));
            }
        }

        if (minutes > 0) {
            minutesParam = GSText(GSText.STR_DURATION_TEXT_MINUTES);
            minutesParam.AddParam(minutes);
            if (seconds > 0) {
                if (!middleAdded) {
                    minutesParam.AddParam(GSText(GSText.STR_WORD_AND_SPACE));
                    middleAdded = true;
                } else {
                    minutesParam.AddParam(GSText(GSText.STR_EMPTY));
                }
            } else {
                minutesParam.AddParam(GSText(GSText.STR_EMPTY));
            }
        }
        if (seconds > 0) {
            secondsParam = GSText(GSText.STR_DURATION_TEXT_SECONDS);
            secondsParam.AddParam(seconds);
            secondsParam.AddParam(GSText(GSText.STR_EMPTY));
        }
        local count = 0;

        if (daysParam != null) {
            count++;
            titleText.AddParam(daysParam);
        }
        if (hoursParam != null && count < maxCount) {
            count++;
            titleText.AddParam(hoursParam);
        }
        if (minutesParam != null && count < maxCount) {
            count++;
            titleText.AddParam(minutesParam);
        }
        if (secondsParam != null && count < maxCount) {
            count++;
            titleText.AddParam(secondsParam);
        }
        if (count < maxCount) {
            for (local fill = count; fill < maxCount; fill++) {
                titleText.AddParam(GSText(GSText.STR_EMPTY, 0, ""));
            }
        }
        return titleText

    }


    /**
         @brief Returns idle multiplier string label
        @details Returns string for adding as param to text elements

        @returns GSText     String representation of idle multiplier (with '%' appended)
    */
    function GetIdleMultiplierLabel() {
        local label = GSText.STR_EMPTY;
        local setting = GSController.GetSetting("idle_multiplier").tofloat();
        if (setting == 1) {
            label = GSText.STR_MULTIPLIER_LABEL_1;
        } else if (setting == 1) {
            label = GSText.STR_MULTIPLIER_LABEL_1;
        } else if (setting == 2) {
            label = GSText.STR_MULTIPLIER_LABEL_2;
        } else if (setting == 3) {
            label = GSText.STR_MULTIPLIER_LABEL_3;
        } else if (setting == 4) {
            label = GSText.STR_MULTIPLIER_LABEL_4;
        } else if (setting == 5) {
            label = GSText.STR_MULTIPLIER_LABEL_5;
        } else if (setting == 6) {
            label = GSText.STR_MULTIPLIER_LABEL_6;
        } else if (setting == 7) {
            label = GSText.STR_MULTIPLIER_LABEL_7;
        } else if (setting == 8) {
            label = GSText.STR_MULTIPLIER_LABEL_8;
        } else if (setting == 9) {
            label = GSText.STR_MULTIPLIER_LABEL_9;
        } else if (setting == 10) {
            label = GSText.STR_MULTIPLIER_LABEL_10;
        }
        return GSText(label);
    }

    /**
    @brief Returns STRING3 (string1 string string7 = "earning / losing", "$XXX" "x hours, y min etc..."") showing amount per time unit
    @details Renders text element with amount of money in given period

    @param totalAmount      Gross balance change across a period
    @param totalSeconds     Number of real-time seconds passed in period od time
    @param forceTimeUnit    Force time unit index (1 = minute, 2 = hour, 3 = day)
    @param intMinTreshold   Minimum treshold - values below this will cause next (longer) time unit to be picked

    @returns int Id of balance text element
    */
    function GetBalancePerTimeUnit(totalAmount, totalSeconds, forceTimeUnit = ::TimeUnits.TIME_UNIT_SECOND, intMinTreshold = 1) {
        local balanceInTimeUnitText = GSText(GSText.STR_EMPTY);
        local amount = 0;
        local newAmount = 0;
        local timeUnitString = GSText(GSText.STR_EMPTY);
        local unitPicked = 0;

        if (totalSeconds > 0) {
            balanceInTimeUnitText = GSText(GSText.STR_EARN_IN_TIME);
            local perSecond = totalAmount.tofloat() / totalSeconds.tofloat();
            newAmount = perSecond;
            timeUnitString = GSText(GSText.STR_PER_SECOND);
            if (forceTimeUnit <= 0) {
                if ((totalAmount > 0 && newAmount < intMinTreshold) || (totalAmount < 0 && newAmount > -1 * intMinTreshold)) {
                    newAmount = perSecond * ::SecondsInPeriod.MINUTE;
                    timeUnitString = GSText(GSText.STR_PER_MINUTE);
                    unitPicked = 1;
                }

                if ((totalAmount > 0 && newAmount < intMinTreshold) || (totalAmount < 0 && newAmount > -1 * intMinTreshold)) {
                    newAmount = perSecond * ::SecondsInPeriod.HOUR;
                    timeUnitString = GSText(GSText.STR_PER_HOUR);
                    unitPicked = 2;
                }

                if ((totalAmount > 0 && newAmount < intMinTreshold) || (totalAmount < 0 && newAmount > -1 * intMinTreshold)) {
                    newAmount = perSecond * ::SecondsInPeriod.DAY;
                    timeUnitString = GSText(GSText.STR_PER_DAY);
                    unitPicked = 3;
                }
            } else {
                if (forceTimeUnit == 1) {
                    newAmount = this.CashInPeriod(totalAmount, totalSeconds, ::SecondsInPeriod.MINUTE);
                    timeUnitString = GSText(GSText.STR_PER_MINUTE);
                } else if (forceTimeUnit == 2) {
                    newAmount = this.CashInPeriod(totalAmount, totalSeconds, ::SecondsInPeriod.HOUR);
                    timeUnitString = GSText(GSText.STR_PER_HOUR);
                } else if (forceTimeUnit == 3) {
                    newAmount = this.CashInPeriod(totalAmount, totalSeconds, ::SecondsInPeriod.DAY);
                    timeUnitString = GSText(GSText.STR_PER_DAY);
                }
            }

            amount = newAmount.tointeger();
            if (newAmount == 0 && amount != 0) {
                if (amount > 0) {
                    newAmount = 1;
                } else {
                    newAmount = -1;
                }
            }

        }
        local amountText = GSText(GSText.STR_CURRENCY_POSITIVE, amount);
        if (amount < 0) {
            amountText = GSText(GSText.STR_CURRENCY_NEGATIVE, amount);
        }
        balanceInTimeUnitText.AddParam(amountText);
        balanceInTimeUnitText.AddParam(timeUnitString);

        return balanceInTimeUnitText;
    }

    /**
        @}
    */


    /**
        @name Utility / calculation functions
        Commonly used utility and calculation functions
        @{
    */


    /**
        @brief Returns amount of cash calculated fer given period
        @details Calculates amount for given period based on yearly total amount

        @param totalAmount  Yearly amount (in-game year)
        @param totalSeconds Number of real-time seconds in the period
        @param ratio        Ratio (seconds in period) to calculate

        @returns float Amount per period
    */
    function CashInPeriod(totalAmount, totalSeconds, ratio = ::SecondsInPeriod.SECOND) {
        local amount = 0.0;
        if (totalSeconds > 0 && totalAmount != 0) {
            amount = ((totalAmount.tofloat() / totalSeconds.tofloat()) * ratio).tofloat();
        }
        return amount;
    }










}