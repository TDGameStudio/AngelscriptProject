/**
 * Prints assembled with actor name, session id and player id context. C++ verifies the
 * player id and session id by path, so the UPROPERTY names and the LogWithContext
 * entrypoint are part of the contract and are kept verbatim.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ContextRichLogging
 * @Harness UClass
 * @Tag Gameplay.Debug.ContextRichLogging
 * @Provenance Theme: Gameplay.Debug. WorldStory context-rich Print with session/player ids.
 * @Provenance C++: AngelscriptCoverageLoggingTests.cpp::ContextRichLogging
 * @Provenance Oracle VerifyByPath PlayerID 12345 after spawn. SessionID "SESSION-ABC-123".
 * @Provenance Extra: empty SessionID / PlayerID 0. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class AContextLogTestActor : AActor
{
	UPROPERTY()
	int PlayerID = 12345;

	UPROPERTY()
	FString SessionID = "SESSION-ABC-123";

	/**
	 * Assemble a message with the actor name, session and player context, then print it.
	 *
	 * @Kind Observe
	 * @Covers Debug.ContextRichLogging
	 * @Inputs the message body to wrap
	 * @Return the full context line printed
	 * @Param Message the message body to wrap
	 */
	UFUNCTION()
	void LogWithContext(FString Message)
	{
		FString FullMessage = "[" + GetName() + "] ";

		FullMessage += "[Session:" + SessionID + "] ";

		FullMessage += "[Player:" + PlayerID + "] ";

		FullMessage += Message;

		Print(FullMessage);
	}

	/**
	 * WorldStory: BeginPlay logs the lifecycle with context and reports the actor's
	 * location and owner.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.ContextRichLogging
	 * @Inputs none
	 * @Return two context lines plus the location and owner lines printed
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LogWithContext("Actor initialized");

		FVector Loc = GetActorLocation();
		Print("[" + GetName() + "] Location: X=" + Loc.X + " Y=" + Loc.Y + " Z=" + Loc.Z);

		AActor Owner = GetOwner();
		if (Owner != nullptr)
		{
			Print("[" + GetName() + "] Owned by: " + Owner.GetName());
		}
		else
		{
			Print("[" + GetName() + "] No owner");
		}

		LogWithContext("Initialization complete");
	}

	/**
	 * Observe that a locally constructed actor keeps its declared context ids.
	 *
	 * @Kind Observe
	 * @Covers Debug.ContextRichLogging
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when PlayerID is 12345 and SessionID is SESSION-ABC-123
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (PlayerID != 12345)
		{
			return false;
		}
		return SessionID == "SESSION-ABC-123";
	}

	/**
	 * Observe that logging with cleared context still prints.
	 *
	 * @Kind Observe
	 * @Covers Debug.ContextRichLogging
	 * @Inputs none
	 * @Return true when the session id is empty and the player id is 0
	 * @Boundary empty context
	 */
	UFUNCTION()
	bool EmptyBoundary()
	{
		SessionID = "";
		PlayerID = 0;
		LogWithContext("");

		if (SessionID.Len() != 0)
		{
			return false;
		}
		return PlayerID == 0;
	}
}
