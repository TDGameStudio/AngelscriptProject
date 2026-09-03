/**
 * A profiled debug path combining a function-level scoped event, per-iteration scoped
 * events, a counter and a scratch buffer. C++ executes ProfiledDebugPath expecting 7.
 * The observers cover the nominal run and the empty scratch buffer.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ProfilerDebugPatterns
 * @Harness Function
 * @Tag Gameplay.Debug.ProfilerDebugPatternsUseScopedEventsCountersAndScratchMemory
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Positive profiled debug path: scoped events, counters, scratch.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::ProfilerDebugPatternsUseScopedEventsCountersAndScratchMemory
 * @Provenance ExecuteAndExpectInt ProfiledDebugPath == 7 (1+2+4). Extra: empty scratch array is 0
 * @Provenance messages; 4 iterations is the filled vector. DefaultSafe.
 */

namespace DebugTest
{
	/**
	 * The entrypoint C++ executes, collecting one bit each for the filled scratch buffer,
	 * the iteration count and the accumulated text length.
	 *
	 * @Kind Observe
	 * @Covers Debug.ProfilerDebugPatterns
	 * @Inputs none
	 * @Return 7 when all three scored
	 */
	UFUNCTION()
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

	/**
	 * Observe that every profiled pattern scored.
	 *
	 * @Kind Observe
	 * @Covers Debug.ProfilerDebugPatterns
	 * @Inputs none
	 * @Return true when the score is 7
	 */
	UFUNCTION()
	bool ProfiledDebugPathNominal()
	{
		return ProfiledDebugPath() == 7;
	}

	/**
	 * Observe that a fresh scratch buffer is empty.
	 *
	 * @Kind Observe
	 * @Covers Debug.ProfilerDebugPatterns
	 * @Inputs a freshly declared scratch buffer
	 * @Return true when it holds no messages
	 * @Boundary empty scratch
	 */
	UFUNCTION()
	bool ProfiledDebugPathEmptyScratch()
	{
		TArray<FString> ScratchMessages;
		return ScratchMessages.Num() == 0;
	}
}
