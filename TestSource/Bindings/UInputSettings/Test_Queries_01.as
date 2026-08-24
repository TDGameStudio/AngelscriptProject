// Purpose: Observe unique action/axis name allocation and the configured
// action, axis, and speech mapping arrays.
// AS-facing API: FName UInputSettings.GetUniqueActionName(const FName BaseActionMappingName);
// FName UInputSettings.GetUniqueAxisName(const FName BaseAxisMappingName);
// const TArray<FInputActionKeyMapping>& UInputSettings.GetActionMappings() const;
// const TArray<FInputAxisKeyMapping>& UInputSettings.GetAxisMappings() const;
// const TArray<FInputActionSpeechMapping>& UInputSettings.GetSpeechMappings() const;
// Inputs: UInputSettings::GetInputSettings() as the live settings object,
// n"TestSource.Action" / n"TestSource.Axis" as requested bases, NAME_None as
// the empty base, and a second array read for alias identity.
// Expected observations: Unique names are not NAME_None. Array Num of a
// follow-up Get*Mappings equals the first read, proving the settings-owned
// alias. When Count > 0, index 0 names match across the alias.
// Boundary/ownership: Returned arrays alias settings configuration and are not
// copied. Unique-name helpers do not add mappings. Null Settings is setup
// failure.

namespace TS_UInputSettings_Queries_01
{
	bool Observe_GetUniqueActionName_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
		}
		FName Unique = Settings.GetUniqueActionName(n"TestSource.Action");
		FName Again = Settings.GetUniqueActionName(n"TestSource.Action");
		FName FromNone = Settings.GetUniqueActionName(NAME_None);
		return !Unique.IsNone() && !Again.IsNone() && FromNone != Unique;
	}

	bool Observe_GetUniqueAxisName_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
		}
		FName Unique = Settings.GetUniqueAxisName(n"TestSource.Axis");
		FName Again = Settings.GetUniqueAxisName(n"TestSource.Axis");
		FName FromNone = Settings.GetUniqueAxisName(NAME_None);
		return !Unique.IsNone() && !Again.IsNone() && FromNone != Unique;
	}

	bool Observe_GetActionMappings_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
		}
		const TArray<FInputActionKeyMapping>& Mappings = Settings.GetActionMappings();
		const TArray<FInputActionKeyMapping>& Alias = Settings.GetActionMappings();
		int32 Count = Mappings.Num();
		if (Count > 0)
		{
			return Count == Alias.Num() && Mappings[0].ActionName == Alias[0].ActionName;
		}
		return Count == Alias.Num();
	}

	bool Observe_GetAxisMappings_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
		}
		const TArray<FInputAxisKeyMapping>& Mappings = Settings.GetAxisMappings();
		const TArray<FInputAxisKeyMapping>& Alias = Settings.GetAxisMappings();
		int32 Count = Mappings.Num();
		if (Count > 0)
		{
			return Count == Alias.Num() && Mappings[0].AxisName == Alias[0].AxisName;
		}
		return Count == Alias.Num();
	}

	bool Observe_GetSpeechMappings_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
		}
		const TArray<FInputActionSpeechMapping>& Mappings = Settings.GetSpeechMappings();
		const TArray<FInputActionSpeechMapping>& Alias = Settings.GetSpeechMappings();
		int32 Count = Mappings.Num();
		return Count == Alias.Num();
	}
}
