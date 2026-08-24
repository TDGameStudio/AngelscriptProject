// Purpose: Observe FName compare, none-check, numeric suffix, plain string,
// IsEqual policy flags, and hash.
// AS-facing API: int32 Order = Name.Compare(const FName& Other) const;
// bool bNone = Name.IsNone() const; int32 Number = Name.GetNumber() const;
// FString Plain = Name.GetPlainNameString() const;
// bool bEqual = Name.IsEqual(const FName& Other, bool bIgnoreCase = true, bool bCompareNumber = true) const;
// uint Hash = Name.GetHash() const;
// Inputs: NAME_None, n"Alpha", n"Alpha_1", and n"alpha" for case policy.
// Expected observations: NAME_None.IsNone is true. Compare of a name with
// itself is 0. GetPlainNameString of Alpha_1 is Alpha. Default IsEqual ignores
// case. Hash of identical names matches.
// Boundary/ownership: GetPlainNameString returns a new FString without the
// numeric suffix. SetNumber is a separate mutation file.

namespace TS_FName_Queries_01
{
	bool Observe_Compare_Nominal()
	{
		FName Alpha = n"Alpha";
		FName Beta = n"Beta";
		int32 Self = Alpha.Compare(Alpha);
		int32 Ordered = Alpha.Compare(Beta);
		return Self == 0 && Ordered != 0;
	}

	bool Observe_IsNone_Nominal()
	{
		bool bNoneIsNone = NAME_None.IsNone();
		bool bAlphaIsNone = n"Alpha".IsNone();
		return bNoneIsNone && !bAlphaIsNone;
	}

	bool Observe_GetNumber_Nominal()
	{
		FName Plain = n"Alpha";
		int32 PlainNumber = Plain.GetNumber();
		FName Numbered = n"Alpha_1";
		int32 NumberedValue = Numbered.GetNumber();
		return PlainNumber == 0 && NumberedValue == 1 && Numbered.GetPlainNameString() == "Alpha";
	}

	bool Observe_GetPlainNameString_Nominal()
	{
		FName Numbered = n"Alpha_1";
		FString Plain = Numbered.GetPlainNameString();
		FString NonePlain = NAME_None.GetPlainNameString();
		return Plain == "Alpha" && NonePlain == "None";
	}

	bool Observe_IsEqual_Nominal()
	{
		FName Alpha = n"Alpha";
		FName Lower = n"alpha";
		bool bIgnoreCase = Alpha.IsEqual(Lower);
		bool bDefaultEqualsSelf = Alpha.IsEqual(Alpha);
		bool bHonorSelf = Alpha.IsEqual(Alpha, false, true);
		bool bHonorBeta = Alpha.IsEqual(n"Beta", false, true);
		return bIgnoreCase && bDefaultEqualsSelf && bHonorSelf && !bHonorBeta;
	}

	bool Observe_GetHash_Nominal()
	{
		FName Alpha = n"Alpha";
		FName Same = n"Alpha";
		FName Other = n"Beta";
		uint AlphaHash = Alpha.GetHash();
		uint SameHash = Same.GetHash();
		uint OtherHash = Other.GetHash();
		return AlphaHash == SameHash && OtherHash != AlphaHash;
	}
}
