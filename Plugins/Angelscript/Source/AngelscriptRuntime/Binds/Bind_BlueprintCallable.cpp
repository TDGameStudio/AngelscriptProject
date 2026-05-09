#include "AngelscriptBinds.h"
#include "AngelscriptEngine.h"
#include "AngelscriptType.h"
#include "AngelscriptDocs.h"

#include "UObject/UObjectIterator.h"
#include "UObject/UnrealType.h"
#include "ClassGenerator/ASClass.h"

#include "BlueprintCallableReflectiveFallback.h"
#include "Helper_FunctionSignature.h"
#include "Bind_BlueprintTypePrep.h"

extern void RegisterBlueprintEventByScriptName(UClass* Class, const FString& ScriptName, UFunction* Function);

// Bind a native function to angelscript, provided all
// argument and return types are known as FAngelscriptTypes.
void BindBlueprintCallable(
	TSharedRef<FAngelscriptType> InType,
	UFunction* Function,
	FAngelscriptMethodBind& DBBind
#if !AS_USE_BIND_DB
	, const TCHAR* OverrideName
#endif
)
{
#if !AS_USE_BIND_DB
	// Don't bind functions that aren't native
	if (!Function->HasAnyFunctionFlags(FUNC_Native))
		return;
	if (FAngelscriptBinds::ShouldSkipBlueprintCallableFunction(Function))
		return;
#endif

	UClass* OwningClass = CastChecked<UClass>(Function->GetOuter());
	FFuncEntry* Entry = nullptr;

	if (OwningClass != nullptr)
	{
		FString Name = Function->GetFName().ToString();
		auto* map = FAngelscriptBinds::GetClassFuncMaps().Find(OwningClass);

		if (map)
			Entry = map->Find(Name);
	}

	// Don't bind functions without a native pointer
	if (Entry == nullptr)
		return;

#if AS_USE_BIND_DB
	FAngelscriptFunctionSignature Signature;
	Signature.InitFromDB(InType, Function, DBBind, /* bInitTypes= */ false);

#elif !AS_USE_BIND_DB
	FAngelscriptFunctionSignature Signature(InType, Function, OverrideName);

	// Don't bind things that have types that are unknown to us
	if (!Signature.bAllTypesValid)
		return;
#endif

	if (BindBlueprintCallableReflectionFallback(InType, Signature))
	{
		Entry->bReflectiveFallbackBound = false;

#if !AS_USE_BIND_DB
		Signature.WriteToDB(DBBind);
#endif
		return;
	}

	auto* DirectNativePointer = &Entry->FuncPtr;
	const bool bHasDirectNativePointer = DirectNativePointer != nullptr && DirectNativePointer->IsBound();
	if (!bHasDirectNativePointer)
	{
		if (!BindBlueprintCallableReflectionFallback(InType, Function, Signature, *Entry))
			return;

#if AS_CAN_GENERATE_JIT
#if AS_USE_BIND_DB
		SCRIPT_NATIVE_UFUNCTION(Function, FPackageName::ObjectPathToObjectName(DBBind.UnrealPath), false);
#else
		SCRIPT_NATIVE_UFUNCTION(Function, Function->GetName(), false);
#endif
#endif

#if !AS_USE_BIND_DB
		Signature.WriteToDB(DBBind);
#endif
		return;
	}

	Entry->bReflectiveFallbackBound = false;

	// FGenericFuncPtr is a copy of asSFuncPtr, so do a direct memcpy
	asSFuncPtr ASFuncPtr;
	static_assert(sizeof(asSFuncPtr) == sizeof(FGenericFuncPtr), "FGenericFuncPtr must be the same struct as asSFuncPtr");
	FMemory::Memcpy(&ASFuncPtr, DirectNativePointer, sizeof(asSFuncPtr));

	// Actually bind into angelscript engine
	if (Signature.bStaticInScript)
	{
		// Some functions have a meta tag to put them in global scope
		if (Signature.bGlobalScope)
		{
			//int GlobalFunctionId = FAngelscriptBinds::BindGlobalFunction(Signature.Declaration, ASFuncPtr, FuncInMap->Value);			
			int GlobalFunctionId = FAngelscriptBinds::BindGlobalFunction(Signature.Declaration, ASFuncPtr, Entry->Caller);
			Signature.ModifyScriptFunction(GlobalFunctionId);
		}

		// Static functions should be bound as a global function in a namespace
		FAngelscriptBinds::FNamespace ns(Signature.ClassName);
		//int FunctionId = FAngelscriptBinds::BindGlobalFunction(Signature.Declaration, ASFuncPtr, FuncInMap->Value);
		int FunctionId = FAngelscriptBinds::BindGlobalFunction(Signature.Declaration, ASFuncPtr, Entry->Caller);
		Signature.ModifyScriptFunction(FunctionId);
	}
	else if (Signature.bStaticInUnreal)
	{
		// This is a static function converted through mixin to a script member function
		int FunctionId = FAngelscriptBinds::BindMethodDirect
		(
			Signature.ClassName,
			Signature.Declaration, ASFuncPtr,
			asCALL_CDECL_OBJFIRST, Entry->Caller /*FuncInMap->Value*/
		);
		Signature.ModifyScriptFunction(FunctionId);
	}
	else
	{
		//auto caller = ASAutoCaller::FunctionCaller::Make();
		//caller.MethodPtr = DirectNativePointer;
		// Member methods should be bound as THISCALL		
		int FunctionId = FAngelscriptBinds::BindMethodDirect
		(
			InType->GetAngelscriptTypeName(),
			Signature.Declaration, ASFuncPtr, asCALL_THISCALL, Entry->Caller /*FuncInMap->Value*/
		);
		Signature.ModifyScriptFunction(FunctionId);
	}

#if AS_CAN_GENERATE_JIT
#if AS_USE_BIND_DB
	SCRIPT_NATIVE_UFUNCTION(Function, FPackageName::ObjectPathToObjectName(DBBind.UnrealPath), Signature.bTrivial);
#else
	SCRIPT_NATIVE_UFUNCTION(Function, Function->GetName(), Signature.bTrivial);
#endif
#endif

#if !AS_USE_BIND_DB
	Signature.WriteToDB(DBBind);
#endif
}

#if !AS_USE_BIND_DB && WITH_EDITOR
// Prepare-only entry point used by the Bind_Defaults Late+100 Phase 2A.
// Performs all read-only checks and builds Signature + CachedEntry into Prep.
// On success, sets Prep.Kind = Callable. On any rejection, leaves
// Prep.Kind = Skip so Phase 2B can short-circuit. Read-only with respect to
// the AS Engine and the binding registries (UE reflection reads only).
//
// The NameArray prewarm in Bind_BlueprintType.cpp Phase 2A guards against
// FindFunctionByName lazy mutation reaching this path concurrently.
void BindBlueprintCallable_Prepare(
	TSharedRef<FAngelscriptType> InType,
	UFunction* Function,
	FUFunctionBindPrep& Prep)
{
	Prep.Function = Function;
	Prep.Kind = FUFunctionBindPrep::EKind::Skip;
	Prep.CachedEntry = nullptr;

	if (Function == nullptr)
	{
		return;
	}

	if (!Function->HasAnyFunctionFlags(FUNC_Native))
	{
		return;
	}
	if (FAngelscriptBinds::ShouldSkipBlueprintCallableFunction(Function))
	{
		return;
	}

	UClass* OwningClass = CastChecked<UClass>(Function->GetOuter());
	FFuncEntry* Entry = nullptr;
	if (OwningClass != nullptr)
	{
		FString Name = Function->GetFName().ToString();
		auto* Map = FAngelscriptBinds::GetClassFuncMaps().Find(OwningClass);
		if (Map)
			Entry = Map->Find(Name);
	}
	if (Entry == nullptr)
	{
		return;
	}

	Prep.Signature = FAngelscriptFunctionSignature(InType, Function, /*OverrideName=*/nullptr);
	if (!Prep.Signature.bAllTypesValid)
	{
		return;
	}

	Prep.CachedEntry = Entry;
	Prep.Kind = FUFunctionBindPrep::EKind::Callable;
}

// Commit-only entry point used by the Bind_Defaults Late+100 Phase 2A/2B split
// (see Plan_BindParallelization). The caller is responsible for filling Prep with:
//   - Function           (UFunction*, non-null, FUNC_Native, not skipped)
//   - Signature          (already InitFromFunction'd, bAllTypesValid == true)
//   - CachedEntry        (FAngelscriptBinds::GetClassFuncMaps lookup result, non-null)
//   - Kind == Callable
// This function only performs the AS Engine register half (must run on GameThread).
void BindBlueprintCallable_FromPrep(
	TSharedRef<FAngelscriptType> InType,
	FUFunctionBindPrep& Prep,
	FAngelscriptMethodBind& DBBind)
{
	UFunction* Function = Prep.Function;
	FFuncEntry* Entry = Prep.CachedEntry;
	FAngelscriptFunctionSignature& Signature = Prep.Signature;

	if (Function == nullptr || Entry == nullptr)
	{
		return;
	}

	if (BindBlueprintCallableReflectionFallback(InType, Signature))
	{
		Entry->bReflectiveFallbackBound = false;
		Signature.WriteToDB(DBBind);
		return;
	}

	auto* DirectNativePointer = &Entry->FuncPtr;
	const bool bHasDirectNativePointer = DirectNativePointer != nullptr && DirectNativePointer->IsBound();
	if (!bHasDirectNativePointer)
	{
		if (!BindBlueprintCallableReflectionFallback(InType, Function, Signature, *Entry))
		{
			return;
		}

#if AS_CAN_GENERATE_JIT
		SCRIPT_NATIVE_UFUNCTION(Function, Function->GetName(), false);
#endif

		Signature.WriteToDB(DBBind);
		return;
	}

	Entry->bReflectiveFallbackBound = false;

	asSFuncPtr ASFuncPtr;
	static_assert(sizeof(asSFuncPtr) == sizeof(FGenericFuncPtr), "FGenericFuncPtr must be the same struct as asSFuncPtr");
	FMemory::Memcpy(&ASFuncPtr, DirectNativePointer, sizeof(asSFuncPtr));

	if (Signature.bStaticInScript)
	{
		if (Signature.bGlobalScope)
		{
			int GlobalFunctionId = FAngelscriptBinds::BindGlobalFunction(Signature.Declaration, ASFuncPtr, Entry->Caller);
			Signature.ModifyScriptFunction(GlobalFunctionId);
		}

		FAngelscriptBinds::FNamespace ns(Signature.ClassName);
		int FunctionId = FAngelscriptBinds::BindGlobalFunction(Signature.Declaration, ASFuncPtr, Entry->Caller);
		Signature.ModifyScriptFunction(FunctionId);
	}
	else if (Signature.bStaticInUnreal)
	{
		int FunctionId = FAngelscriptBinds::BindMethodDirect(
			Signature.ClassName,
			Signature.Declaration, ASFuncPtr,
			asCALL_CDECL_OBJFIRST, Entry->Caller);
		Signature.ModifyScriptFunction(FunctionId);
	}
	else
	{
		int FunctionId = FAngelscriptBinds::BindMethodDirect(
			InType->GetAngelscriptTypeName(),
			Signature.Declaration, ASFuncPtr,
			asCALL_THISCALL, Entry->Caller);
		Signature.ModifyScriptFunction(FunctionId);
	}

#if AS_CAN_GENERATE_JIT
	SCRIPT_NATIVE_UFUNCTION(Function, Function->GetName(), Signature.bTrivial);
#endif

	Signature.WriteToDB(DBBind);
}
#endif // !AS_USE_BIND_DB && WITH_EDITOR
