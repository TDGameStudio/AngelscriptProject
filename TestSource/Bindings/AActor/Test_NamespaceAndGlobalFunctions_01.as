// Purpose: Observe Actor::FinishSpawningActor completing a deferred spawn,
// including nullptr ignore and an explicit final transform.
// AS-facing API: void Actor::FinishSpawningActor(AActor Actor);
// void Actor::FinishSpawningActor(AActor Actor, const FTransform& SpawnTransform);
// Inputs: Deferred SpawnActor/SpawnPersistentActor results, a null AActor
// handle, current actor transform, and FTransform at (350,0,0).
// Expected observations: nullptr is ignored. A deferred actor becomes
// finishable and reports the requested location after the transform overload.
// Boundary/ownership: nullptr is ignored (API contract, not setup failure).
// An actor that has begun play raises a script exception. Source destroys
// finished actors. FixtureIsolated.

namespace TS_AActor_NamespaceAndGlobalFunctions_01
{
	bool Observe_FinishSpawningActor_Nominal()
	{
		AActor NullActor;
		AActor::FinishSpawningActor(NullActor);
		AActor::FinishSpawningActor(NullActor, FTransform());
		bool bNullIgnored = NullActor is null;

		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		AActor Deferred = AActor::SpawnActor(ActorClass, FVector(300.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_FinishDeferred", true);
		if (Deferred is null)
		{
			throw("TS_AActor_NamespaceAndGlobalFunctions_01 setup: deferred SpawnActor returned null");
		}
		AActor::FinishSpawningActor(Deferred);
		FVector AfterCurrent = Deferred.GetActorLocation();
		bool bCurrentTransformUsed = AfterCurrent.Equals(FVector(300.0, 0.0, 0.0));
		Deferred.DestroyActor();

		AActor DeferredTransform = AActor::SpawnActor(ActorClass, FVector::ZeroVector, FRotator::ZeroRotator, n"TS_AActor_FinishTransform", true);
		if (DeferredTransform is null)
		{
			throw("TS_AActor_NamespaceAndGlobalFunctions_01 setup: deferred transform SpawnActor returned null");
		}
		FTransform SpawnTransform(FRotator::ZeroRotator, FVector(350.0, 0.0, 0.0), FVector::OneVector);
		AActor::FinishSpawningActor(DeferredTransform, SpawnTransform);
		FVector AfterExplicit = DeferredTransform.GetActorLocation();
		bool bExplicitTransformUsed = AfterExplicit.Equals(FVector(350.0, 0.0, 0.0));
		DeferredTransform.DestroyActor();

		AActor PersistentDeferred = AActor::SpawnPersistentActor(ActorClass, FVector(450.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_FinishPersistent", true);
		if (PersistentDeferred is null)
		{
			throw("TS_AActor_NamespaceAndGlobalFunctions_01 setup: deferred SpawnPersistentActor returned null");
		}
		AActor::FinishSpawningActor(PersistentDeferred);
		FVector AfterPersistent = PersistentDeferred.GetActorLocation();
		bool bPersistentFinished = AfterPersistent.Equals(FVector(450.0, 0.0, 0.0));
		PersistentDeferred.DestroyActor();
		return bNullIgnored && bCurrentTransformUsed && bExplicitTransformUsed && bPersistentFinished;
	}
}
