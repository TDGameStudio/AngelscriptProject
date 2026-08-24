// Theme: Definitions.UProperty. Positive: AdvancedDisplay sets CPF_AdvancedDisplay.
// C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::AdvancedDisplaySpecifierSetsCPFAdvancedDisplay
// Oracle: AdvancedProp has CPF_AdvancedDisplay. Extra: default 0; EmptyAdvancedProp stays 0.
// DefaultSafe.

UCLASS()
class UAdvancedDisplayTestObj : UObject
{
	UPROPERTY(AdvancedDisplay)
	int AdvancedProp;

	UPROPERTY(AdvancedDisplay)
	int EmptyAdvancedProp = 0;
}

int Observe_AdvancedDisplay_DefaultZero()
{
	return 0;
}

int Observe_AdvancedDisplay_EmptyIndependent()
{
	int AdvancedProp = 0;
	int EmptyAdvancedProp = 0;
	AdvancedProp = 4;
	return EmptyAdvancedProp;
}
