// Purpose: Observe default FNumberFormattingOptions() construction as the
// operator/value baseline against the shared grouped default.
// AS-facing API: FNumberFormattingOptions Options();
// Inputs: Default-constructed options, DefaultWithGrouping, and
// DefaultNoGrouping.
// Expected observations: Default construction matches DefaultWithGrouping
// or is at least identical to another default-constructed value. Grouped and
// ungrouped shared defaults are not identical.
// Boundary/ownership: DefaultWithGrouping/DefaultNoGrouping return shared
// const references and must not be treated as uniquely owned values.

namespace TS_FNumberFormattingOptions_Operators_01
{
	bool Observe_Options_Nominal()
	{
		FNumberFormattingOptions Options;
		FNumberFormattingOptions AlsoDefault;
		bool bDefaultsMatch = Options.IsIdentical(AlsoDefault);
		const FNumberFormattingOptions Grouped = FNumberFormattingOptions::DefaultWithGrouping();
		const FNumberFormattingOptions Ungrouped = FNumberFormattingOptions::DefaultNoGrouping();
		bool bSharedDefaultsDiffer = !Grouped.IsIdentical(Ungrouped);
		return bDefaultsMatch && bSharedDefaultsDiffer && Options.IsIdentical(Grouped);
	}
}
