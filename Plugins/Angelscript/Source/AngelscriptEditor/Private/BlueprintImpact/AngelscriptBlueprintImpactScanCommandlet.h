#pragma once

#include "CoreMinimal.h"
#include "Commandlets/Commandlet.h"

#include "AngelscriptBlueprintImpactScanCommandlet.generated.h"

namespace AngelscriptEditor::BlueprintImpact
{
	struct FBlueprintImpactRequest;
}

UCLASS()
class ANGELSCRIPTEDITOR_API UAngelscriptBlueprintImpactScanCommandlet : public UCommandlet
{
	GENERATED_BODY()

public:
#if WITH_DEV_AUTOMATION_TESTS
	static bool BuildRequestForTesting(
		const FString& Params,
		AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest& OutRequest,
		FString& OutErrorMessage);
#endif

	virtual int32 Main(const FString& Params) override;
};
