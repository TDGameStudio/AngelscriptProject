// Theme: Definitions.UFunction. WorldStory FString/FName/FText UFUNCTION in/out/inout/defaults.
// C++: AngelscriptCoverageFStringFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: ConcatStrings("Hello"," World")=="Hello World"; DefaultString omitted -> "UFunctionDefaultString|Seen".
// Extra: ConcatStrings empty strings; nullptr actor is the empty handle; MutateAll leaves a copy of the original.
// FixtureIsolated.

UCLASS()
class ACoverageFStringFunctionActor : AActor
{
	UFUNCTION()
	FString ConcatStrings(FString a, FString b)
	{
		return a + b;
	}

	UFUNCTION()
	FName GetName()
	{
		return n"ActorName";
	}

	UFUNCTION()
	FText EchoText(FText value)
	{
		return value;
	}

	UFUNCTION()
	FString DescribeReferences(const FString&in label, FName&in name, FText&in text)
	{
		return label + "|" + name.ToString() + "|" + text.ToString();
	}

	UFUNCTION()
	FString FormatTextResult()
	{
		return FText::Format(FText::FromString("{0}:{1}"), FText::FromString("Count"), 7).ToString();
	}

	UFUNCTION()
	FString DefaultString(FString value = "UFunctionDefaultString")
	{
		return value + "|Seen";
	}

	UFUNCTION()
	FString DefaultName(FName value = n"UFunctionDefaultName")
	{
		return value.ToString() + "|Seen";
	}

	UFUNCTION()
	void WriteOut(FString&out result)
	{
		result = "UFUNCTION Output";
	}

	UFUNCTION()
	void WriteNameAndText(FName&out outName, FText&out outText)
	{
		outName = n"UFunctionNameOut";
		outText = FText::FromString("UFunctionTextOut");
	}

	UFUNCTION()
	void MutateAll(FString&inout label, FName&inout name, FText&inout text)
	{
		label += "|Mutated";
		name = FName(name.ToString() + "Mutated");
		text = FText::FromString(text.ToString() + "Mutated");
	}
}

bool Observe_StringFunction_Nominal(ACoverageFStringFunctionActor Actor)
{
	FString OutString = "";
	Actor.WriteOut(OutString);
	FName OutName;
	FText OutText;
	Actor.WriteNameAndText(OutName, OutText);
	return Actor.ConcatStrings("Hello", " World") == "Hello World"
		&& Actor.GetName() == n"ActorName"
		&& Actor.EchoText(FText::FromString("Echo")).ToString() == "Echo"
		&& Actor.DescribeReferences("L", n"N", FText::FromString("T")) == "L|N|T"
		&& Actor.FormatTextResult() == "Count:7"
		&& Actor.DefaultString() == "UFunctionDefaultString|Seen"
		&& Actor.DefaultName() == "UFunctionDefaultName|Seen"
		&& OutString == "UFUNCTION Output"
		&& OutName == n"UFunctionNameOut"
		&& OutText.ToString() == "UFunctionTextOut";
}

bool Observe_StringFunction_EmptyConcat(ACoverageFStringFunctionActor Actor)
{
	return Actor.ConcatStrings("", "") == "" && Actor.DefaultString("") == "|Seen";
}

bool Observe_StringFunction_NullDefault()
{
	ACoverageFStringFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_StringFunction_MutateCopyIndependence(ACoverageFStringFunctionActor Actor)
{
	FString Label = "Base";
	FName Name = n"Name";
	FText Text = FText::FromString("Text");
	FString LabelCopy = Label;
	Actor.MutateAll(Label, Name, Text);
	return LabelCopy == "Base"
		&& Label == "Base|Mutated"
		&& Name.ToString() == "NameMutated"
		&& Text.ToString() == "TextMutated";
}
