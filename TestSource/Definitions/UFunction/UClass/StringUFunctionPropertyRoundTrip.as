/**
 * FString, FName, and FText stored properties plus default parameters.
 * StoreAndReturnString("RuntimeString") yields "RuntimeString_Stored".
 * CallDefaultString yields "DefaultString_Returned". Empty StoredText is the
 * default, a nullptr actor is the empty handle, and StoreAndReturnString("")
 * writes "_Stored".
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.StringUFunctionPropertyRoundTrip
 * @Harness UClass
 * @Tag Definitions.UFunction.StringUFunctionPropertyRoundTrip
 * @Provenance Theme: Definitions.UFunction. WorldStory FString/FName/FText stored properties plus default parameters.
 * @Provenance C++: AngelscriptCoverageFStringPropertyTests.cpp::StringUFunctionPropertyRoundTrip
 * @Provenance Oracle: StoreAndReturnString("RuntimeString") -> "RuntimeString_Stored"; CallDefaultString -> "DefaultString_Returned".
 * @Provenance Extra: empty StoredText default; nullptr actor is the empty handle; StoreAndReturnString("") writes "_Stored".
 * @Provenance FixtureIsolated. Keep StoredString / StoredName / StoredText names.
 */

UCLASS()
class ACoverageFStringUFunctionActor : AActor
{
	UPROPERTY()
	FString StoredString = "Initial";

	UPROPERTY()
	FName StoredName = n"InitialName";

	UPROPERTY()
	FText StoredText;

	/**
	 * Store Input plus "_Stored" and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input String suffix source
	 * @Inputs Input
	 * @Return Input + "_Stored"
	 */
	UFUNCTION()
	FString StoreAndReturnString(FString Input)
	{
		StoredString = Input + "_Stored";
		return StoredString;
	}

	/**
	 * Store Input as StoredName and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input Name to store
	 * @Inputs Input
	 * @Return StoredName
	 */
	UFUNCTION()
	FName StoreAndReturnName(FName Input)
	{
		StoredName = Input;
		return StoredName;
	}

	/**
	 * Store Input as StoredText and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input Text to store
	 * @Inputs Input
	 * @Return StoredText
	 */
	UFUNCTION()
	FText StoreAndReturnText(FText Input)
	{
		StoredText = Input;
		return StoredText;
	}

	/**
	 * Store Input, defaulting to "DefaultString", and return it plus "_Returned".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input String stored, default "DefaultString"
	 * @Inputs Input
	 * @Return StoredString + "_Returned"
	 */
	UFUNCTION()
	FString UseDefaultString(FString Input = "DefaultString")
	{
		StoredString = Input;
		return StoredString + "_Returned";
	}

	/**
	 * Store Input, defaulting to DefaultName, and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input Name stored, default n"DefaultName"
	 * @Inputs Input
	 * @Return StoredName
	 */
	UFUNCTION()
	FName UseDefaultName(FName Input = n"DefaultName")
	{
		StoredName = Input;
		return StoredName;
	}

	/**
	 * Store an explicit FText and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Input Text to store
	 * @Inputs Input
	 * @Return StoredText
	 */
	UFUNCTION()
	FText UseExplicitText(FText Input)
	{
		StoredText = Input;
		return StoredText;
	}

	/**
	 * Call UseDefaultString with no arguments.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs UseDefaultString()
	 * @Return "DefaultString_Returned"
	 */
	UFUNCTION()
	FString CallDefaultString()
	{
		return UseDefaultString();
	}

	/**
	 * Call UseDefaultName with no arguments.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs UseDefaultName()
	 * @Return n"DefaultName"
	 */
	UFUNCTION()
	FName CallDefaultName()
	{
		return UseDefaultName();
	}

	/**
	 * Call UseExplicitText with "Default Text".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs UseExplicitText(FText::FromString("Default Text"))
	 * @Return that text
	 */
	UFUNCTION()
	FText CallDefaultText()
	{
		return UseExplicitText(FText::FromString("Default Text"));
	}

	/**
	 * Observe the runtime string, name, and text round trip.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs StoreAndReturnString/Name/Text with runtime values
	 * @Return true when stored properties match the runtime values
	 */
	UFUNCTION()
	bool RuntimeRoundTrip()
	{
		FString Stored = StoreAndReturnString("RuntimeString");
		FName Named = StoreAndReturnName(n"RuntimeName");
		FText Texted = StoreAndReturnText(FText::FromString("Runtime Text"));
		if (Stored != "RuntimeString_Stored")
		{
			return false;
		}
		if (StoredString != "RuntimeString_Stored")
		{
			return false;
		}
		if (Named != n"RuntimeName")
		{
			return false;
		}
		if (StoredName != n"RuntimeName")
		{
			return false;
		}
		if (Texted.ToString() != "Runtime Text")
		{
			return false;
		}
		return StoredText.ToString() == "Runtime Text";
	}

	/**
	 * Observe that StoredText starts empty.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs a freshly constructed actor
	 * @Return true when StoredText.ToString() is empty
	 * @Boundary default text
	 */
	UFUNCTION()
	bool StoredTextStartsEmpty()
	{
		return StoredText.ToString() == "";
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFStringUFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFStringUFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe default-parameter helpers and the empty-string boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs CallDefaultString/Name/Text and StoreAndReturnString("")
	 * @Return true when defaults and the empty suffix match the oracle
	 * @Boundary default parameters and empty string
	 */
	UFUNCTION()
	bool DefaultAndEmptyBoundary()
	{
		FString Defaulted = CallDefaultString();
		FName DefaultName = CallDefaultName();
		FText DefaultText = CallDefaultText();
		FString EmptyStored = StoreAndReturnString("");
		if (Defaulted != "DefaultString_Returned")
		{
			return false;
		}
		if (DefaultName != n"DefaultName")
		{
			return false;
		}
		if (DefaultText.ToString() != "Default Text")
		{
			return false;
		}
		return EmptyStored == "_Stored";
	}
}
