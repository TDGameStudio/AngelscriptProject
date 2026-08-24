// Purpose: Observe strongly typed <ActorType>::Spawn overloads and the
// duplicate-name negative path. Spawn is the API under test; each live actor
// is destroyed in this file.
// AS-facing API: <ActorType> <ActorType>::Spawn(const FVector& Location = FVector::ZeroVector, const FRotator& Rotation = FRotator::ZeroRotator, const FName& Name = NAME_None, ULevel Level = nullptr);
// <ActorType> <ActorType>::Spawn(const FTransform& SpawnTransform, const FActorSpawnParameters& SpawnParameters);
// Inputs: Default Spawn(), location (100,0,0), NAME_None, explicit name
// n"TS_AActor_TypedSpawn", null ULevel, Identity transform, and
// FActorSpawnParameters with NameMode Requested then Required_ErrorAndReturnNull.
// Expected observations: Each Spawn returns a live actor of the requested type
// at the requested location. Duplicate Required_ErrorAndReturnNull is the
// diagnostic companion.
// Boundary/ownership: Source owns spawn cleanup via DestroyActor.
// FixtureIsolated. Duplicate-name path is DiagnosticOnly.

namespace TS_AActor_MutationAndLifecycle_02
{
	bool Observe_Spawn_Nominal()
	{
		AActor DefaultSpawned = AActor::Spawn();
		if (DefaultSpawned is null)
		{
			throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn() returned null");
		}
		DefaultSpawned.DestroyActor();

		AActor LocationSpawned = AActor::Spawn(FVector(100.0, 0.0, 0.0), FRotator::ZeroRotator, n"TS_AActor_TypedSpawn");
		if (LocationSpawned is null)
		{
			throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn(location) returned null");
		}
		bool bLocation = LocationSpawned.GetActorLocation().Equals(FVector(100.0, 0.0, 0.0));
		LocationSpawned.DestroyActor();

		ULevel Level;
		AActor LevelSpawned = AActor::Spawn(FVector::ZeroVector, FRotator::ZeroRotator, NAME_None, Level);
		if (LevelSpawned is null)
		{
			throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn(level) returned null");
		}
		LevelSpawned.DestroyActor();

		FTransform SpawnTransform(FRotator::ZeroRotator, FVector(125.0, 250.0, 375.0), FVector::OneVector);
		FActorSpawnParameters Params;
		Params.Name = n"TS_AActor_TypedParams";
		Params.NameMode = ESpawnActorNameMode::Requested;
		Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		AActor ParamSpawned = AActor::Spawn(SpawnTransform, Params);
		if (ParamSpawned is null)
		{
			throw("TS_AActor_MutationAndLifecycle_02 setup: AActor::Spawn(params) returned null");
		}
		bool bParamsLocation = ParamSpawned.GetActorLocation().Equals(FVector(125.0, 250.0, 375.0));
		ParamSpawned.DestroyActor();

		APlayerController Controller = APlayerController::Spawn();
		if (Controller is null)
		{
			throw("TS_AActor_MutationAndLifecycle_02 setup: APlayerController::Spawn() returned null");
		}
		Controller.DestroyActor();

		APawn Pawn = APawn::Spawn(FVector(0.0, 100.0, 0.0));
		if (Pawn is null)
		{
			throw("TS_AActor_MutationAndLifecycle_02 setup: APawn::Spawn() returned null");
		}
		bool bPawnLocation = Pawn.GetActorLocation().Equals(FVector(0.0, 100.0, 0.0));
		Pawn.DestroyActor();
		return bLocation && bParamsLocation && bPawnLocation;
	}

	void ExerciseExpectedFailure()
	{
		FActorSpawnParameters Params;
		Params.Name = n"TS_AActor_TypedSpawn_Duplicate";
		Params.NameMode = ESpawnActorNameMode::Required_ErrorAndReturnNull;
		Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		FTransform SpawnTransform;
		AActor First = AActor::Spawn(SpawnTransform, Params);
		AActor Second = AActor::Spawn(SpawnTransform, Params);
		if (First != nullptr)
		{
			First.DestroyActor();
		}
		if (Second != nullptr)
		{
			Second.DestroyActor();
		}
	}
}
