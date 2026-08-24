// Theme: Definitions.UStruct. WorldStory: opEquals, opAdd, opCmp, opIndex, opAssign.
// C++: AngelscriptCoverageUStructTests.cpp::UStructOperators spawn + BeginPlay.
// Oracle: Sum 15/35, AreEqual true, AssignedViaOperator 6/16, ALessThanB true, IndexedSum 30.
// Extra: default zeros; opIndex(-1) is -1. FixtureIsolated.

USTRUCT()
struct FOperatorStruct
{
	UPROPERTY()
	int X = 0;

	UPROPERTY()
	int Y = 0;

	bool opEquals(const FOperatorStruct& Other) const
	{
		return X == Other.X && Y == Other.Y;
	}

	FOperatorStruct opAdd(const FOperatorStruct& Other) const
	{
		FOperatorStruct Result;
		Result.X = X + Other.X;
		Result.Y = Y + Other.Y;
		return Result;
	}

	int opCmp(const FOperatorStruct& Other) const
	{
		if (X < Other.X) return -1;
		if (X > Other.X) return 1;
		if (Y < Other.Y) return -1;
		if (Y > Other.Y) return 1;
		return 0;
	}

	int opIndex(int Index) const
	{
		if (Index == 0) return X;
		if (Index == 1) return Y;
		return -1;
	}
}

USTRUCT()
struct FAssignOperatorStruct
{
	UPROPERTY()
	int X = 0;

	UPROPERTY()
	int Y = 0;

	FAssignOperatorStruct& opAssign(const FAssignOperatorStruct& Other)
	{
		X = Other.X + 1;
		Y = Other.Y + 1;
		return this;
	}
}

UCLASS()
class ACoverageStructOperatorActor : AActor
{
	UPROPERTY()
	FOperatorStruct A;

	UPROPERTY()
	FOperatorStruct B;

	UPROPERTY()
	FOperatorStruct Sum;

	UPROPERTY()
	FAssignOperatorStruct AssignedViaOperator;

	UPROPERTY()
	bool AreEqual = false;

	UPROPERTY()
	bool ALessThanB = false;

	UPROPERTY()
	bool AGreaterThanB = false;

	UPROPERTY()
	int IndexedSum = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		A.X = 10;
		A.Y = 20;

		B.X = 5;
		B.Y = 15;

		// opEquals
		FOperatorStruct ACopy;
		ACopy.X = 10;
		ACopy.Y = 20;
		AreEqual = (A == ACopy);

		// opAdd
		Sum = A + B;

		FAssignOperatorStruct AssignSource;
		AssignSource.X = 5;
		AssignSource.Y = 15;
		AssignedViaOperator = AssignSource;

		// opCmp
		ALessThanB = (B < A);
		AGreaterThanB = (A > B);

		// opIndex
		IndexedSum = A[0] + A[1];
	}
}

bool Observe_Operators_DefaultEmpty(ACoverageStructOperatorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructOperators setup: required Actor is null");
	}
	return Actor.Sum.X == 0 && Actor.Sum.Y == 0 && Actor.IndexedSum == 0 && !Actor.AreEqual;
}

bool Observe_Operators_NominalBeginPlay(ACoverageStructOperatorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructOperators setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Sum.X == 15
		&& Actor.Sum.Y == 35
		&& Actor.AreEqual
		&& Actor.AssignedViaOperator.X == 6
		&& Actor.AssignedViaOperator.Y == 16
		&& Actor.ALessThanB
		&& Actor.AGreaterThanB
		&& Actor.IndexedSum == 30;
}

int Observe_Operators_IndexOutOfRangeBoundary()
{
	FOperatorStruct Value;
	Value.X = 10;
	Value.Y = 20;
	return Value[-1];
}
