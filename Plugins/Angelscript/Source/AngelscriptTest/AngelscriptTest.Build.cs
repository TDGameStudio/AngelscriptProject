using System.IO;
using UnrealBuildTool;

namespace UnrealBuildTool.Rules
{
	public class AngelscriptTest : ModuleRules
	{
		public AngelscriptTest(ReadOnlyTargetRules Target) : base(Target)
		{
			PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
			bUseUnity = false;

			// Module root + subdirectories mirroring AngelscriptRuntime layout
			PublicIncludePaths.Add(ModuleDirectory);
			PrivateIncludePaths.Add(ModuleDirectory);
			PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Core"));
			PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Debugger"));
			PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Dump"));
			PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Internals"));
			PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Native"));
			PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "Preprocessor"));
			PrivateIncludePaths.Add(Path.Combine(ModuleDirectory, "ClassGenerator"));

			PublicDependencyModuleNames.AddRange(new string[]
			{
				"Core",
				"CoreUObject",
				"Engine",
				"GameplayAbilities",
				"GameplayTasks",
				"GameplayTags",
				"Json",
				"JsonUtilities",
				"AngelscriptRuntime",
			});

			PrivateDependencyModuleNames.AddRange(new string[]
			{
				"AIModule",
				"UMG",
			});

			if (Target.bBuildEditor)
			{
				PrivateDependencyModuleNames.AddRange(new string[]
				{
					"BlueprintGraph",
					"CQTest",
					"Networking",
					"Sockets",
					"UnrealEd",
					"AngelscriptEditor",
				});
			}
		}
	}
}
