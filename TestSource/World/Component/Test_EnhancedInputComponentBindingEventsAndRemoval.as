// Theme: World.Component. WorldStory: Enhanced Input BindAction, BindActionValue,
// BindDebugKey, then Clear*Bindings.
// C++: AngelscriptCoverageInputTests.cpp::EnhancedInputComponentBindingEventsAndRemoval
// sha256=9e9375a655b5ec66f2bc818de54c84864a2e308ec23d55b4e7f939805870871c; lines 1190-1254.
// Oracle VerifyByPath: bBindingsAdded, bActionValueBindingAdded, bDebugBindingAdded,
// bClearRemovedBindings all true. Extra: local construct Action null, counts 0,
// flags false. FixtureIsolated.

UCLASS()
class AEnhancedInputCoverageActor : AActor
{
	UPROPERTY()
	UInputAction Action;

	UPROPERTY()
	int StartedCount = 0;

	UPROPERTY()
	bool bBindingsAdded = false;

	UPROPERTY()
	bool bActionValueBindingAdded = false;

	UPROPERTY()
	bool bDebugBindingAdded = false;

	UPROPERTY()
	bool bClearRemovedBindings = false;

	UFUNCTION()
	void OnAction(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
	{
		StartedCount += 1;
	}

	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue ActionValue)
	{
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Action = Cast<UInputAction>(NewObject(this, UInputAction::StaticClass(), n"CoverageAction", true));
		UEnhancedInputComponent EnhancedComponent = Cast<UEnhancedInputComponent>(NewObject(this, UEnhancedInputComponent::StaticClass(), n"CoverageEnhancedInputComponent", true));
		if (Action == nullptr || EnhancedComponent == nullptr)
		{
			return;
		}

		FEnhancedInputActionHandlerDynamicSignature StartedDelegate;
		StartedDelegate.BindUFunction(this, n"OnAction");
		EnhancedComponent.BindAction(Action, ETriggerEvent::Started, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Ongoing, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Triggered, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Completed, StartedDelegate);
		EnhancedComponent.BindAction(Action, ETriggerEvent::Canceled, StartedDelegate);
		bBindingsAdded = EnhancedComponent.HasBindings();

		EnhancedComponent.BindActionValue(Action);
		bActionValueBindingAdded = EnhancedComponent.HasBindings();

		FInputDebugKeyHandlerDynamicSignature DebugDelegate;
		DebugDelegate.BindUFunction(this, n"OnDebug");
		EnhancedComponent.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, DebugDelegate, true);
		bDebugBindingAdded = EnhancedComponent.HasBindings();

		EnhancedComponent.ClearActionEventBindings();
		EnhancedComponent.ClearActionValueBindings();
		EnhancedComponent.ClearDebugKeyBindings();
		bClearRemovedBindings = !EnhancedComponent.HasBindings();
	}
}

bool Observe_EnhancedInputBindings_DefaultEmpty(AEnhancedInputCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EnhancedInputComponentBindingEventsAndRemoval setup: required Actor is null");
	}
	return Actor.Action == nullptr
		&& Actor.StartedCount == 0
		&& !Actor.bBindingsAdded
		&& !Actor.bActionValueBindingAdded
		&& !Actor.bDebugBindingAdded
		&& !Actor.bClearRemovedBindings;
}

bool Observe_EnhancedInputBindings_CopyIndependence(AEnhancedInputCoverageActor First, AEnhancedInputCoverageActor Second)
{
	if (First is null)
	{
		throw("Test_EnhancedInputComponentBindingEventsAndRemoval setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_EnhancedInputComponentBindingEventsAndRemoval setup: required Second is null");
	}
	First.bBindingsAdded = true;
	First.StartedCount = 1;
	return First.bBindingsAdded
		&& First.StartedCount == 1
		&& !Second.bBindingsAdded
		&& Second.StartedCount == 0
		&& Second.Action == nullptr;
}
