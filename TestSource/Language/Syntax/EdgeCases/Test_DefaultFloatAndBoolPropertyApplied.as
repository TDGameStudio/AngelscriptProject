// Theme: Language.Syntax.EdgeCases. Positive CDO float+bool defaults.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFloatAndBoolPropertyApplied
// sha256=d774accb145943002fef49bba4c55d2c0d13697889e90a79e77163149690fc08; lines 167-190.
// Oracle: VerifyDefaults returns 42. Extra: MyFloat=0 returns 1; bEnabled=false
// returns 2. DefaultSafe.

UCLASS()
class UDefaultFloatBoolCarrier : UObject
{
	UPROPERTY()
	float MyFloat;

	UPROPERTY()
	bool bEnabled;

	default MyFloat = 3.14f;
	default bEnabled = true;

	UFUNCTION()
	int VerifyDefaults()
	{
		if (MyFloat < 3.13f || MyFloat > 3.15f)
		{
			return 1;
		}
		if (!bEnabled)
		{
			return 2;
		}
		return 42;
	}
}

bool Observe_DefaultFloatBool_Nominal(UDefaultFloatBoolCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultFloatAndBoolPropertyApplied setup: required Carrier is null");
	}
	return Carrier.VerifyDefaults() == 42;
}

bool Observe_DefaultFloatBool_FloatBoundary(UDefaultFloatBoolCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultFloatAndBoolPropertyApplied setup: required Carrier is null");
	}
	Carrier.MyFloat = 0.0f;
	return Carrier.VerifyDefaults() == 1;
}

bool Observe_DefaultFloatBool_DisabledBoundary(UDefaultFloatBoolCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultFloatAndBoolPropertyApplied setup: required Carrier is null");
	}
	Carrier.bEnabled = false;
	return Carrier.VerifyDefaults() == 2;
}
