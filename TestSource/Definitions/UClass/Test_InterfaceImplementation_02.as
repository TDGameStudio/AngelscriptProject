// Theme: Definitions.UClass. WorldStory native interface implementer.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::InterfaceImplementation compiles then VerifyByPath.
// CSV NegativeDiagnostic is wrong for this block (script interface fail is Test_InterfaceImplementation_01).
// Oracle after BeginPlay: InterfaceCastWorked=true, NativeValue=100, NativeMarker=FromClassFeatures, AdjustedValue=12.
// Extra: unset handle is null; pre-BeginPlay InterfaceCastWorked=false NativeValue=100. FixtureIsolated.

UCLASS()
class ANativeInterfaceFeatureActor : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 100;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int AdjustedValue = 0;

	UPROPERTY()
	bool InterfaceCastWorked = false;

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
		Value += Delta;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface InterfaceRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (InterfaceRef != nullptr)
		{
			InterfaceCastWorked = true;
			NativeValue = InterfaceRef.GetNativeValue();
			InterfaceRef.SetNativeMarker(n"FromClassFeatures");

			int Value = 5;
			InterfaceRef.AdjustNativeValue(7, Value);
			AdjustedValue = Value;
		}
	}
}

bool Observe_NativeInterfaceActor_EmptyDefaultIsNull()
{
	ANativeInterfaceFeatureActor Actor;
	return Actor == nullptr;
}

int Observe_NativeInterfaceActor_NativeValueDefault(ANativeInterfaceFeatureActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0034 setup: required ANativeInterfaceFeatureActor is null");
	}
	return Actor.NativeValue;
}

bool Observe_NativeInterfaceActor_CastFlagDefaultFalse(ANativeInterfaceFeatureActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0034 setup: required ANativeInterfaceFeatureActor is null");
	}
	return Actor.InterfaceCastWorked == false;
}

int Observe_AdjustNativeValue_ZeroDeltaBoundary(ANativeInterfaceFeatureActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0034 setup: required ANativeInterfaceFeatureActor is null");
	}
	int Value = 5;
	Actor.AdjustNativeValue(0, Value);
	return Value;
}
