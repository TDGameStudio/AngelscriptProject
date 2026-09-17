/**
 * @version v1
 * @summary Observe empty/copy construction, lexical ordering, reverse, and left/right/mid slicing plus control-character escaping.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe empty/copy construction, lexical ordering, reverse, and left/right/mid slicing plus control-character escaping.
 * @topic Baseline
 */
// FString FString.Reverse() const; Left/LeftChop/Right/RightChop/Mid;
// FString FString.ReplaceCharWithEscapedChar() const;
// Inputs: Empty default, copy of "alpha", "beta" for ordering, "abc", Count 0
// and Count 2, Mid start 1, and a string containing a newline.
// Expected observations: Empty constructs length 0. Copy is independent.
// "alpha" < "beta". Reverse("abc") is "cba". Left(2) is "ab". Count 0 yields
// empty slices. Escaping a newline grows the copy.
// Boundary/ownership: Slice helpers return copies. Mid Count defaults to the
// remainder of the string.

namespace TS_FString_Behavior_01
{
	// FString default constructor. No extra inputs. IsEmpty is true. Value type;
	// no fixture.
	bool Observe_Surface003_Nominal()
	{
		FString Text;
		return Text.IsEmpty();
	}

	// FString copy constructor. Input "alpha", then mutate the source with "x".
	// Copy stays "alpha"; source becomes "alphax". Copy is independent.
	bool Observe_Text_Nominal()
	{
		FString Source = "alpha";
		FString Copied(Source);
		Source += "x";
		return Copied == "alpha" && Source == "alphax";
	}

	// FString < <= > >=. Inputs "alpha" and "beta". alpha < beta, alpha <= "alpha",
	// beta > alpha, beta >= "beta". Lexical ordering; operands unchanged.
	bool Observe_Ordering_Nominal()
	{
		FString Alpha = "alpha";
		FString Beta = "beta";
		return (Alpha < Beta) && (Alpha <= FString("alpha")) && (Beta > Alpha) && (Beta >= FString("beta"));
	}

	// FString.Reverse. Inputs "abc" and "". Reverse is "cba"; empty stays empty.
	// Returns a copy.
	bool Observe_Reverse_Nominal()
	{
		FString Reversed = FString("abc").Reverse();
		FString Empty = FString("").Reverse();
		return Reversed == "cba" && Empty.IsEmpty();
	}

	// FString.Left. Input "abc", Count 2 and 0. Left(2) is "ab"; Left(0) is empty.
	// Returns a copy; source unchanged.
	bool Observe_Left_Nominal()
	{
		FString Text = "abc";
		return Text.Left(2) == "ab" && Text.Left(0).IsEmpty();
	}

	// FString.LeftChop. Input "abc", Count 1 and 0. LeftChop(1) is "ab";
	// LeftChop(0) is "abc". Returns a copy.
	bool Observe_LeftChop_Nominal()
	{
		FString Text = "abc";
		return Text.LeftChop(1) == "ab" && Text.LeftChop(0) == "abc";
	}

	// FString.Right. Input "abc", Count 2 and 0. Right(2) is "bc"; Right(0) is
	// empty. Returns a copy.
	bool Observe_Right_Nominal()
	{
		FString Text = "abc";
		return Text.Right(2) == "bc" && Text.Right(0).IsEmpty();
	}

	// FString.RightChop. Input "abc", Count 1 and 0. RightChop(1) is "bc";
	// RightChop(0) is "abc". Returns a copy.
	bool Observe_RightChop_Nominal()
	{
		FString Text = "abc";
		return Text.RightChop(1) == "bc" && Text.RightChop(0) == "abc";
	}

	// FString.Mid. Input "abc", start 1 omitted count, start 1 count 2, start 3.
	// Results "bc", "bc", and empty. Returns a copy; default count is remainder.
	bool Observe_Mid_Nominal()
	{
		FString Text = "abc";
		return Text.Mid(1) == "bc" && Text.Mid(1, 2) == "bc" && Text.Mid(3).IsEmpty();
	}

	// FString.ReplaceCharWithEscapedChar. Input "a\nb". Escaped length grows;
	// source stays "a\nb". Returns a copy.
	bool Observe_ReplaceCharWithEscapedChar_Nominal()
	{
		FString Text = "a\nb";
		FString Escaped = Text.ReplaceCharWithEscapedChar();
		return Escaped.Len() > Text.Len() && Text == "a\nb";
	}
}
/** @end */
