// Theme: Gameplay.FRotator. Positive == / != oracles.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorComparisonOperators
// Oracle: OpEquals_True true; OpEquals_False false; OpNotEquals_True true;
// OpNotEquals_False false.
// Extra: default Zero equals; (10,20,30) != Zero. DefaultSafe.

bool OpEquals_True()
{
	FRotator a = FRotator(10, 20, 30);
	FRotator b = FRotator(10, 20, 30);
	return a == b;
}

bool OpEquals_False()
{
	FRotator a = FRotator(10, 20, 30);
	FRotator b = FRotator(40, 50, 60);
	return a == b;
}

bool OpNotEquals_True()
{
	FRotator a = FRotator(10, 20, 30);
	FRotator b = FRotator(40, 50, 60);
	return a != b;
}

bool OpNotEquals_False()
{
	FRotator a = FRotator(10, 20, 30);
	FRotator b = FRotator(10, 20, 30);
	return a != b;
}

bool Observe_Comparison_Nominal()
{
	return OpEquals_True() == true
		&& OpEquals_False() == false
		&& OpNotEquals_True() == true
		&& OpNotEquals_False() == false;
}

bool Observe_Comparison_DefaultEmpty()
{
	FRotator EmptyA = FRotator();
	FRotator EmptyB = FRotator::ZeroRotator;
	return (EmptyA == EmptyB) == true && (EmptyA != EmptyB) == false;
}

bool Observe_Comparison_ZeroBoundary()
{
	return (FRotator(10, 20, 30) == FRotator::ZeroRotator) == false
		&& (FRotator(10, 20, 30) != FRotator::ZeroRotator) == true;
}
