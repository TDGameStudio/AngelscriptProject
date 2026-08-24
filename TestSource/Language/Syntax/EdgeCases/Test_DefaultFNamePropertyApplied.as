// Theme: Language.Syntax.EdgeCases. Positive CDO FName default.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFNamePropertyApplied
// sha256=5a11c4a8d8378be2dd4c9b0088cb1b8ed9083f3bd24586fffef3b29595094ca3; lines 53-62.
// Oracle: CDO MyName is n"TestName". Extra: MyName is not NAME_None; a second
// instance stays n"TestName" after the first is cleared. DefaultSafe.

UCLASS()
class UDefaultFNameCarrier : UObject
{
	UPROPERTY()
	FName MyName;

	default MyName = n"TestName";
}

bool Observe_DefaultFName_Nominal(UDefaultFNameCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultFNamePropertyApplied setup: required Carrier is null");
	}
	return Carrier.MyName == n"TestName";
}

bool Observe_DefaultFName_NotNoneBoundary(UDefaultFNameCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultFNamePropertyApplied setup: required Carrier is null");
	}
	return !Carrier.MyName.IsNone();
}

bool Observe_DefaultFName_SecondInstanceIndependent(UDefaultFNameCarrier First, UDefaultFNameCarrier Second)
{
	if (First is null)
	{
		throw("Test_DefaultFNamePropertyApplied setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DefaultFNamePropertyApplied setup: required Second is null");
	}
	First.MyName = NAME_None;
	return First.MyName.IsNone() && Second.MyName == n"TestName";
}
