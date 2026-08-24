// Theme: Language.ControlFlow.While. Positive do-while, once, break, continue, nested.
// C++: AngelscriptCoverageLoopTests.cpp::DoWhileBasic
// sha256=52e07d894e3bdeca1d135980bbb170551f9575e9b6f0935ace29e8ee747cf696; lines 608-680.
// Oracle: BasicDoWhile 10; DoWhileOnce 1; DoWhileWithBreak 3; DoWhileWithContinue 25; NestedDoWhile 4.
// Extra: do-while(false) still runs once; nested body is a 2x2 sum.
// DefaultSafe. Source owns locals.

int BasicDoWhile()
{
	int Sum = 0;
	int i = 0;
	do
	{
		Sum += i;
		i++;
	} while (i < 5);
	return Sum;
}

int DoWhileOnce()
{
	int Count = 0;
	do
	{
		Count++;
	} while (false);
	return Count;
}

int DoWhileWithBreak()
{
	int Sum = 0;
	int i = 0;
	do
	{
		Sum += i;
		i++;
		if (i >= 3)
		{
			break;
		}
	} while (true);
	return Sum;
}

int DoWhileWithContinue()
{
	int Sum = 0;
	int i = 0;
	do
	{
		i++;
		if (i % 2 == 0)
		{
			continue;
		}
		Sum += i;
	} while (i < 10);
	return Sum;
}

int NestedDoWhile()
{
	int Sum = 0;
	int i = 0;
	do
	{
		int j = 0;
		do
		{
			Sum += i + j;
			j++;
		} while (j < 2);
		i++;
	} while (i < 2);
	return Sum;
}

bool Observe_DoWhileBasic_Nominal()
{
	return BasicDoWhile() == 10 && DoWhileOnce() == 1 && DoWhileWithBreak() == 3 && DoWhileWithContinue() == 25 && NestedDoWhile() == 4;
}

int Observe_DoWhile_OnceEmptyBodyCount()
{
	int Count = 0;
	do
	{
		Count++;
	} while (false);
	return Count;
}

int Observe_DoWhile_ZeroAfterFirst()
{
	int Sum = 0;
	int i = 1;
	do
	{
		Sum += i;
		i++;
	} while (i < 1);
	return Sum;
}
