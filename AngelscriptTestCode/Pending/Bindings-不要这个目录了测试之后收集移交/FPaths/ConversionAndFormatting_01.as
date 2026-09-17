/**
 * @version v1
 * @summary Observe ConvertRelativePathToFull using the process base directory and an explicit BasePath.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ConvertRelativePathToFull using the process base directory and an explicit BasePath.
 * @topic Baseline
 */
// FString FPaths::ConvertRelativePathToFull(const FString& BasePath,
// const FString& InPath);
// Inputs: Relative "Script/Test.as", empty InPath, ProjectDir as BasePath,
// and ProjectDir as an already-absolute InPath.
// Expected observations: Relative conversion is non-empty and not equal to
// the relative fragment. The BasePath overload matches combining ProjectDir
// with the relative path after normalization. Empty InPath still returns a
// consumed string.
// Boundary/ownership: Both overloads return a new FString. Inputs are
// borrowed.

namespace TS_FPaths_ConversionAndFormatting_01
{
	bool Observe_ConvertRelativePathToFull_Nominal()
	{
		FString Relative = "Script/Test.as";
		FString FullFromProcess = FPaths::ConvertRelativePathToFull(Relative);
		FString EmptyFull = FPaths::ConvertRelativePathToFull("");
		FString ProjectDir = FPaths::ProjectDir();
		FString FullFromBase = FPaths::ConvertRelativePathToFull(ProjectDir, Relative);
		FString AbsolutePassthrough = FPaths::ConvertRelativePathToFull(ProjectDir, ProjectDir);
		bool bProcessFullDiffers = FullFromProcess.Len() > Relative.Len() && FullFromProcess.Contains("Test.as");
		bool bBaseUsesProject = FullFromBase.Contains("Script") && FullFromBase.Contains("Test.as");
		return bProcessFullDiffers && bBaseUsesProject && EmptyFull.Len() > 0 && AbsolutePassthrough.Len() > 0;
	}
}
/** @end */
