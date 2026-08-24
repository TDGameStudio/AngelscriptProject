// Theme: Gameplay.FLinearColor. Positive R/G/B/A getter and setter oracles.
// C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorMemberAccess
// Oracle: GetR 0.1; GetG 0.2; GetB 0.3; GetA 0.4;
// SetR (0.9,0.2,0.3,0.4); SetG (0.1,0.8,0.3,0.4); SetB (0.1,0.2,0.7,0.4); SetA (0.1,0.2,0.3,1.0).
// Extra: default empty (0,0,0,1); copy independence of SetR source. DefaultSafe.

float GetR()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	return c.R;
}

float GetG()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	return c.G;
}

float GetB()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	return c.B;
}

float GetA()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	return c.A;
}

FLinearColor SetR()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	c.R = 0.9;
	return c;
}

FLinearColor SetG()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	c.G = 0.8;
	return c;
}

FLinearColor SetB()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	c.B = 0.7;
	return c;
}

FLinearColor SetA()
{
	FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
	c.A = 1.0;
	return c;
}

bool Observe_Getters_Nominal()
{
	return GetR() == 0.1 && GetG() == 0.2 && GetB() == 0.3 && GetA() == 0.4;
}

bool Observe_SetR()
{
	return SetR().Equals(FLinearColor(0.9, 0.2, 0.3, 0.4));
}

bool Observe_SetG()
{
	return SetG().Equals(FLinearColor(0.1, 0.8, 0.3, 0.4));
}

bool Observe_SetB()
{
	return SetB().Equals(FLinearColor(0.1, 0.2, 0.7, 0.4));
}

bool Observe_SetA()
{
	return SetA().Equals(FLinearColor(0.1, 0.2, 0.3, 1.0));
}

bool Observe_MemberAccess_DefaultEmpty()
{
	FLinearColor Empty = FLinearColor();
	return Empty.R == 0.0 && Empty.G == 0.0 && Empty.B == 0.0 && Empty.A == 1.0;
}

bool Observe_SetR_CopyIndependence()
{
	FLinearColor Source = FLinearColor(0.1, 0.2, 0.3, 0.4);
	FLinearColor Mutated = Source;
	Mutated.R = 0.9;
	return Source.Equals(FLinearColor(0.1, 0.2, 0.3, 0.4)) && Mutated.R == 0.9;
}
