// Purpose: Observe UEnum value-name lookups, max/count, and validity
// predicates.
// AS-facing API: FName UEnum.GetNameByValue(int64 InValue) const;
// int64 UEnum.GetValueByName(FName InName, EGetByNameFlags Flags = EGetByNameFlags::None) const;
// FString UEnum.GetNameStringByValue(int64 InValue) const;
// int64 UEnum.GetValueByNameString(const FString& SearchString, EGetByNameFlags Flags = EGetByNameFlags::None) const;
// FText UEnum.GetDisplayNameTextByValue(int64 InValue) const;
// int64 UEnum.GetMaxEnumValue() const; int32 UEnum.NumEnums() const;
// bool UEnum.IsValidEnumValue(int64 InValue) const;
// bool UEnum.IsValidEnumName(FName InName) const;
// bool UEnum.ContainsExistingMax() const;
// Inputs: UEnum for EAttachmentRule, first enumerator name/value from index 0,
// missing name "DefinitelyMissing", missing value 9999, Flags None and
// CaseSensitive.
// Expected observations: Name/value lookups round-trip for index 0. Missing
// names/values are invalid. NumEnums is > 0. GetMaxEnumValue is >= the first
// value. EAttachmentRule does not declare a conventional MAX entry.
// Boundary/ownership: Lookups copy names and display text. They do not mutate
// the UEnum object. Missing UEnum is setup failure.

namespace TS_UEnum_Queries_01
{
	bool Observe_GetNameByValue_Nominal()
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

	bool Observe_GetValueByName_Nominal()
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

	bool Observe_GetNameStringByValue_Nominal()
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

	bool Observe_GetValueByNameString_Nominal()
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

	bool Observe_GetDisplayNameTextByValue_Nominal()
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

	bool Observe_GetMaxEnumValue_Nominal()
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

	bool Observe_NumEnums_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
		}
		return EnumObject.NumEnums() > 0;
	}

	bool Observe_IsValidEnumValue_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
		}
		int64 FirstValue = EnumObject.GetValueByName(EnumObject.GetNameByIndex(0));
		return EnumObject.IsValidEnumValue(FirstValue) && !EnumObject.IsValidEnumValue(9999);
	}

	bool Observe_IsValidEnumName_Nominal()
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

	bool Observe_ContainsExistingMax_Nominal()
	{
		UEnum EnumObject = Cast<UEnum>(FindObject("/Script/Engine.EAttachmentRule"));
		if (EnumObject is null)
		{
			throw("TS_UEnum_Queries_01 setup: required EAttachmentRule UEnum is null");
		}
		return !EnumObject.ContainsExistingMax();
	}
}
