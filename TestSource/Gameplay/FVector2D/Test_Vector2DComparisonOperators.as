// Theme: Gameplay.FVector2D. Positive comparison operator oracles.
// C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DComparisonOperators
// Oracle: OpEquals_True true; OpEquals_False false; OpNotEquals_True true;
// OpNotEquals_False false. Extra: default vector equals FVector2D::ZeroVector;
// ZeroVector != (1,2) true. DefaultSafe.

bool OpEquals_True()
{
	FVector2D a = FVector2D(1.5, 2.5);
	FVector2D b = FVector2D(1.5, 2.5);
	return a == b;
}

bool OpEquals_False()
{
	FVector2D a = FVector2D(1.5, 2.5);
	FVector2D b = FVector2D(3.0, 4.0);
	return a == b;
}

bool OpNotEquals_True()
{
	FVector2D a = FVector2D(1.0, 2.0);
	FVector2D b = FVector2D(3.0, 4.0);
	return a != b;
}

bool OpNotEquals_False()
{
	FVector2D a = FVector2D(5.5, 6.5);
	FVector2D b = FVector2D(5.5, 6.5);
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
	FVector2D Empty = FVector2D();
	return (Empty == FVector2D::ZeroVector) == true;
}

bool Observe_OpNotEquals_ZeroBoundary()
{
	FVector2D Empty = FVector2D();
	return (Empty != FVector2D(1.0, 2.0)) == true;
}
