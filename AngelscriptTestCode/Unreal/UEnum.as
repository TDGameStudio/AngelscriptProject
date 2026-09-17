/**
 * @version v1
 * @summary UEnum host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UEnum
 *
 * generate-enum-prefix
 * eattachmentrule-enumerators-copy-assign
 * egetbynameflags-enumerators-copy-assign
 * get-name-by-index
 * get-index-by-name
 * get-name-string-by-index
 * get-index-by-name-string
 * get-display-name-text-by-index
 * egetbynameflags-none-matches-getindexbyname
 * egetbynameflags-errorifnotfound-still-finds
 * egetbynameflags-casesensitive-finds-first
 * egetbynameflags-checkauthoredname-finds-index
 * get-name-by-value
 * get-value-by-name
 * get-name-string-by-value
 * get-value-by-name-string
 * get-display-name-text-by-value
 * get-max-enum-value
 * num-enums
 * is-valid-enum-value
 * is-valid-enum-name
 * contains-existing-max
 */
/**
 * @begin generate-enum-prefix
 * @summary mutate enumerator names.
 * @topic Unreal
 */
/**
 * @function ObserveGenerateEnumPrefixNominal
 * @summary mutate enumerator names.
 * @covers UEnum.generate-enum-prefix
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGenerateEnumPrefixNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Behavior_01 setup: required EAttachmentRule UEnum is null");
	}
	FString Prefix = EnumObject.GenerateEnumPrefix();
	FString Repeated = EnumObject.GenerateEnumPrefix();
	return Prefix.Len() > 0 && Repeated == Prefix;
}
/** @end */
/**
 * @begin eattachmentrule-enumerators-copy-assign
 * @summary EAttachmentRule enumerators copy and assign by value and stay distinct.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary EAttachmentRule enumerators copy and assign by value and stay distinct.
 * @covers UEnum.eattachmentrule-enumerators-copy-assign
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	EAttachmentRule World = EAttachmentRule::KeepWorld;
	EAttachmentRule Relative = EAttachmentRule::KeepRelative;
	EAttachmentRule Snap = EAttachmentRule::SnapToTarget;
	EAttachmentRule Copied = World;
	bool bCopyEqualsSource = Copied == World;
	Copied = Relative;
	return bCopyEqualsSource &&
		Copied == Relative &&
		World == EAttachmentRule::KeepWorld &&
		World != Relative &&
		Relative != Snap &&
		World != Snap;
}
/** @end */
/**
 * @begin egetbynameflags-enumerators-copy-assign
 * @summary EGetByNameFlags enumerators copy and assign by value and stay distinct.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary EGetByNameFlags enumerators copy and assign by value and stay distinct.
 * @covers UEnum.egetbynameflags-enumerators-copy-assign
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	EGetByNameFlags None = EGetByNameFlags::None;
	EGetByNameFlags ErrorIfNotFound = EGetByNameFlags::ErrorIfNotFound;
	EGetByNameFlags CaseSensitive = EGetByNameFlags::CaseSensitive;
	EGetByNameFlags CheckAuthoredName = EGetByNameFlags::CheckAuthoredName;
	EGetByNameFlags Copied = None;
	bool bCopyEqualsNone = Copied == None;
	Copied = ErrorIfNotFound;
	return bCopyEqualsNone &&
		Copied == ErrorIfNotFound &&
		None != ErrorIfNotFound &&
		None != CaseSensitive &&
		None != CheckAuthoredName &&
		ErrorIfNotFound != CaseSensitive &&
		CaseSensitive != CheckAuthoredName;
}
/** @end */
/**
 * @begin get-name-by-index
 * @summary Inputs: UEnum for EAttachmentRule
 * @topic Unreal
 */
/**
 * @function ObserveGetNameByIndexNominal
 * @summary Inputs: UEnum for EAttachmentRule
 * @covers UEnum.get-name-by-index
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: UEnum for EAttachmentRule

 via FindObject("/Script/Engine.EAttachmentRule"),
// index 0 and last NumEnums()-1, KeepWorld name/string, missing
// "DefinitelyMissing", Flags None/CaseSensitive/CheckAuthoredName, and
// ErrorIfNotFound as the diagnostic flag.
// Expected observations: Index 0 returns a non-none name. GetIndexByName of
// that name round-trips to the same index. Invalid index/name returns none
// or INDEX_NONE under Flags None. Display text at 0 is non-empty.
// Boundary/ownership: Lookups copy FName/FString/FText. ErrorIfNotFound on a
// missing name is the diagnostic path. Missing UEnum is setup failure.
bool ObserveGetNameByIndexNominal()
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
/** @end */
/**
 * @begin get-index-by-name
 * @summary missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetIndexByNameNominal
 * @summary missing name is the diagnostic path.
 * @covers UEnum.get-index-by-name
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: UEnum for EAttachmentRule

bool ObserveGetIndexByNameNominal()
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
/** @end */
/**
 * @begin get-name-string-by-index
 * @summary missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetNameStringByIndexNominal
 * @summary missing name is the diagnostic path.
 * @covers UEnum.get-name-string-by-index
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: UEnum for EAttachmentRule

bool ObserveGetNameStringByIndexNominal()
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
/** @end */
/**
 * @begin get-index-by-name-string
 * @summary missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetIndexByNameStringNominal
 * @summary missing name is the diagnostic path.
 * @covers UEnum.get-index-by-name-string
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: UEnum for EAttachmentRule

bool ObserveGetIndexByNameStringNominal()
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
/** @end */
/**
 * @begin get-display-name-text-by-index
 * @summary missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetDisplayNameTextByIndexNominal
 * @summary missing name is the diagnostic path.
 * @covers UEnum.get-display-name-text-by-index
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: UEnum for EAttachmentRule

bool ObserveGetDisplayNameTextByIndexNominal()
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
/** @end */
/**
 * @begin egetbynameflags-none-matches-getindexbyname
 * @summary EGetByNameFlags::None matches default GetIndexByName omission at index 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary EGetByNameFlags::None matches default GetIndexByName omission at index 0.
 * @covers UEnum.egetbynameflags-none-matches-getindexbyname
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
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
/** @end */
/**
 * @begin egetbynameflags-errorifnotfound-still-finds
 * @summary EGetByNameFlags::ErrorIfNotFound still finds a present enumerator at index 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary EGetByNameFlags::ErrorIfNotFound still finds a present enumerator at index 0.
 * @covers UEnum.egetbynameflags-errorifnotfound-still-finds
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
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
/** @end */
/**
 * @begin egetbynameflags-casesensitive-finds-first
 * @summary EGetByNameFlags::CaseSensitive finds the first enumerator at index 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary EGetByNameFlags::CaseSensitive finds the first enumerator at index 0.
 * @covers UEnum.egetbynameflags-casesensitive-finds-first
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
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
/** @end */
/**
 * @begin egetbynameflags-checkauthoredname-finds-index
 * @summary EGetByNameFlags::CheckAuthoredName finds index 0 by name and by name string.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary EGetByNameFlags::CheckAuthoredName finds index 0 by name and by name string.
 * @covers UEnum.egetbynameflags-checkauthoredname-finds-index
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface006Nominal()
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
/** @end */
/**
 * @begin get-name-by-value
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveGetNameByValueNominal
 * @summary the UEnum object.
 * @covers UEnum.get-name-by-value
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNameByValueNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	int64 FirstValue = EnumObject.GetValueByName(EnumObject.GetNameByIndex(0));
	FName FirstName = EnumObject.GetNameByValue(FirstValue);
	FName MissingName = EnumObject.GetNameByValue(9999);
	return !FirstName.IsNone() && MissingName.IsNone();
}
/** @end */
/**
 * @begin get-value-by-name
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveGetValueByNameNominal
 * @summary the UEnum object.
 * @covers UEnum.get-value-by-name
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetValueByNameNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	FName FirstName = EnumObject.GetNameByIndex(0);
	int64 FirstValue = EnumObject.GetValueByName(FirstName);
	int64 FirstNone = EnumObject.GetValueByName(FirstName, EGetByNameFlags::None);
	int64 MissingValue = EnumObject.GetValueByName(n"DefinitelyMissing");
	int64 CaseValue = EnumObject.GetValueByName(FirstName, EGetByNameFlags::CaseSensitive);
	return FirstValue == FirstNone &&
		FirstValue >= 0 &&
		MissingValue != FirstValue &&
		CaseValue == FirstValue;
}
/** @end */
/**
 * @begin get-name-string-by-value
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveGetNameStringByValueNominal
 * @summary the UEnum object.
 * @covers UEnum.get-name-string-by-value
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNameStringByValueNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	int64 FirstValue = EnumObject.GetValueByName(EnumObject.GetNameByIndex(0));
	FString First = EnumObject.GetNameStringByValue(FirstValue);
	FString Missing = EnumObject.GetNameStringByValue(9999);
	return First.Len() > 0 && Missing.IsEmpty();
}
/** @end */
/**
 * @begin get-value-by-name-string
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveGetValueByNameStringNominal
 * @summary the UEnum object.
 * @covers UEnum.get-value-by-name-string
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetValueByNameStringNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	FString FirstString = EnumObject.GetNameStringByIndex(0);
	int64 FirstValue = EnumObject.GetValueByNameString(FirstString);
	int64 FirstNone = EnumObject.GetValueByNameString(FirstString, EGetByNameFlags::None);
	int64 MissingValue = EnumObject.GetValueByNameString("DefinitelyMissing");
	int64 CaseValue = EnumObject.GetValueByNameString(FirstString, EGetByNameFlags::CaseSensitive);
	return FirstValue == FirstNone &&
		FirstValue >= 0 &&
		MissingValue != FirstValue &&
		CaseValue == FirstValue;
}
/** @end */
/**
 * @begin get-display-name-text-by-value
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveGetDisplayNameTextByValueNominal
 * @summary the UEnum object.
 * @covers UEnum.get-display-name-text-by-value
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDisplayNameTextByValueNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	int64 FirstValue = EnumObject.GetValueByName(EnumObject.GetNameByIndex(0));
	FText First = EnumObject.GetDisplayNameTextByValue(FirstValue);
	FString FirstString = First.ToString();
	return FirstString.Len() > 0;
}
/** @end */
/**
 * @begin get-max-enum-value
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxEnumValueNominal
 * @summary the UEnum object.
 * @covers UEnum.get-max-enum-value
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMaxEnumValueNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	int64 MaxValue = EnumObject.GetMaxEnumValue();
	int64 FirstValue = EnumObject.GetValueByName(EnumObject.GetNameByIndex(0));
	return MaxValue >= FirstValue;
}
/** @end */
/**
 * @begin num-enums
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveNumEnumsNominal
 * @summary the UEnum object.
 * @covers UEnum.num-enums
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveNumEnumsNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	return EnumObject.NumEnums() > 0;
}
/** @end */
/**
 * @begin is-valid-enum-value
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidEnumValueNominal
 * @summary the UEnum object.
 * @covers UEnum.is-valid-enum-value
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidEnumValueNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	int64 FirstValue = EnumObject.GetValueByName(EnumObject.GetNameByIndex(0));
	return EnumObject.IsValidEnumValue(FirstValue) && !EnumObject.IsValidEnumValue(9999);
}
/** @end */
/**
 * @begin is-valid-enum-name
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidEnumNameNominal
 * @summary the UEnum object.
 * @covers UEnum.is-valid-enum-name
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidEnumNameNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	FName FirstName = EnumObject.GetNameByIndex(0);
	return EnumObject.IsValidEnumName(FirstName) &&
		!EnumObject.IsValidEnumName(n"DefinitelyMissing") &&
		!EnumObject.IsValidEnumName(NAME_None);
}
/** @end */
/**
 * @begin contains-existing-max
 * @summary the UEnum object.
 * @topic Unreal
 */
/**
 * @function ObserveContainsExistingMaxNominal
 * @summary the UEnum object.
 * @covers UEnum.contains-existing-max
 * @inputs UEnum values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveContainsExistingMaxNominal()
{
	UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
	if (EnumObject is null)
	{
		throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
	}
	return !EnumObject.ContainsExistingMax();
}
/** @end */
