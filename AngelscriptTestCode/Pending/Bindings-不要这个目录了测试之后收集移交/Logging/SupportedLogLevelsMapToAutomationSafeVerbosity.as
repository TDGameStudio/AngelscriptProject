/**
 * @version v1
 * @summary The supported log-level wrappers route each severity to an automation-safe verbosity: Log, LogInfo, LogDisplay, Warning, and Error, each with a plain message form and a category-tagged form. Emission has no return value.
 * @topic Bindings
 */
/**
 * @version root
 * @summary The supported log-level wrappers route each severity to an automation-safe verbosity: Log, LogInfo, LogDisplay, Warning, and Error, each with a plain message form and a category-tagged form. Emission has no return value.
 * @topic Baseline
 */
namespace LoggingTest
{
	/**
	 * Observe that every supported log level emits, in both the plain message
	 * form and the category-tagged form.
	 *
	 * @Kind Observe
	 * @Covers Logging.Log
	 * @Inputs Log, LogInfo, LogDisplay, Warning, Error; then the same with a category
	 * @Return true when all ten emissions complete without throwing
	 */
	UFUNCTION()
	bool EmitSupportedLogLevels()
	{
		Log("CoverageSeverity_Log");
		LogInfo("CoverageSeverity_Info");
		LogDisplay("CoverageSeverity_Display");
		Warning("CoverageSeverity_Warning");
		Error("CoverageLogLevel_Error");

		Log(n"CoverageSeverityCategory", "CoverageSeverity_CategoryLog");
		LogInfo(n"CoverageSeverityCategory", "CoverageSeverity_CategoryInfo");
		LogDisplay(n"CoverageSeverityCategory", "CoverageSeverity_CategoryDisplay");
		Warning(n"CoverageSeverityCategory", "CoverageSeverity_CategoryWarning");
		Error(n"CoverageCustomCategory", "CoverageCategory_Error");

		return true;
	}

	/**
	 * Observe that repeated emission is stable: the second pass reaches every
	 * level the same way the first did.
	 *
	 * @Kind Observe
	 * @Covers Logging.Log
	 * @Inputs Two consecutive passes over every supported level
	 * @Return true when both passes complete without throwing
	 */
	UFUNCTION()
	bool EmitSupportedLogLevelsRepeated()
	{
		if (!EmitSupportedLogLevels())
		{
			return false;
		}
		return EmitSupportedLogLevels();
	}

	/**
	 * Observe the plain message form on its own: each level accepts a message
	 * with no category.
	 *
	 * @Kind Observe
	 * @Covers Logging.Log
	 * @Inputs Log, LogInfo, LogDisplay, Warning, Error with plain messages
	 * @Return true when all five emissions complete without throwing
	 */
	UFUNCTION()
	bool EmitPlainLogLevels()
	{
		Log("CoveragePlain_Log");
		LogInfo("CoveragePlain_Info");
		LogDisplay("CoveragePlain_Display");
		Warning("CoveragePlain_Warning");
		Error("CoveragePlain_Error");
		return true;
	}

	/**
	 * Observe the category-tagged form on its own: each level accepts a
	 * category alongside the message.
	 *
	 * @Kind Observe
	 * @Covers Logging.Log
	 * @Inputs Log, LogInfo, LogDisplay, Warning, Error with a category
	 * @Return true when all five emissions complete without throwing
	 */
	UFUNCTION()
	bool EmitCategoryLogLevels()
	{
		Log(n"CoveragePlainCategory", "CoverageCategory_Log");
		LogInfo(n"CoveragePlainCategory", "CoverageCategory_Info");
		LogDisplay(n"CoveragePlainCategory", "CoverageCategory_Display");
		Warning(n"CoveragePlainCategory", "CoverageCategory_Warning");
		Error(n"CoveragePlainCategory", "CoverageCategory_Error");
		return true;
	}

	/**
	 * In-only: emit at a level named by a const&in category and message.
	 *
	 * @Kind RoundTrip
	 * @Covers Logging.Log
	 * @Param Category Name received as const FName&in, used as the log category
	 * @Param Message Text received as const FString&in, used as the log message
	 * @Inputs A category name and a message string
	 * @Return true when the tagged emission completes without throwing
	 */
	UFUNCTION()
	bool EmitTagged(const FName&in Category, const FString&in Message)
	{
		Log(Category, Message);
		return true;
	}

	/**
	 * Out-only: emit and report the level that was used.
	 *
	 * @Kind RoundTrip
	 * @Covers Logging.Log
	 * @Param Level Destination received as FString&out
	 * @Inputs Empty &out FString
	 * @Return void; Level names the severity that was emitted
	 */
	UFUNCTION()
	void EmitAndReportLevel(FString&out Level)
	{
		Warning("CoverageOutParam_Warning");
		Level = "Warning";
	}

	/**
	 * Inout: emit once per entry in a list of messages supplied by the caller.
	 *
	 * @Kind RoundTrip
	 * @Covers Logging.Log
	 * @Param Messages Array received as TArray<FString>&inout, each entry logged
	 * @Inputs Messages holds one or more message strings
	 * @Return void; every entry has been emitted
	 */
	UFUNCTION()
	void EmitEachMessage(TArray<FString>&inout Messages)
	{
		for (int Index = 0; Index < Messages.Num(); ++Index)
		{
			Log(Messages[Index]);
		}
	}
}
/** @end */
