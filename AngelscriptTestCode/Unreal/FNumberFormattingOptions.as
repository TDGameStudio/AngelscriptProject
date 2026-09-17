/**
 * @version v1
 * @summary FNumberFormattingOptions host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FNumberFormattingOptions
 *
 * mutates-only-copy
 * set-always-sign
 * set-use-grouping
 * set-rounding-mode
 * set-minimum-integral-digits
 * set-maximum-integral-digits
 * set-minimum-fractional-digits
 * set-maximum-fractional-digits
 * default-with-grouping
 * default-no-grouping
 * options
 * get-type-hash
 * is-identical
 */
/**
 * @begin mutates-only-copy
 * @summary mutates only the copy.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary mutates only the copy.
 * @covers FNumberFormattingOptions.mutates-only-copy
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FNumberFormattingOptions DefaultOptions;
	FNumberFormattingOptions Copied = DefaultOptions;
	bool bCopyIdentical = Copied.IsIdentical(DefaultOptions);
	Copied.SetUseGrouping(false);
	return bCopyIdentical && !Copied.IsIdentical(DefaultOptions) && Copied.IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
}
/** @end */
/**
 * @begin set-always-sign
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @topic Unreal
 */
/**
 * @function ObserveSetAlwaysSignNominal
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @covers FNumberFormattingOptions.set-always-sign
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetAlwaysSignNominal()
{
	FNumberFormattingOptions Options;
	FNumberFormattingOptions Original;
	Options.SetAlwaysSign(true);
	Options.SetAlwaysSign(true);
	bool bMutated = !Options.IsIdentical(Original);
	Options.SetAlwaysSign(false);
	return bMutated && Options.IsIdentical(Original);
}
/** @end */
/**
 * @begin set-use-grouping
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @topic Unreal
 */
/**
 * @function ObserveSetUseGroupingNominal
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @covers FNumberFormattingOptions.set-use-grouping
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetUseGroupingNominal()
{
	FNumberFormattingOptions Options;
	Options.SetUseGrouping(false);
	bool bMatchesUngrouped = Options.IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
	Options.SetUseGrouping(true);
	return bMatchesUngrouped && Options.IsIdentical(FNumberFormattingOptions::DefaultWithGrouping());
}
/** @end */
/**
 * @begin set-rounding-mode
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @topic Unreal
 */
/**
 * @function ObserveSetRoundingModeNominal
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @covers FNumberFormattingOptions.set-rounding-mode
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetRoundingModeNominal()
{
	FNumberFormattingOptions Options;
	FNumberFormattingOptions Original;
	Options.SetRoundingMode(ERoundingMode::ToZero);
	return !Options.IsIdentical(Original);
}
/** @end */
/**
 * @begin set-minimum-integral-digits
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @topic Unreal
 */
/**
 * @function ObserveSetMinimumIntegralDigitsNominal
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @covers FNumberFormattingOptions.set-minimum-integral-digits
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetMinimumIntegralDigitsNominal()
{
	FNumberFormattingOptions Options;
	FNumberFormattingOptions Original;
	Options.SetMinimumIntegralDigits(3);
	Options.SetMinimumIntegralDigits(3);
	return !Options.IsIdentical(Original);
}
/** @end */
/**
 * @begin set-maximum-integral-digits
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @topic Unreal
 */
/**
 * @function ObserveSetMaximumIntegralDigitsNominal
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @covers FNumberFormattingOptions.set-maximum-integral-digits
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetMaximumIntegralDigitsNominal()
{
	FNumberFormattingOptions Options;
	FNumberFormattingOptions Original;
	Options.SetMaximumIntegralDigits(3);
	return !Options.IsIdentical(Original);
}
/** @end */
/**
 * @begin set-minimum-fractional-digits
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @topic Unreal
 */
/**
 * @function ObserveSetMinimumFractionalDigitsNominal
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @covers FNumberFormattingOptions.set-minimum-fractional-digits
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetMinimumFractionalDigitsNominal()
{
	FNumberFormattingOptions Options;
	FNumberFormattingOptions Original;
	Options.SetMinimumFractionalDigits(2);
	return !Options.IsIdentical(Original);
}
/** @end */
/**
 * @begin set-maximum-fractional-digits
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @topic Unreal
 */
/**
 * @function ObserveSetMaximumFractionalDigitsNominal
 * @summary Boundary/ownership: Setters mutate this value and return a reference to it.
 * @covers FNumberFormattingOptions.set-maximum-fractional-digits
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetMaximumFractionalDigitsNominal()
{
	FNumberFormattingOptions Options;
	FNumberFormattingOptions Original;
	Options.SetMaximumFractionalDigits(2);
	return !Options.IsIdentical(Original);
}
/** @end */
/**
 * @begin default-with-grouping
 * @summary assume unique ownership or mutate the shared objects.
 * @topic Unreal
 */
/**
 * @function ObserveDefaultWithGroupingNominal
 * @summary assume unique ownership or mutate the shared objects.
 * @covers FNumberFormattingOptions.default-with-grouping
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDefaultWithGroupingNominal()
{
	const FNumberFormattingOptions Grouped = FNumberFormattingOptions::DefaultWithGrouping();
	FNumberFormattingOptions Local;
	Local.SetUseGrouping(true);
	return Local.IsIdentical(Grouped) && !Grouped.IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
}
/** @end */
/**
 * @begin default-no-grouping
 * @summary assume unique ownership or mutate the shared objects.
 * @topic Unreal
 */
/**
 * @function ObserveDefaultNoGroupingNominal
 * @summary assume unique ownership or mutate the shared objects.
 * @covers FNumberFormattingOptions.default-no-grouping
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDefaultNoGroupingNominal()
{
	const FNumberFormattingOptions Ungrouped = FNumberFormattingOptions::DefaultNoGrouping();
	const FNumberFormattingOptions Grouped = FNumberFormattingOptions::DefaultWithGrouping();
	bool bSharedDefaultsDiffer = !Ungrouped.IsIdentical(Grouped);
	FNumberFormattingOptions Local;
	Local.SetUseGrouping(false);
	return bSharedDefaultsDiffer && Local.IsIdentical(Ungrouped);
}
/** @end */
/**
 * @begin options
 * @summary const references and must not be treated as uniquely owned values.
 * @topic Unreal
 */
/**
 * @function ObserveOptionsNominal
 * @summary const references and must not be treated as uniquely owned values.
 * @covers FNumberFormattingOptions.options
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOptionsNominal()
{
	FNumberFormattingOptions Options;
	FNumberFormattingOptions AlsoDefault;
	bool bDefaultsMatch = Options.IsIdentical(AlsoDefault);
	const FNumberFormattingOptions Grouped = FNumberFormattingOptions::DefaultWithGrouping();
	const FNumberFormattingOptions Ungrouped = FNumberFormattingOptions::DefaultNoGrouping();
	bool bSharedDefaultsDiffer = !Grouped.IsIdentical(Ungrouped);
	return bDefaultsMatch && bSharedDefaultsDiffer && Options.IsIdentical(Grouped);
}
/** @end */
/**
 * @begin get-type-hash
 * @summary Inputs: Two default options, one mutated
 * @topic Unreal
 */
/**
 * @function ObserveGetTypeHashNominal
 * @summary Inputs: Two default options, one mutated
 * @covers FNumberFormattingOptions.get-type-hash
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Two default options, one mutated

 with SetAlwaysSign(true), and the
// shared grouped/ungrouped defaults.
// Expected observations: Identical defaults share a hash and IsIdentical true.
// Mutated options are not identical to the original. Grouped vs ungrouped is
// false.
// Boundary/ownership: GetTypeHash does not mutate options. IsIdentical
// compares every formatting field.
bool ObserveGetTypeHashNominal()
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
/** @end */
/**
 * @begin is-identical
 * @summary compares every formatting field.
 * @topic Unreal
 */
/**
 * @function ObserveIsIdenticalNominal
 * @summary compares every formatting field.
 * @covers FNumberFormattingOptions.is-identical
 * @inputs FNumberFormattingOptions values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Two default options, one mutated

bool ObserveIsIdenticalNominal()
{
	FNumberFormattingOptions Left;
	FNumberFormattingOptions Right;
	bool bDefaultsIdentical = Left.IsIdentical(Right);
	Left.SetUseGrouping(false);
	bool bMutatedDiffers = Left.IsIdentical(Right);
	bool bSharedDiffer = FNumberFormattingOptions::DefaultWithGrouping().IsIdentical(FNumberFormattingOptions::DefaultNoGrouping());
	return bDefaultsIdentical && !bMutatedDiffers && !bSharedDiffer;
}
/** @end */
