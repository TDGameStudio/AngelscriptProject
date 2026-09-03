/**
 * FString, FName, and FText UFUNCTION in, out, inout, and defaults.
 * ConcatStrings("Hello"," World") is "Hello World". DefaultString omitted
 * yields "UFunctionDefaultString|Seen". Empty concat is empty, a nullptr
 * actor is the empty handle, and MutateAll leaves a copy of the original.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ParametersAndReturnFStringNameText
 * @Harness UClass
 * @Tag Definitions.UFunction.ParametersAndReturnFStringNameText
 * @Provenance Theme: Definitions.UFunction. WorldStory FString/FName/FText UFUNCTION in/out/inout/defaults.
 * @Provenance C++: AngelscriptCoverageFStringFunctionTests.cpp::UFunctionParametersAndReturn
 * @Provenance Oracle: ConcatStrings("Hello"," World")=="Hello World"; DefaultString omitted -> "UFunctionDefaultString|Seen".
 * @Provenance Extra: ConcatStrings empty strings; nullptr actor is the empty handle; MutateAll leaves a copy of the original.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageFStringFunctionActor : AActor
{
	/**
	 * Concatenate two strings.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First string
	 * @Param b Second string
	 * @Inputs a and b
	 * @Return a + b
	 */
	UFUNCTION()
	FString ConcatStrings(FString a, FString b)
	{
		return a + b;
	}

	/**
	 * Return the name ActorName.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs none
	 * @Return n"ActorName"
	 */
	UFUNCTION()
	FName GetName()
	{
		return n"ActorName";
	}

	/**
	 * Echo an FText.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param value Text echoed
	 * @Inputs value
	 * @Return value
	 */
	UFUNCTION()
	FText EchoText(FText value)
	{
		return value;
	}

	/**
	 * Describe const &in string, name, and text references.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param label String received as const FString&in
	 * @Param name Name received as FName&in
	 * @Param text Text received as FText&in
	 * @Inputs label, name, and text
	 * @Return label|name|text
	 */
	UFUNCTION()
	FString DescribeReferences(const FString&in label, FName&in name, FText&in text)
	{
		return label + "|" + name.ToString() + "|" + text.ToString();
	}

	/**
	 * Format Count:7 through FText::Format.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs FText::Format of Count and 7
	 * @Return "Count:7"
	 */
	UFUNCTION()
	FString FormatTextResult()
	{
		return FText::Format(FText::FromString("{0}:{1}"), FText::FromString("Count"), 7).ToString();
	}

	/**
	 * Append |Seen to a string, defaulting to UFunctionDefaultString.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param value String stored, default "UFunctionDefaultString"
	 * @Inputs value
	 * @Return value + "|Seen"
	 */
	UFUNCTION()
	FString DefaultString(FString value = "UFunctionDefaultString")
	{
		return value + "|Seen";
	}

	/**
	 * Append |Seen to a name, defaulting to UFunctionDefaultName.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param value Name stored, default n"UFunctionDefaultName"
	 * @Inputs value
	 * @Return value.ToString() + "|Seen"
	 */
	UFUNCTION()
	FString DefaultName(FName value = n"UFunctionDefaultName")
	{
		return value.ToString() + "|Seen";
	}

	/**
	 * Write "UFUNCTION Output" to an out string.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as FString&out
	 * @Inputs an empty out string
	 * @Return void
	 */
	UFUNCTION()
	void WriteOut(FString&out result)
	{
		result = "UFUNCTION Output";
	}

	/**
	 * Write a name and text to out slots.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param outName Destination received as FName&out
	 * @Param outText Destination received as FText&out
	 * @Inputs two empty out slots
	 * @Return void
	 */
	UFUNCTION()
	void WriteNameAndText(FName&out outName, FText&out outText)
	{
		outName = n"UFunctionNameOut";
		outText = FText::FromString("UFunctionTextOut");
	}

	/**
	 * Mutate string, name, and text through &inout.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param label String received as FString&inout
	 * @Param name Name received as FName&inout
	 * @Param text Text received as FText&inout
	 * @Inputs label, name, and text
	 * @Return void; each channel appends Mutated
	 */
	UFUNCTION()
	void MutateAll(FString&inout label, FName&inout name, FText&inout text)
	{
		label += "|Mutated";
		name = FName(name.ToString() + "Mutated");
		text = FText::FromString(text.ToString() + "Mutated");
	}

	/**
	 * Observe concat, name, text, describe, format, defaults, and out writes.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ConcatStrings, GetName, EchoText, DescribeReferences, FormatTextResult, DefaultString, DefaultName, WriteOut, WriteNameAndText
	 * @Return true when every channel matches the oracle
	 */
	UFUNCTION()
	bool StringFunctionLiveMatrix()
	{
		FString OutString = "";
		WriteOut(OutString);
		FName OutName;
		FText OutText;
		WriteNameAndText(OutName, OutText);
		if (ConcatStrings("Hello", " World") != "Hello World")
		{
			return false;
		}
		if (GetName() != n"ActorName")
		{
			return false;
		}
		if (EchoText(FText::FromString("Echo")).ToString() != "Echo")
		{
			return false;
		}
		if (DescribeReferences("L", n"N", FText::FromString("T")) != "L|N|T")
		{
			return false;
		}
		if (FormatTextResult() != "Count:7")
		{
			return false;
		}
		if (DefaultString() != "UFunctionDefaultString|Seen")
		{
			return false;
		}
		if (DefaultName() != "UFunctionDefaultName|Seen")
		{
			return false;
		}
		if (OutString != "UFUNCTION Output")
		{
			return false;
		}
		if (OutName != n"UFunctionNameOut")
		{
			return false;
		}
		return OutText.ToString() == "UFunctionTextOut";
	}

	/**
	 * Observe empty concat and DefaultString("").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ConcatStrings("", "") and DefaultString("")
	 * @Return true when concat is empty and DefaultString is |Seen
	 * @Boundary empty strings
	 */
	UFUNCTION()
	bool EmptyConcat()
	{
		if (ConcatStrings("", "") != "")
		{
			return false;
		}
		return DefaultString("") == "|Seen";
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFStringFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFStringFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe MutateAll leaving a copy of the original string.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutateAll of Base / Name / Text
	 * @Return true when the copy stays Base and the mutated channels append Mutated
	 */
	UFUNCTION()
	bool MutateCopyIndependence()
	{
		FString Label = "Base";
		FName Name = n"Name";
		FText Text = FText::FromString("Text");
		FString LabelCopy = Label;
		MutateAll(Label, Name, Text);
		if (LabelCopy != "Base")
		{
			return false;
		}
		if (Label != "Base|Mutated")
		{
			return false;
		}
		if (Name.ToString() != "NameMutated")
		{
			return false;
		}
		return Text.ToString() == "TextMutated";
	}
}
