// Theme: Language.Operators.Arithmetic. Positive value oracle from EdgeCases.
// C++: AngelscriptSyntaxOperatorsTests.cpp::EdgeCases
// sha256=f703a91639dfb55a06fd8cfbe7c75fb2ed58dfc8c5cee18479844a54d126e246; lines 645-651.
// Oracle: MaxParens 3; LongChain 55; PrecedenceMix 13; BitAndLogic 1; AssignInExpr 5.
// Extra: zero-parenthesized identity; precedence mix matches 2+3*4-1 and 1+2*0.
// DefaultSafe. Source owns locals.

int MaxParens()
{
	return ((((1 + 2))));
}

int LongChain()
{
	return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10;
}

int PrecedenceMix()
{
	return 2 + 3 * 4 - 1;
}

int BitAndLogic()
{
	int X = 5;
	return (X > 0 && (X & 1) == 1) ? 1 : 0;
}

int AssignInExpr()
{
	int X = 0;
	X = 5;
	int Y = X;
	return Y;
}

bool Observe_EdgeCases_Nominal()
{
	return MaxParens() == 3
		&& LongChain() == 55
		&& PrecedenceMix() == 13
		&& BitAndLogic() == 1
		&& AssignInExpr() == 5;
}

bool Observe_EdgeCases_EmptyDefault()
{
	int Start = 0;
	int Copied = Start;
	return Copied == 0 && MaxParens() != Copied && AssignInExpr() - 5 == Copied;
}

bool Observe_EdgeCases_PrecedenceBoundary()
{
	return (2 + 3 * 4 - 1) == PrecedenceMix() && (1 + 2 * 0) == 1;
}
