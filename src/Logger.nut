/**
    @file Logger.nut This file is part of the IdleTTD game script for OpenTTD and contains Logger class
*/

require("constants.nut");

/**
    @class Logger

    @brief      Class that handles all logging in IdleTTD
    @details    Class contains static methods for logging messages of various log levels. Checks game script setting @ref config_sec "log_level" to determine whether given log level is allowed. For info about all log levels available check out #ScriptLogLevels enum.
*/ 
class Logger {
    
    /**
        @property _NestedPrependString
        @static

        @brief      String that gets prepended to children of arrays / tables
        @details    String that gets prepended to all log messages when logging arrays or tables recursively
	*/
    static _NestedPrependString = "  .  ";

    /**
        \privatesection
    */

    /**
        @static
        @brief                  Checks if given log level is enabled
        @details                Checks given log level against @ref config_sec "log_level" game script setting and returns the result. For info about all log levels available check out #ScriptLogLevels enum.

        @param      logLevel    Log level to check for

        @returns    bool
        @retval     true        Message can be logged
        @retval     false       Message can not be logged
    */
    static function _CanLog(logLevel = ScriptLogLevels.LOG_LEVEL_NONE) {
        local LogLevelSetting = GSController.GetSetting("log_level");
        if (LogLevelSetting >= logLevel) {
            return true;
        }
        return false;
    }

    /**
        @static
        @brief              Logs message with custom level
        @details            If @ref config_sec "log_level" game string setting allows, logs the message to the console with custom logLevel.
        
        @param  logLevel    Log level
        @param  message     Message to log

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
        \publicsection
    */

    /**
        @static
        @brief          Logs verbose message
        @details        If @ref config_sec "log_level" game string setting is equal to or lower than [LOG_LEVEL_VERBOSE](#ScriptLogLevels.LOG_LEVEL_VERBOSE) message will be logged to the console.

        @param  message Message to log

        @returns void
    */
    static function Verbose(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_VERBOSE)) {
            GSLog.Info(message);
        }
    }

    /**
        @static
        @brief          Logs debug message
        @details        If @ref config_sec "log_level" game string setting is equal to or lower than [LOG_LEVEL_DEBUG](#ScriptLogLevels.LOG_LEVEL_DEBUG) message will be logged to the console.

        @param  message Message to log

        @returns void
    */
    static function Debug(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_DEBUG)) {
            GSLog.Info(message);
        }
    }

    /**
        @static
        @brief          Logs info message
        @details        If @ref config_sec "log_level" game string setting is equal to or lower than [LOG_LEVEL_INFO](#ScriptLogLevels.LOG_LEVEL_INFO) message will be logged to the console.

        @param  message Message to log

        @returns void
    */
    static function Info(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_INFO)) {
            GSLog.Info(message);
        }
    }

    /**
        @static
        @brief          Logs warning message
        @details        If @ref config_sec "log_level" game string setting is equal to or lower than [LOG_LEVEL_WARNING](#ScriptLogLevels.LOG_LEVEL_WARNING) message will be logged to the console.

        @param  message Message to log

        @returns void
    */
    static function Warning(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_WARNING)) {
            GSLog.Warning(message);
        }
    }

    /**
        @static
        @brief          Logs error message
        @details        If @ref config_sec "log_level" game string setting is equal to or lower than [LOG_LEVEL_ERROR](#ScriptLogLevels.LOG_LEVEL_ERROR) message will be logged to the console.

        @param  message Message to log
        
        @returns void
    */
    static function Error(message) {
        if (Logger._CanLog(ScriptLogLevels.LOG_LEVEL_ERROR)) {
            GSLog.Error(message);
        }
    }
        
  

    /**
        @static
        @brief                      Logs tables and arrays
        @details                    Dumps table or array recursively by logging a message for each of their members.

        @param tableToLog           Table or array to log
        @param tableIdentifier      Text used to identify table dump in the log
        @param logLevel             Log level (see #ScriptLogLevels for list)
        @param prependText          Optional string to prependText to log messages (indenting)
        @param skipIdentifer        Optional flag to prevent logging messages with identifier before and after dumping the data

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
        @static
        @brief                      Logs a particular table (or array) member
        @details                    Logs a line for each table or array member. If the member itself is an array or table, all its children will be logged recursively.

        @param memberKey            Table member key
        @param memberValue          Member value
        @param logLevel             Log level (see #ScriptLogLevels for list)
        @param prependText          String to prepend to log messages (used for indentation when logging child members). Empty string is used as default if nothing is passed.

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