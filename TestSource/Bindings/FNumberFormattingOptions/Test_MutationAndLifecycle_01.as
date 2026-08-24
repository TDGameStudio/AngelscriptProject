// Purpose: Observe fluent setters on FNumberFormattingOptions, including
// repeated sets and restoration toward defaults.
// AS-facing API: FNumberFormattingOptions& FNumberFormattingOptions.SetAlwaysSign(bool InValue);
// FNumberFormattingOptions& FNumberFormattingOptions.SetUseGrouping(bool InValue);
// FNumberFormattingOptions& FNumberFormattingOptions.SetRoundingMode(ERoundingMode InValue);
// FNumberFormattingOptions& FNumberFormattingOptions.SetMinimumIntegralDigits(int32 InValue);
// FNumberFormattingOptions& FNumberFormattingOptions.SetMaximumIntegralDigits(int32 InValue);
// FNumberFormattingOptions& FNumberFormattingOptions.SetMinimumFractionalDigits(int32 InValue);
// FNumberFormattingOptions& FNumberFormattingOptions.SetMaximumFractionalDigits(int32 InValue);
// Inputs: Default options, true/false flags, ToZero rounding, digit counts
// 1 and 3, repeated identical sets, then restore grouping true.
// Expected observations: Each setter returns the same options instance for
// chaining. After mutation IsIdentical against a fresh default is false.
// Restoration of grouping can be observed against DefaultNoGrouping.
// Boundary/ownership: Setters mutate this value and return a reference to it.

namespace TS_FNumberFormattingOptions_MutationAndLifecycle_01
{
	bool Observe_SetAlwaysSign_Nominal()
	{
		FNumberFormattingOptions Options;
		FNumberFormattingOptions Original;
		Options.SetAlwaysSign(true);
		Options.SetAlwaysSign(true);
		bool bMutated = !Options.IsIdentical(Original);
		Options.SetAlwaysSign(false);
		return bMutated && Options.IsIdentical(Original);
	}

	bool Observe_SetUseGrouping_Nominal()
	{
		FNumberFormattingOptions Options;
		Options.SetUseGrouping(false);
		bool bMatchesUngrouped = Options.IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
		Options.SetUseGrouping(true);
		return bMatchesUngrouped && Options.IsIdentical(FNumberFormattingOptions::DefaultWithGrouping());
	}

	bool Observe_SetRoundingMode_Nominal()
	{
		FNumberFormattingOptions Options;
		FNumberFormattingOptions Original;
		Options.SetRoundingMode(ERoundingMode::ToZero);
		return !Options.IsIdentical(Original);
	}

	bool Observe_SetMinimumIntegralDigits_Nominal()
	{
		FNumberFormattingOptions Options;
		FNumberFormattingOptions Original;
		Options.SetMinimumIntegralDigits(3);
		Options.SetMinimumIntegralDigits(3);
		return !Options.IsIdentical(Original);
	}

	bool Observe_SetMaximumIntegralDigits_Nominal()
	{
		FNumberFormattingOptions Options;
		FNumberFormattingOptions Original;
		Options.SetMaximumIntegralDigits(3);
		return !Options.IsIdentical(Original);
	}

	bool Observe_SetMinimumFractionalDigits_Nominal()
	{
		FNumberFormattingOptions Options;
		FNumberFormattingOptions Original;
		Options.SetMinimumFractionalDigits(2);
		return !Options.IsIdentical(Original);
	}

	bool Observe_SetMaximumFractionalDigits_Nominal()
	{
		FNumberFormattingOptions Options;
		FNumberFormattingOptions Original;
		Options.SetMaximumFractionalDigits(2);
		return !Options.IsIdentical(Original);
	}
}
