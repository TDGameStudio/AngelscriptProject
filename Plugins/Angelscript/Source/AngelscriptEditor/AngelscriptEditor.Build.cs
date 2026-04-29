using System.IO;
using UnrealBuildTool;

namespace UnrealBuildTool.Rules
{
	public class AngelscriptEditor : ModuleRules
	{
		public AngelscriptEditor(ReadOnlyTargetRules Target) : base(Target)
		{
			PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
			bUseUnity = false;

			PublicIncludePaths.Add(ModuleDirectory);
			PrivateIncludePaths.Add(ModuleDirectory);

			PublicDependencyModuleNames.AddRange(new string[]
			{
				"Core",
				"CoreUObject",
				"Engine",
				"UnrealEd",
				"EditorSubsystem",
				"AngelscriptRuntime",
				"BlueprintGraph",
				"Kismet",
				"DirectoryWatcher",
				"Slate",
				"SlateCore",
				"AssetTools",
            });

			PrivateDependencyModuleNames.AddRange(new string[]
			{
				"Projects",
				"GameplayAbilities",
				"GameplayTags",
				"Settings",
				"InputCore",
				"LevelEditor",
				"PlacementMode",
				"PropertyEditor",
				"ContentBrowser",
				"ContentBrowserData",
				"ToolMenus",
				"ToolWidgets",
            });
		}
	}
}
