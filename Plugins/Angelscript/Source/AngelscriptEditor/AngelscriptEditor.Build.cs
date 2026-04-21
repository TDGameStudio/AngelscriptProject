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
