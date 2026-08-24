// Theme: Definitions.UClass. Positive AHUD DrawHUD BlueprintOverride dispatch.
// C++: AngelscriptCoverageUClassTests.cpp::UClassHUDDrawHUDReflectionDispatchBoundary
// Oracle after ReceiveDrawHUD(640, 360): DrawHUDCount=1, DrawHUDMarker=77, LastDrawHUDSizeX=640, LastDrawHUDSizeY=360.
// Extra: unset handle is null; default counters 0; DrawHUD(0,0) zero boundary. DefaultSafe.

UCLASS()
class ACoverageUClassDispatchHUD : AHUD
{
	UPROPERTY()
	int DrawHUDCount = 0;

	UPROPERTY()
	int DrawHUDMarker = 0;

	UPROPERTY()
	int LastDrawHUDSizeX = 0;

	UPROPERTY()
	int LastDrawHUDSizeY = 0;

	UFUNCTION(BlueprintOverride)
	void DrawHUD(int SizeX, int SizeY)
	{
		DrawHUDCount++;
		DrawHUDMarker = 77;
		LastDrawHUDSizeX = SizeX;
		LastDrawHUDSizeY = SizeY;
	}
}

bool Observe_DispatchHUD_EmptyDefaultIsNull()
{
	ACoverageUClassDispatchHUD HUD;
	return HUD == nullptr;
}

int Observe_DispatchHUD_CountersDefault(ACoverageUClassDispatchHUD HUD)
{
	if (HUD == nullptr)
	{
		throw("TS-DEF-0151 setup: required ACoverageUClassDispatchHUD is null");
	}
	return HUD.DrawHUDCount + HUD.DrawHUDMarker + HUD.LastDrawHUDSizeX + HUD.LastDrawHUDSizeY;
}

int Observe_DispatchHUD_ZeroSizeBoundary(ACoverageUClassDispatchHUD HUD)
{
	if (HUD == nullptr)
	{
		throw("TS-DEF-0151 setup: required ACoverageUClassDispatchHUD is null");
	}
	HUD.DrawHUD(0, 0);
	return HUD.LastDrawHUDSizeX + HUD.LastDrawHUDSizeY;
}

int Observe_DispatchHUD_Nominal(ACoverageUClassDispatchHUD HUD)
{
	if (HUD == nullptr)
	{
		throw("TS-DEF-0151 setup: required ACoverageUClassDispatchHUD is null");
	}
	HUD.DrawHUD(640, 360);
	return HUD.DrawHUDMarker;
}
