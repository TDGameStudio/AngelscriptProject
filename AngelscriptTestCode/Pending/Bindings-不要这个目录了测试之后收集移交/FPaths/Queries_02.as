/**
 * @version v1
 * @summary Observe FPaths::IsUnderDirectory for contained, prefix-collision, and empty paths.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FPaths::IsUnderDirectory for contained, prefix-collision, and empty paths.
 * @topic Baseline
 */
// const FString& InDirectory);
// Inputs: Combined ProjectDir/"Script/Test.as" under GetPath of that file,
// ProjectDir/"ScriptBackup/Test.as" as a prefix collision, the directory
// compared with itself, and empty strings.
// Expected observations: A file under its parent directory is true. A
// ScriptBackup sibling is not under Script. A directory is under itself.
// Empty path is not under a real directory. A file is not under empty.
// Boundary/ownership: The helper borrows both strings and does not mutate
// them.

namespace TS_FPaths_Queries_02
{
	bool Observe_IsUnderDirectory_Nominal()
	{
		FString Combined = FPaths::CombinePaths(FPaths::ProjectDir(), "Script/Test.as");
		FString ScriptDir = FPaths::GetPath(Combined);
		bool bFileUnderParent = FPaths::IsUnderDirectory(Combined, ScriptDir);
		FString PrefixCollision = FPaths::CombinePaths(FPaths::ProjectDir(), "ScriptBackup/Test.as");
		bool bPrefixCollision = FPaths::IsUnderDirectory(PrefixCollision, ScriptDir);
		bool bDirectoryUnderSelf = FPaths::IsUnderDirectory(ScriptDir, ScriptDir);
		bool bEmptyUnderDir = FPaths::IsUnderDirectory("", ScriptDir);
		bool bFileUnderEmpty = FPaths::IsUnderDirectory(Combined, "");
		return bFileUnderParent && !bPrefixCollision && bDirectoryUnderSelf && !bEmptyUnderDir && !bFileUnderEmpty;
	}
}
/** @end */
