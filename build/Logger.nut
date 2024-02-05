/**
    @file Logger.nut This file is part of the IdleTTD game script for OpenTTD and contains Logger class
*/

require("constants.nut");

/**
    @class Logger

    @brief      Class that is used for all logging in IdleTTD
    @details    Class contains static methods for logging messages of various log levels. Checks game script setting @ref config_sec "log_level" to determine whether given log level is allowed.
*/ 
class Logger {

    static _NestedPrependString = "  .  ";

    /**
        \privatesection
    */

    /**
        @brief Checks if given log level is enabled
        @static
        @details Checks given log level against @ref config_sec "log_level" game script setting and returns the result

        @param logLevel integer Log level to check for

        @returns bool
        @retval true    Message can be logged
        @retval false   Message can not be logged
    */
    static function _CanLog(logLevel = ScriptLogLevels.LOG_LEVEL_NONE) {
        local LogLevelSetting = GSController.GetSetting("log_level");
        if (LogLevelSetting >= logLevel) {
            return true;
        }
        return false;
    }

    /**
        \publicsection
    */

    /**
        @brief Logs verbose message
        @static
        @details If `log_level` game string setting permits, logs the message to the console

        @param message  string Message to log

        @returns void
    */
    static function Verbose(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_VERBOSE)) {
            GSLog.Info(message);
        }
    }

    /**
        @brief Logs debug message
        @static
        @details If `log_level` game string setting permits, logs the message to the console

        @param message  string Message to log

        @returns void
    */
    static function Debug(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_DEBUG)) {
            GSLog.Info(message);
        }
    }

    /**
        @brief Logs info message
        @static
        @details If `log_level` game string setting permits, logs the message to the console

        @param message  string Message to log

        @returns void
    */
    static function Info(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_INFO)) {
            GSLog.Info(message);
        }
    }

    /**
        @brief Logs warning message
        @static
        @details If `log_level` game string setting permits, logs the message to the console

        @param message  string Message to log

        @returns void
    */
    static function Warning(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_WARNING)) {
            GSLog.Warning(message);
        }
    }

    /**
        @brief Logs error message
        @static
        @details If `log_level` game string setting permits, logs the message to the console

        @param message  string Message to log
        
        @returns void
    */
    static function Error(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_ERROR)) {
            GSLog.Error(message);
        }
    }
        
    /**
        @brief Logs message with custom level
        @static
        @details If `log_level` game string setting allows, logs the message to the console with custom logLevel
        
        @param logLevel Log level
        @param message  string Message to log

        @returns void
    */
    static function _Log(logLevel, message) {
        if (Logger._CanLog(logLevel)) {
            if (logLevel == ScriptLogLevels.LOG_LEVEL_ERROR) {
                GSLog.Error(message);
            } else if (logLevel == ScriptLogLevels.LOG_LEVEL_WARNING) {
                GSLog.Warning(message);
            } else  {
                GSLog.Info(message);
            }
        }
    }

    /**
        @brief Logs tables
        @static
        @details Dumps table info message for each member of the table

        @param tableToLog Table with data to log
        @param tableIdentifier Text used to identify table dump in the log
        @param logLevel Log level
        @param prependText String to prependText to log messages (indenting)
        @param skipIdentifer Prevent logging of identifier START/STOP messages

        @returns void
    */
    static function Table(tableToLog, tableIdentifier, logLevel, prependText=null, skipIdentifer = false) {
        if (Logger._CanLog(logLevel)) {
            if (prependText == null) {
                prependText = "";
            }
            if (!skipIdentifer) {
                // GSLog.Info("");
                Logger._Log(logLevel, "");
                if (!tableIdentifier) {
                    tableIdentifier = "TABLE";
                }
                // GSLog.Info("|||||||||||||| " + tableIdentifier + " START ||||||||||||||");
                Logger._Log(logLevel, "|||||||||||||| " + tableIdentifier + " START ||||||||||||||");
            }
            foreach(key, value in tableToLog) {
                Logger._LogTableMember(key, value, logLevel, prependText + Logger._NestedPrependString);
            }
            if (!skipIdentifer) {
                Logger._Log(logLevel, "============== " + tableIdentifier + " END ==============");
                Logger._Log(logLevel, "");
            }
        }
    }

    /**
        @brief Logs table member
        @static
        @details Logs a line for table member. Arrays and tables are logged recursively.

        @param memberKey Table member key
        @param memberValue Member value
        @param logLevel Log level
        @param prependText String to prependText to log messages (used for indentation when logging child members)

        @returns void
    */
    static function _LogTableMember(memberKey, memberValue, logLevel, prependText) {
        if (Logger._CanLog(logLevel)) {
            local formatted = memberValue
            if (!prependText) {
                prependText = "";
            }

            if (typeof memberValue == "array") {
                local arraySize = memberValue.len();
                
                formatted = "__array[" + arraySize + "]__";
                local msg = prependText + memberKey + ": " + formatted;
                Logger._Log(logLevel, msg);
                
                for (local index = 0; index < arraySize; index++) {
                    Logger._LogTableMember(memberKey + "[" + index + "]", memberValue[index], logLevel, prependText + Logger._NestedPrependString);
                }
            } else if (typeof memberValue == "table") {
                local tableSize = memberValue.len();
                formatted = "__table[" + tableSize + "]__";
                local msg = prependText + memberKey + ": " + formatted;
                Logger._Log(logLevel, msg);
                Logger.Table(memberValue, memberKey, logLevel, prependText, true);
            } else if (typeof memberValue == "function") {
                formatted = "__function__";
                local msg = prependText + memberKey + ": " + formatted;
                Logger._Log(logLevel, msg);
            } else {
                local msg = prependText + memberKey + ": " + formatted;
                Logger._Log(logLevel, msg);
            }
        }
    }
};