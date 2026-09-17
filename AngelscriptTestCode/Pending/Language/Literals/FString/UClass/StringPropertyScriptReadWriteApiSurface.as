/**
 * @version v1
 * @summary A script reads the initial string-family UPROPERTY values, then rewrites them in place and reads the rewritten values back. Each read reports a mask whose bits track the string, name, and text members, so the observers.
 * @topic Language
 */
/**
 * @version root
 * @summary A script reads the initial string-family UPROPERTY values, then rewrites them in place and reads the rewritten values back. Each read reports a mask whose bits track the string, name, and text members, so the observers.
 * @topic Baseline
 */
UCLASS()
class ACoverageFStringScriptApiSurfaceActor : AActor
{
	UPROPERTY()
	FString StoredString = "InitialString";

	UPROPERTY()
	FName StoredName = n"InitialName";

	UPROPERTY()
	FText StoredText;

	/**
	 * Read the initial string, name, and text members into a bitmask.
	 *
	 * @Covers Literals.FString
	 * @Inputs The actor's initial string-family members
	 * @Return 7 when all three members match their initial values
	 */
	UFUNCTION()
	int ReadInitialState()
	{
		int Mask = 0;
		if (StoredString == "InitialString")
		{
			Mask |= 1;
		}
		if (StoredName == n"InitialName")
		{
			Mask |= 2;
		}
		if (StoredText.IsEmpty())
		{
			Mask |= 4;
		}
		return Mask;
	}

	/**
	 * Rewrite the string, name, and text members in place, then read them back
	 * into a bitmask.
	 *
	 * @Covers Literals.FString
	 * @Inputs The actor's members rewritten to script values
	 * @Return 7 when all three members match the rewritten values
	 */
	UFUNCTION()
	int RewriteAndReadState()
	{
		StoredString = "ScriptString";
		StoredName = n"ScriptName";
		StoredText = FText::FromString("Script Text");

		int Mask = 0;
		if (StoredString == "ScriptString")
		{
			Mask |= 1;
		}
		if (StoredName == n"ScriptName")
		{
			Mask |= 2;
		}
		if (StoredText.ToString() == "Script Text")
		{
			Mask |= 4;
		}
		return Mask;
	}

	/**
	 * Confirm the initial state reads back as 7.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ReadInitialState over the actor
	 * @Return true when the initial state mask is 7
	 */
	UFUNCTION()
	bool VerifyReadInitialState()
	{
		return ReadInitialState() == 7;
	}

	/**
	 * Confirm the rewritten state reads back as 7.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs RewriteAndReadState over the actor
	 * @Return true when the rewritten state mask is 7
	 */
	UFUNCTION()
	bool VerifyRewriteAndReadState()
	{
		return RewriteAndReadState() == 7;
	}

	/**
	 * Confirm a local empty FText reports empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FText
	 * @Inputs A default-constructed local FText
	 * @Return true when the local text is empty
	 * @Boundary empty text default
	 */
	UFUNCTION()
	bool VerifyLocalTextEmptyDefault()
	{
		FText Empty;
		return Empty.IsEmpty();
	}
}
/** @end */
