// Theme: Definitions.UClass. Positive UUserWidget OnInitialized/Construct/Destruct/Tick overrides.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::WidgetLifecycle
// Oracle: NewObject widget; OnInitialized/Construct reflection write 1; Tick UFunction exists.
// Extra: unset handle is null; default counters 0; OnInitialized then Construct. DefaultSafe.

UCLASS()
class ULifecycleWidget : UUserWidget
{
	UPROPERTY()
	int ConstructCalled = 0;

	UPROPERTY()
	int DestructCalled = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int OnInitializedCalled = 0;

	UFUNCTION(BlueprintOverride)
	void OnInitialized()
	{
		OnInitializedCalled = 1;
	}

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
		ConstructCalled = 1;
	}

	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
		DestructCalled = 1;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float InDeltaTime)
	{
		TickCount++;
	}
}

bool Observe_LifecycleWidget_EmptyDefaultIsNull()
{
	ULifecycleWidget Widget;
	return Widget == nullptr;
}

int Observe_LifecycleWidget_CountersDefault(ULifecycleWidget Widget)
{
	if (Widget == nullptr)
	{
		throw("TS-DEF-0047 setup: required ULifecycleWidget is null");
	}
	return Widget.OnInitializedCalled + Widget.ConstructCalled + Widget.DestructCalled + Widget.TickCount;
}

int Observe_LifecycleWidget_OnInitializedNominal(ULifecycleWidget Widget)
{
	if (Widget == nullptr)
	{
		throw("TS-DEF-0047 setup: required ULifecycleWidget is null");
	}
	Widget.OnInitialized();
	return Widget.OnInitializedCalled;
}

int Observe_LifecycleWidget_ConstructNominal(ULifecycleWidget Widget)
{
	if (Widget == nullptr)
	{
		throw("TS-DEF-0047 setup: required ULifecycleWidget is null");
	}
	Widget.Construct();
	return Widget.ConstructCalled;
}
