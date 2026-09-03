/**
 * Not TSet API. Kept here until moved.
 *
 * @Theme Containers.TSet
 * @Subject Misplaced
 * @Harness Function
 * @Tag Containers.TSet.InputSettingsAndRuntimeMappingApi
 */

// Theme: Containers.TSet. Positive: UInputSettings reads plus UPlayerInput remap signatures.
// C++: AngelscriptCoverageInputTests.cpp::InputSettingsAndRuntimeMappingApi
// ExecuteAndExpectInt InputSettingsReadApi()==1 and RuntimeMappingSignatureEntry()==1.
// Extra: missing action/axis names stay absent; RuntimeMappingSignatureEntry is the constant 1.
// DefaultSafe. Source owns locals. PlayerInput is not invoked from observations.

int InputSettingsReadApi()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings == nullptr)
	{
		return 0;
	}

	FName UniqueAction = Settings.GetUniqueActionName(n"CoverageAction");
	FName UniqueAxis = Settings.GetUniqueAxisName(n"CoverageAxis");
	int ActionCount = Settings.GetActionMappings().Num();
	int AxisCount = Settings.GetAxisMappings().Num();
	bool bMissingAction = Settings.DoesActionExist(n"DefinitelyMissingCoverageAction") == false;
	bool bMissingAxis = Settings.DoesAxisExist(n"DefinitelyMissingCoverageAxis") == false;
	return UniqueAction != NAME_None && UniqueAxis != NAME_None && ActionCount >= 0 && AxisCount >= 0 && bMissingAction && bMissingAxis ? 1 : 0;
}

void RuntimeMappingSignaturesCompile(UPlayerInput PlayerInput, FInputActionKeyMapping ActionMapping, FInputAxisKeyMapping AxisMapping)
{
	PlayerInput.AddActionMapping(ActionMapping);
	PlayerInput.RemoveActionMapping(ActionMapping);
	PlayerInput.AddAxisMapping(AxisMapping);
	PlayerInput.RemoveAxisMapping(AxisMapping);
	PlayerInput.ForceRebuildingKeyMaps();
	int ActionKeyCount = PlayerInput.GetKeysForAction(n"CoverageAction").Num();
	int AxisKeyCount = PlayerInput.GetKeysForAxis(n"CoverageAxis").Num();
	if (ActionKeyCount < 0 || AxisKeyCount < 0)
	{
		return;
	}
}

int RuntimeMappingSignatureEntry()
{
	return 1;
}

int Observe_InputSettingsReadApi_Nominal()
{
	return InputSettingsReadApi();
}

int Observe_RuntimeMappingSignatureEntry_Nominal()
{
	return RuntimeMappingSignatureEntry();
}

bool Observe_InputSettings_MissingNamesBoundary()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings == nullptr)
	{
		return false;
	}
	return Settings.DoesActionExist(n"DefinitelyMissingCoverageAction") == false
		&& Settings.DoesAxisExist(n"DefinitelyMissingCoverageAxis") == false;
}
