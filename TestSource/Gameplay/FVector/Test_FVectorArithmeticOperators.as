// Theme: Gameplay.FVector. Positive arithmetic operator oracles.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorArithmeticOperators
// Oracle: add (5,7,9); sub (9,18,27); *3 (6,9,12); /2 (10,20,30);
// negate (-5,-10,-15); += (3,5,7); -= (7,5,3); *= (4,8,12); /= (5,10,15).
// Extra: empty ZeroVector add; copy independence of OpAdd inputs. DefaultSafe.

FVector OpAdd()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(4, 5, 6);
	return a + b;
}

FVector OpSubtract()
{
	FVector a = FVector(10, 20, 30);
	FVector b = FVector(1, 2, 3);
	return a - b;
}

FVector OpMultiplyScalar()
{
	FVector v = FVector(2, 3, 4);
	return v * 3.0;
}

FVector OpDivideScalar()
{
	FVector v = FVector(20, 40, 60);
	return v / 2.0;
}

FVector OpNegate()
{
	FVector v = FVector(5, 10, 15);
	return -v;
}

FVector OpCompoundAdd()
{
	FVector v = FVector(1, 2, 3);
	v += FVector(2, 3, 4);
	return v;
}

FVector OpCompoundSubtract()
{
	FVector v = FVector(10, 10, 10);
	v -= FVector(3, 5, 7);
	return v;
}

FVector OpCompoundMultiply()
{
	FVector v = FVector(2, 4, 6);
	v *= 2.0;
	return v;
}

FVector OpCompoundDivide()
{
	FVector v = FVector(20, 40, 60);
	v /= 4.0;
	return v;
}

bool Observe_OpAdd()
{
	return OpAdd().Equals(FVector(5, 7, 9));
}

bool Observe_OpSubtract()
{
	return OpSubtract().Equals(FVector(9, 18, 27));
}

bool Observe_OpMultiplyScalar()
{
	return OpMultiplyScalar().Equals(FVector(6, 9, 12));
}

bool Observe_OpDivideScalar()
{
	return OpDivideScalar().Equals(FVector(10, 20, 30));
}

bool Observe_OpNegate()
{
	return OpNegate().Equals(FVector(-5, -10, -15));
}

bool Observe_OpCompoundAdd()
{
	return OpCompoundAdd().Equals(FVector(3, 5, 7));
}

bool Observe_OpCompoundSubtract()
{
	return OpCompoundSubtract().Equals(FVector(7, 5, 3));
}

bool Observe_OpCompoundMultiply()
{
	return OpCompoundMultiply().Equals(FVector(4, 8, 12));
}

bool Observe_OpCompoundDivide()
{
	return OpCompoundDivide().Equals(FVector(5, 10, 15));
}

bool Observe_OpAdd_DefaultEmpty()
{
	FVector Empty = FVector();
	return Empty.Equals(FVector::ZeroVector)
		&& (Empty + FVector::ZeroVector).Equals(FVector::ZeroVector);
}

bool Observe_OpAdd_CopyIndependence()
{
	FVector A = FVector(1, 2, 3);
	FVector B = FVector(4, 5, 6);
	FVector Sum = A + B;
	Sum.X = 0.0;
	return A.Equals(FVector(1, 2, 3)) && B.Equals(FVector(4, 5, 6));
}
