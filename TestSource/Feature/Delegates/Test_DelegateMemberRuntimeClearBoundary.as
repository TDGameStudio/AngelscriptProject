// Theme: Feature.Delegates. WorldStory UPROPERTY bind / execute / Clear / ExecuteIfBound.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateMemberRuntimeClearBoundary
// Oracle after BeginPlay: bInitialBound==false, bBoundAfterBind==true, LastWeight==2.5,
// LastLabel=="member", bBoundAfterClear==false, CallCount==1.
// Extra: empty actor is null; pre-BeginPlay defaults (true/false mix as declared).
// FixtureIsolated.

delegate void FCoverageDelegateAction(float Weight, const FString& Label);

UCLASS()
class ACoverageDelegateMemberRuntimeActor : AActor
{
	UPROPERTY()
	FCoverageDelegateAction OnAction;

	UPROPERTY()
	bool bInitialBound = true;

	UPROPERTY()
	bool bBoundAfterBind = false;

	UPROPERTY()
	bool bBoundAfterClear = true;

	UPROPERTY()
	float LastWeight = 0.0f;

	UPROPERTY()
	FString LastLabel;

	UPROPERTY()
	int CallCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bInitialBound = OnAction.IsBound();

		OnAction.BindUFunction(this, n"HandleAction");
		bBoundAfterBind = OnAction.IsBound();
		OnAction.Execute(2.5f, "member");

		OnAction.Clear();
		bBoundAfterClear = OnAction.IsBound();
		OnAction.ExecuteIfBound(9.0f, "cleared");
	}

	UFUNCTION()
	void HandleAction(float Weight, const FString& Label)
	{
		LastWeight = Weight;
		LastLabel = Label;
		CallCount += 1;
	}
}

bool Observe_MemberRuntime_EmptyDefaultIsNull()
{
	ACoverageDelegateMemberRuntimeActor Actor;
	return Actor == nullptr;
}

int Observe_MemberRuntime_CallCountDefault(ACoverageDelegateMemberRuntimeActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0027 setup: required ACoverageDelegateMemberRuntimeActor is null");
	}
	return Actor.CallCount;
}

bool Observe_MemberRuntime_InitialBoundDefaultTrue(ACoverageDelegateMemberRuntimeActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0027 setup: required ACoverageDelegateMemberRuntimeActor is null");
	}
	return Actor.bInitialBound;
}
