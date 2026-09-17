/**
 * @version v1
 * @summary A UPROPERTY FString compiles. The observers cover Name "Default", an empty string write, and copy independence of a local snapshot.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY FString compiles. The observers cover Name "Default", an empty string write, and copy independence of a local snapshot.
 * @topic Baseline
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
/** @end */
