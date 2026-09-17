/**
 * @version v1
 * @summary Scalar/text/struct UCLASS members reflect native property types. C++ verifies named members by path, so those UPROPERTY names are kept. The observers cover an empty FString versus MemberString and the Idle enum boundary.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Scalar/text/struct UCLASS members reflect native property types. C++ verifies named members by path, so those UPROPERTY names are kept. The observers cover an empty FString versus MemberString and the Idle enum boundary.
 * @topic Baseline
 */
UENUM()
enum EUClassPropertyScalarState
{
	Idle,
	Armed,
	Fired
}

UCLASS()
class ACoverageUClassScalarTextStructActor : AActor
{
	UPROPERTY()
	bool bBoolValue = true;

	UPROPERTY()
	int8 Int8Value = -8;

	UPROPERTY()
	int16 Int16Value = -1600;

	UPROPERTY()
	int IntValue = 3200;

	UPROPERTY()
	int64 Int64Value = -6400000000;

	UPROPERTY()
	uint8 UInt8Value = 8;

	UPROPERTY()
	uint16 UInt16Value = 1600;

	UPROPERTY()
	uint UIntValue = 3200;

	UPROPERTY()
	uint64 UInt64Value = 6400000000;

	UPROPERTY()
	float FloatValue = 1.25f;

	UPROPERTY()
	double DoubleValue = 2.5;

	UPROPERTY()
	FString StringValue = "MemberString";

	UPROPERTY()
	FName NameValue = n"MemberName";

	UPROPERTY()
	FText TextValue;

	UPROPERTY()
	FVector VectorValue = FVector(1, 2, 3);

	UPROPERTY()
	FVector2D Vector2DValue = FVector2D(4, 5);

	UPROPERTY()
	FIntPoint IntPointValue = FIntPoint(6, 7);

	UPROPERTY()
	FRotator RotatorValue = FRotator(10, 20, 30);

	UPROPERTY()
	FQuat QuatValue;

	UPROPERTY()
	FTransform TransformValue;

	UPROPERTY()
	FLinearColor LinearColorValue = FLinearColor(0.1, 0.2, 0.3, 0.4);

	UPROPERTY()
	FColor ColorValue = FColor(10, 20, 30, 40);

	UPROPERTY()
	EUClassPropertyScalarState EnumValue = EUClassPropertyScalarState::Armed;

	/**
	 * WorldStory: fill FText/FQuat/FTransform after play begins.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.UClassScalarTextStructMemberMatrix
	 * @Inputs none
	 * @Return TextValue, QuatValue and TransformValue assigned
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TextValue = FText::FromString("Member Text");
		QuatValue = FQuat(FRotator(0, 90, 0));
		TransformValue = FTransform(FRotator(0, 45, 0), FVector(3, 4, 5), FVector(2, 2, 2));
	}

	/**
	 * Observe that an empty FString is independent of MemberString.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassScalarTextStructMemberMatrix
	 * @Inputs an empty FString and "MemberString"
	 * @Return true when only the empty string has Len 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool ScalarTextEmptyFStringIndependent()
	{
		FString Empty;
		FString StringValue = "MemberString";
		if (Empty.Len() != 0)
		{
			return false;
		}
		return StringValue.Len() != 0;
	}

	/**
	 * Observe that Idle is the unused enum boundary.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassScalarTextStructMemberMatrix
	 * @Inputs EUClassPropertyScalarState::Idle
	 * @Return true when Idle converts to 0
	 * @Boundary unused enumerator
	 */
	UFUNCTION()
	bool ScalarTextIdleEnumBoundary()
	{
		return int(EUClassPropertyScalarState::Idle) == 0;
	}
}
/** @end */
