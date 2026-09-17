/**
 * @version v1
 * @summary Observe the shared default FNumberFormattingOptions with grouping enabled and disabled.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe the shared default FNumberFormattingOptions with grouping enabled and disabled.
 * @topic Baseline
 */
// const FNumberFormattingOptions& FNumberFormattingOptions::DefaultNoGrouping();
// Inputs: The two shared defaults, compared with a locally grouped/ungrouped
// constructed options value.
// Expected observations: The two shared defaults are not identical. A local
// SetUseGrouping(false) matches DefaultNoGrouping or at least differs from
// DefaultWithGrouping.
// Boundary/ownership: These return shared const references. Callers must not
// assume unique ownership or mutate the shared objects.

namespace TS_FNumberFormattingOptions_NamespaceAndGlobalFunctions_01
{
	bool Observe_DefaultWithGrouping_Nominal()
	{
		const FNumberFormattingOptions Grouped = FNumberFormattingOptions::DefaultWithGrouping();
		FNumberFormattingOptions Local;
		Local.SetUseGrouping(true);
		return Local.IsIdentical(Grouped) && !Grouped.IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
	}

	bool Observe_DefaultNoGrouping_Nominal()
	{
		const FNumberFormattingOptions Ungrouped = FNumberFormattingOptions::DefaultNoGrouping();
		const FNumberFormattingOptions Grouped = FNumberFormattingOptions::DefaultWithGrouping();
		bool bSharedDefaultsDiffer = !Ungrouped.IsIdentical(Grouped);
		FNumberFormattingOptions Local;
		Local.SetUseGrouping(false);
		return bSharedDefaultsDiffer && Local.IsIdentical(Ungrouped);
	}
}
/** @end */
