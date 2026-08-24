// Theme: Gameplay.FVector. Positive comparison operator oracles.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorComparisonOperators
// Oracle: OpEquals_True true; OpEquals_False false; OpNotEquals_True true;
// OpNotEquals_False false. Extra: default vector equals FVector::ZeroVector;
// ZeroVector != (1,2,3) true. DefaultSafe.

bool OpEquals_True()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(1, 2, 3);
	return a == b;
}

bool OpEquals_False()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(4, 5, 6);
	return a == b;
}

bool OpNotEquals_True()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(4, 5, 6);
	return a != b;
}

bool OpNotEquals_False()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(1, 2, 3);
	return a != b;
}

bool Observe_OpEquals_True()
{
	return OpEquals_True() == true;
}

bool Observe_OpEquals_False()
{
	return OpEquals_False() == false;
}

bool Observe_OpNotEquals_True()
{
	return OpNotEquals_True() == true;
}

bool Observe_OpNotEquals_False()
{
	return OpNotEquals_False() == false;
}

bool Observe_OpEquals_DefaultEmpty()
{
	FVector Empty = FVector();
	return (Empty == FVector::ZeroVector) == true;
}

bool Observe_OpNotEquals_ZeroBoundary()
{
	FVector Empty = FVector();
	return (Empty != FVector(1, 2, 3)) == true;
}
