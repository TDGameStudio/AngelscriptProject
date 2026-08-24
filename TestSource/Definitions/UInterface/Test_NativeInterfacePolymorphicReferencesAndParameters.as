// Theme: Definitions.UInterface. WorldStory: parent/child implementers dispatch through one collector.
// C++: VerifyByPath FirstAssigned/SecondAssigned/PolymorphicDispatchWorked/InterfaceParameterWorked/ChildCastWorked true;
// PolymorphicSum 57; ParameterAdjustedValue 50; ChildInterfaceValue 223.
// Extra: missing FirstSource/SecondSource leaves flags false and sums 0. FixtureIsolated.

UCLASS()
class ACoverageNativeInterfaceBaseActor : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 11;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta + NativeValue;
	}
}

UCLASS()
class ACoverageNativeInterfaceChildActor : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int NativeValue = 23;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UFUNCTION()
	int GetChildValue() const
	{
		return 223;
	}

	UFUNCTION()
	int GetNativeValue() const
	{
		return 46;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta + NativeValue;
	}
}

UCLASS()
class ACoverageNativeInterfacePolymorphicCollector : AActor
{
	UPROPERTY()
	UObject FirstSource;

	UPROPERTY()
	UObject SecondSource;

	UAngelscriptNativeParentInterface CurrentRef;

	UPROPERTY()
	int PolymorphicSum = 0;

	UPROPERTY()
	int ParameterAdjustedValue = 0;

	UPROPERTY()
	int ChildInterfaceValue = 0;

	UPROPERTY()
	bool FirstAssigned = false;

	UPROPERTY()
	bool SecondAssigned = false;

	UPROPERTY()
	bool PolymorphicDispatchWorked = false;

	UPROPERTY()
	bool InterfaceParameterWorked = false;

	UPROPERTY()
	bool ChildCastWorked = false;

	void CaptureParent(UAngelscriptNativeParentInterface InInterface)
	{
		if (InInterface == nullptr)
		{
			return;
		}

		int Value = 5;
		InInterface.AdjustNativeValue(3, Value);
		ParameterAdjustedValue += Value;
		InterfaceParameterWorked = ParameterAdjustedValue == 50;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface FirstRef = Cast<UAngelscriptNativeParentInterface>(FirstSource);
		UAngelscriptNativeParentInterface SecondRef = Cast<UAngelscriptNativeParentInterface>(SecondSource);

		FirstAssigned = FirstRef != nullptr;
		SecondAssigned = SecondRef != nullptr;
		if (FirstRef == nullptr || SecondRef == nullptr)
		{
			return;
		}

		PolymorphicSum = FirstRef.GetNativeValue() + SecondRef.GetNativeValue();
		PolymorphicDispatchWorked = PolymorphicSum == 57;

		CurrentRef = SecondRef;
		CaptureParent(FirstRef);
		CaptureParent(CurrentRef);

		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(SecondSource);
		ChildCastWorked = ChildRef != nullptr;
		if (ChildRef != nullptr)
		{
			ChildInterfaceValue = ChildRef.GetChildValue();
		}
	}
}

bool Observe_NullSourcesDoNotAssign()
{
	UAngelscriptNativeParentInterface FirstRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	UAngelscriptNativeParentInterface SecondRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return FirstRef == nullptr && SecondRef == nullptr;
}

bool Observe_NullCaptureParentIsNoOp()
{
	UAngelscriptNativeParentInterface EmptyRef;
	return EmptyRef == nullptr;
}
