/**
 * @version v1
 * @summary FFileHelper host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FFileHelper
 *
 * append-replaces-uint32-none
 * oracle-copy-equals-none
 * FFileHelper-ConstructionAndAssignment_01-oracle-copy-equals-none
 * forceutf8-replaces-named-encodings
 * load-file-to-string
 * save-string-to-file
 */
/**
 * @begin append-replaces-uint32-none
 * @summary Append replaces, uint32(None) is 0, named flags differ from None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Append replaces, uint32(None) is 0, named flags differ from None.
 * @covers FFileHelper.append-replaces-uint32-none
 * @inputs FFileHelper values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	EFileWrite None = EFileWrite::None;
	EFileWrite Append = EFileWrite::Append;
	EFileWrite NoFail = EFileWrite::NoFail;
	EFileWrite NoReplaceExisting = EFileWrite::NoReplaceExisting;
	EFileWrite EvenIfReadOnly = EFileWrite::EvenIfReadOnly;
	EFileWrite AllowRead = EFileWrite::AllowRead;
	EFileWrite Silent = EFileWrite::Silent;
	EFileWrite Copied = None;
	bool bCopyEqualsNone = Copied == None;
	Copied = Append;
	uint32 NoneFlags = uint32(EFileWrite::None);
	return bCopyEqualsNone && Copied == Append && None == EFileWrite::None && NoneFlags == 0 && NoFail != None && NoReplaceExisting != None && EvenIfReadOnly != None && AllowRead != None && Silent != None;
}
/** @end */
/**
 * @begin oracle-copy-equals-none
 * @summary Oracle: copy equals None, assignment to AllowWrite replaces, uint32(None) is 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Oracle: copy equals None, assignment to AllowWrite replaces, uint32(None) is 0.
 * @covers FFileHelper.oracle-copy-equals-none
 * @inputs FFileHelper values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	EFileRead None = EFileRead::None;
	EFileRead AllowWrite = EFileRead::AllowWrite;
	EFileRead NoFail = EFileRead::NoFail;
	EFileRead Silent = EFileRead::Silent;
	EFileRead Copied = None;
	bool bCopyEqualsNone = Copied == None;
	Copied = AllowWrite;
	uint32 NoneFlags = uint32(EFileRead::None);
	return bCopyEqualsNone && Copied == AllowWrite && None == EFileRead::None && NoneFlags == 0 && NoFail != None && Silent != None;
}
/** @end */
/**
 * @begin FFileHelper-ConstructionAndAssignment_01-oracle-copy-equals-none
 * @summary Oracle: copy equals None, assignment to EnableVerify replaces, ErrorMissingHash is distinct.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary Oracle: copy equals None, assignment to EnableVerify replaces, ErrorMissingHash is distinct.
 * @covers FFileHelper.oracle-copy-equals-none
 * @inputs FFileHelper values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	FFileHelper::EHashOptions None = FFileHelper::EHashOptions::None;
	FFileHelper::EHashOptions EnableVerify = FFileHelper::EHashOptions::EnableVerify;
	FFileHelper::EHashOptions ErrorMissingHash = FFileHelper::EHashOptions::ErrorMissingHash;
	FFileHelper::EHashOptions Copied = None;
	bool bCopyEqualsNone = Copied == None;
	Copied = EnableVerify;
	return bCopyEqualsNone && Copied == EnableVerify && None == FFileHelper::EHashOptions::None && ErrorMissingHash != None && ErrorMissingHash != EnableVerify;
}
/** @end */
/**
 * @begin forceutf8-replaces-named-encodings
 * @summary ForceUTF8 replaces, named encodings are distinct.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary ForceUTF8 replaces, named encodings are distinct.
 * @covers FFileHelper.forceutf8-replaces-named-encodings
 * @inputs FFileHelper values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	FFileHelper::EEncodingOptions AutoDetect = FFileHelper::EEncodingOptions::AutoDetect;
	FFileHelper::EEncodingOptions ForceAnsi = FFileHelper::EEncodingOptions::ForceAnsi;
	FFileHelper::EEncodingOptions ForceUnicode = FFileHelper::EEncodingOptions::ForceUnicode;
	FFileHelper::EEncodingOptions ForceUTF8 = FFileHelper::EEncodingOptions::ForceUTF8;
	FFileHelper::EEncodingOptions ForceUTF8WithoutBOM = FFileHelper::EEncodingOptions::ForceUTF8WithoutBOM;
	FFileHelper::EEncodingOptions Copied = AutoDetect;
	bool bCopyEqualsAutoDetect = Copied == AutoDetect;
	Copied = ForceUTF8;
	return bCopyEqualsAutoDetect && Copied == ForceUTF8 && AutoDetect == FFileHelper::EEncodingOptions::AutoDetect && ForceAnsi != AutoDetect && ForceUnicode != AutoDetect && ForceUTF8WithoutBOM != AutoDetect && ForceUTF8 != ForceUTF8WithoutBOM;
}
/** @end */
/**
 * @begin load-file-to-string
 * @summary String.
 * @topic Unreal
 */
/**
 * @function ObserveLoadFileToStringNominal
 * @summary String.
 * @covers FFileHelper.load-file-to-string
 * @inputs FFileHelper values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLoadFileToStringNominal()
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
/** @end */
/**
 * @begin save-string-to-file
 * @summary String.
 * @topic Unreal
 */
/**
 * @function ObserveSaveStringToFileNominal
 * @summary String.
 * @covers FFileHelper.save-string-to-file
 * @inputs FFileHelper values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSaveStringToFileNominal()
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
/** @end */
