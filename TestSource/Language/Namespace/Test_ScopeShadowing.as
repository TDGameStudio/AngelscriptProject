// Theme: Language.Namespace. Value oracle: inner names shadow outer; C++ still executes.
// CSV SourceShape is NegativeDiagnostic; C++ BuildModule + ExpectGlobalReturn (not AssertFailsToCompile).
// C++: AngelscriptCoverageNamespaceTests.cpp::ScopeShadowing
// sha256=6c0ebc91e7b829d3e5088b9f93ec798e1f0d06b10cfcb7c7ea845131a17b014e; lines 510-604.
// Oracle: LocalShadowsGlobal 50; InnerShadowsOuter 20; MultipleShadowLevels 3;
// ShadowingInLoop 100; ShadowingSameType 30; AccessOuterAfterInner 10;
// ShadowingInConditional(true) 200; ParameterShadowsMember(5) == 105.
// Extra: ShadowingInConditional(false) == 100.
// Keep UPROPERTY Value. C++ expected-error text is a warning, not a compile-fail.

UCLASS()
class AScopeShadowMemberActor : AActor
{
	UPROPERTY()
	int Value = 100;

	UFUNCTION()
	int ParameterShadowsMember(int Value)
	{
		return Value + this.Value;
	}
}

const int GlobalValue = 100;

int LocalShadowsGlobal()
{
	int GlobalValue = 50;  // Shadows global
	return GlobalValue;
}

int InnerShadowsOuter()
{
	int X = 10;
	{
		int X = 20;  // Shadows outer X
		return X;
	}
}

int MultipleShadowLevels()
{
	int Value = 1;
	{
		int Value = 2;  // Shadow level 1
		{
			int Value = 3;  // Shadow level 2
			return Value;
		}
	}
}

int ShadowingInLoop()
{
	int i = 100;
	int Sum = 0;
	for (int i = 0; i < 5; i++)  // Shadows outer i
	{
		Sum += i;
	}
	return i;  // Returns outer i (100)
}

int ShadowingSameType()
{
	int Value = 10;
	{
		int Value = 20;
		{
			int Value = 30;
			return Value;
		}
	}
}

int AccessOuterAfterInner()
{
	int X = 10;
	{
		int X = 20;
		// Inner X is 20
	}
	return X;  // Outer X is still 10
}

int ShadowingInConditional(bool Flag)
{
	int Value = 100;
	if (Flag)
	{
		int Value = 200;  // Shadows outer
		return Value;
	}
	return Value;  // Outer value
}

bool Observe_ScopeShadowing_Nominal()
{
	return LocalShadowsGlobal() == 50
		&& InnerShadowsOuter() == 20
		&& MultipleShadowLevels() == 3
		&& ShadowingInLoop() == 100
		&& ShadowingSameType() == 30
		&& AccessOuterAfterInner() == 10
		&& ShadowingInConditional(true) == 200;
}

int Observe_ShadowingInConditional_FalseBoundary()
{
	return ShadowingInConditional(false);
}
