/**
 * @version v1
 * @summary FFormatArgumentValue host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FFormatArgumentValue
 *
 * container-api
 * oracle-ftext-format-0
 */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Observe the container API.
 * @covers FFormatArgumentValue.container-api
 * @inputs FFormatArgumentValue values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FFormatArgumentValue Value(const int32 Value);
// FFormatArgumentValue Value(const uint32 Value);
// FFormatArgumentValue Value(const int64 Value);
// FFormatArgumentValue Value(const uint64 Value);
// FFormatArgumentValue Value(const float32 Value);
// FFormatArgumentValue Value(const float64 Value);
// FFormatArgumentValue Value(const FText& Value);
// FFormatArgumentValue Value(ETextGender Value);
// Inputs: Empty default, 0 and 7 for integer widths, 0.0 and 1.5 for floats,
// FText::FromString("arg"), and ETextGender::Masculine.
// Expected observations: Each constructor produces a value that FText::Format
// can consume without discarding the argument.
// Boundary/ownership: Numeric constructors copy the scalar. The FText
// constructor copies localized text rather than aliasing the source.
bool ObserveValueNominal()
{
	FFormatArgumentValue Empty;
	FFormatArgumentValue FromInt32(7);
	FFormatArgumentValue FromUint32(uint32(7));
	FFormatArgumentValue FromInt64(int64(7));
	FFormatArgumentValue FromUint64(uint64(7));
	FFormatArgumentValue FromFloat32(float32(1.5));
	FFormatArgumentValue FromFloat64(float64(1.5));
	FText SourceText = FText::FromString("arg");
	FFormatArgumentValue FromText(SourceText);
	FFormatArgumentValue FromGender(ETextGender::Masculine);

	FText Pattern = FText::FromString("{0}");
	FString EmptyFormatted = FText::Format(Pattern, Empty).ToString();
	FString IntFormatted = FText::Format(Pattern, FromInt32).ToString();
	FString UintFormatted = FText::Format(Pattern, FromUint32).ToString();
	FString Int64Formatted = FText::Format(Pattern, FromInt64).ToString();
	FString Uint64Formatted = FText::Format(Pattern, FromUint64).ToString();
	FString Float32Formatted = FText::Format(Pattern, FromFloat32).ToString();
	FString Float64Formatted = FText::Format(Pattern, FromFloat64).ToString();
	FString TextFormatted = FText::Format(Pattern, FromText).ToString();
	FString GenderFormatted = FText::Format(Pattern, FromGender).ToString();

	return IntFormatted == "7" && UintFormatted == "7" && Int64Formatted == "7" && Uint64Formatted == "7" && Float32Formatted.Len() > 0 && Float64Formatted.Len() > 0 && TextFormatted == "arg" && EmptyFormatted != IntFormatted && GenderFormatted != IntFormatted;
}
/** @end */
/**
 * @begin oracle-ftext-format-0
 * @summary Oracle: FText::Format("{0}", Numeric) is "7".
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Oracle: FText::Format("{0}", Numeric) is "7".
 * @covers FFormatArgumentValue.oracle-ftext-format-0
 * @inputs FFormatArgumentValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FFormatArgumentValue DefaultValue;
	FFormatArgumentValue Numeric(7);
	FFormatArgumentValue Copied = Numeric;
	Copied = FFormatArgumentValue(9);
	FText Pattern = FText::FromString("{0}");
	FText Formatted = FText::Format(Pattern, Numeric);
	FString Text = Formatted.ToString();
	FString CopiedText = FText::Format(Pattern, Copied).ToString();
	return Text == "7" && CopiedText == "9";
}
/** @end */
