/**
 * @version v1
 * @summary FPlatformProcess host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FPlatformProcess
 *
 * user-dir
 * user-settings-dir
 * user-temp-dir
 * application-settings-dir
 * executable-path
 * executable-name
 * current-working-directory
 * launch-url
 * computer-name
 * user-name
 * game-bundle-id
 * can-launch-url
 */
/**
 * @begin user-dir
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveUserDirNominal
 * @summary setup failure.
 * @covers FPlatformProcess.user-dir
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUserDirNominal()
{
	return FPlatformProcess::UserDir().Len() > 0;
}
/** @end */
/**
 * @begin user-settings-dir
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveUserSettingsDirNominal
 * @summary setup failure.
 * @covers FPlatformProcess.user-settings-dir
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUserSettingsDirNominal()
{
	return FPlatformProcess::UserSettingsDir().Len() > 0;
}
/** @end */
/**
 * @begin user-temp-dir
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveUserTempDirNominal
 * @summary setup failure.
 * @covers FPlatformProcess.user-temp-dir
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUserTempDirNominal()
{
	return FPlatformProcess::UserTempDir().Len() > 0;
}
/** @end */
/**
 * @begin application-settings-dir
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveApplicationSettingsDirNominal
 * @summary setup failure.
 * @covers FPlatformProcess.application-settings-dir
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveApplicationSettingsDirNominal()
{
	return FPlatformProcess::ApplicationSettingsDir().Len() > 0;
}
/** @end */
/**
 * @begin executable-path
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveExecutablePathNominal
 * @summary setup failure.
 * @covers FPlatformProcess.executable-path
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExecutablePathNominal()
{
	return FPlatformProcess::ExecutablePath().Len() > 0;
}
/** @end */
/**
 * @begin executable-name
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveExecutableNameNominal
 * @summary setup failure.
 * @covers FPlatformProcess.executable-name
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExecutableNameNominal()
{
	return FPlatformProcess::ExecutableName().Len() > 0;
}
/** @end */
/**
 * @begin current-working-directory
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveCurrentWorkingDirectoryNominal
 * @summary setup failure.
 * @covers FPlatformProcess.current-working-directory
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCurrentWorkingDirectoryNominal()
{
	return FPlatformProcess::CurrentWorkingDirectory().Len() > 0;
}
/** @end */
/**
 * @begin launch-url
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveLaunchURLNominal
 * @summary setup failure.
 * @covers FPlatformProcess.launch-url
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLaunchURLNominal(bool bAllowLaunch)
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
/** @end */
/**
 * @begin computer-name
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveComputerNameNominal
 * @summary setup failure.
 * @covers FPlatformProcess.computer-name
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComputerNameNominal()
{
	return FPlatformProcess::ComputerName().Len() > 0;
}
/** @end */
/**
 * @begin user-name
 * @summary own OS identity.
 * @topic Unreal
 */
/**
 * @function ObserveUserNameNominal
 * @summary own OS identity.
 * @covers FPlatformProcess.user-name
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUserNameNominal()
{
	FString Empty;
	FString Name = FPlatformProcess::UserName();
	return Name.Len() > 0 && Empty.IsEmpty();
}
/** @end */
/**
 * @begin game-bundle-id
 * @summary own OS identity.
 * @topic Unreal
 */
/**
 * @function ObserveGameBundleIdNominal
 * @summary own OS identity.
 * @covers FPlatformProcess.game-bundle-id
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGameBundleIdNominal()
{
	FString Empty;
	FString Id = FPlatformProcess::GameBundleId();
	FString Again = FPlatformProcess::GameBundleId();
	return Id == Again && Empty.IsEmpty();
}
/** @end */
/**
 * @begin can-launch-url
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveCanLaunchURLNominal
 * @summary borrowed.
 * @covers FPlatformProcess.can-launch-url
 * @inputs FPlatformProcess values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCanLaunchURLNominal()
{
	bool bHttps = FPlatformProcess::CanLaunchURL("https://example.com");
	bool bEmpty = FPlatformProcess::CanLaunchURL("");
	bool bInvalid = FPlatformProcess::CanLaunchURL("not-a-protocol");
	return bHttps && !bEmpty && !bInvalid;
}
/** @end */
