#include "CoreMinimal.h"
#include "AngelscriptBinds.h"

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_Skip
(
	(int32)FAngelscriptBinds::EOrder::Late,
	[]()
	{		
		FAngelscriptBinds::AddSkipEntry("StaticMesh", "GetMinLODForQualityLevels");
		FAngelscriptBinds::AddSkipEntry("StaticMesh", "SetMinLODForQualityLevels");
		FAngelscriptBinds::AddSkipEntry("SkeletalMesh", "GetMinLODForQualityLevels");
		FAngelscriptBinds::AddSkipEntry("SkeletalMesh", "SetMinLODForQualityLevels");
		FAngelscriptBinds::AddSkipEntry("SourceEffectEQPreset", "SetSettings");
		FAngelscriptBinds::AddSkipEntry("KismetMathLibrary", "ClampAngle");
		FAngelscriptBinds::AddSkipEntry("KismetMathLibrary", "FInterpTo");
		FAngelscriptBinds::AddSkipEntry("KismetMathLibrary", "GetReflectionVector");
		FAngelscriptBinds::AddSkipEntry("KismetMathLibrary", "RInterpTo");
		FAngelscriptBinds::AddSkipEntry("KismetMathLibrary", "VInterpTo");
		FAngelscriptBinds::AddSkipClass("ClothingSimulationInteractorNv");
		FAngelscriptBinds::AddSkipClass("NiagaraPreviewGrid");
		FAngelscriptBinds::AddSkipClass("GameplayCamerasSubsystem");
		FAngelscriptBinds::AddSkipClass("AsyncAction_PerformTargeting");
	}
);
