// Theme: Definitions.UProperty. WorldStory: TOptional members including empty Reset and null UObject Set.
// C++: Maybe* reflect as FOptionalProperty; bMaybeBoolSet true with bBoolValue false; EmptyCount Reset;
// NullObject Set(GetNullObject()) is set and null. FixtureIsolated.

UENUM(BlueprintType)
enum EUClassPropertyOptionalState
{
	Idle,
	Armed,
	Fired
}

USTRUCT(BlueprintType)
struct FUClassPropertyOptionalPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageUClassOptionalMemberActor : AActor
{
	UPROPERTY()
	TOptional<bool> MaybeBool;

	UPROPERTY()
	TOptional<int> MaybeCount;

	UPROPERTY()
	TOptional<float> MaybeFloat;

	UPROPERTY()
	TOptional<FName> MaybeName;

	UPROPERTY()
	TOptional<EUClassPropertyOptionalState> MaybeState;

	UPROPERTY()
	TOptional<FString> MaybeLabel;

	UPROPERTY()
	TOptional<FVector> MaybeVector;

	UPROPERTY()
	TOptional<FUClassPropertyOptionalPayload> MaybePayload;

	UPROPERTY()
	TOptional<UObject> MaybeObject;

	UPROPERTY()
	TOptional<int> EmptyCount;

	UPROPERTY()
	TOptional<UObject> NullObject;

	UPROPERTY()
	bool bMaybeBoolSet = false;

	UPROPERTY()
	bool bBoolValue = false;

	UPROPERTY()
	bool bMaybeCountSet = false;

	UPROPERTY()
	int CountValue = 0;

	UPROPERTY()
	bool bMaybeFloatSet = false;

	UPROPERTY()
	float FloatValue = 0.0;

	UPROPERTY()
	bool bMaybeNameSet = false;

	UPROPERTY()
	FName NameValue;

	UPROPERTY()
	bool bMaybeStateSet = false;

	UPROPERTY()
	int StateValue = 0;

	UPROPERTY()
	bool bMaybeLabelSet = false;

	UPROPERTY()
	FString LabelValue;

	UPROPERTY()
	bool bMaybeVectorSet = false;

	UPROPERTY()
	FVector VectorValue;

	UPROPERTY()
	bool bMaybePayloadSet = false;

	UPROPERTY()
	int PayloadCountValue = 0;

	UPROPERTY()
	FString PayloadLabelValue;

	UPROPERTY()
	bool bMaybeObjectSet = false;

	UPROPERTY()
	bool bMaybeObjectIsSelf = false;

	UPROPERTY()
	bool bEmptyCountSet = true;

	UPROPERTY()
	bool bNullObjectSet = false;

	UPROPERTY()
	bool bNullObjectValueIsNull = false;

	UObject GetNullObject()
	{
		return nullptr;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MaybeBool.Set(false);
		MaybeCount.Set(71);
		MaybeFloat.Set(12.5f);
		MaybeName.Set(n"OptionalName");
		MaybeState.Set(EUClassPropertyOptionalState::Fired);
		MaybeLabel.Set(FString("OptionalLabel"));
		MaybeVector.Set(FVector(7, 8, 9));
		MaybeObject.Set(this);
		NullObject.Set(GetNullObject());

		FUClassPropertyOptionalPayload Payload;
		Payload.Count = 83;
		Payload.Label = "PayloadLabel";
		MaybePayload.Set(Payload);

		EmptyCount.Reset();

		bMaybeBoolSet = MaybeBool.IsSet();
		bBoolValue = MaybeBool.GetValue();
		bMaybeCountSet = MaybeCount.IsSet();
		CountValue = MaybeCount.GetValue();
		bMaybeFloatSet = MaybeFloat.IsSet();
		FloatValue = MaybeFloat.GetValue();
		bMaybeNameSet = MaybeName.IsSet();
		NameValue = MaybeName.GetValue();
		bMaybeStateSet = MaybeState.IsSet();
		StateValue = int(MaybeState.GetValue());
		bMaybeLabelSet = MaybeLabel.IsSet();
		LabelValue = MaybeLabel.GetValue();
		bMaybeVectorSet = MaybeVector.IsSet();
		VectorValue = MaybeVector.GetValue();
		bMaybePayloadSet = MaybePayload.IsSet();
		PayloadCountValue = MaybePayload.GetValue().Count;
		PayloadLabelValue = MaybePayload.GetValue().Label;
		bMaybeObjectSet = MaybeObject.IsSet();
		bMaybeObjectIsSelf = MaybeObject.GetValue() == this;
		bEmptyCountSet = EmptyCount.IsSet();
		bNullObjectSet = NullObject.IsSet();
		bNullObjectValueIsNull = NullObject.GetValue() == nullptr;
	}
}

bool Observe_Optional_UnsetIsEmpty()
{
	TOptional<int> EmptyCount;
	return !EmptyCount.IsSet();
}

UObject Observe_Optional_GetNullObjectBoundary()
{
	return nullptr;
}
