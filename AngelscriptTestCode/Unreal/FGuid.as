/**
 * @version v1
 * @summary FGuid host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FGuid
 *
 * guid
 * ordering
 * invalidate
 * container-api
 * to-string
 * parse
 * parse-exact
 * new-guid
 * equality
 * index
 * is-valid
 * get-type-hash
 */
/**
 * @begin guid
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveGuidNominal
 * @summary Observe the container API.
 * @covers FGuid.guid
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FGuid Guid(const FString& InGuidStr); bool bOrdered = Left < Right;
// void Guid.Invalidate();
// Inputs: Words (1,2,3,4), the default ToString of that GUID, empty string
// construction as the boundary, and a larger GUID for ordering.
// Expected observations: Word constructor stores indexable words. String
// constructor round-trips ToString. Left < Right is true for (1,..) vs
// (5,..). Invalidate clears IsValid.
// Boundary/ownership: Invalid string construction is the diagnostic path.
// Ordering uses the same opCmp surface for <=, >, and >=.
bool ObserveGuidNominal()
{
	FGuid FromWords(1, 2, 3, 4);
	FString Text = FromWords.ToString();
	FGuid FromString(Text);
	return FromWords[0] == 1 && FromWords[3] == 4 && FromString == FromWords;
}
/** @end */
/**
 * @begin ordering
 * @summary Ordering uses the same opCmp surface for <=, >, and >=.
 * @topic Unreal
 */
/**
 * @function ObserveOrderingNominal
 * @summary Ordering uses the same opCmp surface for <=, >, and >=.
 * @covers FGuid.ordering
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveOrderingNominal()
{
	FGuid Left(1, 2, 3, 4);
	FGuid Right(5, 6, 7, 8);
	return Left < Right && Left <= Right && Right > Left && Right >= Left;
}
/** @end */
/**
 * @begin invalidate
 * @summary Ordering uses the same opCmp surface for <=, >, and >=.
 * @topic Unreal
 */
/**
 * @function ObserveInvalidateNominal
 * @summary Ordering uses the same opCmp surface for <=, >, and >=.
 * @covers FGuid.invalidate
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInvalidateNominal()
{
	FGuid Guid(1, 2, 3, 4);
	bool bWasValid = Guid.IsValid();
	Guid.Invalidate();
	bool bNowInvalid = !Guid.IsValid();
	Guid.Invalidate();
	bool bRepeatedInvalidateStable = !Guid.IsValid();
	return bWasValid && bNowInvalid && bRepeatedInvalidateStable;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Observe the container API.
 * @covers FGuid.container-api
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
 Inputs: Guid(1,2,3,4). Oracle: Digits copy, assignment to DigitsWithHyphens,
// every format yields a non-empty string. Shared enumerators.
bool ObserveSurface001Nominal()
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
/** @end */
/**
 * @begin to-string
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary Observe the container API.
 * @covers FGuid.to-string
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Guid(1,2,3,4), Digits and DigitsWithHyphens formats, empty string,
// and a Digits string parsed with the wrong exact format.
// Expected observations: Default ToString is non-empty. Parse of that text
// succeeds. Parse of empty text fails. ParseExact with the matching format
// succeeds and the mismatched format fails.
// Boundary/ownership: OutGuid is written only when the parse returns true.
bool ObserveToStringNominal()
{
	FGuid Guid(1, 2, 3, 4);
	FString DefaultText = Guid.ToString();
	FString Digits = Guid.ToString(EGuidFormats::Digits);
	FString Hyphens = Guid.ToString(EGuidFormats::DigitsWithHyphens);
	FString ZeroText = FGuid(0, 0, 0, 0).ToString();
	return DefaultText.Len() > 0 && Digits.Len() > 0 && Hyphens.Len() > Digits.Len() && ZeroText.Len() > 0;
}
/** @end */
/**
 * @begin parse
 * @summary Boundary/ownership: OutGuid is written only when the parse returns true.
 * @topic Unreal
 */
/**
 * @function ObserveParseNominal
 * @summary Boundary/ownership: OutGuid is written only when the parse returns true.
 * @covers FGuid.parse
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveParseNominal()
{
	FGuid Guid(1, 2, 3, 4);
	FString Text = Guid.ToString();
	FGuid Parsed;
	bool bParsed = FGuid::Parse(Text, Parsed);
	FGuid Failed;
	bool bEmptyFailed = FGuid::Parse("", Failed);
	return bParsed && Parsed == Guid && !bEmptyFailed;
}
/** @end */
/**
 * @begin parse-exact
 * @summary Boundary/ownership: OutGuid is written only when the parse returns true.
 * @topic Unreal
 */
/**
 * @function ObserveParseExactNominal
 * @summary Boundary/ownership: OutGuid is written only when the parse returns true.
 * @covers FGuid.parse-exact
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveParseExactNominal()
{
	FGuid Guid(1, 2, 3, 4);
	FString Digits = Guid.ToString(EGuidFormats::Digits);
	FGuid Parsed;
	bool bExactDigits = FGuid::ParseExact(Digits, EGuidFormats::Digits, Parsed);
	FGuid Mismatched;
	bool bWrongFormat = FGuid::ParseExact(Digits, EGuidFormats::DigitsWithHyphens, Mismatched);
	return bExactDigits && Parsed == Guid && !bWrongFormat;
}
/** @end */
/**
 * @begin new-guid
 * @summary generator.
 * @topic Unreal
 */
/**
 * @function ObserveNewGuidNominal
 * @summary generator.
 * @covers FGuid.new-guid
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveNewGuidNominal()
{
	FGuid First = FGuid::NewGuid();
	FGuid Second = FGuid::NewGuid();
	FGuid Zero(0, 0, 0, 0);
	return First.IsValid() && Second.IsValid() && !(First == Zero) && !(Second == Zero);
}
/** @end */
/**
 * @begin equality
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Observe the container API.
 * @covers FGuid.equality
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Guid(1,2,3,4), an identical copy, a zero Guid(0,0,0,0), and index
// 0 as the first word plus 3 as the last word.
// Expected observations: Identical GUIDs compare true. Zero vs nonzero is
// false. Guid[0] is 1. Assigning through the mutable reference changes word 0
// and is visible on a later read of Guid[0].
// Boundary/ownership: Subscript returns an alias into the GUID words.
// Out-of-range index is the diagnostic path.
bool ObserveEqualityNominal()
{
	FGuid Left(1, 2, 3, 4);
	FGuid Right(1, 2, 3, 4);
	FGuid Zero(0, 0, 0, 0);
	return Left == Right && !(Left == Zero);
}
/** @end */
/**
 * @begin index
 * @summary Out-of-range index is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Out-of-range index is the diagnostic path.
 * @covers FGuid.index
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIndexNominal()
{
	FGuid Guid(1, 2, 3, 4);
	uint32 First = Guid[0];
	uint32 Last = Guid[3];
	Guid[0] = 9;
	uint32 Aliased = Guid[0];
	const FGuid ConstGuid(1, 2, 3, 4);
	uint32 ConstWord = ConstGuid[1];
	return First == 1 && Last == 4 && Aliased == 9 && ConstWord == 2;
}
/** @end */
/**
 * @begin is-valid
 * @summary does not mutate the GUID.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary does not mutate the GUID.
 * @covers FGuid.is-valid
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidNominal()
{
	FGuid Valid(1, 2, 3, 4);
	FGuid Invalid(0, 0, 0, 0);
	return Valid.IsValid() && !Invalid.IsValid();
}
/** @end */
/**
 * @begin get-type-hash
 * @summary does not mutate the GUID.
 * @topic Unreal
 */
/**
 * @function ObserveGetTypeHashNominal
 * @summary does not mutate the GUID.
 * @covers FGuid.get-type-hash
 * @inputs FGuid values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTypeHashNominal()
{
	FGuid Left(1, 2, 3, 4);
	FGuid Right(1, 2, 3, 4);
	FGuid Other(5, 6, 7, 8);
	uint32 LeftHash = Left.GetTypeHash();
	uint32 RightHash = Right.GetTypeHash();
	return LeftHash == RightHash && !(Other == Left) && Other.IsValid();
}
/** @end */
