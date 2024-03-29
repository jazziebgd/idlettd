/**
	@file info.nut OpenTTD game script info file for IdleTTD
*/

require("version.nut");
require("constants.nut");

/**
	@class FMainClass
	@hideinheritancegraph
	@brief IdleTTD game script info class.
	@details GSInfo instance for IdleTTD game script. Check out <a href="https://docs.openttd.org/gs-api/classGSInfo" target="_blank">GSInfo</a> docs for more details.
*/
class FMainClass extends GSInfo {

	/**
		@brief Returns author name
	 	@returns string
	 */
	function GetAuthor() {
		return "jazziettd";
	}

	/**
		@brief Returns game script name
		@returns string
	 */
	function GetName() {
		return "IdleTTD";
	}

	/**
		@brief Returns game script description
		@returns string
	 */
	function GetDescription() {
		return "Enables your company to earn money while you sleep.";
	}

	/**
		@brief Returns game script version
		@see SELF_VERSION
		@returns int     Game script version

	 */
	function GetVersion() {
		return SELF_VERSION;
	}

	/**
		@brief Returns minimum game script version that can be loaded (relies on #ScriptMinVersionToLoad from constants.nut file)
		@see ScriptMinVersionToLoad
		@returns int     Min game script version
	 */
	function MinVersionToLoad() {
		return ::ScriptMinVersionToLoad;
	}
	/**
		@brief Returns game script last update date (relies on #ScriptLastUpdateDate from constants.nut file)
		@see ScriptLastUpdateDate
		@returns string
	 */
	function GetDate() {
		return ::ScriptLastUpdateDate;
	}

	/**
		@brief Checks if script is developer only
		@returns bool
	 */
	 function IsDeveloperOnly() {
		return false;
	}

	/**
		@brief Returns game script main class name
		@returns string
	 */
	function CreateInstance() {
		return "MainClass";
	}

	/**
		@brief Returns game script short name
		@returns string
	 */
	 function GetShortName() {
		return "idle";
	}

	/**
		@brief Returns game script compatible API version
		@returns string
	 */
	function GetAPIVersion() {
		return "13";
	}

	/**
		@brief Returns game script home page URL
		@returns string
	 */
	function GetURL() {
		return "https://github.com/jazziebgd/idlettd";
	}

	/**
		@brief Initializes game script settings:
		@returns void
	 */
	function GetSettings(){
		AddSetting({
			name = "idle_multiplier",
			description = "Idle income multiplier",
			easy_value = 2,
			medium_value = 2,
			hard_value = 2,
			custom_value = 2,
			flags = CONFIG_NONE,
			min_value = 1,
			max_value = 10
		});

		AddLabels("idle_multiplier", {
			_1 = "0.1%",
			_2 = "0.2%",
			_3 = "0.3%",
			_4 = "0.4%",
			_5 = "0.5%",
			_6 = "0.6%",
			_7 = "0.7%",
			_8 = "0.8%",
			_9 = "0.9%",
			_10 = "1%",
		});

		AddSetting({
			name = "show_intro",
			description = "Show intro when new game starts",
			easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1,
			flags = CONFIG_NONE | CONFIG_BOOLEAN
		});

		AddSetting({
			name = "show_news",
			description = "Show news when bank account gets updated",
			easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1,
			flags = CONFIG_NONE | CONFIG_BOOLEAN
		});

		AddSetting({
			name = "day_interval",
		 	// description = "Tune script performance by delaying each iteratn by",
		 	description = "Performance tuning - run script",
		 	easy_value = 1,
		 	medium_value = 1,
		 	hard_value = 1,
		 	custom_value = 1,
			flags = CONFIG_INGAME,
			min_value = 1,
			max_value = 7
		});

		AddLabels("day_interval", {
			// one day ~ 74 ticks
			_1 = "daily (best experience)",
			_2 = "every 2 days",
			_3 = "every 3 days",
			_4 = "every 4 days",
			_5 = "every 5 days",
			_6 = "every 6 days",
			_7 = "weekly (best performance, worst experience)",
		});


		// developer settings
		AddSetting({
			name = "idle_enabled",
			description = "[DEV] Enable IdleTTD",
			easy_value = 1, medium_value = 1, hard_value = 1, custom_value = 1,
			flags = CONFIG_DEVELOPER | CONFIG_NONE | CONFIG_BOOLEAN
		});

		AddSetting({
			name = "show_story_debug",
			description = "[DEV] Show debug info on story pages",
			easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0,
			flags = CONFIG_DEVELOPER | CONFIG_INGAME | CONFIG_BOOLEAN
		});

		AddSetting({
			name = "ignore_hq",
			description = "[DEV] Don't check for Company HQ",
			easy_value = 0, medium_value = 0, hard_value = 0, custom_value = 0,
			flags = CONFIG_DEVELOPER | CONFIG_INGAME | CONFIG_BOOLEAN
		});

		AddSetting(
			{
				name = "log_level",
				description = "[DEV] Logging level",
				easy_value = 2,
				medium_value = 2,
				hard_value = 2,
				custom_value = 2,
				flags = CONFIG_DEVELOPER | CONFIG_INGAME,
				min_value = 0,
				max_value = 5
			}
		);

		AddLabels("log_level",
			{
				_0 = "None",
				_1 = "Error",
				_2 = "Warning",
				_3 = "Info",
				_4 = "Debug",
				_5 = "Verbose",
			}
		);
	}
}

/// \privatesection
RegisterGS(FMainClass());
/// \publicsection