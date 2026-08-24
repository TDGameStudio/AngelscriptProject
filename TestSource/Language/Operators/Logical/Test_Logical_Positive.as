// Theme: Language.Operators.Logical. Positive value oracle from Logical_Positive.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Positive
// sha256=d91e8ad4be8d3be30179016aea025b6d8c8e5a21484a18333d787b33ab63763f; lines 286-292.
// Oracle: LogicAnd 1; LogicOr 1; LogicNot 1; LogicCompound 1; ShortCircuit 0.
// Extra: ShortCircuit is the false vector; false && true is 0 without evaluating a divisor.
// DefaultSafe. Source owns locals. ShortCircuit must not evaluate 1/Z.

int LogicAnd()
{
	return (true && true) ? 1 : 0;
}

int LogicOr()
{
	return (false || true) ? 1 : 0;
}

int LogicNot()
{
	return (!false) ? 1 : 0;
}

int LogicCompound()
{
	return ((true && !false) || (false && true)) ? 1 : 0;
}

int ShortCircuit()
{
	bool A = false;
	int Z = 0;
	return (A && (1/Z > 0)) ? 1 : 0;
}

bool Observe_Logical_Nominal()
{
	return LogicAnd() == 1
		&& LogicOr() == 1
		&& LogicNot() == 1
		&& LogicCompound() == 1
		&& ShortCircuit() == 0;
}

bool Observe_Logical_FalseBoundary()
{
	return ShortCircuit() == 0 && ((false && true) ? 1 : 0) == 0;
}

bool Observe_Logical_NotTrueBoundary()
{
	return ((!true) ? 1 : 0) == 0 && LogicNot() == 1;
}
