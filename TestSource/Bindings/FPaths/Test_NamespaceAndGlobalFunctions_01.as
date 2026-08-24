// Purpose: Observe engine, launch, and project directory helpers plus
// CombinePaths joining fragments.
// AS-facing API: FString FPaths::RootDir(); FString FPaths::LaunchDir();
// FString FPaths::CombinePaths(const FString& FirstPath, const FString& SecondPath);
// FString FPaths::EngineDir(); FString FPaths::EngineContentDir();
// FString FPaths::EngineConfigDir(); FString FPaths::EngineEditorSettingsDir();
// FString FPaths::EngineIntermediateDir(); FString FPaths::EngineSavedDir();
// FString FPaths::ProjectDir();
// Inputs: Empty second fragment for CombinePaths, "Script/Test.as" as a
// relative second path, and the live engine/project directories.
// Expected observations: Every directory helper returns a non-empty path.
// CombinePaths joins ProjectDir with a relative fragment. Combining with
// empty SecondPath still returns FirstPath content.
// Boundary/ownership: Each helper returns a new FString except where noted
// elsewhere. Directory strings are snapshots, not owned mounts.

namespace TS_FPaths_NamespaceAndGlobalFunctions_01
{
	bool Observe_RootDir_Nominal()
	{
		return FPaths::RootDir().Len() > 0;
	}

	bool Observe_LaunchDir_Nominal()
	{
		return FPaths::LaunchDir().Len() > 0;
	}

	bool Observe_CombinePaths_Nominal()
	{
		FString Combined = FPaths::CombinePaths(FPaths::ProjectDir(), "Script/Test.as");
		FString WithEmpty = FPaths::CombinePaths(FPaths::ProjectDir(), "");
		FString EmptyFirst = FPaths::CombinePaths("", "Script/Test.as");
		bool bJoinedContainsScript = Combined.Contains("Script") && Combined.Contains("Test.as");
		bool bEmptySecondKeepsFirst = WithEmpty.Len() > 0;
		bool bEmptyFirstKeepsSecond = EmptyFirst.Contains("Test.as");
		return bJoinedContainsScript && bEmptySecondKeepsFirst && bEmptyFirstKeepsSecond;
	}

	bool Observe_EngineDir_Nominal()
	{
		return FPaths::EngineDir().Len() > 0;
	}

	bool Observe_EngineContentDir_Nominal()
	{
		FString Content = FPaths::EngineContentDir();
		return Content.Len() > 0 && Content.Contains("Content");
	}

	bool Observe_EngineConfigDir_Nominal()
	{
		return FPaths::EngineConfigDir().Len() > 0;
	}

	bool Observe_EngineEditorSettingsDir_Nominal()
	{
		return FPaths::EngineEditorSettingsDir().Len() > 0;
	}

	bool Observe_EngineIntermediateDir_Nominal()
	{
		return FPaths::EngineIntermediateDir().Len() > 0;
	}

	bool Observe_EngineSavedDir_Nominal()
	{
		return FPaths::EngineSavedDir().Len() > 0;
	}

	bool Observe_ProjectDir_Nominal()
	{
		return FPaths::ProjectDir().Len() > 0;
	}
}
