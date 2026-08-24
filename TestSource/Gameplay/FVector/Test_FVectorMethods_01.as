// Theme: Gameplay.FVector. Positive Size/GetSafeNormal/IsZero/Distance oracles.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorMethods
// Oracle: Size 5.0; SizeSquared 25.0; GetSafeNormal (1,0,0); IsZero true;
// IsNearlyZero true; Distance 5.0; DotProduct 32.0; CrossProduct (0,0,1).
// Extra: empty ZeroVector Size 0; copy independence of GetSafeNormal input.
// DefaultSafe.

float VectorLength()
{
	FVector v = FVector(3, 4, 0);
	return v.Size();
}

float VectorSquaredLength()
{
	FVector v = FVector(3, 4, 0);
	return v.SizeSquared();
}

FVector VectorNormalize()
{
	FVector v = FVector(5, 0, 0);
	return v.GetSafeNormal();
}

bool VectorIsZero()
{
	FVector v = FVector::ZeroVector;
	return v.IsZero();
}

bool VectorIsNearlyZero()
{
	FVector v = FVector(0.00001, 0.00001, 0.00001);
	return v.IsNearlyZero();
}

float VectorDistance()
{
	FVector a = FVector(0, 0, 0);
	FVector b = FVector(3, 4, 0);
	return a.Distance(b);
}

float VectorDot()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(4, 5, 6);
	return a.DotProduct(b);
}

FVector VectorCross()
{
	FVector a = FVector(1, 0, 0);
	FVector b = FVector(0, 1, 0);
	return a.CrossProduct(b);
}

bool Observe_VectorLength()
{
	return Math::IsNearlyEqual(VectorLength(), 5.0);
}

bool Observe_VectorSquaredLength()
{
	return Math::IsNearlyEqual(VectorSquaredLength(), 25.0);
}

bool Observe_VectorNormalize()
{
	return VectorNormalize().Equals(FVector(1, 0, 0));
}

bool Observe_VectorIsZero()
{
	return VectorIsZero() == true;
}

bool Observe_VectorIsNearlyZero()
{
	return VectorIsNearlyZero() == true;
}

bool Observe_VectorDistance()
{
	return Math::IsNearlyEqual(VectorDistance(), 5.0);
}

bool Observe_VectorDot()
{
	return Math::IsNearlyEqual(VectorDot(), 32.0);
}

bool Observe_VectorCross()
{
	return VectorCross().Equals(FVector(0, 0, 1));
}

bool Observe_VectorLength_DefaultEmpty()
{
	FVector Empty = FVector();
	return Math::IsNearlyEqual(Empty.Size(), 0.0) && Empty.IsZero() == true;
}

bool Observe_VectorNormalize_CopyIndependence()
{
	FVector V = FVector(5, 0, 0);
	FVector Normal = V.GetSafeNormal();
	Normal.X = 0.0;
	return V.Equals(FVector(5, 0, 0));
}

bool Observe_VectorIsZero_FalseBoundary()
{
	return FVector(1, 0, 0).IsZero() == false;
}
