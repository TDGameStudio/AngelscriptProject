using UnrealBuildTool;

[SupportedPlatforms(UnrealPlatformClass.Desktop)]
public class AngelscriptDebuggerTarget : TargetRules
{
	public AngelscriptDebuggerTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		bExplicitTargetForType = true;
		bGenerateProgramProject = true;
		BuildEnvironment = TargetBuildEnvironment.Shared;
		LinkType = TargetLinkType.Modular;
		LaunchModuleName = "AngelscriptDebugger";

		DefaultBuildSettings = BuildSettingsVersion.Latest;
		IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
		bAllowEnginePluginsEnabledByDefault = false;
		bOverrideBuildEnvironment = true;
		bWithLiveCoding = false;

		bIsBuildingConsoleApplication = false;
		bBuildAdditionalConsoleApp = false;
		bUsesSteam = false;

		string BaseExeName = "AngelscriptDebugger";
		OutputFile = "Binaries/" + Platform.ToString() + "/" + BaseExeName;
		if (Configuration != UndecoratedConfiguration)
		{
			OutputFile += "-" + Platform.ToString() + "-" + Configuration.ToString();
		}
		if (Platform == UnrealTargetPlatform.Win64)
		{
			OutputFile += ".exe";
			PostBuildSteps.Add("if exist \"$(ProjectDir)\\Plugins\\Angelscript\\Binaries\\Win64\\UnrealEditor-AngelscriptDebugProtocol.dll\" copy /Y \"$(ProjectDir)\\Plugins\\Angelscript\\Binaries\\Win64\\UnrealEditor-AngelscriptDebugProtocol.dll\" \"$(EngineDir)\\Binaries\\Win64\\UnrealEditor-AngelscriptDebugProtocol.dll\"");
			PostBuildSteps.Add("if exist \"$(ProjectDir)\\Plugins\\Angelscript\\Binaries\\Win64\\UnrealEditor-AngelscriptSyntax.dll\" copy /Y \"$(ProjectDir)\\Plugins\\Angelscript\\Binaries\\Win64\\UnrealEditor-AngelscriptSyntax.dll\" \"$(EngineDir)\\Binaries\\Win64\\UnrealEditor-AngelscriptSyntax.dll\"");
			PostBuildSteps.Add("if exist \"$(ProjectDir)\\Binaries\\Win64\\AngelscriptDebugger.target\" copy /Y \"$(ProjectDir)\\Binaries\\Win64\\AngelscriptDebugger.target\" \"$(EngineDir)\\Binaries\\Win64\\AngelscriptDebugger.target\"");
		}
	}
}
