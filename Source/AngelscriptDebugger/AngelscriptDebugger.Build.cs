using UnrealBuildTool;

public class AngelscriptDebugger : ModuleRules
{
	public AngelscriptDebugger(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PrivateDependencyModuleNames.AddRange(new string[]
		{
			"ApplicationCore",
			"AssetRegistry",
			"AngelscriptDebugProtocol",
			"AngelscriptSyntax",
			"Core",
			"CoreUObject",
			"DerivedDataCache",
			"DesktopPlatform",
			"Engine",
			"InputCore",
			"InstallBundleManager",
			"MediaUtils",
			"Messaging",
			"MoviePlayer",
			"MoviePlayerProxy",
			"Networking",
			"PIEPreviewDeviceProfileSelector",
			"PreLoadScreen",
			"ProfileVisualizer",
			"PropertyEditor",
			"Projects",
			"RenderCore",
			"RHI",
			"Sockets",
			"Slate",
			"SlateCore",
			"StandaloneRenderer",
			"ToolWidgets",
			"TraceLog",
			"UnrealEd",
		});

		if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			PrivateDependencyModuleNames.Add("AgilitySDK");

			RuntimeDependencies.Add(
				"$(TargetOutputDir)/UnrealEditor-AngelscriptDebugProtocol.dll",
				"$(ProjectDir)/Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptDebugProtocol.dll",
				StagedFileType.NonUFS);

			RuntimeDependencies.Add(
				"$(TargetOutputDir)/UnrealEditor-AngelscriptSyntax.dll",
				"$(ProjectDir)/Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptSyntax.dll",
				StagedFileType.NonUFS);
		}

		PrivateIncludePathModuleNames.AddRange(new string[]
		{
			"Launch",
			"AutomationWorker",
			"AutomationController",
			"AutomationTest",
			"DerivedDataCache",
			"HeadMountedDisplay",
			"MRMesh",
			"SlateNullRenderer",
			"SlateRHIRenderer",
		});
	}
}
