#include "AngelscriptDirectoryWatcherInternal.h"

#include "HAL/FileManager.h"
#include "Misc/Paths.h"

namespace
{
	bool TryMakeRelativeScriptPath(const FString& AbsolutePath, const TArray<FString>& RootPaths, FString& OutRelativePath)
	{
		for (const FString& RootPath : RootPaths)
		{
			const FString NormalizedRootPath = FPaths::ConvertRelativePathToFull(RootPath);
			const FString RootPathWithSeparator = FPaths::ConvertRelativePathToFull(NormalizedRootPath / TEXT(""));
			if (AbsolutePath.Equals(NormalizedRootPath) || AbsolutePath.StartsWith(RootPathWithSeparator))
			{
				OutRelativePath = AbsolutePath;
				FPaths::MakePathRelativeTo(OutRelativePath, *RootPathWithSeparator);
				return true;
			}
		}

		return false;
	}
}

namespace AngelscriptEditor::Private
{
	TArray<FAngelscriptEngine::FFilenamePair> GatherLoadedScriptsForFolder(FAngelscriptEngine& Engine, const FString& AbsoluteFolderPath)
	{
		TArray<FAngelscriptEngine::FFilenamePair> LoadedScripts;
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Engine.GetActiveModules())
		{
			for (const FAngelscriptModuleDesc::FCodeSection& CodeSection : Module->Code)
			{
				if (CodeSection.AbsoluteFilename.StartsWith(AbsoluteFolderPath))
				{
					LoadedScripts.AddUnique({ CodeSection.AbsoluteFilename, CodeSection.RelativeFilename });
				}
			}
		}

		return LoadedScripts;
	}

	void QueueScriptFileChanges(const TArray<FFileChangeData>& Changes, const TArray<FString>& RootPaths, FAngelscriptEngine& Engine, IFileManager& FileManager, const FEnumerateLoadedScripts& EnumerateLoadedScripts)
	{
		for (const FFileChangeData& Change : Changes)
		{
			const FString AbsolutePath = FPaths::ConvertRelativePathToFull(Change.Filename);
			FString RelativePath;

			if (!TryMakeRelativeScriptPath(AbsolutePath, RootPaths, RelativePath))
			{
				continue;
			}

			Engine.LastFileChangeDetectedTime = FPlatformTime::Seconds();

			if (AbsolutePath.EndsWith(TEXT(".as")))
			{
				if (Change.Action == FFileChangeData::EFileChangeAction::FCA_Removed)
				{
					Engine.FileDeletionsDetectedForReload.AddUnique({ AbsolutePath, RelativePath });
				}
				else
				{
					Engine.FileChangesDetectedForReload.AddUnique({ AbsolutePath, RelativePath });
				}

				UE_LOG(Angelscript, Log, TEXT("Queued script file change for primary engine reload: %s"), *RelativePath);
				continue;
			}

			if (Change.Action == FFileChangeData::EFileChangeAction::FCA_Removed)
			{
				for (const FAngelscriptEngine::FFilenamePair& LoadedScript : EnumerateLoadedScripts(AbsolutePath / TEXT("")))
				{
					Engine.FileDeletionsDetectedForReload.AddUnique(LoadedScript);
				}
			}
			else if (Change.Action == FFileChangeData::EFileChangeAction::FCA_Added && FileManager.DirectoryExists(*AbsolutePath))
			{
				TArray<FAngelscriptEngine::FFilenamePair> ContainedScriptFiles;
				FAngelscriptEngine::FindScriptFiles(FileManager, RelativePath, AbsolutePath, TEXT("*.as"), ContainedScriptFiles, false, false);

				for (const FAngelscriptEngine::FFilenamePair& ScriptFile : ContainedScriptFiles)
				{
					Engine.FileChangesDetectedForReload.AddUnique(ScriptFile);
				}
			}
		}
	}
}
