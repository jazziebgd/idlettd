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
    /** No logging at all */
    LOG_LEVEL_NONE = 0,
    /** Log error messages */
    LOG_LEVEL_ERROR = 1,
    /** Log warnings and errors */
    LOG_LEVEL_WARNING = 2,
    /** Log info, warning and error messages */
    LOG_LEVEL_INFO = 3,
    /** Log debug, info, warning and error messages (_can be noisy_) */
    LOG_LEVEL_DEBUG = 4,
    /** Log verbose, debug, info, warning and error messages (_noisy_) */
    LOG_LEVEL_VERBOSE = 5,
}

/**
    @enum SecondsInPeriod
    @brief Number of seconds in time period

    @details Used to generate duration strings and calculate idle balances 
*/
enum SecondsInPeriod {
    /** One second per second */
    SECOND = 1,
    /** 60 seconds per minute */
    MINUTE = 60,
    /** 3600 seconds per hour */
    HOUR = 3600,
    /** 86400 seconds per day */
    DAY = 86400,
}

/**
@var SecondsPerGameDay

@brief Number (float) of seconds per one game day
@details Predefined value (2.22 s, taken from <a href="https://wiki.openttd.org/en/Manual/FAQ%20gameplay#how-long-is-a-game-day-in-real-time" target="_blank">OpenTTD FAQ</a>) that represents a ratio between game time and real time.
*/
SecondsPerGameDay <- 2.22;

/**
    @var ScriptMinVersionToLoad

    @brief      Minimum script version to load
    @details    Script versions get stored in save games and upon loading the game, stored value is checked agains this value.

    This value is returned from <a href="https://docs.openttd.org/gs-api/classGSInfo#a44f99f7837e3fcbb863faebef07589b6" target="_blank">GSInfo::MinVersionToLoad</a> in IdleTTD game script info file.
*/
ScriptMinVersionToLoad <- 1;