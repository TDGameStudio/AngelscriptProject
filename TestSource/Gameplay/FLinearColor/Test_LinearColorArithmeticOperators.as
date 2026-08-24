// Theme: Gameplay.FLinearColor. Positive arithmetic operator oracles.
// C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorArithmeticOperators
// Oracle (Equals 0.0001): add (0.6,0.6,0.6,0.6); sub (0.8,0.5,0.5,0.3);
// *2 (0.4,0.8,1.2,1.6); color*color (0.4,0.3,0.2,1.0); /2 (0.5,0.4,0.3,0.2);
// += (0.3,0.3,0.4,0.5); *= (1.0,0.8,0.6,0.4).
// Extra: default black add; copy independence of OpAdd inputs. DefaultSafe.

FLinearColor OpAdd()
{
	FLinearColor a = FLinearColor(0.1, 0.2, 0.3, 0.4);
	FLinearColor b = FLinearColor(0.5, 0.4, 0.3, 0.2);
	return a + b;
}

FLinearColor OpSubtract()
{
	FLinearColor a = FLinearColor(1.0, 0.8, 0.6, 0.4);
	FLinearColor b = FLinearColor(0.2, 0.3, 0.1, 0.1);
	return a - b;
}

FLinearColor OpMultiplyScalar()
{
	FLinearColor c = FLinearColor(0.2, 0.4, 0.6, 0.8);
	return c * 2.0;
}

FLinearColor OpMultiplyColor()
{
	FLinearColor a = FLinearColor(0.5, 0.5, 0.5, 1.0);
	FLinearColor b = FLinearColor(0.8, 0.6, 0.4, 1.0);
	return a * b;
}

FLinearColor OpDivideScalar()
{
	FLinearColor c = FLinearColor(1.0, 0.8, 0.6, 0.4);
	return c / 2.0;
}

FLinearColor OpCompoundAdd()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	c += FLinearColor(0.2, 0.1, 0.1, 0.1);
	return c;
}

FLinearColor OpCompoundMultiply()
{
	FLinearColor c = FLinearColor(0.5, 0.4, 0.3, 0.2);
	c *= 2.0;
	return c;
}

bool Observe_OpAdd()
{
	return OpAdd().Equals(FLinearColor(0.6, 0.6, 0.6, 0.6));
}

bool Observe_OpSubtract()
{
	return OpSubtract().Equals(FLinearColor(0.8, 0.5, 0.5, 0.3));
}

bool Observe_OpMultiplyScalar()
{
	return OpMultiplyScalar().Equals(FLinearColor(0.4, 0.8, 1.2, 1.6));
}

bool Observe_OpMultiplyColor()
{
	return OpMultiplyColor().Equals(FLinearColor(0.4, 0.3, 0.2, 1.0));
}

bool Observe_OpDivideScalar()
{
	return OpDivideScalar().Equals(FLinearColor(0.5, 0.4, 0.3, 0.2));
}

bool Observe_OpCompoundAdd()
{
	return OpCompoundAdd().Equals(FLinearColor(0.3, 0.3, 0.4, 0.5));
}

bool Observe_OpCompoundMultiply()
{
	return OpCompoundMultiply().Equals(FLinearColor(1.0, 0.8, 0.6, 0.4));
}

bool Observe_OpAdd_DefaultEmpty()
{
	FLinearColor Empty = FLinearColor();
	FLinearColor Sum = Empty + FLinearColor(0.0, 0.0, 0.0, 0.0);
	return Empty.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0)) && Sum.A == 1.0;
}

bool Observe_OpAdd_CopyIndependence()
{
	FLinearColor A = FLinearColor(0.1, 0.2, 0.3, 0.4);
	FLinearColor B = FLinearColor(0.5, 0.4, 0.3, 0.2);
	FLinearColor Sum = A + B;
	Sum.R = 0.0;
	return A.Equals(FLinearColor(0.1, 0.2, 0.3, 0.4)) && B.Equals(FLinearColor(0.5, 0.4, 0.3, 0.2));
}
