#pragma once

#include "CoreMinimal.h"

class UFunction;
class UObject;
class asIScriptGeneric;
struct FAngelscriptType;
struct FFuncEntry;
struct FAngelscriptFunctionSignature;

enum class EAngelscriptReflectiveFallbackEligibility : uint8
{
	Eligible,
	RejectedNullFunction,
	RejectedMissingOwningClass,
	RejectedInterfaceClass,
	RejectedCustomThunk,
	RejectedTooManyArguments,
};

ANGELSCRIPTRUNTIME_API EAngelscriptReflectiveFallbackEligibility EvaluateReflectiveFallbackEligibility(const UFunction* Function);
ANGELSCRIPTRUNTIME_API bool ShouldBindBlueprintCallableReflectiveFallback(const UFunction* Function);
ANGELSCRIPTRUNTIME_API bool InvokeReflectiveUFunctionFromGenericCall(
	asIScriptGeneric* Generic,
	UObject* TargetObject,
	UFunction* Function,
	bool bInjectMixinObject = false);
bool IsScriptDeclarationAlreadyBound(TSharedRef<FAngelscriptType> InType, const FAngelscriptFunctionSignature& Signature);

// RAII guard that enables TLS caches used by Phase 2 of Bind_Defaults:
//   - global declaration cache for IsScriptDeclarationAlreadyBound (Opt 1)
//   - per-class function-name cache for GetScriptNameForFunction prefix conflict detection (Opt 3)
// Outside of the guard scope, cached lookups fall back to the original linear / FindFunctionByName path.
struct ANGELSCRIPTRUNTIME_API FScopedBindCaches
{
	FScopedBindCaches();
	~FScopedBindCaches();

	FScopedBindCaches(const FScopedBindCaches&) = delete;
	FScopedBindCaches& operator=(const FScopedBindCaches&) = delete;
};

// Called by FAngelscriptBinds::BindGlobalFunction (or equivalent paths) to keep the TLS global-decl cache warm.
// Safe to call when no FScopedBindCaches is active (becomes a no-op).
ANGELSCRIPTRUNTIME_API void AngelscriptBindCaches_NotifyGlobalFunctionRegistered(const char* Namespace, const char* Name, const char* Declaration);

// Called by GetScriptNameForFunction as a fast path replacement for OwningClass->FindFunctionByName during Phase 2.
// Returns true when Phase 2 caches are active and populated; sets bOutExists accordingly.
// When false, callers must fall back to FindFunctionByName.
ANGELSCRIPTRUNTIME_API bool AngelscriptBindCaches_TryHasFunctionName(class UClass* OwningClass, FName FunctionName, bool& bOutExists);

ANGELSCRIPTRUNTIME_API bool BindBlueprintCallableReflectiveFallback(
	TSharedRef<FAngelscriptType> InType,
	UFunction* Function,
	FAngelscriptFunctionSignature& Signature,
	FFuncEntry& Entry);
