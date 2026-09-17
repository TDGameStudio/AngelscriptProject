/**
 * @version v1
 * @summary Every spawn syntax followed by the three GetAllActorsOfClass query shapes. C++ runs the entrypoint and expects 1. The spawned class carries a tag and a default marker so both the class and tag queries can resolve it.
 * @topic World
 */
/**
 * @version root
 * @summary Every spawn syntax followed by the three GetAllActorsOfClass query shapes. C++ runs the entrypoint and expects 1. The spawned class carries a tag and a default marker so both the class and tag queries can resolve it.
 * @topic Baseline
 */
UCLASS()
class ATestActorInterfaceSpawned : AActor
{
	default Tags.Add(n"ActorInterfaceSpawned");

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY()
	int Marker = 7;
}

UCLASS()
class ATestActorInterfaceSpawnAndQuery : AActor
{
	/**
	 * Spawn through every supported syntax, then query the results by class and by tag.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceSpawnAndQuery
	 * @Inputs none
	 * @Return 1 on success; 10 through 80 naming the step that failed
	 */
	UFUNCTION()
	int RunSpawnAndQuery()
	{
		AActor NativeSpawned = AActor::Spawn(FVector(100.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceNativeSpawned");
		if (!IsValid(NativeSpawned))
		{
			return 10;
		}

		AActor GenericSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector(200.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceGenericSpawned");
		if (!IsValid(GenericSpawned))
		{
			return 20;
		}

		AActor DeferredSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector(300.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfaceDeferredSpawned", true);
		if (!IsValid(DeferredSpawned))
		{
			return 30;
		}
		FinishSpawningActor(DeferredSpawned);
		if (!DeferredSpawned.GetActorLocation().Equals(FVector(300.0, 0.0, 0.0)))
		{
			return 40;
		}

		AActor DeferredTransformSpawned = SpawnActor(ATestActorInterfaceSpawned::StaticClass(), FVector::ZeroVector, FRotator::ZeroRotator, n"ActorInterfaceDeferredTransformSpawned", true);
		if (!IsValid(DeferredTransformSpawned))
		{
			return 45;
		}
		FinishSpawningActor(DeferredTransformSpawned, FTransform(FRotator::ZeroRotator, FVector(350.0, 0.0, 0.0), FVector::OneVector));
		if (!DeferredTransformSpawned.GetActorLocation().Equals(FVector(350.0, 0.0, 0.0)))
		{
			return 46;
		}

		AActor PersistentSpawned = SpawnPersistentActor(ATestActorInterfaceSpawned::StaticClass(), FVector(400.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfacePersistentSpawned");
		if (!IsValid(PersistentSpawned))
		{
			return 50;
		}

		AActor PersistentDeferredSpawned = SpawnPersistentActor(ATestActorInterfaceSpawned::StaticClass(), FVector(450.0, 0.0, 0.0), FRotator::ZeroRotator, n"ActorInterfacePersistentDeferredSpawned", true);
		if (!IsValid(PersistentDeferredSpawned))
		{
			return 55;
		}
		FinishSpawningActor(PersistentDeferredSpawned);
		if (!PersistentDeferredSpawned.GetActorLocation().Equals(FVector(450.0, 0.0, 0.0)))
		{
			return 56;
		}

		TArray<ATestActorInterfaceSpawned> TypedActors;
		GetAllActorsOfClass(TypedActors);
		if (TypedActors.Num() < 5)
		{
			return 60;
		}

		TArray<AActor> ExplicitClassActors;
		GetAllActorsOfClass(ATestActorInterfaceSpawned::StaticClass(), ExplicitClassActors);
		if (ExplicitClassActors.Num() < 5)
		{
			return 70;
		}

		TArray<AActor> TaggedActors;
		GetAllActorsOfClassWithTag(n"ActorInterfaceSpawned", TaggedActors);
		if (TaggedActors.Num() < 5)
		{
			return 80;
		}

		return 1;
	}
}
/** @end */
