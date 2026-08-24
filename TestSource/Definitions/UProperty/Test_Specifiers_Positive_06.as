// Theme: Definitions.UProperty. WorldStory: ReplicatedUsing = OnRep_Health compiles with an empty notify.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles UPropSP_ReplicatedUsing.
// Extra: empty sibling Health 0; OnRep_Health remains a no-op. FixtureIsolated.

class AUPropRepUsingActor : AActor
{
	UPROPERTY(ReplicatedUsing = OnRep_Health)
	int Health = 100;

	UFUNCTION()
	void OnRep_Health()
	{
	}
}

class AUPropRepUsingActorEmpty : AActor
{
	UPROPERTY(ReplicatedUsing = OnRep_Health)
	int Health = 0;

	UFUNCTION()
	void OnRep_Health()
	{
	}
}

int Observe_UPropRepUsing_DefaultHealth()
{
	return 100;
}

int Observe_UPropRepUsing_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}
