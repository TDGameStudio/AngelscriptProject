/**
 * @version v1
 * @summary Observe FFileHelper option enumerators, including copy and assignment independence for write, read, hash, and encoding flags.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FFileHelper option enumerators, including copy and assignment independence for write, read, hash, and encoding flags.
 * @topic Baseline
 */
// EvenIfReadOnly, Append, AllowRead, Silent };
// enum EFileRead { None, NoFail, Silent, AllowWrite };
// enum FFileHelper::EHashOptions { None, EnableVerify, ErrorMissingHash };
// enum FFileHelper::EEncodingOptions { AutoDetect, ForceAnsi, ForceUnicode,
// ForceUTF8, ForceUTF8WithoutBOM };
// Inputs: Default None values, explicit Append/AllowWrite/EnableVerify/
// ForceUTF8, copies of those values, and assignment of a sibling enumerator.
// Expected observations: Copied enumerators compare equal to the source.
// Assigned values differ from the original None. uint32 casts of None are 0.
// Boundary/ownership: Enumerators are value types. Script does not own file
// I/O policy. ErrorMissingHash is the diagnostic companion enumerator.

namespace TS_FFileHelper_ConstructionAndAssignment_01
{
	// EFileWrite enumerators. Inputs: None, Append, NoFail, NoReplaceExisting,
	// EvenIfReadOnly, AllowRead, Silent. Oracle: copy equals None, assignment to
	// Append replaces, uint32(None) is 0, named flags differ from None.
	bool Observe_Surface001_Nominal()
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

	// EFileRead enumerators. Inputs: None, AllowWrite, NoFail, Silent.
	// Oracle: copy equals None, assignment to AllowWrite replaces, uint32(None) is 0.
	bool Observe_Surface002_Nominal()
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

	// FFileHelper::EHashOptions. Inputs: None, EnableVerify, ErrorMissingHash.
	// Oracle: copy equals None, assignment to EnableVerify replaces, ErrorMissingHash is distinct.
	bool Observe_Surface003_Nominal()
	{
		FFileHelper::EHashOptions None = FFileHelper::EHashOptions::None;
		FFileHelper::EHashOptions EnableVerify = FFileHelper::EHashOptions::EnableVerify;
		FFileHelper::EHashOptions ErrorMissingHash = FFileHelper::EHashOptions::ErrorMissingHash;
		FFileHelper::EHashOptions Copied = None;
		bool bCopyEqualsNone = Copied == None;
		Copied = EnableVerify;
		return bCopyEqualsNone && Copied == EnableVerify && None == FFileHelper::EHashOptions::None && ErrorMissingHash != None && ErrorMissingHash != EnableVerify;
	}

	// FFileHelper::EEncodingOptions. Inputs: AutoDetect, ForceAnsi, ForceUnicode,
	// ForceUTF8, ForceUTF8WithoutBOM. Oracle: copy equals AutoDetect, assignment to
	// ForceUTF8 replaces, named encodings are distinct.
	bool Observe_Surface004_Nominal()
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

	void ExerciseExpectedFailure()
	{
		FFileHelper::EHashOptions MissingHash = FFileHelper::EHashOptions::ErrorMissingHash;
	}
}
/** @end */
