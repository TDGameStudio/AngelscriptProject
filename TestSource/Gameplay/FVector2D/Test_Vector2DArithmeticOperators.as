// Theme: Gameplay.FVector2D. Positive arithmetic operator oracles.
// C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DArithmeticOperators
// Oracle: add (4.5,6.5); sub (7.0,15.0); *4 (8.0,12.0); /2 (10.0,20.0);
// negate (-5.0,-10.0); += (4.0,6.0); -= (8.0,10.0); *= (6.0,12.0); /= (5.0,10.0).
// Extra: empty ZeroVector add; copy independence of OpAdd inputs. DefaultSafe.

FVector2D OpAdd()
{
	FVector2D a = FVector2D(1.5, 2.5);
	FVector2D b = FVector2D(3.0, 4.0);
	return a + b;
}

FVector2D OpSubtract()
{
	FVector2D a = FVector2D(10.0, 20.0);
	FVector2D b = FVector2D(3.0, 5.0);
	return a - b;
}

FVector2D OpMultiplyScalar()
{
	FVector2D v = FVector2D(2.0, 3.0);
	return v * 4.0;
}

FVector2D OpDivideScalar()
{
	FVector2D v = FVector2D(20.0, 40.0);
	return v / 2.0;
}

FVector2D OpNegate()
{
	FVector2D v = FVector2D(5.0, 10.0);
	return -v;
}

FVector2D OpCompoundAdd()
{
	FVector2D v = FVector2D(1.0, 2.0);
	v += FVector2D(3.0, 4.0);
	return v;
}

FVector2D OpCompoundSubtract()
{
	FVector2D v = FVector2D(10.0, 15.0);
	v -= FVector2D(2.0, 5.0);
	return v;
}

FVector2D OpCompoundMultiply()
{
	FVector2D v = FVector2D(3.0, 6.0);
	v *= 2.0;
	return v;
}

FVector2D OpCompoundDivide()
{
	FVector2D v = FVector2D(20.0, 40.0);
	v /= 4.0;
	return v;
}

bool Observe_OpAdd()
{
	return OpAdd().Equals(FVector2D(4.5, 6.5));
}

bool Observe_OpSubtract()
{
	return OpSubtract().Equals(FVector2D(7.0, 15.0));
}

bool Observe_OpMultiplyScalar()
{
	return OpMultiplyScalar().Equals(FVector2D(8.0, 12.0));
}

bool Observe_OpDivideScalar()
{
	return OpDivideScalar().Equals(FVector2D(10.0, 20.0));
}

bool Observe_OpNegate()
{
	return OpNegate().Equals(FVector2D(-5.0, -10.0));
}

bool Observe_OpCompoundAdd()
{
	return OpCompoundAdd().Equals(FVector2D(4.0, 6.0));
}

bool Observe_OpCompoundSubtract()
{
	return OpCompoundSubtract().Equals(FVector2D(8.0, 10.0));
}

bool Observe_OpCompoundMultiply()
{
	return OpCompoundMultiply().Equals(FVector2D(6.0, 12.0));
}

bool Observe_OpCompoundDivide()
{
	return OpCompoundDivide().Equals(FVector2D(5.0, 10.0));
}

bool Observe_OpAdd_DefaultEmpty()
{
	FVector2D Empty = FVector2D();
	return Empty.Equals(FVector2D::ZeroVector)
		&& (Empty + FVector2D::ZeroVector).Equals(FVector2D::ZeroVector);
}

bool Observe_OpAdd_CopyIndependence()
{
	FVector2D A = FVector2D(1.5, 2.5);
	FVector2D B = FVector2D(3.0, 4.0);
	FVector2D Sum = A + B;
	Sum.X = 0.0;
	return A.Equals(FVector2D(1.5, 2.5)) && B.Equals(FVector2D(3.0, 4.0));
}
