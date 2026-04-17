#include "AngelscriptDirectoryWatcherInternal.h"

#include "AngelscriptEngine.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Guid.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDirectoryWatcherMatchingRootSelectionTest,
	"Angelscript.Editor.DirectoryWatcher.Queue.UsesMatchingRootWhenMultipleRootsSharePrefix",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptEditor_Private_Tests_AngelscriptDirectoryWatcherRootResolutionTests_Private
{
	FString MakeTempWatcherRoot(const TCHAR* Prefix)
	{
		return FPaths::ConvertRelativePathToFull(
			FPaths::ProjectSavedDir() / TEXT("Automation") / TEXT("DirectoryWatcherTests") / FString::Printf(TEXT("%s_%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits)));
	}

	FFileChangeData MakeFileChange(const FString& Filename, FFileChangeData::EFileChangeAction Action)
	{
		return FFileChangeData(Filename, Action);
	}

	TUniquePtr<FAngelscriptEngine> MakeTestEngineWithRoots(const TArray<FString>& RootPaths)
	{
		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		TUniquePtr<FAngelscriptEngine> Engine = MakeUnique<FAngelscriptEngine>(Config, Dependencies);

		for (const FString& RootPath : RootPaths)
		{
			Engine->AllRootPaths.Add(FPaths::ConvertRelativePathToFull(RootPath));
		}

		return Engine;
	}

	bool ContainsFilenamePair(const TArray<FAngelscriptEngine::FFilenamePair>& Files, const FString& AbsolutePath, const FString& RelativePath)
	{
		for (const FAngelscriptEngine::FFilenamePair& File : Files)
		{
			if (File.AbsolutePath == AbsolutePath && File.RelativePath == RelativePath)
			{
				return true;
			}
		}

		return false;
	}
}

using namespace AngelscriptEditor_Private_Tests_AngelscriptDirectoryWatcherRootResolutionTests_Private;

bool FAngelscriptDirectoryWatcherMatchingRootSelectionTest::RunTest(const FString& Parameters)
{
	IFileManager& FileManager = IFileManager::Get();
	const FString BaseRoot = MakeTempWatcherRoot(TEXT("RootResolution"));
	const FString ProjectRoot = FPaths::ConvertRelativePathToFull(BaseRoot / TEXT("Scripts"));
	const FString PluginRoot = FPaths::ConvertRelativePathToFull(BaseRoot / TEXT("ScriptsPlugin"));
	ON_SCOPE_EXIT
	{
		FileManager.DeleteDirectory(*BaseRoot, false, true);
	};

	FileManager.MakeDirectory(*ProjectRoot, true);
	FileManager.MakeDirectory(*(PluginRoot / TEXT("Feature")), true);

	const FString PluginScriptAbsolutePath = FPaths::ConvertRelativePathToFull(PluginRoot / TEXT("Feature/Changed.as"));
	if (!FFileHelper::SaveStringToFile(TEXT("// Changed"), *PluginScriptAbsolutePath))
	{
		AddError(TEXT("DirectoryWatcher.Queue.UsesMatchingRootWhenMultipleRootsSharePrefix should create the plugin-root script fixture"));
		return false;
	}

	TUniquePtr<FAngelscriptEngine> Engine = MakeTestEngineWithRoots({ ProjectRoot, PluginRoot });
	Engine->LastFileChangeDetectedTime = 1234.0;

	int32 EnumerateCallCount = 0;
	const TArray<FFileChangeData> Changes = {
		MakeFileChange(PluginScriptAbsolutePath, FFileChangeData::FCA_Modified)
	};

	AngelscriptEditor::Private::QueueScriptFileChanges(Changes, Engine->AllRootPaths, *Engine, FileManager, [&](const FString&)
	{
		++EnumerateCallCount;
		return TArray<FAngelscriptEngine::FFilenamePair>();
	});

	if (!TestEqual(
			TEXT("DirectoryWatcher.Queue.UsesMatchingRootWhenMultipleRootsSharePrefix should queue exactly one modified script"),
			Engine->FileChangesDetectedForReload.Num(),
			1)
		|| !TestEqual(
			TEXT("DirectoryWatcher.Queue.UsesMatchingRootWhenMultipleRootsSharePrefix should not queue deletions for the modified script"),
			Engine->FileDeletionsDetectedForReload.Num(),
			0)
		|| !TestTrue(
			TEXT("DirectoryWatcher.Queue.UsesMatchingRootWhenMultipleRootsSharePrefix should advance the timestamp for an in-root script change"),
			Engine->LastFileChangeDetectedTime > 1234.0)
		|| !TestEqual(
			TEXT("DirectoryWatcher.Queue.UsesMatchingRootWhenMultipleRootsSharePrefix should not enumerate loaded scripts for file-level modified events"),
			EnumerateCallCount,
			0))
	{
		return false;
	}

	return TestTrue(
		TEXT("DirectoryWatcher.Queue.UsesMatchingRootWhenMultipleRootsSharePrefix should compute the relative path from the matching root instead of preserving the root segment"),
		ContainsFilenamePair(Engine->FileChangesDetectedForReload, PluginScriptAbsolutePath, TEXT("Feature/Changed.as")));
}

#endif
