// Theme: Language.ControlFlow.Switch. Positive switch, fallthrough, multi-case, default.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Switch_Positive
// sha256=05010834a7c5d6c043e9b9d5393a029706005e54294a5608422886d7fc8460a0; lines 294-299.
// Oracle: BasicSwitch 1; Fallthrough 10; MultiCase 99; DefaultOnly 100.
// Extra: unmatched default returns -1; multi-case miss returns 0.
// DefaultSafe. Source owns locals.

int BasicSwitch()
{
	int X = 1;
	switch (X)
	{
		case 0:
			return 0;
		case 1:
			return 1;
		default:
			return -1;
	}
}

int Fallthrough()
{
	int X = 0;
	int Y = 0;
	switch (X)
	{
		case 0:
			fallthrough;
		case 1:
			Y = 10;
			break;
		default:
			Y = 20;
			break;
	}
	return Y;
}

int MultiCase()
{
	int X = 1;
	switch (X)
	{
		case 0:
		case 1:
		case 2:
			return 99;
		default:
			return 0;
	}
}

int DefaultOnly()
{
	int X = 42;
	switch (X)
	{
		case 0:
			return 0;
		default:
			return 100;
	}
}

bool Observe_Switch_Nominal()
{
	return BasicSwitch() == 1 && Fallthrough() == 10 && MultiCase() == 99 && DefaultOnly() == 100;
}

int Observe_Switch_UnmatchedDefault()
{
	int X = -1;
	switch (X)
	{
		case 0:
			return 0;
		case 1:
			return 1;
		default:
			return -1;
	}
}

int Observe_MultiCase_MissBoundary()
{
	int X = 9;
	switch (X)
	{
		case 0:
		case 1:
		case 2:
			return 99;
		default:
			return 0;
	}
}
