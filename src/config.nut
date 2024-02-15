/**
    @file config.nut Contains base configuration options for IdleTTD game script
 */


 /**
    @var ScriptConfig
    @hideinitializer

    
    @brief Script configuration (not related with script settings, see #StructGameScriptConfig for details).
    @details Variables that too rarely used to be added as script settings, yet too commonly used for harcoding.

    @see StructGameScriptConfig for structure member docs.
    */
::ScriptConfig <- {
    /**
        @var ScriptConfig::WarnAfterCloseAttempts
        @brief Report close attempt limit
        @details Initially idle report doesn't show close warning text. This is the number of times report window will re-open if user tries to dismiss it before closing warning text gets displayed.
    */
    WarnAfterCloseAttempts = 2,

    /**
        @var ScriptConfig::ShowStatsAfterReport
        @brief Close story book after accepting idle balance
        @details False will show stats screen instead of closing story book
    */
    ShowStatsAfterReport = true,

    /**
        @var ScriptConfig::MinSleepTime
        @brief Minimum sleep time for immediate next loop iteration
        @details Smallest number of ticks that script loop can sleep for
    */
    MinSleepTime = 1,
    
    /**
        @var ScriptConfig::ShortestSleepTime
        @brief Shortest sleep time for initialization / starting
        @details Very small number of ticks that script loop can sleep for
    */
    ShortestSleepTime = 5,

    /**
        @var ScriptConfig::ShortSleepTime
        @brief Short sleep time for listening to events
        @details Small number of ticks that script loop can sleep for

    */
    ShortSleepTime = 10,

    /**
        @var ScriptConfig::MedSleepTime
        @brief Medium sleep time for misc processing
        @details Medium number of ticks that script loop can sleep for
    */
    MedSleepTime = 33,
};