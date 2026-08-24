// Purpose: Observe instigator controller, input component, and world actor
// queries that append without clearing. Runner owns Actor/Controller fixtures.
// AS-facing API: AController Actor.GetInstigatorController() const;
// UInputComponent Actor.GetInputComponent() const;
// void Actor::GetAllActorsOfClass(?& OutActors);
// void Actor::GetAllActorsOfClass(UClass Class, ?& OutActors);
// void Actor::GetAllActorsOfClassWithTag(FName TagName, ?& OutActors);
// Inputs: Runner-owned AActor, optional APlayerController, sentinel OutActors
// entries, UClass AActor::StaticClass(), and Actor Tag n"TestTag".
// Expected observations: CDO GetInstigatorController is null. CDO
// GetInputComponent is null. EnableInput on the runner actor can produce a
// non-null input component; DisableInput restores. GetAllActorsOfClass keeps
// index 0 as the sentinel. GetAllActorsOfClassWithTag finds the tagged actor
// after the sentinel.
// Boundary/ownership: SetupOwner=Runner. CleanupOwner=Runner. FixtureIsolated.
// Null required fixtures throw. OutActors element type selects the actor class.

namespace TS_AActor_Queries_02
{
	bool Observe_GetInstigatorController_Nominal(AActor Actor, AController Expected)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_02 setup: required Actor is null");
		}
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		AActor Cdo = ActorClass.GetDefaultObject();
		AController CdoController = Cdo.GetInstigatorController();
		return CdoController is null && Actor.GetInstigatorController() == Expected;
	}

	bool Observe_GetInputComponent_Nominal(AActor Actor, APlayerController Controller)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_02 setup: required Actor is null");
		}
		if (Controller is null)
		{
			throw("TS_AActor_Queries_02 setup: required Controller is null");
		}
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		AActor Cdo = ActorClass.GetDefaultObject();
		UInputComponent CdoInput = Cdo.GetInputComponent();
		UInputComponent Before = Actor.GetInputComponent();
		Actor.EnableInput(Controller);
		UInputComponent After = Actor.GetInputComponent();
		Actor.DisableInput(Controller);
		return CdoInput is null && Before is null && After != nullptr;
	}

	bool Observe_GetAllActorsOfClass_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_02 setup: required Actor is null");
		}
		TArray<AActor> Inferred;
		AActor InferredSentinel;
		Inferred.Add(InferredSentinel);
		int32 InferredBefore = Inferred.Num();
		AActor::GetAllActorsOfClass(Inferred);

		TArray<AActor> Explicit;
		AActor ExplicitSentinel;
		Explicit.Add(ExplicitSentinel);
		int32 ExplicitBefore = Explicit.Num();
		AActor::GetAllActorsOfClass(AActor::StaticClass(), Explicit);

		TArray<AActor> AfterPawnFilter;
		AActor PawnSentinel;
		AfterPawnFilter.Add(PawnSentinel);
		AActor::GetAllActorsOfClass(APawn::StaticClass(), AfterPawnFilter);

		bool bInferred = Inferred.Num() >= InferredBefore && Inferred[0] == InferredSentinel;
		bool bExplicit = Explicit.Num() >= ExplicitBefore && Explicit[0] == ExplicitSentinel;
		bool bPawnSentinel = AfterPawnFilter.Num() >= 1 && AfterPawnFilter[0] == PawnSentinel;
		bool bFoundActor = false;
		for (int32 Index = 1; Index < Explicit.Num(); ++Index)
		{
			if (Explicit[Index] == Actor)
			{
				bFoundActor = true;
			}
		}
		return bInferred && bExplicit && bPawnSentinel && bFoundActor;
	}

	bool Observe_GetAllActorsOfClassWithTag_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_02 setup: required Actor is null");
		}
		Actor.Tags.Add(n"TestTag");

		TArray<AActor> Tagged;
		AActor Sentinel;
		Tagged.Add(Sentinel);
		int32 Before = Tagged.Num();
		AActor::GetAllActorsOfClassWithTag(n"TestTag", Tagged);

		TArray<AActor> Missing;
		AActor MissingSentinel;
		Missing.Add(MissingSentinel);
		AActor::GetAllActorsOfClassWithTag(n"MissingTestTag", Missing);

		bool bPreserved = Tagged.Num() >= Before && Tagged[0] == Sentinel;
		bool bFound = false;
		for (int32 Index = 1; Index < Tagged.Num(); ++Index)
		{
			if (Tagged[Index] == Actor)
			{
				bFound = true;
			}
		}
		bool bMissingKeepsSentinel = Missing.Num() >= 1 && Missing[0] == MissingSentinel;
		return bPreserved && bFound && bMissingKeepsSentinel;
	}
}
