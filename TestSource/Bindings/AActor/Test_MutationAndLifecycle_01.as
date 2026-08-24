// Purpose: Observe scale/tick/input/replication mutations and every SpawnActor
// / SpawnPersistentActor / UWorld.SpawnActor overload, including null Class.
// Runner owns mutation fixtures. Spawn APIs are the behavior under test:
// each SpawnActor/SpawnPersistentActor is destroyed in this file.
// AS-facing API: void Actor.SetActorScale3D(FVector NewScale3D);
// void Actor.SetActorTickInterval(float32 TickInterval);
// void Actor.EnableInput(APlayerController PlayerController);
// void Actor.DisableInput(APlayerController PlayerController);
// void Actor.SetReplicates(bool bInReplicates);
// AActor Actor::SpawnActor overloads; AActor Actor::SpawnPersistentActor overloads;
// AActor UWorld.SpawnActor overload.
// Inputs: Runner-owned AActor and APlayerController for mutations. Spawn uses
// scale (2,3,4), tick interval 0.25, Identity transform, default parameters,
// NAME_None, bDeferredSpawn true/false, and a null TSubclassOf<AActor>.
// Expected observations: Scale becomes (2,3,4). Tick interval becomes 0.25
// then 0. EnableInput creates an input component; DisableInput is issued
// after. SetReplicates(true) then false is visible on GetIsReplicated. Spawn
// helpers return a live actor; null Class is the diagnostic path.
// Boundary/ownership: SetupOwner=Runner for mutations. Spawn cleanup is
// Source via DestroyActor. FixtureIsolated. Null Class is DiagnosticOnly.

namespace TS_AActor_MutationAndLifecycle_01
{
	bool Observe_SetActorScale3D_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
		}
		FVector Before = Actor.GetActorScale3D();
		Actor.SetActorScale3D(FVector(2.0, 3.0, 4.0));
		FVector After = Actor.GetActorScale3D();
		Actor.SetActorScale3D(Before);
		return After.Equals(FVector(2.0, 3.0, 4.0));
	}

	bool Observe_SetActorTickInterval_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
		}
		float32 Before = Actor.GetActorTickInterval();
		Actor.SetActorTickInterval(0.25);
		float32 After = Actor.GetActorTickInterval();
		Actor.SetActorTickInterval(0.0);
		float32 Restored = Actor.GetActorTickInterval();
		Actor.SetActorTickInterval(Before);
		return After == 0.25 && Restored == 0.0;
	}

	bool Observe_EnableInput_Nominal(AActor Actor, APlayerController Controller)
	{
		if (Actor is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
		}
		if (Controller is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required Controller is null");
		}
		Actor.EnableInput(Controller);
		UInputComponent After = Actor.GetInputComponent();
		Actor.DisableInput(Controller);
		return After != nullptr;
	}

	bool Observe_DisableInput_Nominal(AActor Actor, APlayerController Controller)
	{
		if (Actor is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
		}
		if (Controller is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required Controller is null");
		}
		Actor.EnableInput(Controller);
		UInputComponent Before = Actor.GetInputComponent();
		Actor.DisableInput(Controller);
		UInputComponent After = Actor.GetInputComponent();
		return Before != nullptr && After == Before;
	}

	bool Observe_SetReplicates_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required Actor is null");
		}
		Actor.SetReplicates(true);
		bool bEnabled = Actor.GetIsReplicated();
		Actor.SetReplicates(false);
		bool bDisabled = Actor.GetIsReplicated();
		return bEnabled && !bDisabled;
	}

	bool Observe_SpawnActor_Nominal()
	{
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		FTransform SpawnTransform(FRotator::ZeroRotator, FVector(100.0, 0.0, 0.0), FVector::OneVector);
		FActorSpawnParameters Params;
		Params.Name = n"TS_AActor_SpawnWithParams";
		Params.NameMode = ESpawnActorNameMode::Requested;
		Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		AActor FromParams = AActor::SpawnActor(ActorClass, SpawnTransform, Params);
		if (FromParams is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: spawn with params returned null");
		}
		bool bParamsLocation = FromParams.GetActorLocation().Equals(FVector(100.0, 0.0, 0.0));
		FromParams.DestroyActor();

		AActor FromLocation = AActor::SpawnActor(ActorClass, FVector(200.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_SpawnLocation");
		if (FromLocation is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: spawn at location returned null");
		}
		bool bLocation = FromLocation.GetActorLocation().Equals(FVector(200.0, 0.0, 0.0));
		UWorld World = FromLocation.GetWorld();
		FromLocation.DestroyActor();

		AActor FromDefaults = AActor::SpawnActor(ActorClass);
		if (FromDefaults is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: default spawn returned null");
		}
		FromDefaults.DestroyActor();

		ULevel Level;
		AActor FromLevel = AActor::SpawnActor(ActorClass, FVector::ZeroVector, FRotator::ZeroRotator, NAME_None, false, Level);
		if (FromLevel is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: spawn with level returned null");
		}
		FromLevel.DestroyActor();

		AActor Deferred = AActor::SpawnActor(ActorClass, FVector(300.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_SpawnDeferred", true);
		if (Deferred is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: deferred spawn returned null");
		}
		AActor::FinishSpawningActor(Deferred);
		bool bDeferredLocation = Deferred.GetActorLocation().Equals(FVector(300.0, 0.0, 0.0));
		Deferred.DestroyActor();

		if (World is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: required World is null");
		}
		FActorSpawnParameters WorldParams;
		WorldParams.Name = n"TS_AActor_WorldSpawn";
		WorldParams.NameMode = ESpawnActorNameMode::Requested;
		WorldParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		AActor FromWorld = World.SpawnActor(ActorClass, SpawnTransform, WorldParams);
		if (FromWorld is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: world spawn returned null");
		}
		FromWorld.DestroyActor();
		return bParamsLocation && bLocation && bDeferredLocation;
	}

	bool Observe_SpawnPersistentActor_Nominal()
	{
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		FTransform SpawnTransform(FRotator::ZeroRotator, FVector(400.0, 0.0, 0.0), FVector::OneVector);
		FActorSpawnParameters Params;
		Params.Name = n"TS_AActor_PersistentParams";
		Params.NameMode = ESpawnActorNameMode::Requested;
		Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		AActor FromParams = AActor::SpawnPersistentActor(ActorClass, SpawnTransform, Params);
		if (FromParams is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: persistent spawn with params returned null");
		}
		bool bParamsLocation = FromParams.GetActorLocation().Equals(FVector(400.0, 0.0, 0.0));
		FromParams.DestroyActor();

		AActor FromLocation = AActor::SpawnPersistentActor(ActorClass, FVector(450.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_PersistentLocation");
		if (FromLocation is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: persistent spawn at location returned null");
		}
		bool bLocation = FromLocation.GetActorLocation().Equals(FVector(450.0, 0.0, 0.0));
		FromLocation.DestroyActor();

		AActor FromDefaults = AActor::SpawnPersistentActor(ActorClass);
		if (FromDefaults is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: default persistent spawn returned null");
		}
		FromDefaults.DestroyActor();

		AActor Deferred = AActor::SpawnPersistentActor(ActorClass, FVector::ZeroVector, FRotator::ZeroRotator, NAME_None, true);
		if (Deferred is null)
		{
			throw("TS_AActor_MutationAndLifecycle_01 setup: deferred persistent spawn returned null");
		}
		AActor::FinishSpawningActor(Deferred);
		Deferred.DestroyActor();
		return bParamsLocation && bLocation;
	}

	void ExerciseExpectedFailure()
	{
		TSubclassOf<AActor> NullClass;
		FTransform SpawnTransform;
		FActorSpawnParameters Params;
		AActor FromNullClass = AActor::SpawnActor(NullClass, SpawnTransform, Params);
		AActor FromNullPersistent = AActor::SpawnPersistentActor(NullClass);
		UWorld World;
		AActor FromNullWorld = World.SpawnActor(AActor::StaticClass(), SpawnTransform, Params);
		if (FromNullClass != nullptr)
		{
			FromNullClass.DestroyActor();
		}
		if (FromNullPersistent != nullptr)
		{
			FromNullPersistent.DestroyActor();
		}
		if (FromNullWorld != nullptr)
		{
			FromNullWorld.DestroyActor();
		}
	}
}
