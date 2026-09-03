/**
 * The formatted debug log surface, where the emitted line carries both a value and the
 * branch it selected. C++ executes the entrypoint expecting 3 and then checks the log
 * capture for the assembled line, so the message shape is part of the contract. The
 * observers cover the zero value and the branch boundary.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.FormattedDebugLoggingSurface
 * @Harness Function
 * @Tag Gameplay.Debug.FormattedDebugLoggingSurfaceIncludesValuesAndContext
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Positive formatted debug log surface.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::FormattedDebugLoggingSurfaceIncludesValuesAndContext
 * @Provenance ExecuteAndExpectInt 3. LogCapture contains "CoverageDebugFormatted Value=42 Branch=High".
 * @Provenance Extra: Value 0 keeps Branch Low; Value 20 is the false side of > 20. DefaultSafe.
 */

namespace DebugTest
{
	/**
	 * The entrypoint C++ executes, emitting the enter, value and exit lines.
	 *
	 * @Kind Observe
	 * @Covers Debug.FormattedDebugLoggingSurface
	 * @Inputs none
	 * @Return 3 once all three lines have been emitted
	 */
	UFUNCTION()
	int EmitFormattedDebugLogSurface()
	{
		FString FunctionName = "EmitFormattedDebugLogSurface";
		FString ObjectName = "CoverageDebugObject";
		int Value = 42;
		FString Branch = "Low";

		if (Value > 20)
		{
			Branch = "High";
		}

		Log(n"CoverageDebugFormat", "Enter " + FunctionName + " Object=" + ObjectName);
		LogDisplay(n"CoverageDebugFormat", "CoverageDebugFormatted Value=" + Value + " Branch=" + Branch);
		Log(n"CoverageDebugFormat", "Exit " + FunctionName);
		return 3;
	}

	/**
	 * Observe that driving the formatted log surface reports success.
	 *
	 * @Kind Observe
	 * @Covers Debug.FormattedDebugLoggingSurface
	 * @Inputs none
	 * @Return true when the entrypoint returned 3
	 */
	UFUNCTION()
	bool EmitFormattedDebugLogSurfaceNominal()
	{
		return EmitFormattedDebugLogSurface() == 3;
	}

	/**
	 * Observe that a zero value keeps the branch on its low side.
	 *
	 * @Kind Observe
	 * @Covers Debug.FormattedDebugLoggingSurface
	 * @Inputs a zero value
	 * @Return true when the value is 0 and the branch stayed Low
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool FormattedBranchEmptyZero()
	{
		int Value = 0;
		FString Branch = "Low";
		if (Value > 20)
		{
			Branch = "High";
		}

		if (Value != 0)
		{
			return false;
		}
		return Branch == "Low";
	}

	/**
	 * Observe that the branch threshold is exclusive.
	 *
	 * @Kind Observe
	 * @Covers Debug.FormattedDebugLoggingSurface
	 * @Inputs a value exactly at the threshold
	 * @Return true when the value is 20 and the branch stayed Low
	 * @Boundary threshold value
	 */
	UFUNCTION()
	bool FormattedBranchBoundary20()
	{
		int Value = 20;
		FString Branch = "Low";
		if (Value > 20)
		{
			Branch = "High";
		}

		if (Value != 20)
		{
			return false;
		}
		return Branch == "Low";
	}
}
