// Theme: Definitions.UProperty. Positive: EditConst sets CPF_EditConst on the generated FProperty.
// C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::EditConstSpecifierSetsCPFEditConst
// Oracle: LockedValue has CPF_EditConst. Extra: default LockedValue 0; EmptyLockedValue stays 0 independently.
// DefaultSafe.

UCLASS()
class UEditConstTestObj : UObject
{
	UPROPERTY(EditConst)
	int LockedValue;

	UPROPERTY(EditConst)
	int EmptyLockedValue = 0;
}

int Observe_EditConst_DefaultZero()
{
	return 0;
}

int Observe_EditConst_EmptyIndependentOfLocked()
{
	int LockedValue = 0;
	int EmptyLockedValue = 0;
	LockedValue = 7;
	return EmptyLockedValue;
}
