// Theme: Language.Syntax.EdgeCases. Positive initial annotated module.
// C++: AngelscriptCompilerFailureTests.cpp::SyntaxErrorFailsWithoutResidualReflection block 1
// sha256=d90cd300d6a64ea61217049be42b63544b3eaca6f35685785e71b1ac6c7b1e26; lines 169-179.
// Oracle: GetValue returns 7. Extra: a second instance also returns 7.
// DefaultSafe.

UCLASS()
class UBrokenCarrier : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 7;
	}
}

bool Observe_SyntaxErrorInitial_Nominal(UBrokenCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_SyntaxErrorFailsWithoutResidualReflection_01 setup: required Carrier is null");
	}
	return Carrier.GetValue() == 7;
}

bool Observe_SyntaxErrorInitial_SecondInstance(UBrokenCarrier First, UBrokenCarrier Second)
{
	if (First is null)
	{
		throw("Test_SyntaxErrorFailsWithoutResidualReflection_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SyntaxErrorFailsWithoutResidualReflection_01 setup: required Second is null");
	}
	return First.GetValue() == 7 && Second.GetValue() == 7;
}
