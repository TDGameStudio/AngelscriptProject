// Purpose: Observe project user/content/config/saved/intermediate directories,
// capture directories, ChangeExtension, Split writeback, and FileExists.
// AS-facing API: FString FPaths::ProjectUserDir();
// FString FPaths::ProjectContentDir(); FString FPaths::ProjectConfigDir();
// const FString& FPaths::ProjectSavedDir();
// FString FPaths::ProjectIntermediateDir(); FString FPaths::ScreenShotDir();
// FString FPaths::VideoCaptureDir();
// FString FPaths::ChangeExtension(const FString& InPath, const FString& InNewExtension);
// void FPaths::Split(const FString& InPath, FString& PathPart,
// FString& FilenamePart, FString& ExtensionPart);
// bool FPaths::FileExists(const FString& InPath);
// Inputs: Live project directories, "Dir/Test.as" for ChangeExtension/Split,
// empty out strings before Split, ProjectDir as a non-file, and empty InPath.
// Expected observations: Directory helpers are non-empty. ProjectSavedDir is
// a borrowed string. ChangeExtension replaces the extension without mutating
// the source. Split writes directory, base name, and extension without a
// leading period. FileExists is false for ProjectDir and empty.
// Boundary/ownership: ProjectSavedDir returns a borrowed engine string. Split
// writes the three out strings in place.

namespace TS_FPaths_NamespaceAndGlobalFunctions_02
{
	bool Observe_ProjectUserDir_Nominal()
	{
		return FPaths::ProjectUserDir().Len() > 0;
	}

	bool Observe_ProjectContentDir_Nominal()
	{
		return FPaths::ProjectContentDir().Len() > 0;
	}

	bool Observe_ProjectConfigDir_Nominal()
	{
		return FPaths::ProjectConfigDir().Len() > 0;
	}

	bool Observe_ProjectSavedDir_Nominal()
	{
		const FString& Saved = FPaths::ProjectSavedDir();
		const FString& Again = FPaths::ProjectSavedDir();
		FString Copy = Saved;
		return Copy == Saved && Saved == Again && Saved.Len() > 0;
	}

	bool Observe_ProjectIntermediateDir_Nominal()
	{
		return FPaths::ProjectIntermediateDir().Len() > 0;
	}

	bool Observe_ScreenShotDir_Nominal()
	{
		return FPaths::ScreenShotDir().Len() > 0;
	}

	bool Observe_VideoCaptureDir_Nominal()
	{
		return FPaths::VideoCaptureDir().Len() > 0;
	}

	bool Observe_ChangeExtension_Nominal()
	{
		FString Source = "Dir/Test.as";
		FString Changed = FPaths::ChangeExtension(Source, "txt");
		FString EmptyExt = FPaths::ChangeExtension(Source, "");
		bool bSourceUnchanged = Source == "Dir/Test.as";
		bool bChangedTxt = FPaths::GetExtension(Changed) == "txt";
		bool bEmptyExtKeepsBase = EmptyExt.Contains("Test") && FPaths::GetExtension(EmptyExt).IsEmpty();
		return bSourceUnchanged && bChangedTxt && bEmptyExtKeepsBase;
	}

	bool Observe_Split_Nominal()
	{
		FString PathPart;
		FString FilenamePart;
		FString ExtensionPart;
		bool bEmptyBefore =
			PathPart.IsEmpty() &&
			FilenamePart.IsEmpty() &&
			ExtensionPart.IsEmpty();
		FPaths::Split("Dir/Sub/Test.as", PathPart, FilenamePart, ExtensionPart);
		bool bPathWriteback = PathPart.Contains("Dir") && PathPart.Contains("Sub");
		bool bFilenameWriteback = FilenamePart == "Test";
		bool bExtensionWriteback = ExtensionPart == "as";
		FString EmptyPath;
		FString EmptyFile;
		FString EmptyExt;
		FPaths::Split("", EmptyPath, EmptyFile, EmptyExt);
		return bEmptyBefore && bPathWriteback && bFilenameWriteback && bExtensionWriteback && EmptyPath.IsEmpty() && EmptyFile.IsEmpty() && EmptyExt.IsEmpty();
	}

	bool Observe_FileExists_Nominal()
	{
		bool bProjectDirIsFile = FPaths::FileExists(FPaths::ProjectDir());
		bool bEmptyExists = FPaths::FileExists("");
		FString Missing = FPaths::CombinePaths(FPaths::ProjectDir(), "DefinitelyMissingTestSourceFile.txt");
		bool bMissingExists = FPaths::FileExists(Missing);
		return !bProjectDirIsFile && !bEmptyExists && !bMissingExists;
	}
}
