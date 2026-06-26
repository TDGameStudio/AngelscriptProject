using UnrealBuildTool;

public class AngelscriptProjectTest : ModuleRules
{
	public AngelscriptProjectTest(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[]
		{
			"Core",
			"CoreUObject",
			"Engine",
		});

		PrivateDependencyModuleNames.AddRange(new string[]
		{
			"AngelscriptRuntime",
		});

		if (Target.bBuildEditor)
		{
			PrivateDependencyModuleNames.AddRange(new string[]
			{
				"AngelscriptTest",
				"BlueprintGraph",
				"ClassViewer",
				"CQTest",
				"UnrealEd",
				"AngelscriptEditor",
			});
		}
	}
}
