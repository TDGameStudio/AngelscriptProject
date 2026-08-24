// Purpose: Observe Equals, Compare, and GetHash with case policy and empty
// strings.
// AS-facing API: bool FString.Equals(const FString& Other, ESearchCase SearchCase = ESearchCase::CaseSensitive) const;
// int32 FString.Compare(const FString& Other, ESearchCase SearchCase = ESearchCase::CaseSensitive) const;
// uint FString.GetHash() const;
// Inputs: "Alpha" vs "alpha" vs "Beta" vs "".
// Expected observations: Default Equals is case-sensitive. IgnoreCase Equals
// is true for Alpha/alpha. Compare with self is 0. Identical strings share a
// hash.
// Boundary/ownership: These queries do not intern or mutate either operand.

namespace TS_FString_Queries_02
{
	bool Observe_Equals_Nominal()
	{
		FString Alpha = "Alpha";
		FString Lower = "alpha";
		FString Same = "Alpha";
		return !Alpha.Equals(Lower) && Alpha.Equals(Lower, ESearchCase::IgnoreCase) && Alpha.Equals(Same);
	}

	bool Observe_Compare_Nominal()
	{
		FString Alpha = "Alpha";
		FString Beta = "Beta";
		FString Same = "Alpha";
		return Alpha.Compare(Same) == 0 && Alpha.Compare(Beta) != 0 && Alpha.Compare("alpha", ESearchCase::IgnoreCase) == 0;
	}

	bool Observe_GetHash_Nominal()
	{
		FString Alpha = "Alpha";
		FString Same = "Alpha";
		FString Empty = "";
		uint AlphaHash = Alpha.GetHash();
		uint SameHash = Same.GetHash();
		uint EmptyHash = Empty.GetHash();
		return AlphaHash == SameHash && EmptyHash != AlphaHash;
	}
}
