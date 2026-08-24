// Theme: Language.Preprocessor. Positive: CONTEXT_ENABLED selects the explicit
// carrier; the #else UWrongContextCarrier is inactive.
// C++: AngelscriptPreprocessorContextTests.cpp::ExplicitContextControlsFlagsAndDefaults
// lines 33-54; Context.PreprocessorFlags CONTEXT_ENABLED=true.
// sha256=effa82863492dfc277c727e87b4d7aaca599ddb95e27490bdabc2bdea95cc085.
// Oracle: UExplicitContextCarrier is detected; ImplicitProperty default 0;
// ImplicitFunction is callable and does not mutate ImplicitProperty.
// Extra: UWrongContextCarrier / WrongProperty exist only in the skipped branch.
// DefaultSafe. Keep ImplicitFunction, ImplicitProperty, UWrongContextCarrier.

#if CONTEXT_ENABLED
UCLASS()
class UExplicitContextCarrier : UObject
{
	UFUNCTION()
	void ImplicitFunction()
	{
	}

	UPROPERTY()
	int ImplicitProperty;
}
#else
UCLASS()
class UWrongContextCarrier : UObject
{
	UPROPERTY()
	int WrongProperty;
}
#endif

bool Observe_ImplicitProperty_DefaultZero(UExplicitContextCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_ExplicitContextControlsFlagsAndDefaults setup: required Carrier is null");
	}
	return Carrier.ImplicitProperty == 0;
}

bool Observe_ImplicitFunction_NoMutation(UExplicitContextCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_ExplicitContextControlsFlagsAndDefaults setup: required Carrier is null");
	}
	Carrier.ImplicitFunction();
	return Carrier.ImplicitProperty == 0;
}
