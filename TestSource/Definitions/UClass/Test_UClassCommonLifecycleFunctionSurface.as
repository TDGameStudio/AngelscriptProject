// Theme: Definitions.UClass. Positive AHUD DrawHUD plus UUserWidget lifecycle override surface.
// C++: AngelscriptCoverageUClassTests.cpp::UClassCommonLifecycleFunctionSurface
// Oracle: ReceiveDrawHUD exposes SizeX/SizeY; OnInitialized/Construct/Destruct/Tick UFunctions exist.
// Extra: unset handles are null; empty DrawHUD/OnInitialized complete. DefaultSafe.

UCLASS()
class ACoverageUClassSurfaceHUD : AHUD
{
	UFUNCTION(BlueprintOverride)
	void DrawHUD(int SizeX, int SizeY)
	{
	}
}

UCLASS()
class UCoverageUClassSurfaceWidget : UUserWidget
{
	UFUNCTION(BlueprintOverride)
	void OnInitialized()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Construct()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Destruct()
	{
	}

	UFUNCTION(BlueprintOverride)
	void Tick(FGeometry MyGeometry, float InDeltaTime)
	{
	}
}

bool Observe_SurfaceHUD_EmptyDefaultIsNull()
{
	ACoverageUClassSurfaceHUD HUD;
	return HUD == nullptr;
}

bool Observe_SurfaceWidget_EmptyDefaultIsNull()
{
	UCoverageUClassSurfaceWidget Widget;
	return Widget == nullptr;
}

int Observe_SurfaceHUD_DrawHUDEmptyCompletes(ACoverageUClassSurfaceHUD HUD)
{
	if (HUD == nullptr)
	{
		throw("TS-DEF-0154 setup: required ACoverageUClassSurfaceHUD is null");
	}
	HUD.DrawHUD(0, 0);
	return 0;
}

int Observe_SurfaceWidget_OnInitializedEmptyCompletes(UCoverageUClassSurfaceWidget Widget)
{
	if (Widget == nullptr)
	{
		throw("TS-DEF-0154 setup: required UCoverageUClassSurfaceWidget is null");
	}
	Widget.OnInitialized();
	Widget.Construct();
	Widget.Destruct();
	return 0;
}
