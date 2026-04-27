#pragma once
#include "CoreMinimal.h"
#include "UObject/ObjectMacros.h"
#include "Commandlets/Commandlet.h"
#include "Engine/EngineTypes.h"
#include "AngelscriptAllScriptRootsCommandlet.generated.h"

UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptAllScriptRootsCommandlet : public UCommandlet
{
	GENERATED_BODY()

public:		
	//~ Begin UCommandlet Interface
	virtual int32 Main(const FString& Params) override;
	//~ End UCommandlet Interface
};
