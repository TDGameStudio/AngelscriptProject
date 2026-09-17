/**
 * @version v1
 * @summary String-family members on a script actor keep the defaults declared in the UPROPERTY initialisers. The actor exposes FString, FName, and FText members with and without explicit defaults, and the observers confirm the.
 * @topic Language
 */
/**
 * @version root
 * @summary String-family members on a script actor keep the defaults declared in the UPROPERTY initialisers. The actor exposes FString, FName, and FText members with and without explicit defaults, and the observers confirm the.
 * @topic Baseline
 */
UCLASS()
class ACoverageFStringDefaultsActor : AActor
{
	UPROPERTY()
	FString StringValue = "Hello";

	UPROPERTY()
	FString EmptyString = "";

	UPROPERTY()
	FString NoDefaultString;

	UPROPERTY()
	FName NameValue = n"MyName";

	UPROPERTY()
	FName EmptyName = n"";

	UPROPERTY()
	FText TextValue;

	/**
	 * Confirm every declared string-family default matches its initialiser.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's declared defaults
	 * @Return true when all six members read back their declared values
	 */
	UFUNCTION()
	bool VerifyDefaultsMatchDeclaration()
	{
		if (StringValue != "Hello")
		{
			return false;
		}
		if (EmptyString != "")
		{
			return false;
		}
		if (NoDefaultString != "")
		{
			return false;
		}
		if (NameValue != n"MyName")
		{
			return false;
		}
		if (EmptyName != n"")
		{
			return false;
		}
		return TextValue.IsEmpty();
	}

	/**
	 * Confirm the empty-boundary members stay empty at declaration time.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's empty FString and FName members
	 * @Return true when the empty fields have zero length or NAME_None
	 * @Boundary empty defaults
	 */
	UFUNCTION()
	bool VerifyEmptyFieldsStayEmpty()
	{
		if (EmptyString.Len() != 0)
		{
			return false;
		}
		if (NoDefaultString != "")
		{
			return false;
		}
		return EmptyName == n"";
	}

	/**
	 * Confirm copying StringValue and mutating the copy leaves the member
	 * unchanged.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of StringValue changed to "Other"
	 * @Return true when StringValue is still "Hello" and the copy is "Other"
	 */
	UFUNCTION()
	bool VerifyStringValueCopyIsIndependent()
	{
		FString Copy = StringValue;
		Copy = "Other";
		if (StringValue != "Hello")
		{
			return false;
		}
		return Copy == "Other";
	}
}
/** @end */
