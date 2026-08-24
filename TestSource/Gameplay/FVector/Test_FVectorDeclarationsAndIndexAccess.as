// Theme: Gameplay.FVector. Positive declaration/index oracles plus runtime boundary.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorDeclarationsAndIndexAccess
// Oracle: LocalDefaultIsZero 0.0; LocalDefaultValue 6.0; LocalConstValue 1.0;
// GlobalConstValue 0.0; IndexRead 15.0; IndexWrite (7,8,9).
// PlainClassMemberValueRaisesBoundary raises Null pointer access.
// Extra: empty local default; do not wrap the exception function in Observe.
// DefaultSafe.

const FVector GlobalConstVector = FVector::ZeroVector;

float LocalDefaultIsZero()
{
	FVector v;
	return v.X + v.Y + v.Z;
}

float LocalDefaultValue()
{
	FVector v = FVector(1, 2, 3);
	return v.X + v.Y + v.Z;
}

float LocalConstValue()
{
	const FVector v = FVector(1, 0, 0);
	return v.X;
}

float GlobalConstValue()
{
	return GlobalConstVector.X + GlobalConstVector.Y + GlobalConstVector.Z;
}

float IndexRead()
{
	FVector v = FVector(4, 5, 6);
	return v[0] + v[1] + v[2];
}

FVector IndexWrite()
{
	FVector v = FVector::ZeroVector;
	v[0] = 7;
	v[1] = 8;
	v[2] = 9;
	return v;
}

class FPlainVectorHolder
{
	FVector Value;

	FPlainVectorHolder()
	{
		Value = FVector(2, 4, 6);
	}
}

int PlainClassMemberValueRaisesBoundary()
{
	FPlainVectorHolder Holder;
	return Holder.Value.X + Holder.Value.Y + Holder.Value.Z;
}

bool Observe_LocalDefaultIsZero()
{
	return Math::IsNearlyEqual(LocalDefaultIsZero(), 0.0);
}

bool Observe_LocalDefaultValue()
{
	return Math::IsNearlyEqual(LocalDefaultValue(), 6.0);
}

bool Observe_LocalConstValue()
{
	return Math::IsNearlyEqual(LocalConstValue(), 1.0);
}

bool Observe_GlobalConstValue()
{
	return Math::IsNearlyEqual(GlobalConstValue(), 0.0);
}

bool Observe_IndexRead()
{
	return Math::IsNearlyEqual(IndexRead(), 15.0);
}

bool Observe_IndexWrite()
{
	return IndexWrite().Equals(FVector(7, 8, 9));
}

bool Observe_LocalDefault_EmptyZero()
{
	FVector Empty;
	return Empty.Equals(FVector::ZeroVector);
}

bool Observe_IndexWrite_CopyIndependence()
{
	FVector Original = FVector::ZeroVector;
	FVector Written = Original;
	Written[0] = 7;
	Written[1] = 8;
	Written[2] = 9;
	return Original.Equals(FVector::ZeroVector) && Written.Equals(FVector(7, 8, 9));
}
