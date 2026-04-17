#include "AngelscriptEngine.h"

#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_FileSystem_AngelscriptScriptRootDiscoveryTests_Private
{
	FString NormalizeDiscoveryPath(const FString& InPath)
	{
		FString Normalized = InPath;
		FPaths::NormalizeFilename(Normalized);
		Normalized.ReplaceInline(TEXT("\\"), TEXT("/"));
		return Normalized;
	}

	TArray<FString> MakeScriptRootsForTest(
		const FAngelscriptEngineConfig& Config,
		const FAngelscriptEngineDependencies& Dependencies,
		const bool bOnlyProjectRoot)
	{
		FAngelscriptEngine TemporaryEngine(Config, Dependencies);
		return TemporaryEngine.DiscoverScriptRoots(bOnlyProjectRoot);
	}

	bool TestRootSequence(
		FAutomationTestBase& Test,
		const FString& Context,
		const TArray<FString>& Actual,
		const TArray<FString>& Expected)
	{
		bool bPassed = Test.TestEqual(
			*FString::Printf(TEXT("%s should keep the expected root count"), *Context),
			Actual.Num(),
			Expected.Num());
		if (Actual.Num() != Expected.Num())
		{
			return false;
		}

		for (int32 Index = 0; Index < Expected.Num(); ++Index)
		{
			bPassed &= Test.TestEqual(
				*FString::Printf(TEXT("%s should keep root index %d stable"), *Context, Index),
				Actual[Index],
				Expected[Index]);
		}

		return bPassed;
	}
}

using namespace AngelscriptTest_FileSystem_AngelscriptScriptRootDiscoveryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptRootDiscoveryProjectRootFirstAndPluginRootsDedupedTest,
	"Angelscript.TestModule.FileSystem.RootDiscovery.ProjectRootFirstAndPluginRootsDeduped",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptRootDiscoveryProjectRootFirstAndPluginRootsDedupedTest::RunTest(const FString& Parameters)
{
	const FString ProjectDir = NormalizeDiscoveryPath(TEXT("J:/VirtualProject"));
	const FString ProjectScriptRoot = NormalizeDiscoveryPath(ProjectDir / TEXT("Script"));
	const FString PluginBetaRoot = NormalizeDiscoveryPath(TEXT("J:/VirtualProject/Plugins/Beta/Script"));
	const FString PluginAlphaRoot = NormalizeDiscoveryPath(TEXT("J:/VirtualProject/Plugins/Alpha/Script"));
	const FString MissingPluginRoot = NormalizeDiscoveryPath(TEXT("J:/VirtualProject/Plugins/Missing/Script"));

	int32 PluginRootQueryCount = 0;
	TArray<FString> DirectoryExistQueries;
	TArray<FString> MadeDirectories;
	const TSet<FString> ExistingRoots = {ProjectScriptRoot, PluginAlphaRoot, PluginBetaRoot};

	FAngelscriptEngineConfig Config;
	Config.bIsEditor = true;

	FAngelscriptEngineDependencies Dependencies;
	Dependencies.GetProjectDir = [ProjectDir]()
	{
		return ProjectDir;
	};
	Dependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return NormalizeDiscoveryPath(Path);
	};
	Dependencies.DirectoryExists = [&DirectoryExistQueries, ExistingRoots](const FString& Path) mutable
	{
		const FString Normalized = NormalizeDiscoveryPath(Path);
		DirectoryExistQueries.Add(Normalized);
		return ExistingRoots.Contains(Normalized);
	};
	Dependencies.MakeDirectory = [&MadeDirectories](const FString& Path, const bool bTree) mutable
	{
		MadeDirectories.Add(NormalizeDiscoveryPath(Path));
		return true;
	};
	Dependencies.GetEnabledPluginScriptRoots = [&PluginRootQueryCount, PluginBetaRoot, ProjectScriptRoot, MissingPluginRoot, PluginAlphaRoot]() mutable
	{
		++PluginRootQueryCount;
		return TArray<FString>{PluginBetaRoot, ProjectScriptRoot, MissingPluginRoot, PluginAlphaRoot};
	};

	const TArray<FString> DiscoveredRoots = MakeScriptRootsForTest(Config, Dependencies, false);
	const TArray<FString> ProjectOnlyRoots = MakeScriptRootsForTest(Config, Dependencies, true);
	const TArray<FString> WrappedRoots = MakeScriptRootsForTest(Config, Dependencies, false);
	const TArray<FString> ExpectedDiscoveredRoots = {ProjectScriptRoot, PluginAlphaRoot, PluginBetaRoot};

	bool bPassed = true;
	bPassed &= TestRootSequence(*this, TEXT("DiscoverScriptRoots(false)"), DiscoveredRoots, ExpectedDiscoveredRoots);
	bPassed &= TestRootSequence(*this, TEXT("DiscoverScriptRoots(true)"), ProjectOnlyRoots, {ProjectScriptRoot});
	bPassed &= TestRootSequence(*this, TEXT("Equivalent wrapper root discovery"), WrappedRoots, ExpectedDiscoveredRoots);
	bPassed &= TestEqual(
		TEXT("Project root should only appear once even if plugins report the same path"),
		DiscoveredRoots.FilterByPredicate([&ProjectScriptRoot](const FString& Root) { return Root == ProjectScriptRoot; }).Num(),
		1);
	bPassed &= TestFalse(
		TEXT("Missing plugin roots should be filtered out of discovery"),
		DiscoveredRoots.Contains(MissingPluginRoot));
	bPassed &= TestTrue(
		TEXT("Existing project root should not trigger directory creation in editor mode"),
		MadeDirectories.IsEmpty());
	bPassed &= TestEqual(
		TEXT("Plugin root provider should only be queried for the two non-project-only discovery calls"),
		PluginRootQueryCount,
		2);
	bPassed &= TestTrue(
		TEXT("DirectoryExists should consult project and plugin roots during discovery"),
		DirectoryExistQueries.Contains(ProjectScriptRoot)
			&& DirectoryExistQueries.Contains(PluginAlphaRoot)
			&& DirectoryExistQueries.Contains(PluginBetaRoot)
			&& DirectoryExistQueries.Contains(MissingPluginRoot));

	return bPassed;
}

#endif
