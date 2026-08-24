// Theme: Gameplay.Debug. WorldStory context-rich Print with session/player ids.
// C++: AngelscriptCoverageLoggingTests.cpp::ContextRichLogging
// Oracle VerifyByPath PlayerID 12345 after spawn. SessionID "SESSION-ABC-123".
// Extra: empty SessionID / PlayerID 0. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class AContextLogTestActor : AActor
{
	UPROPERTY()
	int PlayerID = 12345;

	UPROPERTY()
	FString SessionID = "SESSION-ABC-123";

	UFUNCTION()
	void LogWithContext(FString Message)
	{
		FString FullMessage = "[" + GetName() + "] ";

		FullMessage += "[Session:" + SessionID + "] ";

		FullMessage += "[Player:" + PlayerID + "] ";

		FullMessage += Message;

		Print(FullMessage);
	}

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
}

bool Observe_ContextLog_Defaults(AContextLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContextRichLogging setup: required Actor is null");
	}
	return Actor.PlayerID == 12345 && Actor.SessionID == "SESSION-ABC-123";
}

bool Observe_ContextLog_EmptyBoundary(AContextLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContextRichLogging setup: required Actor is null");
	}
	Actor.SessionID = "";
	Actor.PlayerID = 0;
	Actor.LogWithContext("");
	return Actor.SessionID.Len() == 0 && Actor.PlayerID == 0;
}
