// Theme: Definitions.UProperty. Positive: NotEditable clears CPF_Edit on the generated FProperty.
// C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::NotEditableSpecifierClearsCPFEdit
// Oracle: HiddenValue does not have CPF_Edit. Extra: default HiddenValue 0; EmptyHiddenValue stays 0.
// DefaultSafe.

UCLASS()
class UNotEditableTestObj : UObject
{
	UPROPERTY(NotEditable)
	int HiddenValue;

	UPROPERTY(NotEditable)
	int EmptyHiddenValue = 0;
}

int Observe_NotEditable_DefaultZero()
{
	return 0;
}

int Observe_NotEditable_EmptyIndependentOfHidden()
{
	int HiddenValue = 0;
	int EmptyHiddenValue = 0;
	HiddenValue = 9;
	return EmptyHiddenValue;
}
