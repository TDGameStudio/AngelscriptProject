// Theme: Feature.Inheritance. Positive default keyword overrides the inline initializer.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultOverridesInlineInitializerPriority
// sha256 from theme-refs TS-FEAT-0009; lines 426-441.
// Oracle: GetScore executes and returns 20 (default 20 beats inline 10).
// Extra: Score after zero assign is 0; two locals independent. DefaultSafe.

UCLASS()
class UDefaultPriorityCarrier : UObject
{
	UPROPERTY()
	int Score = 10;

	default Score = 20;

	UFUNCTION()
	int GetScore()
	{
		return Score;
	}
}

int Observe_DefaultPriority_GetScore(UDefaultPriorityCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultOverridesInlineInitializerPriority setup: required Carrier is null");
	}
	return Carrier.GetScore();
}

int Observe_DefaultPriority_ZeroBoundary(UDefaultPriorityCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultOverridesInlineInitializerPriority setup: required Carrier is null");
	}
	Carrier.Score = 0;
	return Carrier.GetScore();
}

bool Observe_DefaultPriority_TwoLocalsIndependent(UDefaultPriorityCarrier First, UDefaultPriorityCarrier Second)
{
	if (First is null)
	{
		throw("Test_DefaultOverridesInlineInitializerPriority setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DefaultOverridesInlineInitializerPriority setup: required Second is null");
	}
	First.Score = 0;
	return First.GetScore() == 0 && Second.GetScore() == 20;
}
