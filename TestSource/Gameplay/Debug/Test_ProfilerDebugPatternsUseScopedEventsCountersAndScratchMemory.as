// Theme: Gameplay.Debug. Positive profiled debug path: scoped events, counters, scratch.
// C++: AngelscriptCoverageDebugTests.cpp::ProfilerDebugPatternsUseScopedEventsCountersAndScratchMemory
// ExecuteAndExpectInt ProfiledDebugPath == 7 (1+2+4). Extra: empty scratch array is 0
// messages; 4 iterations is the filled vector. DefaultSafe.

int ProfiledDebugPath()
{
	int Score = 0;
	int CallCount = 0;
	int ScratchTextLength = 0;

	{
		FCpuProfilerTraceScoped FunctionScope(n"CoverageDebugProfiledFunction");
		TArray<FString> ScratchMessages;

		for (int Index = 0; Index < 4; ++Index)
		{
			FCpuProfilerTraceScoped IterationScope(n"CoverageDebugProfiledIteration");
			FString Message = "Sample=" + Index;
			ScratchMessages.Add(Message);
			ScratchTextLength += Message.Len();
			CallCount++;
		}

		if (ScratchMessages.Num() == 4)
		{
			Score += 1;
		}
	}

	if (CallCount == 4)
	{
		Score += 2;
	}
	if (ScratchTextLength > 0)
	{
		Score += 4;
	}

	return Score;
}

bool Observe_ProfiledDebugPath_Nominal()
{
	return ProfiledDebugPath() == 7;
}

bool Observe_ProfiledDebugPath_EmptyScratch()
{
	TArray<FString> ScratchMessages;
	return ScratchMessages.Num() == 0;
}
