/**
 * @version v1
 * @summary String-family members on an actor round-trip writes through the reflected UPROPERTY: a script write is read back, then overwritten to empty. The name member starts as NAME_None and copies independently, and the text.
 * @topic Language
 */
/**
 * @version root
 * @summary String-family members on an actor round-trip writes through the reflected UPROPERTY: a script write is read back, then overwritten to empty. The name member starts as NAME_None and copies independently, and the text.
 * @topic Baseline
 */
UCLASS()
class ACoverageFStringWriteActor : AActor
{
	UPROPERTY()
	FString StringValue;

	UPROPERTY()
	FName NameValue;

	UPROPERTY()
	FText TextValue;

	/**
	 * Write StringValue, read it back, then clear it to confirm both states.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs StringValue assigned "Hello World" then cleared
	 * @Return true when it read back "Hello World" and then became empty
	 */
	UFUNCTION()
	bool VerifyStringValueWriteRoundTrip()
	{
		StringValue = "Hello World";
		bool bHello = StringValue == "Hello World";
		StringValue = "";
		if (!bHello)
		{
			return false;
		}
		return StringValue.Len() == 0;
	}

	/**
	 * Confirm NameValue defaults to NAME_None and copies independently.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs NameValue written to n"TestName", then a copy cleared to NAME_None
	 * @Return true when the default, the write, and the independent copy all hold
	 * @Boundary empty name default
	 */
	UFUNCTION()
	bool VerifyNameValueDefaultAndBoundary()
	{
		bool bDefaultNone = NameValue == NAME_None;
		NameValue = n"TestName";
		FName Copy = NameValue;
		Copy = NAME_None;
		if (!bDefaultNone)
		{
			return false;
		}
		if (NameValue != n"TestName")
		{
			return false;
		}
		return Copy == NAME_None;
	}

	/**
	 * Confirm TextValue defaults to empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FText
	 * @Inputs The actor's default TextValue
	 * @Return true when TextValue is empty
	 * @Boundary empty text default
	 */
	UFUNCTION()
	bool VerifyTextValueEmptyDefault()
	{
		return TextValue.IsEmpty();
	}
}
/** @end */
