// Theme: Definitions.Meta. Positive: UCLASS/UENUM/UMETA preprocessor macro shapes.
// C++: AngelscriptPreprocessorMacroShapeTests.cpp::ClassEnumMetaShapes
// Oracle: EMacroState::Alpha is 0; Beta is the next enumerator. Extra: abstract carrier handle stays null.
// DefaultSafe.

UCLASS(Abstract, BlueprintType)
class UMacroCarrier : UObject
{
}

UENUM(BlueprintType)
enum class EMacroState : uint8
{
	// Alpha Friendly
	Alpha,
	Beta UMETA(DisplayName="Beta Friendly"),
};

int Observe_MacroState_AlphaDefault()
{
	return int(EMacroState::Alpha);
}

int Observe_MacroState_BetaBoundary()
{
	return int(EMacroState::Beta);
}

int Observe_MacroCarrier_EmptyDefaultIsNull()
{
	UMacroCarrier Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
