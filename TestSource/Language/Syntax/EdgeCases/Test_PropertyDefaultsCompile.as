// Theme: Language.Syntax.EdgeCases. Positive CDO default override.
// C++: AngelscriptCompilerEndToEndTests.cpp::PropertyDefaultsCompile
// sha256=fb16cb51d60fdc47c447e1ef8821cbe4dd892a2e7983a6db09c6894b72638207; lines 160-173.
// Oracle: generated CDO Score is 21 (overrides inline 7). Extra: Tags contains
// n"Alpha"; a second instance is independent and still Score 21. DefaultSafe.

UCLASS()
class UCompilerDefaultsCarrier : UObject
{
	UPROPERTY()
	int Score = 7;

	UPROPERTY()
	TArray<FName> Tags;

	default Score = 21;
	default Tags.Add(n"Alpha");
}

bool Observe_PropertyDefaults_Nominal(UCompilerDefaultsCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_PropertyDefaultsCompile setup: required Carrier is null");
	}
	return Carrier.Score == 21 && Carrier.Tags.Contains(n"Alpha") && Carrier.Tags.Num() >= 1;
}

bool Observe_PropertyDefaults_SecondInstanceIndependent(UCompilerDefaultsCarrier First, UCompilerDefaultsCarrier Second)
{
	if (First is null)
	{
		throw("Test_PropertyDefaultsCompile setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PropertyDefaultsCompile setup: required Second is null");
	}
	First.Score = 0;
	First.Tags.Empty();
	return First.Score == 0 && First.Tags.Num() == 0 && Second.Score == 21 && Second.Tags.Contains(n"Alpha");
}
