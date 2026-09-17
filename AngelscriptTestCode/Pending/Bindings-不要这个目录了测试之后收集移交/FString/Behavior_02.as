/**
 * @version v1
 * @summary Observe unescape, padding, quote/whitespace/char trimming, and implicit FString construction from a contributed value.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe unescape, padding, quote/whitespace/char trimming, and implicit FString construction from a contributed value.
 * @topic Baseline
 */
// LeftPad/RightPad; TrimQuotes(bool& OutQuotesRemoved);
// TrimStartAndEnd/TrimStart/TrimEnd; TrimChar(int16);
// FString Text(ImplicitContributedValue);
// Inputs: "a\\nb", "ab" padded to 4, quoted "\"ab\"", "  ab  ", TrimChar 46
// ('.'), integer 7 as implicit construction.
// Expected observations: Unescape shrinks or restores control characters.
// LeftPad/RightPad reach Count. TrimQuotes writes OutQuotesRemoved true for
// quoted text and false for unquoted. Trims do not mutate the source.
// Boundary/ownership: All trim/pad helpers return copies. OutQuotesRemoved is
// a writeback bool.

namespace TS_FString_Behavior_02
{
	bool Observe_ReplaceEscapedCharWithChar_Nominal()
	{
		FString Escaped = "a\\nb";
		FString Unescaped = Escaped.ReplaceEscapedCharWithChar();
		return Unescaped != Escaped && Unescaped.Len() > 0 && Escaped == "a\\nb";
	}

	bool Observe_LeftPad_Nominal()
	{
		FString Padded = FString("ab").LeftPad(4);
		FString NoPad = FString("abcd").LeftPad(2);
		return Padded.Len() == 4 && Padded.EndsWith("ab") && NoPad == "abcd";
	}

	bool Observe_RightPad_Nominal()
	{
		FString Padded = FString("ab").RightPad(4);
		return Padded.Len() == 4 && Padded.StartsWith("ab");
	}

	bool Observe_TrimQuotes_Nominal()
	{
		bool bRemoved = false;
		FString Quoted = FString("\"ab\"").TrimQuotes(bRemoved);
		bool bUnquotedRemoved = true;
		FString Unquoted = FString("ab").TrimQuotes(bUnquotedRemoved);
		return Quoted == "ab" && bRemoved && Unquoted == "ab" && !bUnquotedRemoved;
	}

	bool Observe_TrimStartAndEnd_Nominal()
	{
		FString Trimmed = FString("  ab  ").TrimStartAndEnd();
		return Trimmed == "ab";
	}

	bool Observe_TrimStart_Nominal()
	{
		FString Trimmed = FString("  ab  ").TrimStart();
		return Trimmed == "ab  ";
	}

	bool Observe_TrimEnd_Nominal()
	{
		FString Trimmed = FString("  ab  ").TrimEnd();
		return Trimmed == "  ab";
	}

	bool Observe_TrimChar_Nominal()
	{
		FString Trimmed = FString("..ab..").TrimChar(46);
		FString Empty = FString("").TrimChar(46);
		return Trimmed == "ab" && Empty.IsEmpty();
	}

	bool Observe_Text_Nominal()
	{
		FString FromInt(7);
		FName ImplicitName = n"Alpha";
		FString FromName = f"{ImplicitName}";
		return FromInt.Contains("7") && FromName.Contains("Alpha");
	}
}
/** @end */
