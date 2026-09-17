/**
 * @version v1
 * @summary Observe AActor initialization/hidden queries, world transform, name, game instance, component append, and instigator identity.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe AActor initialization/hidden queries, world transform, name, game instance, component append, and instigator identity.
 * @topic Baseline
 */
// Runner owns the Actor fixture and teardown. A null Actor is setup failure.
// AS-facing API: bool Actor.IsActorInitialized() const;
// bool Actor.HasActorBegunPlay() const; bool Actor.IsHidden() const;
// FVector Actor.GetActorLocation() const; FRotator Actor.GetActorRotation() const;
// FString Actor.GetActorNameOrLabel() const; UGameInstance Actor.GetGameInstance() const;
// void Actor.GetComponentsByClass(?& OutComponents) const;
// void Actor.GetComponentsByClass(UClass ComponentClass, ?& OutComponents) const;
// APawn Actor.GetInstigator() const;
// Inputs: Runner-supplied AActor at a known location/rotation/hidden state.
// Expected observations: returned bool is the exact comparison. OutComponents
// keeps a sentinel at index 0 (append-without-clear).
// Boundary/ownership: SetupOwner=Runner. CleanupOwner=Runner. FixtureIsolated.

namespace TS_AActor_Queries_01
{
	bool Observe_IsActorInitialized_Nominal(AActor Actor, bool bExpectInitialized)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		return Actor.IsActorInitialized() == bExpectInitialized;
	}

	bool Observe_HasActorBegunPlay_Nominal(AActor Actor, bool bExpectBegunPlay)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		return Actor.HasActorBegunPlay() == bExpectBegunPlay;
	}

	bool Observe_IsHidden_Nominal(AActor Actor, bool bExpectHidden)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		return Actor.IsHidden() == bExpectHidden;
	}

	bool Observe_GetActorLocation_Nominal(AActor Actor, const FVector& Expected)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		return Actor.GetActorLocation().Equals(Expected);
	}

	bool Observe_GetActorRotation_Nominal(AActor Actor, const FRotator& Expected)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		return Actor.GetActorRotation().Equals(Expected, 0.01);
	}

	bool Observe_GetActorNameOrLabel_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		return Actor.GetActorNameOrLabel().Len() > 0;
	}

	bool Observe_GetGameInstance_Nominal(AActor Actor, bool bExpectInstance)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		UGameInstance Instance = Actor.GetGameInstance();
		if (bExpectInstance)
		{
			return Instance != nullptr;
		}
		return Instance is null;
	}

	bool Observe_GetComponentsByClass_Nominal(AActor Actor, UActorComponent Sentinel)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		TArray<UActorComponent> Inferred;
		Inferred.Add(Sentinel);
		int32 InferredBefore = Inferred.Num();
		Actor.GetComponentsByClass(Inferred);
		TArray<UActorComponent> Explicit;
		Explicit.Add(Sentinel);
		int32 ExplicitBefore = Explicit.Num();
		Actor.GetComponentsByClass(UActorComponent::StaticClass(), Explicit);
		return Inferred.Num() >= InferredBefore && Inferred[0] == Sentinel && Explicit.Num() >= ExplicitBefore && Explicit[0] == Sentinel;
	}

	bool Observe_GetInstigator_Nominal(AActor Actor, APawn Expected)
	{
		if (Actor is null)
		{
			throw("TS_AActor_Queries_01 setup: required Actor is null");
		}
		return Actor.GetInstigator() == Expected;
	}
}
/** @end */
