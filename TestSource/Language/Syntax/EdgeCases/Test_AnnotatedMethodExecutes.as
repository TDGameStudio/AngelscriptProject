// Theme: Language.Syntax.EdgeCases. Positive annotated method mutation.
// C++: AngelscriptCompilerExecutionTests.cpp::AnnotatedMethodExecutes
// sha256=b488c9f97d0e8258d61ec07e26f33bcf03b05cf43fb76f33ede54121d28c9370; lines 35-49.
// Oracle: IncrementAndGetScore returns 42 and persists Score=42. Extra: default
// Score is 41; a second instance stays 41 after the first mutates. DefaultSafe.

UCLASS()
class UCompilerExecutionCarrier : UObject
{
	UPROPERTY()
	int Score = 41;

	UFUNCTION()
	int IncrementAndGetScore()
	{
		Score += 1;
		return Score;
	}
}

bool Observe_AnnotatedMethod_Nominal(UCompilerExecutionCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_AnnotatedMethodExecutes setup: required Carrier is null");
	}
	return Carrier.IncrementAndGetScore() == 42 && Carrier.Score == 42;
}

bool Observe_AnnotatedMethod_DefaultEmpty(UCompilerExecutionCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_AnnotatedMethodExecutes setup: required Carrier is null");
	}
	return Carrier.Score == 41;
}

bool Observe_AnnotatedMethod_InstanceIndependence(UCompilerExecutionCarrier First, UCompilerExecutionCarrier Second)
{
	if (First is null)
	{
		throw("Test_AnnotatedMethodExecutes setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_AnnotatedMethodExecutes setup: required Second is null");
	}
	First.IncrementAndGetScore();
	return First.Score == 42 && Second.Score == 41;
}
