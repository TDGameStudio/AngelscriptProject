/**
 * FString formatting and construction helpers: Format placeholders, FromInt,
 * Chr/ChrN, padding and tab conversion. Each observation isolates one helper
 * so a failure names the exact API that regressed.
 *
 * @Theme Language.Literals
 * @Subject Literals.FormatMethods
 * @Harness Function
 * @Tag Language.Literals.FormatMethods
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringMethodTests.cpp::FormatMethods
 * @Provenance sha256 from TS-LANG-0158; lines 845-888.
 * @Provenance Oracle: 42; 3.140000; Hello World; 2 + 3 = 5; -17; ABBB; "  7|7  "; "A B".
 * @Provenance Extra: Format of empty string; FromInt 0.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Formats a single integer into a placeholder.
	 *
	 * @Covers Literals.FString
	 * @Inputs FString::Format("{0}", 42)
	 * @Return "42"
	 */
	FString FormatInt()
	{
		return FString::Format("{0}", 42);
	}

	/**
	 * Formats a single float into a placeholder.
	 *
	 * @Covers Literals.FString
	 * @Inputs FString::Format("{0}", 3.14f)
	 * @Return "3.140000"
	 */
	FString FormatFloat()
	{
		return FString::Format("{0}", 3.14f);
	}

	/**
	 * Substitutes a string argument into a template.
	 *
	 * @Covers Literals.FString
	 * @Inputs FString::Format("Hello {0}", "World")
	 * @Return "Hello World"
	 */
	FString FormatString()
	{
		return FString::Format("Hello {0}", "World");
	}

	/**
	 * Substitutes several positional arguments at once.
	 *
	 * @Covers Literals.FString
	 * @Inputs FString::Format("{0} + {1} = {2}", 2, 3, 5)
	 * @Return "2 + 3 = 5"
	 */
	FString FormatMultiple()
	{
		return FString::Format("{0} + {1} = {2}", 2, 3, 5);
	}

	/**
	 * Converts a negative integer to text.
	 *
	 * @Covers Literals.FString
	 * @Inputs FString::FromInt(-17)
	 * @Return "-17"
	 */
	FString FromIntNegative()
	{
		return FString::FromInt(-17);
	}

	/**
	 * Builds text from one Chr code point and a ChrN run.
	 *
	 * @Covers Literals.FString
	 * @Inputs Chr(0x41) concatenated with ChrN(3, 0x42)
	 * @Return "ABBB"
	 */
	FString ChrAndChrN()
	{
		return FString::Chr(0x41) + FString::ChrN(3, 0x42);
	}

	/**
	 * Pads one value on the left and one on the right to width three.
	 *
	 * @Covers Literals.FString
	 * @Inputs LeftPad(3) and RightPad(3) over "7"
	 * @Return "  7|7  "
	 */
	FString LeftPadAndRightPad()
	{
		FString left = "7";
		FString right = "7";
		return left.LeftPad(3) + "|" + right.RightPad(3);
	}

	/**
	 * Expands an embedded tab into spaces.
	 *
	 * @Covers Literals.FString
	 * @Inputs ConvertTabsToSpaces(2) over "A\tB"
	 * @Return "A B"
	 */
	FString ConvertTabsToSpaces()
	{
		FString value = "A\tB";
		return value.ConvertTabsToSpaces(2);
	}

	/**
	 * Observe that every formatted and constructed value matches its oracle.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Format/FromInt/Chr/ChrN/pad/tab helpers
	 * @Return true when all eight outcomes match
	 */
	UFUNCTION()
	bool FormatMethodsProduceExpectedValues()
	{
		if (FormatInt() != "42")
		{
			return false;
		}

		if (FormatFloat() != "3.140000")
		{
			return false;
		}

		if (FormatString() != "Hello World")
		{
			return false;
		}

		if (FormatMultiple() != "2 + 3 = 5")
		{
			return false;
		}

		if (FromIntNegative() != "-17")
		{
			return false;
		}

		if (ChrAndChrN() != "ABBB")
		{
			return false;
		}

		if (LeftPadAndRightPad() != "  7|7  ")
		{
			return false;
		}

		return ConvertTabsToSpaces() == "A B";
	}

	/**
	 * Observe that an empty argument substitutes cleanly.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs FString::Format("Hello {0}", "")
	 * @Return the formatted string
	 * @Boundary empty argument
	 */
	UFUNCTION()
	FString FormatEmptyArgument()
	{
		return FString::Format("Hello {0}", "");
	}

	/**
	 * Observe the zero boundary of FromInt.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs FString::FromInt(0)
	 * @Return "0"
	 * @Boundary zero
	 */
	UFUNCTION()
	FString FromIntZeroBoundary()
	{
		return FString::FromInt(0);
	}
}
