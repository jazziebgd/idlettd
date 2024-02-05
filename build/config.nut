/**
    @file config.nut Contains configuration for IdleTTD game script
 */


 /**
    @var ScriptConfig
    @hideinitializer

    
    @brief Script configuration
    @details Variables too rare to add as settings, yet too common for harcoding
    <!--
    | Name | Default | Description |
    | ------------------------------------- | :-----: | ----------- |
    | __WarnAfterCloseAttempts__            | _2_     | Number of times report window will re-open before showing warning text. |
    -->
    @see [GSConfig](#GSConfig) for structure member docs.
    */
::ScriptConfig <- {
/**
        @var ScriptConfig::WarnAfterCloseAttempts
        @brief Report close attempt limit
        @details Number of times report window will re-open before showing warning text.
    */
    WarnAfterCloseAttempts = 2,
    
    KeepQuarterStats = 4,

    /**
        @var ScriptConfig::ShowStatsAfterReport
        @brief Close story book after accepting idle balance
        @details False will show stats screen instead of closing story book
    */
    ShowStatsAfterReport = false,

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

    // KeepQuarterStats = 4,
    // WarnAfterCloseAttempts = 2,    
    // ShowStatsAfterReport = false,
    // MinSleepTime = 1,
    // ShortestSleepTime = 5,
    // ShortSleepTime = 10,
    // MedSleepTime = 33,
};