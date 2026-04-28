#include "BlueprintCallableReflectiveFallback.h"

#include "Core/AngelscriptBinds.h"
#include "Core/AngelscriptEngine.h"
#include "Core/FunctionCallers.h"
#include "Binds/Helper_FunctionSignature.h"

#include "UObject/UnrealType.h"
#include "UObject/Class.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_generic.h"
#include "source/as_scriptfunction.h"
#include "EndAngelscriptHeaders.h"

namespace
{
	FString GetScriptTypeSignatureKey(FAngelscriptTypeUsage Usage, FAngelscriptType::EAngelscriptDeclarationMode Mode)
	{
		if (!Usage.IsValid())
		{
			return TEXT("void");
		}

		// AngelScript does not distinguish top-level const value parameters for overload
		// identity. Keep reference constness because const refs are distinct call contracts.
		if (!Usage.bIsReference)
		{
			Usage.bIsConst = false;
		}

		return Usage.GetAngelscriptDeclaration(Mode);
	}

	FString BuildScriptFunctionSignatureKey(
		const FString& ScriptName,
		const FAngelscriptTypeUsage& ReturnType,
		const TArrayView<const FAngelscriptTypeUsage> ArgumentTypes,
		bool bConstMethod)
	{
		FString Key = GetScriptTypeSignatureKey(ReturnType, FAngelscriptType::EAngelscriptDeclarationMode::FunctionReturnValue);
		Key += TEXT(" ");
		Key += ScriptName;
		Key += TEXT("(");
		for (int32 ArgumentIndex = 0, ArgumentCount = ArgumentTypes.Num(); ArgumentIndex < ArgumentCount; ++ArgumentIndex)
		{
			if (ArgumentIndex != 0)
			{
				Key += TEXT(",");
			}

			Key += GetScriptTypeSignatureKey(ArgumentTypes[ArgumentIndex], FAngelscriptType::EAngelscriptDeclarationMode::FunctionArgument);
		}
		Key += TEXT(")");
		if (bConstMethod)
		{
			Key += TEXT(" const");
		}
		return Key;
	}

	bool SignatureDeclaresConstMethod(const FAngelscriptFunctionSignature& Signature)
	{
		return Signature.Declaration.Contains(TEXT(") const"));
	}

	FString BuildScriptFunctionSignatureKey(const FAngelscriptFunctionSignature& Signature)
	{
		return BuildScriptFunctionSignatureKey(
			Signature.ScriptName,
			Signature.ReturnType,
			MakeArrayView(Signature.ArgumentTypes),
			SignatureDeclaresConstMethod(Signature));
	}

	FString BuildRegisteredScriptFunctionSignatureKey(asIScriptFunction* Function)
	{
		if (Function == nullptr || Function->GetName() == nullptr)
		{
			return FString();
		}

		TArray<FAngelscriptTypeUsage, TInlineAllocator<8>> ArgumentTypes;
		const asUINT ArgumentCount = Function->GetParamCount();
		for (asUINT ArgumentIndex = 0; ArgumentIndex < ArgumentCount; ++ArgumentIndex)
		{
			ArgumentTypes.Add(FAngelscriptTypeUsage::FromParam(Function, static_cast<int32>(ArgumentIndex)));
		}

		return BuildScriptFunctionSignatureKey(
			UTF8_TO_TCHAR(Function->GetName()),
			FAngelscriptTypeUsage::FromReturn(Function),
			MakeArrayView(ArgumentTypes),
			Function->IsReadOnly());
	}

	bool RegisteredScriptFunctionMatchesSignature(asIScriptFunction* Function, const FString& SignatureKey)
	{
		return BuildRegisteredScriptFunctionSignatureKey(Function) == SignatureKey;
	}

	// ---- Opt 1: TLS cache for IsScriptDeclarationAlreadyBound's global-function scan ----
	// Key: namespace (UTF-8). Value: registered normalized signatures in that namespace.
	struct FGlobalDeclCacheEntry
	{
		TSet<FString> SignatureKeys;
	};

	struct FBindCachesTLS
	{
		// Opt 1: namespace -> (names, decls)
		TMap<FString, FGlobalDeclCacheEntry> GlobalDecls;
		asUINT LastSyncedGlobalFunctionCount = 0;
		bool bGlobalDeclsActive = false;

		// Opt 3: per-class function-name cache (includes super chain for parity with FindFunctionByName).
		TMap<UClass*, TSet<FName>> ClassFuncNames;
		bool bClassFuncNamesActive = false;
	};

	thread_local FBindCachesTLS* GBindCachesTLS = nullptr;

	// Bring the TLS global-decl cache up to date with the AS engine's current global function list.
	// We only ever add — Phase 2 monotonically grows the global function set.
	void SyncGlobalDeclCacheFromEngine(asIScriptEngine* ScriptEngine)
	{
		if (GBindCachesTLS == nullptr || !GBindCachesTLS->bGlobalDeclsActive || ScriptEngine == nullptr)
		{
			return;
		}

		const asUINT Count = ScriptEngine->GetGlobalFunctionCount();
		if (Count == GBindCachesTLS->LastSyncedGlobalFunctionCount)
		{
			return;
		}

		for (asUINT Index = GBindCachesTLS->LastSyncedGlobalFunctionCount; Index < Count; ++Index)
		{
			asIScriptFunction* Func = ScriptEngine->GetGlobalFunctionByIndex(Index);
			if (Func == nullptr)
			{
				continue;
			}
			const char* NsRaw = Func->GetNamespace();

			const FString NsStr = NsRaw != nullptr ? FString(UTF8_TO_TCHAR(NsRaw)) : FString();
			FGlobalDeclCacheEntry& Entry = GBindCachesTLS->GlobalDecls.FindOrAdd(NsStr);
			Entry.SignatureKeys.Add(BuildRegisteredScriptFunctionSignatureKey(Func));
		}

		GBindCachesTLS->LastSyncedGlobalFunctionCount = Count;
	}
}

namespace
{
	constexpr int32 BlueprintCallableReflectiveFallbackMaxArgs = 16;
	const FName NAME_BlueprintCallableReflectiveFallback_CustomThunk(TEXT("CustomThunk"));

	struct FReflectiveOutReference
	{
		FProperty* Property = nullptr;
		void* ScriptValue = nullptr;
	};

	struct FBlueprintCallableReflectiveSignature
	{
		FAngelscriptTypeUsage ReturnType;
		FAngelscriptTypeUsage Arguments[BlueprintCallableReflectiveFallbackMaxArgs];
		int32 ArgCount = 0;
		UFunction* UnrealFunction = nullptr;
		UObject* StaticObject = nullptr;
		bool bInjectMixinObject = false;
		bool bInitReturn = false;
		bool bZeroReturnPtr = false;
	};

	int32 GetNonReturnParameterCount(const UFunction* Function)
	{
		int32 ParameterCount = 0;
		for (TFieldIterator<FProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It)
		{
			if (!It->HasAnyPropertyFlags(CPF_ReturnParm))
			{
				++ParameterCount;
			}
		}
		return ParameterCount;
	}

	void InitializeParameterBuffer(const UFunction* Function, uint8* Buffer)
	{
		FMemory::Memzero(Buffer, Function->ParmsSize);
		for (TFieldIterator<FProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It)
		{
			It->InitializeValue_InContainer(Buffer);
		}
	}

	void DestroyParameterBuffer(const UFunction* Function, uint8* Buffer)
	{
		for (TFieldIterator<FProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It)
		{
			It->DestroyValue_InContainer(Buffer);
		}
	}

	void* ResolveScriptArgumentAddress(const FProperty* Property, void* ScriptArgumentAddress)
	{
		if (Property != nullptr && Property->HasAnyPropertyFlags(CPF_ReferenceParm))
		{
			return ScriptArgumentAddress != nullptr ? *(void**)ScriptArgumentAddress : nullptr;
		}

		return ScriptArgumentAddress;
	}

	void CallBlueprintCallableReflectiveFallback(asIScriptGeneric* InGeneric)
	{
		auto* Generic = static_cast<asCGeneric*>(InGeneric);
		auto* Function = static_cast<asCScriptFunction*>(Generic->GetFunction());
		auto* Signature = static_cast<FBlueprintCallableReflectiveSignature*>(Function->GetUserData());

		if (Signature == nullptr || Signature->UnrealFunction == nullptr)
		{
			FAngelscriptEngine::Throw("Attempted reflective BlueprintCallable dispatch without a bound UFunction.");
			return;
		}

		UObject* TargetObject = Signature->StaticObject != nullptr ? Signature->StaticObject : static_cast<UObject*>(Generic->GetObject());
		if (TargetObject == nullptr)
		{
			FAngelscriptEngine::Throw("Attempted reflective BlueprintCallable dispatch without a target object.");
			return;
		}

		InvokeReflectiveUFunctionFromGenericCall(Generic, TargetObject, Signature->UnrealFunction, Signature->bInjectMixinObject);
	}

	bool BindReflectiveFunction(
		TSharedRef<FAngelscriptType> InType,
		FAngelscriptFunctionSignature& Signature,
		FBlueprintCallableReflectiveSignature* ReflectiveSignature)
	{
		if (Signature.bStaticInScript)
		{
			ReflectiveSignature->StaticObject = InType->GetClass(FAngelscriptTypeUsage::DefaultUsage)->GetDefaultObject();
			if (ReflectiveSignature->StaticObject == nullptr)
			{
				return false;
			}

			if (Signature.bGlobalScope)
			{
				const int32 GlobalFunctionId = FAngelscriptBinds::BindGlobalFunctionDirect(
					Signature.Declaration,
					asFUNCTION(CallBlueprintCallableReflectiveFallback),
					asCALL_GENERIC,
					ASAutoCaller::FunctionCaller::Make(),
					ReflectiveSignature);
				Signature.ModifyScriptFunction(GlobalFunctionId);
			}

			FAngelscriptBinds::FNamespace Namespace(Signature.ClassName);
			const int32 NamespacedFunctionId = FAngelscriptBinds::BindGlobalFunctionDirect(
				Signature.Declaration,
				asFUNCTION(CallBlueprintCallableReflectiveFallback),
				asCALL_GENERIC,
				ASAutoCaller::FunctionCaller::Make(),
				ReflectiveSignature);
			Signature.ModifyScriptFunction(NamespacedFunctionId);
			return true;
		}

		if (Signature.bStaticInUnreal)
		{
			ReflectiveSignature->StaticObject = InType->GetClass(FAngelscriptTypeUsage::DefaultUsage)->GetDefaultObject();
			if (ReflectiveSignature->StaticObject == nullptr)
			{
				return false;
			}

			ReflectiveSignature->bInjectMixinObject = true;
			const int32 FunctionId = FAngelscriptBinds::BindMethodDirect(
				Signature.ClassName,
				Signature.Declaration,
				asFUNCTION(CallBlueprintCallableReflectiveFallback),
				asCALL_GENERIC,
				ASAutoCaller::FunctionCaller::Make(),
				ReflectiveSignature);
			Signature.ModifyScriptFunction(FunctionId);
			return true;
		}

		const int32 FunctionId = FAngelscriptBinds::BindMethodDirect(
			InType->GetAngelscriptTypeName(),
			Signature.Declaration,
			asFUNCTION(CallBlueprintCallableReflectiveFallback),
			asCALL_GENERIC,
			ASAutoCaller::FunctionCaller::Make(),
			ReflectiveSignature);
		Signature.ModifyScriptFunction(FunctionId);
		return true;
	}

	bool IsScriptDeclarationAlreadyBoundImpl(TSharedRef<FAngelscriptType> InType, const FAngelscriptFunctionSignature& Signature)
	{
		auto* ScriptEngine = FAngelscriptEngine::Get().GetScriptEngine();
		if (ScriptEngine == nullptr)
		{
			return false;
		}

		const FString SignatureKey = BuildScriptFunctionSignatureKey(Signature);
		auto HasGlobalDeclaration = [&](const FString& Namespace) -> bool
		{
			// Opt 1 fast path: consult TLS cache populated during Phase 2.
			if (GBindCachesTLS != nullptr && GBindCachesTLS->bGlobalDeclsActive)
			{
				SyncGlobalDeclCacheFromEngine(ScriptEngine);
				if (const FGlobalDeclCacheEntry* Entry = GBindCachesTLS->GlobalDecls.Find(Namespace))
				{
					// ScriptName is intentionally not enough here: reflected ScriptName aliases can
					// expose multiple overloads under the same callable name.
					if (Entry->SignatureKeys.Contains(SignatureKey))
					{
						return true;
					}
				}
				return false;
			}

			const FTCHARToUTF8 Utf8Namespace(*Namespace);
			for (asUINT FunctionIndex = 0, FunctionCount = ScriptEngine->GetGlobalFunctionCount(); FunctionIndex < FunctionCount; ++FunctionIndex)
			{
				asIScriptFunction* CandidateFunction = ScriptEngine->GetGlobalFunctionByIndex(FunctionIndex);
				if (CandidateFunction == nullptr)
				{
					continue;
				}

				const char* CandidateNamespace = CandidateFunction->GetNamespace();
				const bool bNamespaceMatches = Namespace.IsEmpty()
					? CandidateNamespace == nullptr || CandidateNamespace[0] == '\0'
					: FCStringAnsi::Strcmp(CandidateNamespace != nullptr ? CandidateNamespace : "", Utf8Namespace.Get()) == 0;
				if (!bNamespaceMatches)
				{
					continue;
				}

				if (RegisteredScriptFunctionMatchesSignature(CandidateFunction, SignatureKey))
				{
					return true;
				}
			}

			return false;
		};

		if (Signature.bStaticInScript)
		{
			if (HasGlobalDeclaration(Signature.ClassName))
			{
				return true;
			}

			if (HasGlobalDeclaration(FString()))
			{
				return true;
			}

			return false;
		}

		const FString& ScriptTypeName = Signature.bStaticInUnreal ? Signature.ClassName : InType->GetAngelscriptTypeName();
		const FTCHARToUTF8 Utf8TypeName(*ScriptTypeName);
		asITypeInfo* TypeInfo = ScriptEngine->GetTypeInfoByName(Utf8TypeName.Get());
		if (TypeInfo == nullptr)
		{
			return false;
		}

		for (asUINT MethodIndex = 0, MethodCount = TypeInfo->GetMethodCount(); MethodIndex < MethodCount; ++MethodIndex)
		{
			if (RegisteredScriptFunctionMatchesSignature(TypeInfo->GetMethodByIndex(MethodIndex), SignatureKey))
			{
				return true;
			}
		}

		return false;
	}
}

bool IsScriptDeclarationAlreadyBound(TSharedRef<FAngelscriptType> InType, const FAngelscriptFunctionSignature& Signature)
{
	return IsScriptDeclarationAlreadyBoundImpl(InType, Signature);
}

EAngelscriptReflectiveFallbackEligibility EvaluateReflectiveFallbackEligibility(const UFunction* Function)
{
	if (Function == nullptr)
	{
		return EAngelscriptReflectiveFallbackEligibility::RejectedNullFunction;
	}

	const UClass* OwningClass = Function->GetOuterUClass();
	if (OwningClass == nullptr)
	{
		return EAngelscriptReflectiveFallbackEligibility::RejectedMissingOwningClass;
	}

	if (OwningClass->HasAnyClassFlags(CLASS_Interface))
	{
		return EAngelscriptReflectiveFallbackEligibility::RejectedInterfaceClass;
	}

	if (Function->HasMetaData(NAME_BlueprintCallableReflectiveFallback_CustomThunk))
	{
		return EAngelscriptReflectiveFallbackEligibility::RejectedCustomThunk;
	}

	if (GetNonReturnParameterCount(Function) > BlueprintCallableReflectiveFallbackMaxArgs)
	{
		return EAngelscriptReflectiveFallbackEligibility::RejectedTooManyArguments;
	}

	return EAngelscriptReflectiveFallbackEligibility::Eligible;
}

bool ShouldBindBlueprintCallableReflectiveFallback(const UFunction* Function)
{
	return EvaluateReflectiveFallbackEligibility(Function) == EAngelscriptReflectiveFallbackEligibility::Eligible;
}

bool InvokeReflectiveUFunctionFromGenericCall(
	asIScriptGeneric* InGeneric,
	UObject* TargetObject,
	UFunction* Function,
	bool bInjectMixinObject)
{
	auto* Generic = static_cast<asCGeneric*>(InGeneric);
	if (Generic == nullptr || TargetObject == nullptr || Function == nullptr)
	{
		return false;
	}

	uint8* ParameterBuffer = static_cast<uint8*>(FMemory_Alloca(Function->ParmsSize));
	InitializeParameterBuffer(Function, ParameterBuffer);

	FReflectiveOutReference OutReferences[BlueprintCallableReflectiveFallbackMaxArgs];
	int32 OutReferenceCount = 0;
	int32 ScriptArgIndex = 0;
	bool bInjectedMixinObject = false;

	for (TFieldIterator<FProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It)
	{
		FProperty* Property = *It;
		if (Property->HasAnyPropertyFlags(CPF_ReturnParm))
		{
			continue;
		}

		void* Destination = Property->ContainerPtrToValuePtr<void>(ParameterBuffer);
		if (bInjectMixinObject && !bInjectedMixinObject)
		{
			UObject* MixinObject = static_cast<UObject*>(Generic->GetObject());
			Property->CopySingleValue(Destination, &MixinObject);
			bInjectedMixinObject = true;
			continue;
		}

		if (!ensure(ScriptArgIndex < Generic->GetArgCount()))
		{
			DestroyParameterBuffer(Function, ParameterBuffer);
			return false;
		}

		void* ScriptArgumentAddress = Generic->GetAddressOfArg(ScriptArgIndex);
		void* SourceAddress = ResolveScriptArgumentAddress(Property, ScriptArgumentAddress);
		Property->CopySingleValue(Destination, SourceAddress);

		if (Property->HasAnyPropertyFlags(CPF_ReferenceParm) && !Property->HasAnyPropertyFlags(CPF_ConstParm) && ensure(OutReferenceCount < BlueprintCallableReflectiveFallbackMaxArgs))
		{
			OutReferences[OutReferenceCount++] = { Property, SourceAddress };
		}

		++ScriptArgIndex;
	}

	TargetObject->ProcessEvent(Function, ParameterBuffer);

	for (int32 OutReferenceIndex = 0; OutReferenceIndex < OutReferenceCount; ++OutReferenceIndex)
	{
		const FReflectiveOutReference& OutReference = OutReferences[OutReferenceIndex];
		if (ensure(OutReference.Property != nullptr && OutReference.ScriptValue != nullptr))
		{
			OutReference.Property->CopySingleValue(
				OutReference.ScriptValue,
				OutReference.Property->ContainerPtrToValuePtr<void>(ParameterBuffer));
		}
	}

	if (FProperty* ReturnProperty = Function->GetReturnProperty())
	{
		void* ReturnDestination = Generic->GetAddressOfReturnLocation();
		if (ReturnDestination != nullptr)
		{
			ReturnProperty->InitializeValue(ReturnDestination);
			ReturnProperty->CopySingleValue(
				ReturnDestination,
				ReturnProperty->ContainerPtrToValuePtr<void>(ParameterBuffer));
		}
	}

	DestroyParameterBuffer(Function, ParameterBuffer);
	return true;
}

bool BindBlueprintCallableReflectiveFallback(
	TSharedRef<FAngelscriptType> InType,
	UFunction* Function,
	FAngelscriptFunctionSignature& Signature,
	FFuncEntry& Entry)
{
	Entry.bReflectiveFallbackBound = false;

	if (!ShouldBindBlueprintCallableReflectiveFallback(Function))
	{
		return false;
	}

	if (!Signature.bAllTypesValid || Signature.ArgumentTypes.Num() > BlueprintCallableReflectiveFallbackMaxArgs)
	{
		return false;
	}

	if (IsScriptDeclarationAlreadyBound(InType, Signature))
	{
		return false;
	}

	auto* ReflectiveSignature = new FBlueprintCallableReflectiveSignature();
	ReflectiveSignature->UnrealFunction = Function;
	ReflectiveSignature->ArgCount = Signature.ArgumentTypes.Num();
	ReflectiveSignature->ReturnType = Signature.ReturnType;

	for (int32 ArgumentIndex = 0; ArgumentIndex < ReflectiveSignature->ArgCount; ++ArgumentIndex)
	{
		ReflectiveSignature->Arguments[ArgumentIndex] = Signature.ArgumentTypes[ArgumentIndex];
	}

	if (ReflectiveSignature->ReturnType.IsValid())
	{
		ReflectiveSignature->bInitReturn = ReflectiveSignature->ReturnType.CanConstruct() && ReflectiveSignature->ReturnType.NeedConstruct();
		ReflectiveSignature->bZeroReturnPtr = !ReflectiveSignature->bInitReturn && ReflectiveSignature->ReturnType.Type->IsObjectPointer();
	}

	if (!BindReflectiveFunction(InType, Signature, ReflectiveSignature))
	{
		delete ReflectiveSignature;
		return false;
	}

	Entry.bReflectiveFallbackBound = true;
	return true;
}

// ---- Opt 1 / Opt 3: Scoped bind caches used during Phase 2 of Bind_Defaults ----
FScopedBindCaches::FScopedBindCaches()
{
	// Nested guards would silently clobber TLS state; forbid re-entry.
	checkf(GBindCachesTLS == nullptr, TEXT("FScopedBindCaches is not re-entrant"));

	static thread_local FBindCachesTLS TlsStorage;
	TlsStorage.GlobalDecls.Reset();
	TlsStorage.ClassFuncNames.Reset();
	TlsStorage.LastSyncedGlobalFunctionCount = 0;
	TlsStorage.bGlobalDeclsActive = true;
	TlsStorage.bClassFuncNamesActive = true;

	GBindCachesTLS = &TlsStorage;
}

FScopedBindCaches::~FScopedBindCaches()
{
	if (GBindCachesTLS == nullptr)
	{
		return;
	}

	GBindCachesTLS->bGlobalDeclsActive = false;
	GBindCachesTLS->bClassFuncNamesActive = false;
	GBindCachesTLS->GlobalDecls.Reset();
	GBindCachesTLS->ClassFuncNames.Reset();
	GBindCachesTLS = nullptr;
}

void AngelscriptBindCaches_NotifyGlobalFunctionRegistered(const char* /*Namespace*/, const char* /*Name*/, const char* /*Declaration*/)
{
	// Deprecated stub: cache is refreshed lazily from ScriptEngine->GetGlobalFunction* on query.
	// Retained for ABI/header compatibility.
}

bool AngelscriptBindCaches_TryHasFunctionName(UClass* OwningClass, FName FunctionName, bool& bOutExists)
{
	if (GBindCachesTLS == nullptr || !GBindCachesTLS->bClassFuncNamesActive || OwningClass == nullptr)
	{
		return false;
	}

	TSet<FName>* NameSet = GBindCachesTLS->ClassFuncNames.Find(OwningClass);
	if (NameSet == nullptr)
	{
		// Lazily populate: enumerate own + super chain to match FindFunctionByName semantics.
		TSet<FName>& NewSet = GBindCachesTLS->ClassFuncNames.Add(OwningClass);
		for (UClass* C = OwningClass; C != nullptr; C = C->GetSuperClass())
		{
			for (TFieldIterator<UFunction> It(C, EFieldIteratorFlags::ExcludeSuper); It; ++It)
			{
				NewSet.Add(It->GetFName());
			}
		}
		NameSet = &NewSet;
	}

	bOutExists = NameSet->Contains(FunctionName);
	return true;
}
