// Purpose: Observe hashing and identity comparison of number-format options.
// AS-facing API: uint32 FNumberFormattingOptions.GetTypeHash() const;
// bool FNumberFormattingOptions.IsIdentical(const FNumberFormattingOptions& Other) const;
// Inputs: Two default options, one mutated with SetAlwaysSign(true), and the
// shared grouped/ungrouped defaults.
// Expected observations: Identical defaults share a hash and IsIdentical true.
// Mutated options are not identical to the original. Grouped vs ungrouped is
// false.
// Boundary/ownership: GetTypeHash does not mutate options. IsIdentical
// compares every formatting field.

namespace TS_FNumberFormattingOptions_Queries_01
{
	bool Observe_GetTypeHash_Nominal()
	{
		FNumberFormattingOptions Left;
		FNumberFormattingOptions Right;
		uint32 LeftHash = Left.GetTypeHash();
		uint32 RightHash = Right.GetTypeHash();
		bool bDefaultHashesMatch = LeftHash == RightHash;
		Left.SetAlwaysSign(true);
		uint32 MutatedHash = Left.GetTypeHash();
		return bDefaultHashesMatch && MutatedHash != RightHash && !Left.IsIdentical(Right);
	}

	bool Observe_IsIdentical_Nominal()
	{
		FNumberFormattingOptions Left;
		FNumberFormattingOptions Right;
		bool bDefaultsIdentical = Left.IsIdentical(Right);
		Left.SetUseGrouping(false);
		bool bMutatedDiffers = Left.IsIdentical(Right);
		bool bSharedDiffer = FNumberFormattingOptions::DefaultWithGrouping().IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
		return bDefaultsIdentical && !bMutatedDiffers && !bSharedDiffer;
	}
}
