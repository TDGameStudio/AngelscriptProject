// Theme: Definitions.UProperty. WorldStory (part 2): MakeObject/BeginPlay fill the reference container matrix.
// C++ compiles this with the actor from part 1; ObjectArrayValueSum 42; InstancedObjectArrayValueSum 84;
// bActorSetDeduplicated true; Find flags all true. Extra: empty MakeObject path is not used; missing OtherActor
// still leaves arrays starting empty. FixtureIsolated.

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

	UCoverageUClassPropertyReferenceContainerObject MakeObject(FName ObjectName, int Value)
	{
		UCoverageUClassPropertyReferenceContainerObject ObjectValue =
			Cast<UCoverageUClassPropertyReferenceContainerObject>(
				NewObject(this, UCoverageUClassPropertyReferenceContainerObject::StaticClass(), ObjectName));
		ObjectValue.ObjectValue = Value;
		return ObjectValue;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor OtherActor = SpawnActor(AActor::StaticClass());
		UCoverageUClassPropertyReferenceContainerObject FirstObject = MakeObject(n"ReferenceContainerFirstObject", 19);
		UCoverageUClassPropertyReferenceContainerObject SecondObject = MakeObject(n"ReferenceContainerSecondObject", 23);
		UCoverageUClassPropertyReferenceContainerObject FirstInstancedObject = MakeObject(n"ReferenceContainerFirstInstancedObject", 41);
		UCoverageUClassPropertyReferenceContainerObject SecondInstancedObject = MakeObject(n"ReferenceContainerSecondInstancedObject", 43);

		ActorArray.Add(this);
		ActorArray.Add(OtherActor);
		ObjectArray.Add(FirstObject);
		ObjectArray.Add(SecondObject);
		InstancedObjectArray.Add(FirstInstancedObject);
		InstancedObjectArray.Add(SecondInstancedObject);
		ActorClassArray.Add(AActor::StaticClass());
		ActorClassArray.Add(ACoverageUClassPropertyReferenceContainerActor::StaticClass());
		WeakActorArray.Add(this);
		WeakActorArray.Add(OtherActor);
		WeakScriptActorArray.Add(this);
		WeakScriptObjectArray.Add(FirstObject);
		SoftActorArray.Add(this);
		SoftActorArray.Add(OtherActor);
		SoftScriptActorArray.Add(this);
		SoftScriptObjectArray.Add(FirstObject);
		SoftActorClassArray.Add(TSoftClassPtr<AActor>(AActor::StaticClass()));
		SoftActorClassArray.Add(TSoftClassPtr<AActor>(ACoverageUClassPropertyReferenceContainerActor::StaticClass()));
		SoftScriptActorClassArray.Add(TSoftClassPtr<ACoverageUClassPropertyReferenceContainerActor>(ACoverageUClassPropertyReferenceContainerActor::StaticClass()));

		ActorSet.Add(this);
		ActorSet.Add(this);
		ActorSet.Add(OtherActor);
		bActorSetDeduplicated = ActorSet.Num() == 2 && ActorSet.Contains(this) && ActorSet.Contains(OtherActor);
		ActorClassSet.Add(AActor::StaticClass());
		ActorClassSet.Add(ACoverageUClassPropertyReferenceContainerActor::StaticClass());
		bActorClassSetContainsScriptClass = ActorClassSet.Contains(ACoverageUClassPropertyReferenceContainerActor::StaticClass());

		NameToActorMap.Add(n"Self", this);
		NameToActorMap.Add(n"Other", OtherActor);
		NameToObjectMap.Add(n"First", FirstObject);
		NameToObjectMap.Add(n"Second", SecondObject);
		NameToInstancedObjectMap.Add(n"First", FirstInstancedObject);
		NameToInstancedObjectMap.Add(n"Second", SecondInstancedObject);
		NameToClassMap.Add(n"NativeActor", AActor::StaticClass());
		NameToClassMap.Add(n"ScriptActor", ACoverageUClassPropertyReferenceContainerActor::StaticClass());
		IntToWeakActorMap.Add(1, this);
		IntToWeakActorMap.Add(2, OtherActor);
		NameToWeakScriptActorMap.Add(n"Self", this);
		NameToWeakScriptObjectMap.Add(n"Object", FirstObject);
		IntToSoftActorMap.Add(1, this);
		IntToSoftActorMap.Add(2, OtherActor);
		NameToSoftScriptActorMap.Add(n"Self", this);
		NameToSoftScriptObjectMap.Add(n"Object", FirstObject);
		NameToSoftScriptClassMap.Add(n"ScriptActor", TSoftClassPtr<ACoverageUClassPropertyReferenceContainerActor>(ACoverageUClassPropertyReferenceContainerActor::StaticClass()));

		ObjectArrayValueSum = ObjectArray[0].ObjectValue + ObjectArray[1].ObjectValue;
		InstancedObjectArrayValueSum = InstancedObjectArray[0].ObjectValue + InstancedObjectArray[1].ObjectValue;

		AActor FoundActor;
		UCoverageUClassPropertyReferenceContainerObject FoundObject;
		UCoverageUClassPropertyReferenceContainerObject FoundInstancedObject;
		TSubclassOf<AActor> FoundClass;
		TWeakObjectPtr<AActor> FoundWeakActor;
		TWeakObjectPtr<ACoverageUClassPropertyReferenceContainerActor> FoundWeakScriptActor;
		TWeakObjectPtr<UCoverageUClassPropertyReferenceContainerObject> FoundWeakScriptObject;
		TSoftObjectPtr<AActor> FoundSoftActor;
		TSoftObjectPtr<ACoverageUClassPropertyReferenceContainerActor> FoundSoftScriptActor;
		TSoftObjectPtr<UCoverageUClassPropertyReferenceContainerObject> FoundSoftScriptObject;
		TSoftClassPtr<ACoverageUClassPropertyReferenceContainerActor> FoundSoftScriptClass;
		bNameToActorFoundSelf = NameToActorMap.Find(n"Self", FoundActor) && FoundActor == this;
		bNameToObjectFound = NameToObjectMap.Find(n"Second", FoundObject) && FoundObject.ObjectValue == 23;
		bNameToInstancedObjectFound = NameToInstancedObjectMap.Find(n"Second", FoundInstancedObject) && FoundInstancedObject.ObjectValue == 43;
		bNameToClassFound = NameToClassMap.Find(n"ScriptActor", FoundClass) && FoundClass == ACoverageUClassPropertyReferenceContainerActor::StaticClass();
		bNameToWeakFound = IntToWeakActorMap.Find(2, FoundWeakActor) && FoundWeakActor.IsValid();
		bNameToWeakScriptFound =
			NameToWeakScriptActorMap.Find(n"Self", FoundWeakScriptActor) && FoundWeakScriptActor.IsValid()
			&& NameToWeakScriptObjectMap.Find(n"Object", FoundWeakScriptObject) && FoundWeakScriptObject.IsValid();
		bNameToSoftFound = IntToSoftActorMap.Find(2, FoundSoftActor) && FoundSoftActor.IsValid();
		bNameToSoftScriptFound =
			NameToSoftScriptActorMap.Find(n"Self", FoundSoftScriptActor) && FoundSoftScriptActor.IsValid()
			&& NameToSoftScriptObjectMap.Find(n"Object", FoundSoftScriptObject) && FoundSoftScriptObject.IsValid();
		bNameToSoftScriptClassFound =
			NameToSoftScriptClassMap.Find(n"ScriptActor", FoundSoftScriptClass)
			&& FoundSoftScriptClass == ACoverageUClassPropertyReferenceContainerActor::StaticClass();
	}
}

int Observe_MakeObject_EmptyArrayBeforeFill()
{
	TArray<UCoverageUClassPropertyReferenceContainerObject> ObjectArray;
	return ObjectArray.Num();
}

bool Observe_FindMissingNameIsFalse()
{
	TMap<FName, AActor> NameToActorMap;
	AActor FoundActor;
	return !NameToActorMap.Find(n"Self", FoundActor);
}
