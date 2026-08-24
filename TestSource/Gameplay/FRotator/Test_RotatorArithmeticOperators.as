// Theme: Gameplay.FRotator. Positive arithmetic operator oracles.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorArithmeticOperators
// Oracle: add (15,30,45); sub (90,180,270); *2 (20,40,60);
// += (15,25,35); -= (90,80,70); *= (30,60,90).
// Extra: default Zero add; copy independence of OpAdd inputs. DefaultSafe.

FRotator OpAdd()
{
	FRotator a = FRotator(10, 20, 30);
	FRotator b = FRotator(5, 10, 15);
	return a + b;
}

FRotator OpSubtract()
{
	FRotator a = FRotator(100, 200, 300);
	FRotator b = FRotator(10, 20, 30);
	return a - b;
}

FRotator OpMultiplyScalar()
{
	FRotator r = FRotator(10, 20, 30);
	return r * 2.0;
}

FRotator OpCompoundAdd()
{
	FRotator r = FRotator(10, 20, 30);
	r += FRotator(5, 5, 5);
	return r;
}

FRotator OpCompoundSubtract()
{
	FRotator r = FRotator(100, 100, 100);
	r -= FRotator(10, 20, 30);
	return r;
}

FRotator OpCompoundMultiply()
{
	FRotator r = FRotator(10, 20, 30);
	r *= 3.0;
	return r;
}

bool Observe_OpAdd()
{
	return OpAdd() == FRotator(15, 30, 45);
}

bool Observe_OpSubtract()
{
	return OpSubtract() == FRotator(90, 180, 270);
}

bool Observe_OpMultiplyScalar()
{
	return OpMultiplyScalar() == FRotator(20, 40, 60);
}

bool Observe_OpCompoundAdd()
{
	return OpCompoundAdd() == FRotator(15, 25, 35);
}

bool Observe_OpCompoundSubtract()
{
	return OpCompoundSubtract() == FRotator(90, 80, 70);
}

bool Observe_OpCompoundMultiply()
{
	return OpCompoundMultiply() == FRotator(30, 60, 90);
}

bool Observe_OpAdd_DefaultEmpty()
{
	FRotator Empty = FRotator();
	return (Empty + FRotator::ZeroRotator) == FRotator::ZeroRotator;
}

bool Observe_OpAdd_CopyIndependence()
{
	FRotator A = FRotator(10, 20, 30);
	FRotator B = FRotator(5, 10, 15);
	FRotator Sum = A + B;
	Sum.Pitch = 0.0;
	return A == FRotator(10, 20, 30) && B == FRotator(5, 10, 15);
}
