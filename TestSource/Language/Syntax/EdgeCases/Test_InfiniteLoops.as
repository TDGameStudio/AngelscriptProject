// Theme: Language.Syntax.EdgeCases. Positive infinite loops terminated by break.
// C++: AngelscriptCoverageLoopTests.cpp::InfiniteLoops ExpectGlobalReturn
// sha256=92956c082956daf50cc005fc0629b9242951fbac58469a98a5f984092823ddd3; lines 704-759.
// Oracle: InfiniteFor()==10; InfiniteWhile()==7; InfiniteDoWhile()==5; MultipleBreaks()==56.
// Extra: do-while still runs once before the break check; MultipleBreaks is the dual-break boundary.
// DefaultSafe. Source owns locals.

int InfiniteFor()
{
	int Sum = 0;
	for (;;)
	{
		Sum++;
		if (Sum >= 10)
			break;
	}
	return Sum;
}

int InfiniteWhile()
{
	int Sum = 0;
	while (true)
	{
		Sum++;
		if (Sum >= 7)
			break;
	}
	return Sum;
}

int InfiniteDoWhile()
{
	int Sum = 0;
	do
	{
		Sum++;
		if (Sum >= 5)
			break;
	} while (true);
	return Sum;
}

int MultipleBreaks()
{
	int Sum = 0;
	for (int i = 0; i < 100; i++)
	{
		if (i > 20)
			break;
		if (i % 2 == 0)
			Sum += i;
		if (Sum > 50)
			break;
	}
	return Sum;
}

bool Observe_InfiniteLoops_Nominal()
{
	return InfiniteFor() == 10 && InfiniteWhile() == 7 && InfiniteDoWhile() == 5 && MultipleBreaks() == 56;
}

int Observe_InfiniteLoops_DoWhileOnceShape()
{
	return InfiniteDoWhile();
}
