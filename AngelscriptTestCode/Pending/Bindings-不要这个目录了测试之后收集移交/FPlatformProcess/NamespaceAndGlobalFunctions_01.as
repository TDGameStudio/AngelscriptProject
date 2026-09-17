/**
 * @version v1
 * @summary Observe platform directory and executable identity helpers plus LaunchURL overloads. Directory helpers are DefaultSafe. LaunchURL is SubprocessOnly and is not default-executable.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe platform directory and executable identity helpers plus LaunchURL overloads. Directory helpers are DefaultSafe. LaunchURL is SubprocessOnly and is not default-executable.
 * @topic Baseline
 */
// FString Path = FPlatformProcess::UserSettingsDir();
// FString Path = FPlatformProcess::UserTempDir();
// FString Path = FPlatformProcess::ApplicationSettingsDir();
// FString Path = FPlatformProcess::ExecutablePath();
// FString Name = FPlatformProcess::ExecutableName();
// FString Path = FPlatformProcess::CurrentWorkingDirectory();
// FPlatformProcess::LaunchURL(const FString& URL, const FString& Params = FString());
// FPlatformProcess::LaunchURL(const FString& URL, const FString& Params, FString& OutError);
// FString Name = FPlatformProcess::ComputerName();
// Inputs: Live process directories. LaunchURL requires bAllowLaunch=true.
// Empty URL/Params as the default launch arguments; invalid URL for OutError.
// Expected observations: Directory and identity helpers return non-empty
// strings. LaunchURL with empty URL returns. OutError is written on the
// diagnostic path.
// Boundary/ownership: Directory helpers return new FStrings. LaunchURL
// borrows URL/Params. OutError is written in place. Missing allow-flag is
// setup failure.

namespace TS_FPlatformProcess_NamespaceAndGlobalFunctions_01
{
	bool Observe_UserDir_Nominal()
	{
		return FPlatformProcess::UserDir().Len() > 0;
	}

	bool Observe_UserSettingsDir_Nominal()
	{
		return FPlatformProcess::UserSettingsDir().Len() > 0;
	}

	bool Observe_UserTempDir_Nominal()
	{
		return FPlatformProcess::UserTempDir().Len() > 0;
	}

	bool Observe_ApplicationSettingsDir_Nominal()
	{
		return FPlatformProcess::ApplicationSettingsDir().Len() > 0;
	}

	bool Observe_ExecutablePath_Nominal()
	{
		return FPlatformProcess::ExecutablePath().Len() > 0;
	}

	bool Observe_ExecutableName_Nominal()
	{
		return FPlatformProcess::ExecutableName().Len() > 0;
	}

	bool Observe_CurrentWorkingDirectory_Nominal()
	{
		return FPlatformProcess::CurrentWorkingDirectory().Len() > 0;
	}

	bool Observe_LaunchURL_Nominal(bool bAllowLaunch)
	{
		if (!bAllowLaunch)
		{
			throw("TS_FPlatformProcess_NamespaceAndGlobalFunctions_01 setup: LaunchURL requires SubprocessOnly host");
		}
		FString EmptyUrl;
		FString EmptyParams;
		FPlatformProcess::LaunchURL(EmptyUrl);
		FPlatformProcess::LaunchURL(EmptyUrl, EmptyParams);
		FString OutError = "Sentinel";
		FPlatformProcess::LaunchURL(EmptyUrl, EmptyParams, OutError);
		return OutError != "Sentinel";
	}

	bool Observe_ComputerName_Nominal()
	{
		return FPlatformProcess::ComputerName().Len() > 0;
	}

	void ExerciseExpectedFailure()
	{
		FString OutError;
		FPlatformProcess::LaunchURL("not-a-protocol://invalid", "", OutError);
	}
}
/** @end */
