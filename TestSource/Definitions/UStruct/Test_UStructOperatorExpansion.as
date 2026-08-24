// Theme: Definitions.UStruct. WorldStory expanded USTRUCT operators and compound assign.
// C++: AngelscriptCoverageUStructTests.cpp::UStructOperatorExpansion
// spawn + BeginPlay + VerifyByPath Results==25 (C=9, D=24, E=4, F=-12).
// Extra: default Value 0; zero-operand subtract; copy independence of +=.
// FixtureIsolated. Keep UPROPERTY name Results.

USTRUCT()
struct FExpandedOperatorStruct
{
	UPROPERTY()
	int Value = 0;

	FExpandedOperatorStruct opSub(const FExpandedOperatorStruct& Other) const
	{
		FExpandedOperatorStruct Result;
		Result.Value = Value - Other.Value;
		return Result;
	}

	FExpandedOperatorStruct opMul(int Scale) const
	{
		FExpandedOperatorStruct Result;
		Result.Value = Value * Scale;
		return Result;
	}

	FExpandedOperatorStruct opDiv(int Divisor) const
	{
		FExpandedOperatorStruct Result;
		Result.Value = Value / Divisor;
		return Result;
	}

	FExpandedOperatorStruct opNeg() const
	{
		FExpandedOperatorStruct Result;
		Result.Value = -Value;
		return Result;
	}

	FExpandedOperatorStruct& opAddAssign(const FExpandedOperatorStruct& Other)
	{
		Value += Other.Value;
		return this;
	}

	FExpandedOperatorStruct& opSubAssign(const FExpandedOperatorStruct& Other)
	{
		Value -= Other.Value;
		return this;
	}

	FExpandedOperatorStruct& opMulAssign(const FExpandedOperatorStruct& Other)
	{
		Value *= Other.Value;
		return this;
	}

	FExpandedOperatorStruct& opDivAssign(const FExpandedOperatorStruct& Other)
	{
		Value /= Other.Value;
		return this;
	}
}

UCLASS()
class AExpandedOperatorActor : AActor
{
	UPROPERTY()
	int Results = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FExpandedOperatorStruct A;
		A.Value = 12;
		FExpandedOperatorStruct B;
		B.Value = 3;
		FExpandedOperatorStruct C = A - B;
		FExpandedOperatorStruct D = A * 2;
		FExpandedOperatorStruct E = A / 3;
		FExpandedOperatorStruct F = -A;
		C += B;
		C -= B;
		C *= B;
		C /= B;
		Results = C.Value + D.Value + E.Value + F.Value;
	}
}

int Observe_ExpandedOperators_NominalResults()
{
	FExpandedOperatorStruct A;
	A.Value = 12;
	FExpandedOperatorStruct B;
	B.Value = 3;
	FExpandedOperatorStruct C = A - B;
	FExpandedOperatorStruct D = A * 2;
	FExpandedOperatorStruct E = A / 3;
	FExpandedOperatorStruct F = -A;
	C += B;
	C -= B;
	C *= B;
	C /= B;
	return C.Value + D.Value + E.Value + F.Value;
}

int Observe_ExpandedOperators_DefaultZero(AExpandedOperatorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructOperatorExpansion setup: required Actor is null");
	}
	FExpandedOperatorStruct Empty;
	return Actor.Results + Empty.Value;
}

int Observe_ExpandedOperators_ZeroOperandBoundary()
{
	FExpandedOperatorStruct A;
	FExpandedOperatorStruct B;
	FExpandedOperatorStruct C = A - B;
	FExpandedOperatorStruct Negated = -A;
	return C.Value + Negated.Value;
}

bool Observe_ExpandedOperators_CopyIndependence()
{
	FExpandedOperatorStruct Original;
	Original.Value = 12;
	FExpandedOperatorStruct Copy = Original;
	Copy += Original;
	return Original.Value == 12 && Copy.Value == 24;
}
