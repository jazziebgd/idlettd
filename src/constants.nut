/**
 * @file constants.nut Contains definitions for constants, globals and enums for IdleTTD game script
 */

/**
    @enum ScriptLogLevels

    @brief Log levels for IdleTTD.

    @details Easy to remember names for integer log levels in IdleTTD. Only when `log_level` setting value is equal to or larger than particular member of this enum, messages of that log level will be logged, along with all lower level messages.

    Identical to @ref config_sec "log_level" developer setting values.
*/
enum ScriptLogLevels {
    /** 
        @hideinitializer
        No logging at all 
    */
    LOG_LEVEL_NONE = 0,
    /** 
        @hideinitializer
        Log error messages
    */
    LOG_LEVEL_ERROR = 1,
    /** 
        @hideinitializer
        Log warnings and errors
    */
    LOG_LEVEL_WARNING = 2,
    /** 
        @hideinitializer
        Log info, warning and error messages
    */
    LOG_LEVEL_INFO = 3,
    /** 
        @hideinitializer
        Log debug, info, warning and error messages (_can be noisy_)
    */
    LOG_LEVEL_DEBUG = 4,
    /** 
        @hideinitializer
        Log verbose, debug, info, warning and error messages (_noisy_)
    */
    LOG_LEVEL_VERBOSE = 5,
}

/**
    @enum SecondsInPeriod
    @brief Number of seconds in time period

    @details Used to generate duration strings and calculate idle balances 
*/
enum SecondsInPeriod {
    /** 
        @hideinitializer
        One second per second
    */
    SECOND = 1,
    /** 
        @hideinitializer
        60 seconds per minute
    */
    MINUTE = 60,
    /** 
        @hideinitializer
        3600 seconds per hour
    */
    HOUR = 3600,
    /** 
        @hideinitializer
        86400 seconds per day
    */
    DAY = 86400,
}


/**
    @enum TimeUnits
    @brief Time units for displaying idle balance values

    @details Used to force same time units when needed (i.e to display previous and current $$$ with same unit for easier (visual) comparation)
*/
enum TimeUnits {
    /** 
        @hideinitializer
        Force second as time unit
    */
    TIME_UNIT_SECOND = 0,
    /** 
        @hideinitializer
        Force minute as time unit
    */
    TIME_UNIT_MINUTE = 1,
    /** 
        @hideinitializer
        Force hour as time unit
    */
    TIME_UNIT_HOUR = 2,
    /** 
        @hideinitializer
        Force day as time unit
    */
    TIME_UNIT_DAY = 3,
}


/**
    @var SecondsPerGameDay
    @hideinitializer
    @brief Number (float) of seconds per one game day
    @details Predefined value (2.22 s, taken from <a href="https://wiki.openttd.org/en/Manual/FAQ%20gameplay#how-long-is-a-game-day-in-real-time" target="_blank">OpenTTD FAQ</a>) that represents a ratio between game time and real time.
*/
SecondsPerGameDay <- 2.22;


/**
    @var TicksPerGameDay
    @hideinitializer
    @brief Number (integer) of ticks per one game day
    @details Predefined value (74) that represents a ratio between game ticks and one game day.
*/
TicksPerGameDay <- 74;

/**
    @var ScriptMinVersionToLoad
    @hideinitializer
    @brief      Minimum script version to load
    @details    Script versions get stored in save games and upon loading the game, stored value is checked against this value.

    This value is returned from FMainClass.MinVersionToLoad() in IdleTTD game script info.nut file.
*/
ScriptMinVersionToLoad <- 1;

/**
    @var ScriptLastUpdateDate
    @hideinitializer
    @brief     Last script update date
    @details   String (ISO) date marking the time the script was updated last time

    This value is used by and returned from (FMainClass.GetDate())[#FMainClass.GetDate] function.
*/
ScriptLastUpdateDate <- "2024-02-15";