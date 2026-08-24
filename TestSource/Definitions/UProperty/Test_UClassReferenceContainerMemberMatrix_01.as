// Theme: Definitions.UProperty. WorldStory (part 1): reference container members default empty.
// C++ compiles the combined actor with TArray/TSet/TMap of actors, objects, weak, soft, and subclass pointers.
// Extra: empty arrays/maps Num 0 before BeginPlay fills them. FixtureIsolated.

UCLASS()
class UCoverageUClassPropertyReferenceContainerObject : UObject
{
	UPROPERTY()
	int ObjectValue = 0;
}

UCLASS()
class ACoverageUClassPropertyReferenceContainerActor : AActor
{
	UPROPERTY()
	TArray<AActor> ActorArray;

	UPROPERTY()
	TArray<UCoverageUClassPropertyReferenceContainerObject> ObjectArray;

	UPROPERTY(Instanced)
	TArray<UCoverageUClassPropertyReferenceContainerObject> InstancedObjectArray;

	UPROPERTY()
	TArray<TSubclassOf<AActor>> ActorClassArray;

	UPROPERTY()
	TArray<TWeakObjectPtr<AActor>> WeakActorArray;

	UPROPERTY()
	TArray<TWeakObjectPtr<ACoverageUClassPropertyReferenceContainerActor>> WeakScriptActorArray;

	UPROPERTY()
	TArray<TWeakObjectPtr<UCoverageUClassPropertyReferenceContainerObject>> WeakScriptObjectArray;

	UPROPERTY()
	TArray<TSoftObjectPtr<AActor>> SoftActorArray;

	UPROPERTY()
	TArray<TSoftObjectPtr<ACoverageUClassPropertyReferenceContainerActor>> SoftScriptActorArray;

	UPROPERTY()
	TArray<TSoftObjectPtr<UCoverageUClassPropertyReferenceContainerObject>> SoftScriptObjectArray;

	UPROPERTY()
	TArray<TSoftClassPtr<AActor>> SoftActorClassArray;

	UPROPERTY()
	TArray<TSoftClassPtr<ACoverageUClassPropertyReferenceContainerActor>> SoftScriptActorClassArray;

	UPROPERTY()
	TSet<AActor> ActorSet;

	UPROPERTY()
	TSet<TSubclassOf<AActor>> ActorClassSet;

	UPROPERTY()
	TMap<FName, AActor> NameToActorMap;

	UPROPERTY()
	TMap<FName, UCoverageUClassPropertyReferenceContainerObject> NameToObjectMap;

	UPROPERTY(Instanced)
	TMap<FName, UCoverageUClassPropertyReferenceContainerObject> NameToInstancedObjectMap;

	UPROPERTY()
	TMap<FName, TSubclassOf<AActor>> NameToClassMap;

	UPROPERTY()
	TMap<int, TWeakObjectPtr<AActor>> IntToWeakActorMap;

	UPROPERTY()
	TMap<FName, TWeakObjectPtr<ACoverageUClassPropertyReferenceContainerActor>> NameToWeakScriptActorMap;

	UPROPERTY()
	TMap<FName, TWeakObjectPtr<UCoverageUClassPropertyReferenceContainerObject>> NameToWeakScriptObjectMap;

	UPROPERTY()
	TMap<int, TSoftObjectPtr<AActor>> IntToSoftActorMap;

	UPROPERTY()
	TMap<FName, TSoftObjectPtr<ACoverageUClassPropertyReferenceContainerActor>> NameToSoftScriptActorMap;

	UPROPERTY()
	TMap<FName, TSoftObjectPtr<UCoverageUClassPropertyReferenceContainerObject>> NameToSoftScriptObjectMap;

	UPROPERTY()
	TMap<FName, TSoftClassPtr<ACoverageUClassPropertyReferenceContainerActor>> NameToSoftScriptClassMap;

	UPROPERTY()
	int ObjectArrayValueSum = 0;

	UPROPERTY()
	int InstancedObjectArrayValueSum = 0;

	UPROPERTY()
	bool bActorSetDeduplicated = false;

	UPROPERTY()
	bool bActorClassSetContainsScriptClass = false;

	UPROPERTY()
	bool bNameToActorFoundSelf = false;

	UPROPERTY()
	bool bNameToObjectFound = false;

	UPROPERTY()
	bool bNameToInstancedObjectFound = false;

	UPROPERTY()
	bool bNameToClassFound = false;

	UPROPERTY()
	bool bNameToWeakFound = false;

	UPROPERTY()
	bool bNameToWeakScriptFound = false;

	UPROPERTY()
	bool bNameToSoftFound = false;

	UPROPERTY()
	bool bNameToSoftScriptFound = false;

	UPROPERTY()
	bool bNameToSoftScriptClassFound = false;
}

int Observe_ReferenceContainer_EmptyActorArrayNum()
{
	TArray<AActor> ActorArray;
	return ActorArray.Num();
}

int Observe_ReferenceContainer_EmptyNameToActorMapNum()
{
	TMap<FName, AActor> NameToActorMap;
	return NameToActorMap.Num();
}
