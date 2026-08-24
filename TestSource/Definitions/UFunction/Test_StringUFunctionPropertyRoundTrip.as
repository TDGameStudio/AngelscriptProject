// Theme: Definitions.UFunction. WorldStory FString/FName/FText stored properties plus default parameters.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringUFunctionPropertyRoundTrip
// Oracle: StoreAndReturnString("RuntimeString") -> "RuntimeString_Stored"; CallDefaultString -> "DefaultString_Returned".
// Extra: empty StoredText default; nullptr actor is the empty handle; StoreAndReturnString("") writes "_Stored".
// FixtureIsolated. Keep StoredString / StoredName / StoredText names.

UCLASS()
class ACoverageFStringUFunctionActor : AActor
{
	UPROPERTY()
	FString StoredString = "Initial";

	UPROPERTY()
	FName StoredName = n"InitialName";

	UPROPERTY()
	FText StoredText;

	UFUNCTION()
	FString StoreAndReturnString(FString Input)
	{
		StoredString = Input + "_Stored";
		return StoredString;
	}

	UFUNCTION()
	FName StoreAndReturnName(FName Input)
	{
		StoredName = Input;
		return StoredName;
	}

	UFUNCTION()
	FText StoreAndReturnText(FText Input)
	{
		StoredText = Input;
		return StoredText;
	}

	UFUNCTION()
	FString UseDefaultString(FString Input = "DefaultString")
	{
		StoredString = Input;
		return StoredString + "_Returned";
	}

	UFUNCTION()
	FName UseDefaultName(FName Input = n"DefaultName")
	{
		StoredName = Input;
		return StoredName;
	}

	UFUNCTION()
	FText UseExplicitText(FText Input)
	{
		StoredText = Input;
		return StoredText;
	}

	UFUNCTION()
	FString CallDefaultString()
	{
		return UseDefaultString();
	}

	UFUNCTION()
	FName CallDefaultName()
	{
		return UseDefaultName();
	}

	UFUNCTION()
	FText CallDefaultText()
	{
		return UseExplicitText(FText::FromString("Default Text"));
	}
}

bool Observe_StringProperty_Nominal(ACoverageFStringUFunctionActor Actor)
{
	FString Stored = Actor.StoreAndReturnString("RuntimeString");
	FName Named = Actor.StoreAndReturnName(n"RuntimeName");
	FText Texted = Actor.StoreAndReturnText(FText::FromString("Runtime Text"));
	return Stored == "RuntimeString_Stored"
		&& Actor.StoredString == "RuntimeString_Stored"
		&& Named == n"RuntimeName"
		&& Actor.StoredName == n"RuntimeName"
		&& Texted.ToString() == "Runtime Text"
		&& Actor.StoredText.ToString() == "Runtime Text";
}

bool Observe_StringProperty_EmptyStoredText(ACoverageFStringUFunctionActor Actor)
{
	return Actor.StoredText.ToString() == "";
}

bool Observe_StringProperty_NullDefault()
{
	ACoverageFStringUFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_StringProperty_DefaultAndEmptyBoundary(ACoverageFStringUFunctionActor Actor)
{
	FString Defaulted = Actor.CallDefaultString();
	FName DefaultName = Actor.CallDefaultName();
	FText DefaultText = Actor.CallDefaultText();
	FString EmptyStored = Actor.StoreAndReturnString("");
	return Defaulted == "DefaultString_Returned"
		&& DefaultName == n"DefaultName"
		&& DefaultText.ToString() == "Default Text"
		&& EmptyStored == "_Stored";
}
