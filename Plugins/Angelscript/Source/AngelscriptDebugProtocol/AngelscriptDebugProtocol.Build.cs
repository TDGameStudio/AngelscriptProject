using UnrealBuildTool;

namespace UnrealBuildTool.Rules
{
	public class AngelscriptDebugProtocol : ModuleRules
	{
		public AngelscriptDebugProtocol(ReadOnlyTargetRules Target) : base(Target)
		{
			PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

			PublicIncludePaths.Add(ModuleDirectory);

			PublicDependencyModuleNames.AddRange(new string[]
			{
				"Core",
			});
		}
	}
}
