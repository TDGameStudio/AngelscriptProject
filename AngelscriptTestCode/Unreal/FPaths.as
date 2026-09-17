/**
 * @version v1
 * @summary FPaths host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FPaths
 *
 * convert-relative-path-to-full
 * set-extension
 * remove-duplicate-slashes
 * root-dir
 * launch-dir
 * combine-paths
 * engine-dir
 * engine-content-dir
 * engine-config-dir
 * engine-editor-settings-dir
 * engine-intermediate-dir
 * engine-saved-dir
 * project-dir
 * project-user-dir
 * project-content-dir
 * project-config-dir
 * project-saved-dir
 * project-intermediate-dir
 * screen-shot-dir
 * video-capture-dir
 * change-extension
 * split
 * file-exists
 * directory-exists
 * normalize-filename
 * normalize-directory-name
 * collapse-relative-directories
 * make-standard-filename
 * make-platform-filename
 * get-relative-path-to-root
 * get-extension
 * get-clean-filename
 * get-base-filename
 * get-path
 * get-path-leaf
 * is-drive
 * is-relative
 * is-restricted-path
 * is-same-path
 * is-under-directory
 */
/**
 * @begin convert-relative-path-to-full
 * @summary borrowed.
 * @topic Unreal
 */
/**
 * @function ObserveConvertRelativePathToFullNominal
 * @summary borrowed.
 * @covers FPaths.convert-relative-path-to-full
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveConvertRelativePathToFullNominal()
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
/** @end */
/**
 * @begin set-extension
 * @summary writes InPath in place.
 * @topic Unreal
 */
/**
 * @function ObserveSetExtensionNominal
 * @summary writes InPath in place.
 * @covers FPaths.set-extension
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetExtensionNominal()
{
	FString Source = "Dir/Test.as";
	FString Replaced = FPaths::SetExtension(Source, "txt");
	FString EmptyExtension = FPaths::SetExtension(Source, "");
	FString EmptyPath = FPaths::SetExtension("", "txt");
	bool bSourceUnchanged = Source == "Dir/Test.as";
	bool bReplacedTxt = Replaced.Contains("Test") && FPaths::GetExtension(Replaced) == "txt";
	bool bEmptyExtensionHasBase = EmptyExtension.Contains("Test");
	bool bEmptyPathHasTxt = EmptyPath.Contains("txt");
	return bSourceUnchanged && bReplacedTxt && bEmptyExtensionHasBase && bEmptyPathHasTxt;
}
/** @end */
/**
 * @begin remove-duplicate-slashes
 * @summary writes InPath in place.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveDuplicateSlashesNominal
 * @summary writes InPath in place.
 * @covers FPaths.remove-duplicate-slashes
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRemoveDuplicateSlashesNominal()
{
	FString Path = "A//B///C";
	FString Before = Path;
	FPaths::RemoveDuplicateSlashes(Path);
	bool bCollapsed = Path != Before && Path.Contains("A") && Path.Contains("B") && Path.Contains("C") && !Path.Contains("//");
	FString AfterFirst = Path;
	FPaths::RemoveDuplicateSlashes(Path);
	bool bSecondCallStable = Path == AfterFirst;
	FString Empty;
	FPaths::RemoveDuplicateSlashes(Empty);
	bool bEmptyRemainsEmpty = Empty.IsEmpty();
	FString Clean = "A/B/C";
	FPaths::RemoveDuplicateSlashes(Clean);
	bool bCleanUnchanged = Clean == "A/B/C";
	return bCollapsed && bSecondCallStable && bEmptyRemainsEmpty && bCleanUnchanged;
}
/** @end */
/**
 * @begin root-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveRootDirNominal
 * @summary elsewhere.
 * @covers FPaths.root-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRootDirNominal()
{
	return FPaths::RootDir().Len() > 0;
}
/** @end */
/**
 * @begin launch-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveLaunchDirNominal
 * @summary elsewhere.
 * @covers FPaths.launch-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLaunchDirNominal()
{
	return FPaths::LaunchDir().Len() > 0;
}
/** @end */
/**
 * @begin combine-paths
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveCombinePathsNominal
 * @summary elsewhere.
 * @covers FPaths.combine-paths
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCombinePathsNominal()
{
	FString Combined = FPaths::CombinePaths(FPaths::ProjectDir(), "Script/Test.as");
	FString WithEmpty = FPaths::CombinePaths(FPaths::ProjectDir(), "");
	FString EmptyFirst = FPaths::CombinePaths("", "Script/Test.as");
	bool bJoinedContainsScript = Combined.Contains("Script") && Combined.Contains("Test.as");
	bool bEmptySecondKeepsFirst = WithEmpty.Len() > 0;
	bool bEmptyFirstKeepsSecond = EmptyFirst.Contains("Test.as");
	return bJoinedContainsScript && bEmptySecondKeepsFirst && bEmptyFirstKeepsSecond;
}
/** @end */
/**
 * @begin engine-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveEngineDirNominal
 * @summary elsewhere.
 * @covers FPaths.engine-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEngineDirNominal()
{
	return FPaths::EngineDir().Len() > 0;
}
/** @end */
/**
 * @begin engine-content-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveEngineContentDirNominal
 * @summary elsewhere.
 * @covers FPaths.engine-content-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEngineContentDirNominal()
{
	FString Content = FPaths::EngineContentDir();
	return Content.Len() > 0 && Content.Contains("Content");
}
/** @end */
/**
 * @begin engine-config-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveEngineConfigDirNominal
 * @summary elsewhere.
 * @covers FPaths.engine-config-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEngineConfigDirNominal()
{
	return FPaths::EngineConfigDir().Len() > 0;
}
/** @end */
/**
 * @begin engine-editor-settings-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveEngineEditorSettingsDirNominal
 * @summary elsewhere.
 * @covers FPaths.engine-editor-settings-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEngineEditorSettingsDirNominal()
{
	return FPaths::EngineEditorSettingsDir().Len() > 0;
}
/** @end */
/**
 * @begin engine-intermediate-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveEngineIntermediateDirNominal
 * @summary elsewhere.
 * @covers FPaths.engine-intermediate-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEngineIntermediateDirNominal()
{
	return FPaths::EngineIntermediateDir().Len() > 0;
}
/** @end */
/**
 * @begin engine-saved-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveEngineSavedDirNominal
 * @summary elsewhere.
 * @covers FPaths.engine-saved-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEngineSavedDirNominal()
{
	return FPaths::EngineSavedDir().Len() > 0;
}
/** @end */
/**
 * @begin project-dir
 * @summary elsewhere.
 * @topic Unreal
 */
/**
 * @function ObserveProjectDirNominal
 * @summary elsewhere.
 * @covers FPaths.project-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectDirNominal()
{
	return FPaths::ProjectDir().Len() > 0;
}
/** @end */
/**
 * @begin project-user-dir
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveProjectUserDirNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.project-user-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectUserDirNominal()
{
	return FPaths::ProjectUserDir().Len() > 0;
}
/** @end */
/**
 * @begin project-content-dir
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveProjectContentDirNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.project-content-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectContentDirNominal()
{
	return FPaths::ProjectContentDir().Len() > 0;
}
/** @end */
/**
 * @begin project-config-dir
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveProjectConfigDirNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.project-config-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectConfigDirNominal()
{
	return FPaths::ProjectConfigDir().Len() > 0;
}
/** @end */
/**
 * @begin project-saved-dir
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveProjectSavedDirNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.project-saved-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectSavedDirNominal()
{
	const FString& Saved = FPaths::ProjectSavedDir();
	const FString& Again = FPaths::ProjectSavedDir();
	FString Copy = Saved;
	return Copy == Saved && Saved == Again && Saved.Len() > 0;
}
/** @end */
/**
 * @begin project-intermediate-dir
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveProjectIntermediateDirNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.project-intermediate-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectIntermediateDirNominal()
{
	return FPaths::ProjectIntermediateDir().Len() > 0;
}
/** @end */
/**
 * @begin screen-shot-dir
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveScreenShotDirNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.screen-shot-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveScreenShotDirNominal()
{
	return FPaths::ScreenShotDir().Len() > 0;
}
/** @end */
/**
 * @begin video-capture-dir
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveVideoCaptureDirNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.video-capture-dir
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVideoCaptureDirNominal()
{
	return FPaths::VideoCaptureDir().Len() > 0;
}
/** @end */
/**
 * @begin change-extension
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveChangeExtensionNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.change-extension
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveChangeExtensionNominal()
{
	FString Source = "Dir/Test.as";
	FString Changed = FPaths::ChangeExtension(Source, "txt");
	FString EmptyExt = FPaths::ChangeExtension(Source, "");
	bool bSourceUnchanged = Source == "Dir/Test.as";
	bool bChangedTxt = FPaths::GetExtension(Changed) == "txt";
	bool bEmptyExtKeepsBase = EmptyExt.Contains("Test") && FPaths::GetExtension(EmptyExt).IsEmpty();
	return bSourceUnchanged && bChangedTxt && bEmptyExtKeepsBase;
}
/** @end */
/**
 * @begin split
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveSplitNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.split
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSplitNominal()
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
/** @end */
/**
 * @begin file-exists
 * @summary writes the three out strings in place.
 * @topic Unreal
 */
/**
 * @function ObserveFileExistsNominal
 * @summary writes the three out strings in place.
 * @covers FPaths.file-exists
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFileExistsNominal()
{
	bool bProjectDirIsFile = FPaths::FileExists(FPaths::ProjectDir());
	bool bEmptyExists = FPaths::FileExists("");
	FString Missing = FPaths::CombinePaths(FPaths::ProjectDir(), "DefinitelyMissingTestSourceFile.txt");
	bool bMissingExists = FPaths::FileExists(Missing);
	return !bProjectDirIsFile && !bEmptyExists && !bMissingExists;
}
/** @end */
/**
 * @begin directory-exists
 * @summary unchanged when it returns false.
 * @topic Unreal
 */
/**
 * @function ObserveDirectoryExistsNominal
 * @summary unchanged when it returns false.
 * @covers FPaths.directory-exists
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDirectoryExistsNominal()
{
	bool bProjectExists = FPaths::DirectoryExists(FPaths::ProjectDir());
	bool bEmptyExists = FPaths::DirectoryExists("");
	FString Missing = FPaths::CombinePaths(FPaths::ProjectDir(), "DefinitelyMissingTestSourceDir");
	bool bMissingExists = FPaths::DirectoryExists(Missing);
	return bProjectExists && !bEmptyExists && !bMissingExists;
}
/** @end */
/**
 * @begin normalize-filename
 * @summary unchanged when it returns false.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeFilenameNominal
 * @summary unchanged when it returns false.
 * @covers FPaths.normalize-filename
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveNormalizeFilenameNominal()
{
	FString Path = "A\\B/C.as";
	FString Before = Path;
	FPaths::NormalizeFilename(Path);
	bool bNormalized = Path.Len() > 0 && Path.Contains("A") && Path.Contains("C.as") && Path != Before;
	FString Empty;
	FPaths::NormalizeFilename(Empty);
	return bNormalized && Empty.IsEmpty();
}
/** @end */
/**
 * @begin normalize-directory-name
 * @summary unchanged when it returns false.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeDirectoryNameNominal
 * @summary unchanged when it returns false.
 * @covers FPaths.normalize-directory-name
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveNormalizeDirectoryNameNominal()
{
	FString Path = "A/B/";
	FPaths::NormalizeDirectoryName(Path);
	bool bTrailingRemoved = Path.Len() > 0 && !Path.EndsWith("/") && !Path.EndsWith("\\");
	FString Empty;
	FPaths::NormalizeDirectoryName(Empty);
	return bTrailingRemoved && Empty.IsEmpty();
}
/** @end */
/**
 * @begin collapse-relative-directories
 * @summary unchanged when it returns false.
 * @topic Unreal
 */
/**
 * @function ObserveCollapseRelativeDirectoriesNominal
 * @summary unchanged when it returns false.
 * @covers FPaths.collapse-relative-directories
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCollapseRelativeDirectoriesNominal()
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
/** @end */
/**
 * @begin make-standard-filename
 * @summary unchanged when it returns false.
 * @topic Unreal
 */
/**
 * @function ObserveMakeStandardFilenameNominal
 * @summary unchanged when it returns false.
 * @covers FPaths.make-standard-filename
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeStandardFilenameNominal()
{
	FString Path = FPaths::CombinePaths(FPaths::ProjectDir(), "Script/Test.as");
	FPaths::MakeStandardFilename(Path);
	FString Empty;
	FPaths::MakeStandardFilename(Empty);
	return Path.Len() > 0 && Path.Contains("Test.as") && Empty.IsEmpty();
}
/** @end */
/**
 * @begin make-platform-filename
 * @summary unchanged when it returns false.
 * @topic Unreal
 */
/**
 * @function ObserveMakePlatformFilenameNominal
 * @summary unchanged when it returns false.
 * @covers FPaths.make-platform-filename
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakePlatformFilenameNominal()
{
	FString Path = "A/B/C.as";
	FPaths::MakePlatformFilename(Path);
	bool bPlatformNonEmpty = Path.Contains("A") && Path.Contains("C.as");
	FString Empty;
	FPaths::MakePlatformFilename(Empty);
	return bPlatformNonEmpty && Empty.IsEmpty();
}
/** @end */
/**
 * @begin get-relative-path-to-root
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveGetRelativePathToRootNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.get-relative-path-to-root
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRelativePathToRootNominal()
{
	const FString& Relative = FPaths::GetRelativePathToRoot();
	const FString& Again = FPaths::GetRelativePathToRoot();
	FString Copy = Relative;
	return Copy == Relative && Relative == Again;
}
/** @end */
/**
 * @begin get-extension
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveGetExtensionNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.get-extension
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetExtensionNominal()
{
	FString WithoutDot = FPaths::GetExtension("Dir/Sub/Test.as");
	FString WithDot = FPaths::GetExtension("Dir/Sub/Test.as", true);
	FString DefaultOmit = FPaths::GetExtension("Dir/Sub/Test.as", false);
	FString Empty = FPaths::GetExtension("");
	return WithoutDot == "as" && WithDot == ".as" && DefaultOmit == "as" && Empty.IsEmpty();
}
/** @end */
/**
 * @begin get-clean-filename
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveGetCleanFilenameNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.get-clean-filename
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCleanFilenameNominal()
{
	FString Clean = FPaths::GetCleanFilename("Dir/Sub/Test.as");
	FString Empty = FPaths::GetCleanFilename("");
	return Clean == "Test.as" && Empty.IsEmpty();
}
/** @end */
/**
 * @begin get-base-filename
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveGetBaseFilenameNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.get-base-filename
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBaseFilenameNominal()
{
	FString Base = FPaths::GetBaseFilename("Dir/Sub/Test.as");
	FString DefaultRemovePath = FPaths::GetBaseFilename("Dir/Sub/Test.as", true);
	FString KeepPath = FPaths::GetBaseFilename("Dir/Sub/Test.as", false);
	FString Empty = FPaths::GetBaseFilename("");
	return Base == "Test" && DefaultRemovePath == "Test" && KeepPath.Contains("Test") && KeepPath != "Test" && Empty.IsEmpty();
}
/** @end */
/**
 * @begin get-path
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveGetPathNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.get-path
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPathNominal()
{
	FString Path = FPaths::GetPath("Dir/Sub/Test.as");
	FString Empty = FPaths::GetPath("");
	return Path.Contains("Dir") && Path.Contains("Sub") && Empty.IsEmpty();
}
/** @end */
/**
 * @begin get-path-leaf
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveGetPathLeafNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.get-path-leaf
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPathLeafNominal()
{
	FString Leaf = FPaths::GetPathLeaf("Dir/Sub");
	FString FileLeaf = FPaths::GetPathLeaf("Dir/Sub/Test.as");
	FString Empty = FPaths::GetPathLeaf("");
	return Leaf == "Sub" && FileLeaf == "Test.as" && Empty.IsEmpty();
}
/** @end */
/**
 * @begin is-drive
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveIsDriveNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.is-drive
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsDriveNominal()
{
	bool bDrive = FPaths::IsDrive("C:");
	bool bNotDrive = FPaths::IsDrive("relative/path");
	bool bEmpty = FPaths::IsDrive("");
	return bDrive && !bNotDrive && !bEmpty;
}
/** @end */
/**
 * @begin is-relative
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveIsRelativeNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.is-relative
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRelativeNominal()
{
	bool bRelative = FPaths::IsRelative("Script/Test.as");
	bool bProjectAbsolute = FPaths::IsRelative(FPaths::ProjectDir());
	bool bEmptyRelative = FPaths::IsRelative("");
	return bRelative && !bProjectAbsolute && bEmptyRelative;
}
/** @end */
/**
 * @begin is-restricted-path
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveIsRestrictedPathNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.is-restricted-path
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRestrictedPathNominal()
{
	bool bEmptyRestricted = FPaths::IsRestrictedPath("");
	bool bRelativeRestricted = FPaths::IsRestrictedPath("relative/path");
	bool bProjectRestricted = FPaths::IsRestrictedPath(FPaths::ProjectDir());
	bool bProjectRestrictedAgain = FPaths::IsRestrictedPath(FPaths::ProjectDir());
	return !bEmptyRestricted && !bRelativeRestricted && bProjectRestricted == bProjectRestrictedAgain;
}
/** @end */
/**
 * @begin is-same-path
 * @summary The other getters return new FStrings.
 * @topic Unreal
 */
/**
 * @function ObserveIsSamePathNominal
 * @summary The other getters return new FStrings.
 * @covers FPaths.is-same-path
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsSamePathNominal()
{
	FString Combined = FPaths::CombinePaths(FPaths::ProjectDir(), "Script/Test.as");
	bool bSameSelf = FPaths::IsSamePath(Combined, Combined);
	bool bDifferent = FPaths::IsSamePath(Combined, FPaths::ProjectDir());
	FString Upper = Combined.ToUpper();
	bool bCaseVariant = FPaths::IsSamePath(Combined, Upper);
	bool bEmptySame = FPaths::IsSamePath("", "");
	return bSameSelf && !bDifferent && bCaseVariant && bEmptySame;
}
/** @end */
/**
 * @begin is-under-directory
 * @summary them.
 * @topic Unreal
 */
/**
 * @function ObserveIsUnderDirectoryNominal
 * @summary them.
 * @covers FPaths.is-under-directory
 * @inputs FPaths values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsUnderDirectoryNominal()
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
/** @end */
