// Theme: Gameplay.FVector. Positive X/Y/Z getter and setter oracles.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorMemberAccess
// Oracle: GetX 10; GetY 20; GetZ 30; SetX (100,20,30); SetY (10,200,30);
// SetZ (10,20,300). Extra: empty ZeroVector members 0; copy independence of
// SetX source. DefaultSafe.

float GetX()
{
	FVector v = FVector(10, 20, 30);
	return v.X;
}

float GetY()
{
	FVector v = FVector(10, 20, 30);
	return v.Y;
}

float GetZ()
{
	FVector v = FVector(10, 20, 30);
	return v.Z;
}

FVector SetX()
{
	FVector v = FVector(10, 20, 30);
	v.X = 100;
	return v;
}

FVector SetY()
{
	FVector v = FVector(10, 20, 30);
	v.Y = 200;
	return v;
}

FVector SetZ()
{
	FVector v = FVector(10, 20, 30);
	v.Z = 300;
	return v;
}

bool Observe_GetX()
{
	return Math::IsNearlyEqual(GetX(), 10.0);
}

bool Observe_GetY()
{
	return Math::IsNearlyEqual(GetY(), 20.0);
}

bool Observe_GetZ()
{
	return Math::IsNearlyEqual(GetZ(), 30.0);
}

bool Observe_SetX()
{
	return SetX().Equals(FVector(100, 20, 30));
}

bool Observe_SetY()
{
	return SetY().Equals(FVector(10, 200, 30));
}

bool Observe_SetZ()
{
	return SetZ().Equals(FVector(10, 20, 300));
}

bool Observe_GetX_DefaultEmpty()
{
	FVector Empty = FVector();
	return Math::IsNearlyEqual(Empty.X, 0.0)
		&& Math::IsNearlyEqual(Empty.Y, 0.0)
		&& Math::IsNearlyEqual(Empty.Z, 0.0);
}

bool Observe_SetX_CopyIndependence()
{
	FVector Original = FVector(10, 20, 30);
	FVector Mutated = Original;
	Mutated.X = 100;
	return Original.Equals(FVector(10, 20, 30)) && Mutated.Equals(FVector(100, 20, 30));
}
