// Theme: Definitions.UProperty. WorldStory: scalar/text/struct UCLASS members reflect native property types.
// C++: bool/int widths/float/double/FString/FName/FText/FVector/FRotator/FQuat/FTransform/FColor/enum all register.
// Extra: default FText/FQuat/FTransform empty until BeginPlay; Idle enum is the unused boundary. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TextValue = FText::FromString("Member Text");
		QuatValue = FQuat(FRotator(0, 90, 0));
		TransformValue = FTransform(FRotator(0, 45, 0), FVector(3, 4, 5), FVector(2, 2, 2));
	}
}

bool Observe_ScalarText_EmptyFStringIndependent()
{
	FString Empty;
	FString StringValue = "MemberString";
	return Empty.Len() == 0 && StringValue.Len() != 0;
}

bool Observe_ScalarText_IdleEnumBoundary()
{
	return int(EUClassPropertyScalarState::Idle) == 0;
}
