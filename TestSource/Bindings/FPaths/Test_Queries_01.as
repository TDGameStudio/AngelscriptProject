// Purpose: Observe FPaths filename queries, relative-to-root, and path
// classification helpers.
// AS-facing API: const FString& FPaths::GetRelativePathToRoot();
// FString FPaths::GetExtension(const FString& InPath, bool bIncludeDot = false);
// FString FPaths::GetCleanFilename(const FString& InPath);
// FString FPaths::GetBaseFilename(const FString& InPath, bool bRemovePath = true);
// FString FPaths::GetPath(const FString& InPath);
// FString FPaths::GetPathLeaf(const FString& InPath);
// bool FPaths::IsDrive(const FString& InPath);
// bool FPaths::IsRelative(const FString& InPath);
// bool FPaths::IsRestrictedPath(const FString& InPath);
// bool FPaths::IsSamePath(const FString& PathA, const FString& PathB);
// Inputs: "Dir/Sub/Test.as", empty path, "C:", "relative/path", ProjectDir,
// and a case-variant of a combined project path.
// Expected observations: Extension without dot is "as"; with dot is ".as".
// Clean filename is "Test.as". Base filename is "Test". Relative-to-root is
// a borrowed string equal across calls. IsRelative is true for relative
// fragments and false for ProjectDir. IsSamePath treats case variants as
// equal on Windows.
// Boundary/ownership: GetRelativePathToRoot returns a borrowed engine string.
// The other getters return new FStrings.

namespace TS_FPaths_Queries_01
{
	bool Observe_GetRelativePathToRoot_Nominal()
	{
		const FString& Relative = FPaths::GetRelativePathToRoot();
		const FString& Again = FPaths::GetRelativePathToRoot();
		FString Copy = Relative;
		return Copy == Relative && Relative == Again;
	}

	bool Observe_GetExtension_Nominal()
	{
		FString WithoutDot = FPaths::GetExtension("Dir/Sub/Test.as");
		FString WithDot = FPaths::GetExtension("Dir/Sub/Test.as", true);
		FString DefaultOmit = FPaths::GetExtension("Dir/Sub/Test.as", false);
		FString Empty = FPaths::GetExtension("");
		return WithoutDot == "as" && WithDot == ".as" && DefaultOmit == "as" && Empty.IsEmpty();
	}

	bool Observe_GetCleanFilename_Nominal()
	{
		FString Clean = FPaths::GetCleanFilename("Dir/Sub/Test.as");
		FString Empty = FPaths::GetCleanFilename("");
		return Clean == "Test.as" && Empty.IsEmpty();
	}

	bool Observe_GetBaseFilename_Nominal()
	{
		FString Base = FPaths::GetBaseFilename("Dir/Sub/Test.as");
		FString DefaultRemovePath = FPaths::GetBaseFilename("Dir/Sub/Test.as", true);
		FString KeepPath = FPaths::GetBaseFilename("Dir/Sub/Test.as", false);
		FString Empty = FPaths::GetBaseFilename("");
		return Base == "Test" && DefaultRemovePath == "Test" && KeepPath.Contains("Test") && KeepPath != "Test" && Empty.IsEmpty();
	}

	bool Observe_GetPath_Nominal()
	{
		FString Path = FPaths::GetPath("Dir/Sub/Test.as");
		FString Empty = FPaths::GetPath("");
		return Path.Contains("Dir") && Path.Contains("Sub") && Empty.IsEmpty();
	}

	bool Observe_GetPathLeaf_Nominal()
	{
		FString Leaf = FPaths::GetPathLeaf("Dir/Sub");
		FString FileLeaf = FPaths::GetPathLeaf("Dir/Sub/Test.as");
		FString Empty = FPaths::GetPathLeaf("");
		return Leaf == "Sub" && FileLeaf == "Test.as" && Empty.IsEmpty();
	}

	bool Observe_IsDrive_Nominal()
	{
		bool bDrive = FPaths::IsDrive("C:");
		bool bNotDrive = FPaths::IsDrive("relative/path");
		bool bEmpty = FPaths::IsDrive("");
		return bDrive && !bNotDrive && !bEmpty;
	}

	bool Observe_IsRelative_Nominal()
	{
		bool bRelative = FPaths::IsRelative("Script/Test.as");
		bool bProjectAbsolute = FPaths::IsRelative(FPaths::ProjectDir());
		bool bEmptyRelative = FPaths::IsRelative("");
		return bRelative && !bProjectAbsolute && bEmptyRelative;
	}

	bool Observe_IsRestrictedPath_Nominal()
	{
		bool bEmptyRestricted = FPaths::IsRestrictedPath("");
		bool bRelativeRestricted = FPaths::IsRestrictedPath("relative/path");
		bool bProjectRestricted = FPaths::IsRestrictedPath(FPaths::ProjectDir());
		bool bProjectRestrictedAgain = FPaths::IsRestrictedPath(FPaths::ProjectDir());
		return !bEmptyRestricted && !bRelativeRestricted && bProjectRestricted == bProjectRestrictedAgain;
	}

	bool Observe_IsSamePath_Nominal()
	{
		FString Combined = FPaths::CombinePaths(FPaths::ProjectDir(), "Script/Test.as");
		bool bSameSelf = FPaths::IsSamePath(Combined, Combined);
		bool bDifferent = FPaths::IsSamePath(Combined, FPaths::ProjectDir());
		FString Upper = Combined.ToUpper();
		bool bCaseVariant = FPaths::IsSamePath(Combined, Upper);
		bool bEmptySame = FPaths::IsSamePath("", "");
		return bSameSelf && !bDifferent && bCaseVariant && bEmptySame;
	}
}
