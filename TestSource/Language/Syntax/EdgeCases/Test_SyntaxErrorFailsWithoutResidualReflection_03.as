// Theme: Language.Syntax.EdgeCases. Positive recovered annotated module.
// C++: AngelscriptCompilerFailureTests.cpp::SyntaxErrorFailsWithoutResidualReflection block 3
// sha256=eb91dc4ae8078f5dc428a4f855de8086ea77448f6c9a60f4ab568fab6773f662; lines 191-201.
// Oracle: GetValue returns 9. Extra: a second instance also returns 9.
// DefaultSafe.

UCLASS()
class UBrokenCarrier : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 9;
	}
}

bool Observe_SyntaxErrorFixed_Nominal(UBrokenCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_SyntaxErrorFailsWithoutResidualReflection_03 setup: required Carrier is null");
	}
	return Carrier.GetValue() == 9;
}

bool Observe_SyntaxErrorFixed_SecondInstance(UBrokenCarrier First, UBrokenCarrier Second)
{
	if (First is null)
	{
		throw("Test_SyntaxErrorFailsWithoutResidualReflection_03 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SyntaxErrorFailsWithoutResidualReflection_03 setup: required Second is null");
	}
	return First.GetValue() == 9 && Second.GetValue() == 9;
}
