// Theme: Gameplay.FVector. Positive component-op and method oracles.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorExtendedOperatorsAndMethods
// Oracle: * (10,18,28); / (10,10,10); NormalizeMutates true;
// UnitAndNormalizedChecks true; DistSquared 25.0; ProjectOnTo (3,0,0);
// ProjectOnToNormal (0,4,0); Lerp (2.5,5,7.5); ClampSize (5,0,0);
// ClampMaxSize (0,3,0); RotateAroundZ (0,1,0); DirectionAndLength true.
// Extra: empty ZeroVector DistSquared 0; copy independence of component *.
// DefaultSafe.

FVector OpComponentMultiply()
{
	return FVector(2, 3, 4) * FVector(5, 6, 7);
}

FVector OpComponentDivide()
{
	return FVector(20, 30, 40) / FVector(2, 3, 4);
}

FVector OpCompoundComponentMultiply()
{
	FVector v = FVector(2, 3, 4);
	v *= FVector(5, 6, 7);
	return v;
}

FVector OpCompoundComponentDivide()
{
	FVector v = FVector(20, 30, 40);
	v /= FVector(2, 3, 4);
	return v;
}

bool NormalizeMutates()
{
	FVector v = FVector(10, 0, 0);
	bool bNormalized = v.Normalize();
	return bNormalized && v.Equals(FVector(1, 0, 0), 0.001);
}

bool UnitAndNormalizedChecks()
{
	FVector v = FVector(1, 0, 0);
	return v.IsUnit() && v.IsNormalized();
}

float DistSquaredMethod()
{
	return FVector(1, 2, 3).DistSquared(FVector(4, 6, 3));
}

FVector ProjectOnToVector()
{
	return FVector(3, 4, 0).ProjectOnTo(FVector(1, 0, 0));
}

FVector ProjectOnToNormalVector()
{
	return FVector(3, 4, 0).ProjectOnToNormal(FVector(0, 1, 0));
}

FVector LerpVector()
{
	return Math::Lerp(FVector(0, 0, 0), FVector(10, 20, 30), 0.25);
}

FVector ClampSizeVector()
{
	return FVector(10, 0, 0).GetClampedToSize(0, 5);
}

FVector ClampMaxSizeVector()
{
	return FVector(0, 12, 0).GetClampedToMaxSize(3);
}

FVector RotateAroundZ()
{
	return FVector(1, 0, 0).RotateAngleAxis(90, FVector(0, 0, 1));
}

bool DirectionAndLengthOutParams()
{
	FVector Direction;
	float64 Length = 0;
	FVector(0, 3, 4).ToDirectionAndLength(Direction, Length);
	return Direction.Equals(FVector(0, 0.6, 0.8), 0.001) && Length > 4.999 && Length < 5.001;
}

bool Observe_OpComponentMultiply()
{
	return OpComponentMultiply().Equals(FVector(10, 18, 28));
}

bool Observe_OpComponentDivide()
{
	return OpComponentDivide().Equals(FVector(10, 10, 10));
}

bool Observe_OpCompoundComponentMultiply()
{
	return OpCompoundComponentMultiply().Equals(FVector(10, 18, 28));
}

bool Observe_OpCompoundComponentDivide()
{
	return OpCompoundComponentDivide().Equals(FVector(10, 10, 10));
}

bool Observe_NormalizeMutates()
{
	return NormalizeMutates() == true;
}

bool Observe_UnitAndNormalizedChecks()
{
	return UnitAndNormalizedChecks() == true;
}

bool Observe_DistSquaredMethod()
{
	return Math::IsNearlyEqual(DistSquaredMethod(), 25.0);
}

bool Observe_ProjectOnToVector()
{
	return ProjectOnToVector().Equals(FVector(3, 0, 0));
}

bool Observe_ProjectOnToNormalVector()
{
	return ProjectOnToNormalVector().Equals(FVector(0, 4, 0));
}

bool Observe_LerpVector()
{
	return LerpVector().Equals(FVector(2.5, 5, 7.5));
}

bool Observe_ClampSizeVector()
{
	return ClampSizeVector().Equals(FVector(5, 0, 0));
}

bool Observe_ClampMaxSizeVector()
{
	return ClampMaxSizeVector().Equals(FVector(0, 3, 0));
}

bool Observe_RotateAroundZ()
{
	return RotateAroundZ().Equals(FVector(0, 1, 0), 0.001);
}

bool Observe_DirectionAndLengthOutParams()
{
	return DirectionAndLengthOutParams() == true;
}

bool Observe_DistSquaredMethod_DefaultEmpty()
{
	FVector Empty = FVector();
	return Math::IsNearlyEqual(Empty.DistSquared(FVector::ZeroVector), 0.0);
}

bool Observe_OpComponentMultiply_CopyIndependence()
{
	FVector A = FVector(2, 3, 4);
	FVector B = FVector(5, 6, 7);
	FVector Product = A * B;
	Product.X = 0.0;
	return A.Equals(FVector(2, 3, 4)) && B.Equals(FVector(5, 6, 7));
}

bool Observe_NormalizeMutates_ZeroBoundary()
{
	FVector Empty = FVector();
	return Empty.Normalize() == false;
}
