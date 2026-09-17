/**
 * @version v1
 * @summary Observe EGuidFormats enumerators used to select textual GUID representations, including copy assignment.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe EGuidFormats enumerators used to select textual GUID representations, including copy assignment.
 * @topic Baseline
 */
// DigitsWithHyphensInBraces, DigitsWithHyphensInParentheses, HexValuesInBraces,
// UniqueObjectGuid, Short, Base36Encoded };
// Inputs: Each enumerator, a copy of Digits, and assignment to
// DigitsWithHyphens.
// Expected observations: Copied Digits equals the source. Assigned
// DigitsWithHyphens differs from Digits. ToString with each format returns
// a string.
// Boundary/ownership: The enum only selects a representation. It does not
// own GUID storage.

namespace TS_FGuid_ConstructionAndAssignment_01
{
	// EGuidFormats copy/assign plus Guid.ToString for each format.
	// Inputs: Guid(1,2,3,4). Oracle: Digits copy, assignment to DigitsWithHyphens,
	// every format yields a non-empty string. Shared enumerators.
	bool Observe_Surface001_Nominal()
	{
		EGuidFormats Digits = EGuidFormats::Digits;
		EGuidFormats Copied = Digits;
		Copied = EGuidFormats::DigitsWithHyphens;
		FGuid Guid(1, 2, 3, 4);
		FString AsDigits = Guid.ToString(EGuidFormats::Digits);
		FString AsHyphens = Guid.ToString(EGuidFormats::DigitsWithHyphens);
		FString AsBraces = Guid.ToString(EGuidFormats::DigitsWithHyphensInBraces);
		FString AsParens = Guid.ToString(EGuidFormats::DigitsWithHyphensInParentheses);
		FString AsHexBraces = Guid.ToString(EGuidFormats::HexValuesInBraces);
		FString AsUnique = Guid.ToString(EGuidFormats::UniqueObjectGuid);
		FString AsShort = Guid.ToString(EGuidFormats::Short);
		FString AsBase36 = Guid.ToString(EGuidFormats::Base36Encoded);
		return Digits == EGuidFormats::Digits && Copied == EGuidFormats::DigitsWithHyphens && AsDigits.Len() > 0 && AsHyphens.Len() > AsDigits.Len() && AsBraces.Len() > 0 && AsParens.Len() > 0 && AsHexBraces.Len() > 0 && AsUnique.Len() > 0 && AsShort.Len() > 0 && AsBase36.Len() > 0;
	}
}
/** @end */
