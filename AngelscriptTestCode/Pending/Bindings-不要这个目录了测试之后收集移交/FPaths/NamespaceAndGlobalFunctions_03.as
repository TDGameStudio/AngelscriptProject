/**
 * @version v1
 * @summary Observe DirectoryExists and in-place filename normalization, collapse, and platform/standard conversion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe DirectoryExists and in-place filename normalization, collapse, and platform/standard conversion.
 * @topic Baseline
 */
// void FPaths::NormalizeFilename(FString& InPath);
// void FPaths::NormalizeDirectoryName(FString& InPath);
// bool FPaths::CollapseRelativeDirectories(FString& InPath);
// void FPaths::MakeStandardFilename(FString& InPath);
// void FPaths::MakePlatformFilename(FString& InPath);
// Inputs: ProjectDir as an existing directory, empty path, "A\\B/C.as" mixed
// separators, "A/B/../C" collapsible segments, a traversal that escapes the
// root, and a trailing-slash directory.
// Expected observations: DirectoryExists is true for ProjectDir and false for
// empty/missing paths. NormalizeFilename rewrites separators in place.
// NormalizeDirectoryName drops a trailing separator. Collapse returns true
// for A/B/../C and false when traversal escapes the root. Standard/platform
// conversion still leave a non-empty string.
// Boundary/ownership: In-place helpers mutate InPath. Collapse leaves InPath
// unchanged when it returns false.

namespace TS_FPaths_NamespaceAndGlobalFunctions_03
{
	bool Observe_DirectoryExists_Nominal()
	{
		bool bProjectExists = FPaths::DirectoryExists(FPaths::ProjectDir());
		bool bEmptyExists = FPaths::DirectoryExists("");
		FString Missing = FPaths::CombinePaths(FPaths::ProjectDir(), "DefinitelyMissingTestSourceDir");
		bool bMissingExists = FPaths::DirectoryExists(Missing);
		return bProjectExists && !bEmptyExists && !bMissingExists;
	}

	bool Observe_NormalizeFilename_Nominal()
	{
		FString Path = "A\\B/C.as";
		FString Before = Path;
		FPaths::NormalizeFilename(Path);
		bool bNormalized = Path.Len() > 0 && Path.Contains("A") && Path.Contains("C.as") && Path != Before;
		FString Empty;
		FPaths::NormalizeFilename(Empty);
		return bNormalized && Empty.IsEmpty();
	}

	bool Observe_NormalizeDirectoryName_Nominal()
	{
		FString Path = "A/B/";
		FPaths::NormalizeDirectoryName(Path);
		bool bTrailingRemoved = Path.Len() > 0 && !Path.EndsWith("/") && !Path.EndsWith("\\");
		FString Empty;
		FPaths::NormalizeDirectoryName(Empty);
		return bTrailingRemoved && Empty.IsEmpty();
	}

	bool Observe_CollapseRelativeDirectories_Nominal()
	{
		FString Path = "A/B/../C";
		bool bCollapsed = FPaths::CollapseRelativeDirectories(Path);
		bool bCollapsedPath = Path.Contains("A") && Path.Contains("C") && !Path.Contains("..");
		FString Escape = "/../Outside";
		FString EscapeBefore = Escape;
		bool bEscaped = FPaths::CollapseRelativeDirectories(Escape);
		FString Empty;
		bool bEmptyCollapsed = FPaths::CollapseRelativeDirectories(Empty);
		return bCollapsed && bCollapsedPath && !bEscaped && Escape == EscapeBefore && bEmptyCollapsed && Empty.IsEmpty();
	}

	bool Observe_MakeStandardFilename_Nominal()
	{
		FString Path = FPaths::CombinePaths(FPaths::ProjectDir(), "Script/Test.as");
		FPaths::MakeStandardFilename(Path);
		FString Empty;
		FPaths::MakeStandardFilename(Empty);
		return Path.Len() > 0 && Path.Contains("Test.as") && Empty.IsEmpty();
	}

	bool Observe_MakePlatformFilename_Nominal()
	{
		FString Path = "A/B/C.as";
		FPaths::MakePlatformFilename(Path);
		bool bPlatformNonEmpty = Path.Contains("A") && Path.Contains("C.as");
		FString Empty;
		FPaths::MakePlatformFilename(Empty);
		return bPlatformNonEmpty && Empty.IsEmpty();
	}
}
/** @end */
