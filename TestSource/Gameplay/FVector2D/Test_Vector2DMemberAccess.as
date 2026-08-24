// Theme: Gameplay.FVector2D. Positive X/Y getter and setter oracles.
// C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DMemberAccess
// Oracle: GetX 10.5; GetY 20.5; SetX (100.0,20.0); SetY (10.0,200.0);
// SetBoth (99.0,88.0). Extra: empty ZeroVector members 0; copy independence
// of SetX source. DefaultSafe.

float GetX()
{
	FVector2D v = FVector2D(10.5, 20.5);
	return v.X;
}

float GetY()
{
	FVector2D v = FVector2D(10.5, 20.5);
	return v.Y;
}

FVector2D SetX()
{
	FVector2D v = FVector2D(10.0, 20.0);
	v.X = 100.0;
	return v;
}

FVector2D SetY()
{
	FVector2D v = FVector2D(10.0, 20.0);
	v.Y = 200.0;
	return v;
}

FVector2D SetBoth()
{
	FVector2D v = FVector2D(1.0, 2.0);
	v.X = 99.0;
	v.Y = 88.0;
	return v;
}

bool Observe_GetX()
{
	return Math::IsNearlyEqual(GetX(), 10.5);
}

bool Observe_GetY()
{
	return Math::IsNearlyEqual(GetY(), 20.5);
}

bool Observe_SetX()
{
	return SetX().Equals(FVector2D(100.0, 20.0));
}

bool Observe_SetY()
{
	return SetY().Equals(FVector2D(10.0, 200.0));
}

bool Observe_SetBoth()
{
	return SetBoth().Equals(FVector2D(99.0, 88.0));
}

bool Observe_GetX_DefaultEmpty()
{
	FVector2D Empty = FVector2D();
	return Math::IsNearlyEqual(Empty.X, 0.0) && Math::IsNearlyEqual(Empty.Y, 0.0);
}

bool Observe_SetX_CopyIndependence()
{
	FVector2D Original = FVector2D(10.0, 20.0);
	FVector2D Mutated = Original;
	Mutated.X = 100.0;
	return Original.Equals(FVector2D(10.0, 20.0)) && Mutated.Equals(FVector2D(100.0, 20.0));
}
