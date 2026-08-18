// @angelscript-jit-scaffold revision=2 kind=build-rules
using UnrealBuildTool;

public class AngelscriptJIT : ModuleRules
{
	public AngelscriptJIT(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
		bUseUnity = false;
		if (Target.bBuildEditor)
		{
			PrivateDefinitions.Add("AS_ENABLE_EDITOR_JITTED_CODE=1");
		}
		PublicDependencyModuleNames.AddRange(new string[]
		{
			"Core",
			"AngelscriptRuntime",
		});
	}
}
