// Theme: Language.Literals.FString. WorldStory: script reads/writes string-family UPROPERTY values.
// C++: AngelscriptCoverageFStringPropertyTests.cpp::StringPropertyScriptReadWriteApiSurface
// sha256=825df287dd7fc69e1c9714353f5ee45ec91a41b2ac9022562e6ee82dbe65b1e5; lines 560-603.
// Oracle: ReadInitialState() == 7; RewriteAndReadState() == 7;
// C++ then VerifyByPath StoredString "ScriptString".
// Extra: StoredText starts empty; rewrite is in-place on the actor, not a separate copy.
// FixtureIsolated. Keep UPROPERTY names StoredString, StoredName, StoredText.

UCLASS()
class ACoverageFStringScriptApiSurfaceActor : AActor
{
	UPROPERTY()
	FString StoredString = "InitialString";

	UPROPERTY()
	FName StoredName = n"InitialName";

	UPROPERTY()
	FText StoredText;

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

	UFUNCTION()
	bool Observe_ReadInitialState_Nominal()
	{
		return ReadInitialState() == 7;
	}

	UFUNCTION()
	bool Observe_RewriteAndReadState_Nominal()
	{
		return RewriteAndReadState() == 7;
	}

	UFUNCTION()
	bool Observe_LocalText_EmptyDefault()
	{
		FText Empty;
		return Empty.IsEmpty();
	}
}
