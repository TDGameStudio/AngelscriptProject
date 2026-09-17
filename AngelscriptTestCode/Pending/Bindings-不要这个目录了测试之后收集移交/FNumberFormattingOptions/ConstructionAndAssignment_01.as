/**
 * @version v1
 * @summary Observe FNumberFormattingOptions as the localized number-format configuration value type, including copy assignment.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FNumberFormattingOptions as the localized number-format configuration value type, including copy assignment.
 * @topic Baseline
 */
// DefaultNoGrouping over DefaultWithGrouping.
// Expected observations: Default options are identical to a second default.
// Assigned copies remain independent after a later SetUseGrouping mutation
// on one instance.
// Boundary/ownership: The struct is a value type. Copies do not share
// mutable storage with the source after assignment.

namespace TS_FNumberFormattingOptions_ConstructionAndAssignment_01
{
	// struct FNumberFormattingOptions copy stays identical until SetUseGrouping
	// mutates only the copy; runner-readable oracle is IsIdentical.
	bool Observe_Surface001_Nominal()
	{
		FNumberFormattingOptions DefaultOptions;
		FNumberFormattingOptions Copied = DefaultOptions;
		bool bCopyIdentical = Copied.IsIdentical(DefaultOptions);
		Copied.SetUseGrouping(false);
		return bCopyIdentical && !Copied.IsIdentical(DefaultOptions) && Copied.IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
	}
}
/** @end */
