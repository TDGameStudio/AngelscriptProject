// Purpose: Observe EGetByNameFlags enumerators that control reflected enum
// name lookup.
// AS-facing API: EGetByNameFlags::None; EGetByNameFlags::ErrorIfNotFound;
// EGetByNameFlags::CaseSensitive; EGetByNameFlags::CheckAuthoredName;
// Inputs: Each enumerator as an explicit flag passed to GetIndexByName on
// EAttachmentRule, the default-argument omission of Flags, a matching first
// enumerator name, and "DefinitelyMissing" with ErrorIfNotFound.
// Expected observations: None, CaseSensitive, and CheckAuthoredName find the
// first enumerator index. Default omission matches None. ErrorIfNotFound on a
// missing name is the diagnostic path.
// Boundary/ownership: Flags only select lookup policy. They do not own the
// UEnum or the search name. Missing UEnum is setup failure.

namespace TS_UEnum_NamespaceAndGlobalFunctions_01
{
	// EGetByNameFlags::None matches default GetIndexByName omission at index 0.
	bool Observe_Surface003_Nominal()
	{
		EGetByNameFlags None = EGetByNameFlags::None;
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_NamespaceAndGlobalFunctions_01 setup: required EAttachmentRule UEnum is null");
		}
		FName FirstName = EnumObject.GetNameByIndex(0);
		int32 DefaultIndex = EnumObject.GetIndexByName(FirstName);
		int32 NoneIndex = EnumObject.GetIndexByName(FirstName, None);
		return None == EGetByNameFlags::None && DefaultIndex == 0 && NoneIndex == 0;
	}

	// EGetByNameFlags::ErrorIfNotFound still finds a present enumerator at index 0.
	bool Observe_Surface004_Nominal()
	{
		EGetByNameFlags ErrorIfNotFound = EGetByNameFlags::ErrorIfNotFound;
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_NamespaceAndGlobalFunctions_01 setup: required EAttachmentRule UEnum is null");
		}
		FName FirstName = EnumObject.GetNameByIndex(0);
		int32 FoundIndex = EnumObject.GetIndexByName(FirstName, ErrorIfNotFound);
		return ErrorIfNotFound == EGetByNameFlags::ErrorIfNotFound && FoundIndex == 0;
	}

	// EGetByNameFlags::CaseSensitive finds the first enumerator at index 0.
	bool Observe_Surface005_Nominal()
	{
		EGetByNameFlags CaseSensitive = EGetByNameFlags::CaseSensitive;
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_NamespaceAndGlobalFunctions_01 setup: required EAttachmentRule UEnum is null");
		}
		FName FirstName = EnumObject.GetNameByIndex(0);
		int32 FoundIndex = EnumObject.GetIndexByName(FirstName, CaseSensitive);
		return CaseSensitive == EGetByNameFlags::CaseSensitive && FoundIndex == 0;
	}

	// EGetByNameFlags::CheckAuthoredName finds index 0 by name and by name string.
	bool Observe_Surface006_Nominal()
	{
		EGetByNameFlags CheckAuthoredName = EGetByNameFlags::CheckAuthoredName;
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_NamespaceAndGlobalFunctions_01 setup: required EAttachmentRule UEnum is null");
		}
		FName FirstName = EnumObject.GetNameByIndex(0);
		int32 FoundIndex = EnumObject.GetIndexByName(FirstName, CheckAuthoredName);
		FString FirstString = EnumObject.GetNameStringByIndex(0);
		int32 AuthoredStringIndex = EnumObject.GetIndexByNameString(FirstString, CheckAuthoredName);
		return CheckAuthoredName == EGetByNameFlags::CheckAuthoredName &&
			FoundIndex == 0 &&
			AuthoredStringIndex == 0;
	}

	void ExerciseExpectedFailure()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		int32 Missing = EnumObject.GetIndexByName(n"DefinitelyMissing", EGetByNameFlags::ErrorIfNotFound);
	}
}
