// Theme: Definitions.UProperty. Positive: Transient sets CPF_Transient.
// C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::TransientSpecifierSetsCPFTransient
// Oracle: CachedValue has CPF_Transient. Extra: default 0; EmptyCachedValue stays 0.
// DefaultSafe.

UCLASS()
class UTransientTestObj : UObject
{
	UPROPERTY(Transient)
	int CachedValue;

	UPROPERTY(Transient)
	int EmptyCachedValue = 0;
}

int Observe_Transient_DefaultZero()
{
	return 0;
}

int Observe_Transient_EmptyIndependent()
{
	int CachedValue = 0;
	int EmptyCachedValue = 0;
	CachedValue = 8;
	return EmptyCachedValue;
}
