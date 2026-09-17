/**
 * @version v1
 * @summary Observe FFileHelper save/load round-trip, default-argument omission, explicit encoding/hash/read-write flags, and missing-file false.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FFileHelper save/load round-trip, default-argument omission, explicit encoding/hash/read-write flags, and missing-file false.
 * @topic Baseline
 */
// const FString& Filename,
// FFileHelper::EHashOptions HashOptions = FFileHelper::EHashOptions::None,
// uint32 ReadFlags = uint32(EFileRead::None));
// bool FFileHelper::SaveStringToFile(const FString& String,
// const FString& Filename,
// FFileHelper::EEncodingOptions EncodingOptions =
// FFileHelper::EEncodingOptions::AutoDetect,
// uint32 WriteFlags = uint32(EFileWrite::None));
// Inputs: Seeded text "HelloFileHelper", destination under ProjectSavedDir,
// empty Result before load, missing filename, HashOptions None, ReadFlags
// None, EncodingOptions AutoDetect/ForceUTF8, WriteFlags None, and a second
// save of the same path.
// Expected observations: Save returns true. Load writes the same text into
// Result. Missing files return false. Repeated save still returns true.
// Boundary/ownership: Result is written in place. The helpers do not retain
// String. Filename is borrowed.

namespace TS_FFileHelper_MutationAndLifecycle_01
{
	bool Observe_LoadFileToString_Nominal()
	{
		FString Filename = FPaths::CombinePaths(FPaths::ProjectSavedDir(), "AngelscriptFileHelperCompat.txt");
		bool bSaved = FFileHelper::SaveStringToFile("HelloFileHelper", Filename);
		FString Result;
		bool bResultEmptyBefore = Result.IsEmpty();
		bool bLoaded = FFileHelper::LoadFileToString(Result, Filename);
		bool bLoadedExplicit = FFileHelper::LoadFileToString(
			Result,
			Filename,
			FFileHelper::EHashOptions::None,
			uint32(EFileRead::None));
		FString MissingResult;
		bool bMissing = FFileHelper::LoadFileToString(MissingResult, "");
		return bSaved && bResultEmptyBefore && bLoaded && Result == "HelloFileHelper" && bLoadedExplicit && !bMissing && MissingResult.IsEmpty();
	}

	bool Observe_SaveStringToFile_Nominal()
	{
		FString Filename = FPaths::CombinePaths(FPaths::ProjectSavedDir(), "AngelscriptFileHelperCompat.txt");
		bool bSavedDefault = FFileHelper::SaveStringToFile("HelloFileHelper", Filename);
		bool bSavedAgain = FFileHelper::SaveStringToFile(
			"HelloFileHelper",
			Filename,
			FFileHelper::EEncodingOptions::AutoDetect,
			uint32(EFileWrite::None));
		bool bSavedUtf8 = FFileHelper::SaveStringToFile(
			"",
			Filename,
			FFileHelper::EEncodingOptions::ForceUTF8,
			uint32(EFileWrite::None));
		FString Reloaded;
		bool bReloadedEmpty = FFileHelper::LoadFileToString(Reloaded, Filename);
		return bSavedDefault && bSavedAgain && bSavedUtf8 && bReloadedEmpty && Reloaded.IsEmpty();
	}
}
/** @end */
