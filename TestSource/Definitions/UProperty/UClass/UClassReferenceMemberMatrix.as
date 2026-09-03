/**
 * UObject/TObjectPtr/TSubclassOf/TWeak/TSoft member matrix. C++ verifies named
 * reference members by path, so those UPROPERTY names are kept. The observers
 * cover a null ObjectRef default and an empty invalid TWeakObjectPtr.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UClassReferenceMemberMatrix
 * @Harness UClass
 * @Tag Definitions.UProperty.UClassReferenceMemberMatrix
 * @Provenance Theme: Definitions.UProperty. WorldStory: UObject/TObjectPtr/TSubclassOf/TWeak/TSoft member matrix.
 * @Provenance C++: each named reference member reflects; BeginPlay wires self/script object/component/class/soft paths.
 * @Provenance Extra: default ObjectRef is null; empty TWeakObjectPtr is invalid. FixtureIsolated.
 */

UCLASS()
class UCoverageUClassPropertyReferenceObject : UObject
{
	UPROPERTY()
	int ObjectValue = 17;
}

UCLASS()
class UCoverageUClassPropertyReferenceComponent : UActorComponent
{
	UPROPERTY()
	int ComponentValue = 23;
}

UCLASS()
class ACoverageUClassPropertyReferenceActor : AActor
{
	UPROPERTY()
	UObject ObjectRef;

	UPROPERTY()
	TObjectPtr<UObject> SmartObjectRef;

	UPROPERTY()
	TObjectPtr<UCoverageUClassPropertyReferenceObject> SmartScriptObjectRef;

	UPROPERTY(Instanced)
	UCoverageUClassPropertyReferenceObject InstancedObjectRef;

	UPROPERTY()
	UCoverageUClassPropertyReferenceObject ScriptObjectRef;

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	TObjectPtr<AActor> SmartActorRef;

	UPROPERTY()
	ACoverageUClassPropertyReferenceActor ScriptActorRef;

	UPROPERTY()
	UActorComponent ComponentRef;

	UPROPERTY()
	TObjectPtr<UCoverageUClassPropertyReferenceComponent> SmartScriptComponentRef;

	UPROPERTY()
	UCoverageUClassPropertyReferenceComponent ScriptComponentRef;

	UPROPERTY()
	TSubclassOf<AActor> ActorClassRef;

	UPROPERTY()
	TSubclassOf<ACoverageUClassPropertyReferenceActor> ScriptActorClassRef;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakActorRef;

	UPROPERTY()
	TWeakObjectPtr<ACoverageUClassPropertyReferenceActor> WeakScriptActorRef;

	UPROPERTY()
	TWeakObjectPtr<UCoverageUClassPropertyReferenceObject> WeakScriptObjectRef;

	UPROPERTY()
	TSoftObjectPtr<AActor> SoftActorRef;

	UPROPERTY()
	TSoftObjectPtr<ACoverageUClassPropertyReferenceActor> SoftScriptActorRef;

	UPROPERTY()
	TSoftObjectPtr<UCoverageUClassPropertyReferenceObject> SoftScriptObjectRef;

	UPROPERTY()
	TSoftClassPtr<AActor> SoftActorClassRef;

	UPROPERTY()
	TSoftClassPtr<ACoverageUClassPropertyReferenceActor> SoftScriptActorClassRef;

	/**
	 * WorldStory: wire every reference member to self, script object, or component.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.UClassReferenceMemberMatrix
	 * @Inputs none
	 * @Return ObjectRef/ActorRef/class/weak/soft members assigned
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ScriptObjectRef = Cast<UCoverageUClassPropertyReferenceObject>(
			NewObject(this, UCoverageUClassPropertyReferenceObject::StaticClass(), n"CoverageUClassPropertyReferenceObject"));
		InstancedObjectRef = Cast<UCoverageUClassPropertyReferenceObject>(
			NewObject(this, UCoverageUClassPropertyReferenceObject::StaticClass(), n"CoverageUClassPropertyInstancedObject"));
		ObjectRef = ScriptObjectRef;
		SmartObjectRef = ScriptObjectRef;
		SmartScriptObjectRef = ScriptObjectRef;
		ActorRef = this;
		SmartActorRef = this;
		ScriptActorRef = this;
		ScriptComponentRef = Cast<UCoverageUClassPropertyReferenceComponent>(
			NewObject(this, UCoverageUClassPropertyReferenceComponent::StaticClass(), n"CoverageUClassPropertyReferenceComponent", true));
		ComponentRef = ScriptComponentRef;
		SmartScriptComponentRef = ScriptComponentRef;
		ActorClassRef = ACoverageUClassPropertyReferenceActor::StaticClass();
		ScriptActorClassRef = ACoverageUClassPropertyReferenceActor::StaticClass();
		WeakActorRef = this;
		WeakScriptActorRef = this;
		WeakScriptObjectRef = ScriptObjectRef;
		SoftActorRef = this;
		SoftScriptActorRef = this;
		SoftScriptObjectRef = ScriptObjectRef;
		SoftActorClassRef = ACoverageUClassPropertyReferenceActor::StaticClass();
		SoftScriptActorClassRef = ACoverageUClassPropertyReferenceActor::StaticClass();
	}

	/**
	 * Observe that ObjectRef defaults to null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassReferenceMemberMatrix
	 * @Inputs an unset UObject
	 * @Return true when the object is null
	 * @Boundary null default
	 */
	UFUNCTION()
	bool ReferenceMemberNullObjectDefault()
	{
		UObject ObjectRef;
		return ObjectRef == nullptr;
	}

	/**
	 * Observe that an empty TWeakObjectPtr is invalid.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassReferenceMemberMatrix
	 * @Inputs a default-constructed TWeakObjectPtr<AActor>
	 * @Return true when IsValid is false
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool ReferenceMemberEmptyWeakIsInvalid()
	{
		TWeakObjectPtr<AActor> WeakActorRef;
		return !WeakActorRef.IsValid();
	}
}
