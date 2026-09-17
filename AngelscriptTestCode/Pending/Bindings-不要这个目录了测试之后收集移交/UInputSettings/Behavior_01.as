/**
 * @version v1
 * @summary Observe whether configured action, axis, and speech mapping names exist on the project input settings.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe whether configured action, axis, and speech mapping names exist on the project input settings.
 * @topic Baseline
 */
// bool UInputSettings.DoesAxisExist(const FName InAxisName);
// bool UInputSettings.DoesSpeechExist(const FName InSpeechName);
// Inputs: UInputSettings::GetInputSettings(), NAME_None and
// n"TestSource.MissingAction/Axis/Speech" as missing names, and the first
// configured mapping name when GetActionMappings/GetAxisMappings/GetSpeechMappings
// are non-empty.
// Expected observations: Missing names report false. NAME_None reports false
// unless a mapping actually uses it. When a mapping exists, Does*Exist on that
// mapping name reports true.
// Boundary/ownership: These queries do not add or remove mappings. Speech
// lookup is the legacy speech-mapping table. Null Settings is setup failure.

namespace TS_UInputSettings_Behavior_01
{
	bool Observe_DoesActionExist_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Behavior_01 setup: required Settings is null");
		}
		bool bMissing = Settings.DoesActionExist(n"TestSource.MissingAction");
		bool bNone = Settings.DoesActionExist(NAME_None);
		const TArray<FInputActionKeyMapping>& Mappings = Settings.GetActionMappings();
		if (Mappings.Num() > 0)
		{
			return !bMissing && !bNone && Settings.DoesActionExist(Mappings[0].ActionName);
		}
		return !bMissing && !bNone;
	}

	bool Observe_DoesAxisExist_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Behavior_01 setup: required Settings is null");
		}
		bool bMissing = Settings.DoesAxisExist(n"TestSource.MissingAxis");
		bool bNone = Settings.DoesAxisExist(NAME_None);
		const TArray<FInputAxisKeyMapping>& Mappings = Settings.GetAxisMappings();
		if (Mappings.Num() > 0)
		{
			return !bMissing && !bNone && Settings.DoesAxisExist(Mappings[0].AxisName);
		}
		return !bMissing && !bNone;
	}

	bool Observe_DoesSpeechExist_Nominal()
	{
		UInputSettings Settings = UInputSettings::GetInputSettings();
		if (Settings is null)
		{
			throw("TS_UInputSettings_Behavior_01 setup: required Settings is null");
		}
		bool bMissing = Settings.DoesSpeechExist(n"TestSource.MissingSpeech");
		bool bNone = Settings.DoesSpeechExist(NAME_None);
		return !bMissing && !bNone;
	}
}
/** @end */
