/**
 * @version v1
 * @summary Observe UEnum name/index lookup in both directions, including display text and ErrorIfNotFound diagnostics.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UEnum name/index lookup in both directions, including display text and ErrorIfNotFound diagnostics.
 * @topic Baseline
 */
// int32 UEnum.GetIndexByName(FName InName, EGetByNameFlags Flags = EGetByNameFlags::None) const;
// FString UEnum.GetNameStringByIndex(int32 InIndex) const;
// int32 UEnum.GetIndexByNameString(const FString& SearchString, EGetByNameFlags Flags = EGetByNameFlags::None) const;
// FText UEnum.GetDisplayNameTextByIndex(int32 InIndex) const;
// Inputs: UEnum for EAttachmentRule via FindObject("/Script/Engine.EAttachmentRule"),
// index 0 and last NumEnums()-1, KeepWorld name/string, missing
// "DefinitelyMissing", Flags None/CaseSensitive/CheckAuthoredName, and
// ErrorIfNotFound as the diagnostic flag.
// Expected observations: Index 0 returns a non-none name. GetIndexByName of
// that name round-trips to the same index. Invalid index/name returns none
// or INDEX_NONE under Flags None. Display text at 0 is non-empty.
// Boundary/ownership: Lookups copy FName/FString/FText. ErrorIfNotFound on a
// missing name is the diagnostic path. Missing UEnum is setup failure.

namespace TS_UEnum_IndexAndIteration_01
{
	bool Observe_GetNameByIndex_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_IndexAndIteration_01 setup: required EAttachmentRule UEnum is null");
		}
		int32 Num = EnumObject.NumEnums();
		FName First = EnumObject.GetNameByIndex(0);
		FName Last = EnumObject.GetNameByIndex(Num - 1);
		FName Invalid = EnumObject.GetNameByIndex(-1);
		FName PastEnd = EnumObject.GetNameByIndex(Num + 4);
		return !First.IsNone() && !Last.IsNone() && Invalid.IsNone() && PastEnd.IsNone();
	}

	bool Observe_GetIndexByName_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_IndexAndIteration_01 setup: required EAttachmentRule UEnum is null");
		}
		FName FirstName = EnumObject.GetNameByIndex(0);
		int32 FirstIndex = EnumObject.GetIndexByName(FirstName);
		int32 FirstDefaultFlags = EnumObject.GetIndexByName(FirstName, EGetByNameFlags::None);
		int32 MissingIndex = EnumObject.GetIndexByName(n"DefinitelyMissing");
		int32 CaseIndex = EnumObject.GetIndexByName(FirstName, EGetByNameFlags::CaseSensitive);
		int32 AuthoredIndex = EnumObject.GetIndexByName(FirstName, EGetByNameFlags::CheckAuthoredName);
		return FirstIndex == 0 &&
			FirstDefaultFlags == 0 &&
			MissingIndex < 0 &&
			CaseIndex == 0 &&
			AuthoredIndex == 0;
	}

	bool Observe_GetNameStringByIndex_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_IndexAndIteration_01 setup: required EAttachmentRule UEnum is null");
		}
		FString First = EnumObject.GetNameStringByIndex(0);
		FString Invalid = EnumObject.GetNameStringByIndex(-1);
		FString Last = EnumObject.GetNameStringByIndex(EnumObject.NumEnums() - 1);
		return First.Len() > 0 && Invalid.IsEmpty() && Last.Len() > 0;
	}

	bool Observe_GetIndexByNameString_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_IndexAndIteration_01 setup: required EAttachmentRule UEnum is null");
		}
		FString FirstString = EnumObject.GetNameStringByIndex(0);
		int32 FirstIndex = EnumObject.GetIndexByNameString(FirstString);
		int32 FirstNone = EnumObject.GetIndexByNameString(FirstString, EGetByNameFlags::None);
		int32 MissingIndex = EnumObject.GetIndexByNameString("DefinitelyMissing");
		int32 CaseIndex = EnumObject.GetIndexByNameString(FirstString, EGetByNameFlags::CaseSensitive);
		int32 AuthoredIndex = EnumObject.GetIndexByNameString(FirstString, EGetByNameFlags::CheckAuthoredName);
		return FirstIndex == 0 &&
			FirstNone == 0 &&
			MissingIndex < 0 &&
			CaseIndex == 0 &&
			AuthoredIndex == 0;
	}

	bool Observe_GetDisplayNameTextByIndex_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_IndexAndIteration_01 setup: required EAttachmentRule UEnum is null");
		}
		FText First = EnumObject.GetDisplayNameTextByIndex(0);
		FText Last = EnumObject.GetDisplayNameTextByIndex(EnumObject.NumEnums() - 1);
		FString FirstString = First.ToString();
		FString LastString = Last.ToString();
		return FirstString.Len() > 0 && LastString.Len() > 0;
	}

	void ExerciseExpectedFailure()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		int32 Missing = EnumObject.GetIndexByName(n"DefinitelyMissing", EGetByNameFlags::ErrorIfNotFound);
		int32 MissingString = EnumObject.GetIndexByNameString("DefinitelyMissing", EGetByNameFlags::ErrorIfNotFound);
	}
}
/** @end */
