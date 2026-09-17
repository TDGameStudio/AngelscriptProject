/**
 * @version v1
 * @summary Extended USTRUCT member types: double, FText, math structs, object/soft/weak. C++ reads Data after BeginPlay. Keep the UPROPERTY names on FStructExtendedMemberData.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Extended USTRUCT member types: double, FText, math structs, object/soft/weak. C++ reads Data after BeginPlay. Keep the UPROPERTY names on FStructExtendedMemberData.
 * @topic Baseline
 */
UCLASS()
class UCoverageStructMemberObject : UObject
{
	UPROPERTY()
	int Value = 17;
}

USTRUCT(BlueprintType)
struct FStructExtendedMemberData
{
	UPROPERTY()
	double DoubleValue = 0.0;

	UPROPERTY()
	FText TextValue;

	UPROPERTY()
	FRotator RotatorValue;

	UPROPERTY()
	FQuat QuatValue;

	UPROPERTY()
	FTransform TransformValue;

	UPROPERTY()
	UCoverageStructMemberObject ObjectRef;

	UPROPERTY()
	TSubclassOf<AActor> ActorClass;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakActor;

	UPROPERTY()
	TSoftObjectPtr<AActor> SoftActor;

	UPROPERTY()
	TSoftClassPtr<AActor> SoftActorClass;
}

UCLASS()
class ACoverageStructExtendedMemberActor : AActor
{
	UPROPERTY()
	FStructExtendedMemberData Data;

	/**
	 * WorldStory: BeginPlay fills extended member types including object and soft/weak refs.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructExtendedMemberTypeMatrix
	 * @Inputs none
	 * @Return Data.DoubleValue 6.25, Text Struct extended text, WeakActor this
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.DoubleValue = 6.25;
		Data.TextValue = FText::FromString("Struct extended text");
		Data.RotatorValue = FRotator(10, 20, 30);
		Data.QuatValue = FQuat(FRotator(0, 90, 0));
		Data.TransformValue = FTransform(FRotator(0, 45, 0), FVector(3, 4, 5), FVector(2, 2, 2));
		Data.ObjectRef = Cast<UCoverageStructMemberObject>(NewObject(this, UCoverageStructMemberObject::StaticClass()));
		Data.ActorClass = ACoverageStructExtendedMemberActor::StaticClass();
		Data.WeakActor = this;
		Data.SoftActor = this;
		Data.SoftActorClass = ACoverageStructExtendedMemberActor::StaticClass();
	}

	/**
	 * Observe empty extended members before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructExtendedMemberTypeMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when DoubleValue is 0.0 and ObjectRef/ActorClass are null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ExtendedMemberDefaultEmpty()
	{
		if (Data.DoubleValue != 0.0)
		{
			return false;
		}
		if (Data.ObjectRef != nullptr)
		{
			return false;
		}
		return Data.ActorClass.Get() == nullptr;
	}

	/**
	 * Observe extended members after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructExtendedMemberTypeMatrix
	 * @Inputs BeginPlay on this actor
	 * @Return true when DoubleValue/Text/Rotator/ObjectRef/ActorClass/WeakActor match
	 */
	UFUNCTION()
	bool ExtendedMemberNominalBeginPlay()
	{
		BeginPlay();
		if (Data.DoubleValue != 6.25)
		{
			return false;
		}
		if (Data.TextValue.ToString() != "Struct extended text")
		{
			return false;
		}
		if (!Data.RotatorValue.Equals(FRotator(10, 20, 30), 0.001))
		{
			return false;
		}
		if (Data.ObjectRef == nullptr)
		{
			return false;
		}
		if (Data.ObjectRef.Value != 17)
		{
			return false;
		}
		if (Data.ActorClass.Get() != ACoverageStructExtendedMemberActor::StaticClass())
		{
			return false;
		}
		return Data.WeakActor.Get() == this;
	}

	/**
	 * Observe that BeginPlay on this actor does not fill a second actor.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructExtendedMemberTypeMatrix
	 * @Inputs BeginPlay on this actor and an untouched second actor
	 * @Return true when this DoubleValue is 6.25 and Second stays 0.0/null
	 * @Boundary spawn isolation
	 * @Param Second the other actor
	 */
	UFUNCTION()
	bool ExtendedMemberCopyIndependence(ACoverageStructExtendedMemberActor Second)
	{
		BeginPlay();
		if (Data.DoubleValue != 6.25)
		{
			return false;
		}
		if (Second.Data.DoubleValue != 0.0)
		{
			return false;
		}
		return Second.Data.ObjectRef == nullptr;
	}
}
/** @end */
