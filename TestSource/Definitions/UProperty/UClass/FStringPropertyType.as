/**
 * A UPROPERTY FString compiles. The observers cover Name "Default", an empty
 * string write, and copy independence of a local snapshot.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.FStringPropertyType
 * @Harness UClass
 * @Tag Definitions.UProperty.FStringPropertyType
 * @Provenance Theme: Definitions.UProperty. WorldStory: UPROPERTY FString.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
 * @Provenance UPropTP_FString; lines 409-415;
 * @Provenance sha256=0e70dc3b83caf18dee04aec4c733f35731c24f3b446ea6655bf4b7c197d25734.
 * @Provenance Oracle: Name default is "Default" on the spawned actor.
 * @Provenance Extra: empty string write; copy-independence of a local snapshot.
 * @Provenance FixtureIsolated.
 */

class AUPropStrActor : AActor
{
	UPROPERTY()
	FString Name = "Default";

	/**
	 * Observe the default Name of "Default".
	 *
	 * @Kind Observe
	 * @Covers UProperty.FStringPropertyType
	 * @Inputs none
	 * @Return true when Name is "Default"
	 */
	UFUNCTION()
	bool NameDefault()
	{
		return Name == "Default";
	}

	/**
	 * Observe an empty string write that restores "Default".
	 *
	 * @Kind Observe
	 * @Covers UProperty.FStringPropertyType
	 * @Inputs Name written to "" then restored
	 * @Return true when the empty write lands and the saved default is "Default"
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool NameEmptyWrite()
	{
		FString Saved = Name;
		Name = "";
		bool bEmpty = Name.IsEmpty();
		Name = Saved;
		if (!bEmpty)
		{
			return false;
		}
		return Saved == "Default";
	}

	/**
	 * Observe that mutating a local copy leaves Name "Default".
	 *
	 * @Kind Observe
	 * @Covers UProperty.FStringPropertyType
	 * @Inputs a local copy written to "Mutated"
	 * @Return true when Name stays "Default" and the copy is "Mutated"
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool NameCopyIndependence()
	{
		FString Original = Name;
		FString Copy = Original;
		Copy = "Mutated";
		if (Name != Original)
		{
			return false;
		}
		if (Copy != "Mutated")
		{
			return false;
		}
		return Original == "Default";
	}
}
