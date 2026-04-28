#pragma once
#include "Engine/World.h"
#include "Engine/LevelStreaming.h"
#include "AngelscriptWorldLibrary.generated.h"

// FunctionLibraries cleanup note (mixin parity):
//
// The //UCLASS(Meta = (ScriptMixin = "UWorld")) line below is kept commented out
// because Bind_UWorld.cpp manually wraps every helper here as an explicit lambda
// Method (e.g. UWorld_.Method("TArray<ULevelStreaming> GetStreamingLevels() const",
// [...] { return UAngelscriptWorldLibrary::GetStreamingLevels(World); })). That
// hand-written path lets the binding precisely control the AS signature
// (TArray<ULevelStreaming> instead of TArray<ULevelStreaming@>, explicit const,
// etc.). Re-enabling ScriptMixin would either be silently dropped by
// IsScriptDeclarationAlreadyBound (Bind_BlueprintCallable.cpp:62-70) or, if the
// reflective signature drifts, register a duplicate overload. See
// Documents/Knowledges/ZH/Syntax_Mixin.md section 6 and
// Documents/Plans/Plan_FunctionLibrariesCleanup.md Phase 4 for the audit plan.

//UCLASS(Meta = (ScriptMixin = "UWorld"))
UCLASS()
class UAngelscriptWorldLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial))
	static TArray<ULevelStreaming*> GetStreamingLevels(const UWorld* World)
	{
		return World != nullptr ? World->GetStreamingLevels() : TArray<ULevelStreaming*>();
	}
};
