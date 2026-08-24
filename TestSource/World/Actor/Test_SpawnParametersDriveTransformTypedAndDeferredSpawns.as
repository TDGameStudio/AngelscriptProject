// Theme: World.Actor. WorldStory: FActorSpawnParameters typed/deferred/world/persistent spawns.
// C++: AngelscriptActorSpawnPatternsTests.cpp::SpawnParametersDriveTransformTypedAndDeferredSpawns
// Oracle: SpawnParametersResult == 1 after owner/transform/tag checks.
// Spawn is the oracle. Extra: SpawnParametersResult 0 until BeginPlay; TargetTag 0;
// failure codes 10..70. FixtureIsolated.

UCLASS()
class ASpawnParametersTargetActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	int32 TargetTag = 0;
}

UCLASS()
class ASpawnParametersSourceActor : AActor
{
	UPROPERTY()
	int32 SpawnParametersResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FActorSpawnParameters Parameters;
		Parameters.Name = n"SpawnParametersTarget";
		Parameters.Owner = this;
		Parameters.NameMode = ESpawnActorNameMode::Requested;
		Parameters.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		Parameters.SetbDeferConstruction(true);

		FTransform SpawnTransform = FTransform(FRotator::ZeroRotator, FVector(125.0, 250.0, 375.0), FVector::OneVector);
		ASpawnParametersTargetActor Spawned = ASpawnParametersTargetActor::Spawn(SpawnTransform, Parameters);
		if (Spawned == nullptr)
		{
			SpawnParametersResult = 10;
			return;
		}
		if (Spawned.GetOwner() != this)
		{
			SpawnParametersResult = 20;
			return;
		}
		Spawned.TargetTag = 42;
		FinishSpawningActor(Spawned, SpawnTransform);
		if (!Spawned.GetActorLocation().Equals(FVector(125.0, 250.0, 375.0)))
		{
			SpawnParametersResult = 30;
			return;
		}
		if (Spawned.TargetTag != 42)
		{
			SpawnParametersResult = 40;
			return;
		}

		FActorSpawnParameters GlobalParameters = Parameters;
		GlobalParameters.Name = n"GlobalSpawnParametersTarget";
		GlobalParameters.SetbDeferConstruction(false);
		AActor GlobalSpawned = SpawnActor(ASpawnParametersTargetActor::StaticClass(), SpawnTransform, GlobalParameters);
		if (GlobalSpawned == nullptr || GlobalSpawned.GetOwner() != this)
		{
			SpawnParametersResult = 50;
			return;
		}

		FActorSpawnParameters WorldParameters;
		WorldParameters.Name = n"WorldSpawnParametersTarget";
		WorldParameters.Owner = this;
		AActor WorldSpawned = GetWorld().SpawnActor(ASpawnParametersTargetActor::StaticClass(), SpawnTransform, WorldParameters);
		if (WorldSpawned == nullptr || WorldSpawned.GetOwner() != this)
		{
			SpawnParametersResult = 60;
			return;
		}

		FActorSpawnParameters PersistentParameters;
		PersistentParameters.Name = n"PersistentSpawnParametersTarget";
		PersistentParameters.Owner = this;
		AActor PersistentSpawned = SpawnPersistentActor(ASpawnParametersTargetActor::StaticClass(), SpawnTransform, PersistentParameters);
		SpawnParametersResult = PersistentSpawned != nullptr && PersistentSpawned.GetOwner() == this ? 1 : 70;
	}
}
