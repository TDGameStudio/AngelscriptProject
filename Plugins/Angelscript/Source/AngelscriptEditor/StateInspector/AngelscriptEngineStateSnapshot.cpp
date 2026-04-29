#include "StateInspector/AngelscriptEngineStateSnapshot.h"

#include "AngelscriptEngine.h"
#include "Core/AngelscriptBindDatabase.h"
#include "Core/AngelscriptBinds.h"
#include "Core/AngelscriptType.h"
#include "Core/FunctionCallers.h"

#include "Misc/DateTime.h"
#include "Misc/PackageName.h"
#include "UObject/UnrealType.h"

namespace
{
	FString BoolToString(const bool bValue)
	{
		return bValue ? TEXT("true") : TEXT("false");
	}

	FString AnsiToString(const char* Value)
	{
		return Value != nullptr ? FString(ANSI_TO_TCHAR(Value)) : FString();
	}

	FString JoinStrings(const TArray<FString>& Values)
	{
		return FString::Join(Values, TEXT("; "));
	}

	FString JoinSearchText(const TArray<FString>& Values)
	{
		return FString::Join(Values, TEXT("\n"));
	}

	void AddFlag(TArray<FString>& Flags, const bool bValue, const TCHAR* Name)
	{
		if (bValue)
		{
			Flags.Add(Name);
		}
	}

	FString GetCreationModeString(const EAngelscriptEngineCreationMode CreationMode)
	{
		switch (CreationMode)
		{
		case EAngelscriptEngineCreationMode::Full:
			return TEXT("Full");
		case EAngelscriptEngineCreationMode::Clone:
			return TEXT("Clone");
		default:
			return TEXT("Unknown");
		}
	}

	FString GetTypeUsageString(const FAngelscriptTypeUsage& TypeUsage)
	{
		return TypeUsage.IsValid() ? TypeUsage.GetAngelscriptDeclaration() : FString();
	}

	FString FormatArguments(const TArray<FAngelscriptArgumentDesc>& Arguments)
	{
		TArray<FString> ArgumentParts;
		ArgumentParts.Reserve(Arguments.Num());
		for (const FAngelscriptArgumentDesc& Argument : Arguments)
		{
			const FString TypeName = GetTypeUsageString(Argument.Type);
			if (Argument.ArgumentName.IsEmpty())
			{
				ArgumentParts.Add(TypeName);
			}
			else
			{
				ArgumentParts.Add(FString::Printf(TEXT("%s %s"), *TypeName, *Argument.ArgumentName));
			}
		}

		return FString::Join(ArgumentParts, TEXT(", "));
	}

	FString FormatPropertyFlags(const FAngelscriptPropertyDesc& PropertyDesc)
	{
		TArray<FString> Flags;
		AddFlag(Flags, PropertyDesc.bBlueprintReadable, TEXT("BlueprintRead"));
		AddFlag(Flags, PropertyDesc.bBlueprintWritable, TEXT("BlueprintWrite"));
		AddFlag(Flags, PropertyDesc.bEditableOnDefaults, TEXT("EditDefaults"));
		AddFlag(Flags, PropertyDesc.bEditableOnInstance, TEXT("EditInstance"));
		AddFlag(Flags, PropertyDesc.bTransient, TEXT("Transient"));
		AddFlag(Flags, PropertyDesc.bReplicated, TEXT("Replicated"));
		AddFlag(Flags, PropertyDesc.bRepNotify, TEXT("RepNotify"));
		AddFlag(Flags, PropertyDesc.bConfig, TEXT("Config"));
		AddFlag(Flags, PropertyDesc.bSaveGame, TEXT("SaveGame"));
		AddFlag(Flags, PropertyDesc.bIsPrivate, TEXT("Private"));
		AddFlag(Flags, PropertyDesc.bIsProtected, TEXT("Protected"));
		return JoinStrings(Flags);
	}

	FString FormatFunctionFlags(const FAngelscriptFunctionDesc& FunctionDesc)
	{
		TArray<FString> Flags;
		AddFlag(Flags, FunctionDesc.bBlueprintCallable, TEXT("BlueprintCallable"));
		AddFlag(Flags, FunctionDesc.bBlueprintEvent, TEXT("BlueprintEvent"));
		AddFlag(Flags, FunctionDesc.bBlueprintPure, TEXT("BlueprintPure"));
		AddFlag(Flags, FunctionDesc.bNetFunction, TEXT("Net"));
		AddFlag(Flags, FunctionDesc.bNetMulticast, TEXT("NetMulticast"));
		AddFlag(Flags, FunctionDesc.bNetClient, TEXT("Client"));
		AddFlag(Flags, FunctionDesc.bNetServer, TEXT("Server"));
		AddFlag(Flags, FunctionDesc.bUnreliable, TEXT("Unreliable"));
		AddFlag(Flags, FunctionDesc.bExec, TEXT("Exec"));
		AddFlag(Flags, FunctionDesc.bIsStatic, TEXT("Static"));
		AddFlag(Flags, FunctionDesc.bIsConstMethod, TEXT("Const"));
		AddFlag(Flags, FunctionDesc.bThreadSafe, TEXT("ThreadSafe"));
		AddFlag(Flags, FunctionDesc.bIsNoOp, TEXT("NoOp"));
		AddFlag(Flags, FunctionDesc.bIsPrivate, TEXT("Private"));
		AddFlag(Flags, FunctionDesc.bIsProtected, TEXT("Protected"));
		return JoinStrings(Flags);
	}

	FString FormatClassFlags(const FAngelscriptClassDesc& ClassDesc)
	{
		TArray<FString> Flags;
		AddFlag(Flags, ClassDesc.bIsStruct, TEXT("Struct"));
		AddFlag(Flags, ClassDesc.bAbstract, TEXT("Abstract"));
		AddFlag(Flags, ClassDesc.bTransient, TEXT("Transient"));
		AddFlag(Flags, ClassDesc.bPlaceable, TEXT("Placeable"));
		AddFlag(Flags, ClassDesc.bIsStaticsClass, TEXT("Statics"));
		AddFlag(Flags, ClassDesc.bHideDropdown, TEXT("HideDropdown"));
		AddFlag(Flags, ClassDesc.bDefaultToInstanced, TEXT("DefaultToInstanced"));
		AddFlag(Flags, ClassDesc.bEditInlineNew, TEXT("EditInlineNew"));
		AddFlag(Flags, ClassDesc.bIsDeprecatedClass, TEXT("Deprecated"));
		return JoinStrings(Flags);
	}

	FString FormatFunctionDeclaration(const FAngelscriptFunctionDesc& FunctionDesc)
	{
		return FString::Printf(
			TEXT("%s %s(%s)%s"),
			*GetTypeUsageString(FunctionDesc.ReturnType),
			*FunctionDesc.FunctionName,
			*FormatArguments(FunctionDesc.Arguments),
			FunctionDesc.bIsConstMethod ? TEXT(" const") : TEXT(""));
	}

	FString GetObjectNameFromPath(const FString& ObjectPath)
	{
		if (ObjectPath.IsEmpty())
		{
			return FString();
		}

		const FString ObjectName = FPackageName::ObjectPathToObjectName(ObjectPath);
		return ObjectName.IsEmpty() ? ObjectPath : ObjectName;
	}

	FString GetFieldMetadataValue(const FField* Field, const FName MetadataName)
	{
#if WITH_METADATA
		return Field != nullptr && Field->HasMetaData(MetadataName) ? Field->GetMetaData(MetadataName) : FString();
#else
		return FString();
#endif
	}

	FString GetUFieldMetadataValue(const UField* Field, const FName MetadataName)
	{
#if WITH_METADATA
		return Field != nullptr && Field->HasMetaData(MetadataName) ? Field->GetMetaData(MetadataName) : FString();
#else
		return FString();
#endif
	}

	FString DisplayFallback(const FString& Primary, const FString& Secondary, const FString& Tertiary)
	{
		if (!Primary.IsEmpty())
		{
			return Primary;
		}
		if (!Secondary.IsEmpty())
		{
			return Secondary;
		}
		return Tertiary;
	}

	FProperty* ResolveBindProperty(const FAngelscriptPropertyBind& PropertyBind, UStruct* OwnerStruct)
	{
		if (OwnerStruct == nullptr)
		{
			return nullptr;
		}

		if (!PropertyBind.UnrealPath.IsEmpty())
		{
			if (FProperty* Property = FindFProperty<FProperty>(OwnerStruct, FName(*PropertyBind.UnrealPath)))
			{
				return Property;
			}
		}

		for (TFieldIterator<FProperty> It(OwnerStruct); It; ++It)
		{
			FProperty* Property = *It;
			if (Property != nullptr && (Property->GetPathName() == PropertyBind.UnrealPath || Property->GetName() == PropertyBind.GeneratedName))
			{
				return Property;
			}
		}

		return nullptr;
	}

	FString FormatPropertyBindFlags(const FAngelscriptPropertyBind& PropertyBind)
	{
		TArray<FString> Flags;
		AddFlag(Flags, PropertyBind.bCanRead, TEXT("CanRead"));
		AddFlag(Flags, PropertyBind.bCanWrite, TEXT("CanWrite"));
		AddFlag(Flags, PropertyBind.bCanEdit, TEXT("CanEdit"));
		AddFlag(Flags, PropertyBind.bGeneratedGetter, TEXT("GeneratedGetter"));
		AddFlag(Flags, PropertyBind.bGeneratedSetter, TEXT("GeneratedSetter"));
		AddFlag(Flags, PropertyBind.bGeneratedHandle, TEXT("GeneratedHandle"));
		AddFlag(Flags, PropertyBind.bGeneratedUnresolvedObject, TEXT("GeneratedUnresolvedObject"));
		return JoinStrings(Flags);
	}

	FString FormatMethodBindFlags(const FAngelscriptMethodBind& MethodBind)
	{
		TArray<FString> Flags;
		AddFlag(Flags, MethodBind.bStaticInUnreal, TEXT("StaticInUnreal"));
		AddFlag(Flags, MethodBind.bStaticInScript, TEXT("StaticInScript"));
		AddFlag(Flags, MethodBind.bGlobalScope, TEXT("GlobalScope"));
		AddFlag(Flags, MethodBind.bNotAngelscriptProperty, TEXT("NotAngelscriptProperty"));
		AddFlag(Flags, MethodBind.bTrivial, TEXT("Trivial"));
		if (MethodBind.WorldContextArgument >= 0)
		{
			Flags.Add(FString::Printf(TEXT("WorldContext:%d"), MethodBind.WorldContextArgument));
		}
		if (MethodBind.DeterminesOutputTypeArgument >= 0)
		{
			Flags.Add(FString::Printf(TEXT("DeterminesOutputType:%d"), MethodBind.DeterminesOutputTypeArgument));
		}
		return JoinStrings(Flags);
	}

	UFunction* ResolveBindFunction(const FAngelscriptMethodBind& MethodBind, UClass* OwnerClass)
	{
		if (MethodBind.ResolvedFunction != nullptr)
		{
			return MethodBind.ResolvedFunction;
		}

		if (OwnerClass != nullptr && !MethodBind.UnrealPath.IsEmpty())
		{
			if (UFunction* Function = OwnerClass->FindFunctionByName(FName(*MethodBind.UnrealPath)))
			{
				return Function;
			}
		}

		if (!MethodBind.UnrealPath.IsEmpty())
		{
			return FindObject<UFunction>(nullptr, *MethodBind.UnrealPath);
		}

		return nullptr;
	}

	FString ResolveMethodBindingPath(
		UFunction* ResolvedFunction,
		bool& bOutHasNativeFunctionEntry,
		bool& bOutHasDirectNativePointer,
		bool& bOutReflectiveFallbackBound)
	{
		bOutHasNativeFunctionEntry = false;
		bOutHasDirectNativePointer = false;
		bOutReflectiveFallbackBound = false;

		if (ResolvedFunction == nullptr)
		{
			return TEXT("UnresolvedFunction");
		}

		UClass* OwningClass = ResolvedFunction->GetOuterUClass();
		if (OwningClass == nullptr)
		{
			return TEXT("NoFunctionPointer");
		}

		TMap<FString, FFuncEntry>* FunctionMap = FAngelscriptBinds::GetClassFuncMaps().Find(OwningClass);
		if (FunctionMap == nullptr)
		{
			return TEXT("NoFunctionPointer");
		}

		FFuncEntry* FunctionEntry = FunctionMap->Find(ResolvedFunction->GetFName().ToString());
		if (FunctionEntry == nullptr)
		{
			return TEXT("NoFunctionPointer");
		}

		bOutHasNativeFunctionEntry = true;
		bOutHasDirectNativePointer = FunctionEntry->FuncPtr.IsBound();
		bOutReflectiveFallbackBound = FunctionEntry->bReflectiveFallbackBound;

		if (bOutHasDirectNativePointer)
		{
			return TEXT("DirectNativePointer");
		}

		return bOutReflectiveFallbackBound ? TEXT("ReflectiveFallback") : TEXT("NoFunctionPointer");
	}

	FAngelscriptStateBindPropertySnapshot CapturePropertyBind(const FAngelscriptPropertyBind& PropertyBind, UStruct* OwnerStruct)
	{
		static const FName NAME_Category(TEXT("Category"));
		static const FName NAME_DisplayName(TEXT("DisplayName"));
		static const FName NAME_ToolTip(TEXT("ToolTip"));

		FProperty* ResolvedProperty = ResolveBindProperty(PropertyBind, OwnerStruct);
		const FString OwnerName = OwnerStruct != nullptr ? OwnerStruct->GetName() : FString();
		const FString MetadataDisplayName = GetFieldMetadataValue(ResolvedProperty, NAME_DisplayName);
		const FString MetadataCategory = GetFieldMetadataValue(ResolvedProperty, NAME_Category);

		FAngelscriptStateBindPropertySnapshot PropertySnapshot;
		PropertySnapshot.Declaration = PropertyBind.Declaration;
		PropertySnapshot.UnrealPath = PropertyBind.UnrealPath;
		PropertySnapshot.GeneratedName = PropertyBind.GeneratedName;
		PropertySnapshot.Flags = FormatPropertyBindFlags(PropertyBind);
		PropertySnapshot.DisplayName = DisplayFallback(MetadataDisplayName, PropertyBind.GeneratedName, GetObjectNameFromPath(PropertyBind.UnrealPath));
		PropertySnapshot.Category = MetadataCategory.IsEmpty() ? TEXT("Uncategorized") : MetadataCategory;
		PropertySnapshot.OwnerName = OwnerName;
		PropertySnapshot.ToolTip = GetFieldMetadataValue(ResolvedProperty, NAME_ToolTip);
		PropertySnapshot.bCanWrite = PropertyBind.bCanWrite;
		PropertySnapshot.bCanRead = PropertyBind.bCanRead;
		PropertySnapshot.bCanEdit = PropertyBind.bCanEdit;
		PropertySnapshot.bGeneratedGetter = PropertyBind.bGeneratedGetter;
		PropertySnapshot.bGeneratedSetter = PropertyBind.bGeneratedSetter;
		PropertySnapshot.bGeneratedHandle = PropertyBind.bGeneratedHandle;
		PropertySnapshot.bGeneratedUnresolvedObject = PropertyBind.bGeneratedUnresolvedObject;
		PropertySnapshot.SortKey = JoinStrings({ PropertySnapshot.Category, PropertySnapshot.OwnerName, PropertySnapshot.DisplayName, PropertySnapshot.Declaration });
		PropertySnapshot.SearchText = JoinSearchText({
			TEXT("kind:property"),
			PropertySnapshot.Declaration,
			PropertySnapshot.UnrealPath,
			PropertySnapshot.GeneratedName,
			PropertySnapshot.DisplayName,
			PropertySnapshot.Category,
			PropertySnapshot.OwnerName,
			PropertySnapshot.ToolTip,
			PropertySnapshot.Flags,
			PropertySnapshot.SortKey
		});
		return PropertySnapshot;
	}

	FAngelscriptStateBindMethodSnapshot CaptureMethodBind(const FAngelscriptMethodBind& MethodBind, UClass* OwnerClass)
	{
		static const FName NAME_Category(TEXT("Category"));
		static const FName NAME_DisplayName(TEXT("DisplayName"));
		static const FName NAME_ScriptName(TEXT("ScriptName"));
		static const FName NAME_ToolTip(TEXT("ToolTip"));

		UFunction* ResolvedFunction = ResolveBindFunction(MethodBind, OwnerClass);
		UClass* ResolvedOwnerClass = ResolvedFunction != nullptr ? ResolvedFunction->GetOuterUClass() : OwnerClass;
		const FString OwnerName = ResolvedOwnerClass != nullptr ? ResolvedOwnerClass->GetName() : MethodBind.ClassName;
		const FString MetadataDisplayName = GetUFieldMetadataValue(ResolvedFunction, NAME_DisplayName);
		const FString MetadataScriptName = GetUFieldMetadataValue(ResolvedFunction, NAME_ScriptName);
		const FString MetadataCategory = GetUFieldMetadataValue(ResolvedFunction, NAME_Category);

		FAngelscriptStateBindMethodSnapshot MethodSnapshot;
		MethodSnapshot.Declaration = MethodBind.Declaration;
		MethodSnapshot.UnrealPath = MethodBind.UnrealPath;
		MethodSnapshot.ClassName = MethodBind.ClassName;
		MethodSnapshot.ScriptName = DisplayFallback(MethodBind.ScriptName, MetadataScriptName, MethodBind.UnrealPath);
		MethodSnapshot.ResolvedFunctionPath = GetPathNameSafe(ResolvedFunction);
		MethodSnapshot.OwningCppClassPath = GetPathNameSafe(ResolvedOwnerClass);
		MethodSnapshot.WorldContextArgument = MethodBind.WorldContextArgument;
		MethodSnapshot.DeterminesOutputTypeArgument = MethodBind.DeterminesOutputTypeArgument;
		MethodSnapshot.bStaticInUnreal = MethodBind.bStaticInUnreal;
		MethodSnapshot.bStaticInScript = MethodBind.bStaticInScript;
		MethodSnapshot.bGlobalScope = MethodBind.bGlobalScope;
		MethodSnapshot.bNotAngelscriptProperty = MethodBind.bNotAngelscriptProperty;
		MethodSnapshot.bTrivial = MethodBind.bTrivial;
		MethodSnapshot.Flags = FormatMethodBindFlags(MethodBind);
		MethodSnapshot.BindingPath = ResolveMethodBindingPath(
			ResolvedFunction,
			MethodSnapshot.bHasNativeFunctionEntry,
			MethodSnapshot.bHasDirectNativePointer,
			MethodSnapshot.bReflectiveFallbackBound);
		MethodSnapshot.DisplayName = DisplayFallback(MetadataDisplayName, MethodSnapshot.ScriptName, MethodSnapshot.UnrealPath);
		MethodSnapshot.Category = MetadataCategory.IsEmpty() ? TEXT("Uncategorized") : MetadataCategory;
		MethodSnapshot.OwnerName = OwnerName;
		MethodSnapshot.ToolTip = GetUFieldMetadataValue(ResolvedFunction, NAME_ToolTip);
		MethodSnapshot.SortKey = JoinStrings({ MethodSnapshot.Category, MethodSnapshot.OwnerName, MethodSnapshot.DisplayName, MethodSnapshot.Declaration });
		MethodSnapshot.SearchText = JoinSearchText({
			TEXT("kind:method"),
			MethodSnapshot.Declaration,
			MethodSnapshot.UnrealPath,
			MethodSnapshot.ClassName,
			MethodSnapshot.ScriptName,
			MethodSnapshot.ResolvedFunctionPath,
			MethodSnapshot.OwningCppClassPath,
			MethodSnapshot.BindingPath,
			MethodSnapshot.DisplayName,
			MethodSnapshot.Category,
			MethodSnapshot.OwnerName,
			MethodSnapshot.ToolTip,
			MethodSnapshot.Flags,
			MethodSnapshot.SortKey
		});
		return MethodSnapshot;
	}

	void AddMethodBindingCount(FAngelscriptStateBindTypeSnapshot& BindSnapshot, const FString& BindingPath)
	{
		if (BindingPath == TEXT("DirectNativePointer"))
		{
			++BindSnapshot.DirectNativeMethodCount;
		}
		else if (BindingPath == TEXT("ReflectiveFallback"))
		{
			++BindSnapshot.ReflectiveFallbackMethodCount;
		}
		else if (BindingPath == TEXT("UnresolvedFunction"))
		{
			++BindSnapshot.UnresolvedMethodCount;
		}
		else
		{
			++BindSnapshot.NoFunctionPointerMethodCount;
		}
	}

	void CaptureModulesAndClasses(FAngelscriptEngine& Engine, FAngelscriptEngineStateSnapshot& Snapshot)
	{
		TArray<TSharedRef<FAngelscriptModuleDesc>> ActiveModules = Engine.GetActiveModules();
		ActiveModules.Sort([](const TSharedRef<FAngelscriptModuleDesc>& A, const TSharedRef<FAngelscriptModuleDesc>& B)
		{
			return A->ModuleName < B->ModuleName;
		});

		for (const TSharedRef<FAngelscriptModuleDesc>& Module : ActiveModules)
		{
			FAngelscriptStateModuleSnapshot ModuleSnapshot;
			ModuleSnapshot.ModuleName = Module->ModuleName;
			ModuleSnapshot.CodeFileCount = Module->Code.Num();
			ModuleSnapshot.ImportedModuleCount = Module->ImportedModules.Num();
			ModuleSnapshot.ClassCount = Module->Classes.Num();
			ModuleSnapshot.EnumCount = Module->Enums.Num();
			ModuleSnapshot.DelegateCount = Module->Delegates.Num();
			ModuleSnapshot.bCompileError = Module->bCompileError;
			ModuleSnapshot.bLoadedPrecompiledCode = Module->bLoadedPrecompiledCode;

			TArray<FString> CodeFiles;
			CodeFiles.Reserve(Module->Code.Num());
			for (const FAngelscriptModuleDesc::FCodeSection& CodeSection : Module->Code)
			{
				CodeFiles.Add(!CodeSection.RelativeFilename.IsEmpty() ? CodeSection.RelativeFilename : CodeSection.AbsoluteFilename);
			}
			CodeFiles.Sort();
			ModuleSnapshot.CodeFiles = JoinStrings(CodeFiles);

			TArray<TSharedRef<FAngelscriptClassDesc>> Classes = Module->Classes;
			Classes.Sort([](const TSharedRef<FAngelscriptClassDesc>& A, const TSharedRef<FAngelscriptClassDesc>& B)
			{
				return A->ClassName < B->ClassName;
			});

			for (const TSharedRef<FAngelscriptClassDesc>& ClassDesc : Classes)
			{
				FAngelscriptStateScriptClassSnapshot ClassSnapshot;
				ClassSnapshot.ModuleName = Module->ModuleName;
				ClassSnapshot.ClassName = ClassDesc->ClassName;
				ClassSnapshot.SuperClass = ClassDesc->SuperClass;
				ClassSnapshot.Namespace = ClassDesc->Namespace.IsSet() ? ClassDesc->Namespace.GetValue() : FString();
				ClassSnapshot.UnrealTypePath = ClassDesc->Class != nullptr
					? ClassDesc->Class->GetPathName()
					: (ClassDesc->Struct != nullptr ? ClassDesc->Struct->GetPathName() : FString());
				ClassSnapshot.Flags = FormatClassFlags(*ClassDesc);
				ClassSnapshot.ConfigName = ClassDesc->ConfigName;
				ClassSnapshot.CodeSuperClass = GetPathNameSafe(ClassDesc->CodeSuperClass);
				ClassSnapshot.LineNumber = ClassDesc->LineNumber;

				TArray<TSharedRef<FAngelscriptPropertyDesc>> Properties = ClassDesc->Properties;
				Properties.Sort([](const TSharedRef<FAngelscriptPropertyDesc>& A, const TSharedRef<FAngelscriptPropertyDesc>& B)
				{
					return A->PropertyName < B->PropertyName;
				});

				for (const TSharedRef<FAngelscriptPropertyDesc>& PropertyDesc : Properties)
				{
					FAngelscriptStateMemberSnapshot PropertySnapshot;
					PropertySnapshot.Name = PropertyDesc->PropertyName;
					PropertySnapshot.Declaration = FString::Printf(TEXT("%s %s"), *PropertyDesc->LiteralType, *PropertyDesc->PropertyName);
					PropertySnapshot.Details = FormatPropertyFlags(*PropertyDesc);
					PropertySnapshot.LineNumber = PropertyDesc->LineNumber;
					ClassSnapshot.Properties.Add(MoveTemp(PropertySnapshot));
				}

				TArray<TSharedRef<FAngelscriptFunctionDesc>> Methods = ClassDesc->Methods;
				Methods.Sort([](const TSharedRef<FAngelscriptFunctionDesc>& A, const TSharedRef<FAngelscriptFunctionDesc>& B)
				{
					return A->FunctionName < B->FunctionName;
				});

				for (const TSharedRef<FAngelscriptFunctionDesc>& FunctionDesc : Methods)
				{
					FAngelscriptStateMemberSnapshot MethodSnapshot;
					MethodSnapshot.Name = FunctionDesc->FunctionName;
					MethodSnapshot.Declaration = FormatFunctionDeclaration(*FunctionDesc);
					MethodSnapshot.Details = FormatFunctionFlags(*FunctionDesc);
					MethodSnapshot.LineNumber = FunctionDesc->LineNumber;
					ClassSnapshot.Methods.Add(MoveTemp(MethodSnapshot));
				}

				ModuleSnapshot.PropertyCount += ClassSnapshot.Properties.Num();
				ModuleSnapshot.MethodCount += ClassSnapshot.Methods.Num();
				Snapshot.ScriptClasses.Add(MoveTemp(ClassSnapshot));
			}

			Snapshot.Modules.Add(MoveTemp(ModuleSnapshot));
		}
	}

	void CaptureRegisteredTypes(asIScriptEngine& ScriptEngine, FAngelscriptEngineStateSnapshot& Snapshot)
	{
		const asUINT TypeCount = ScriptEngine.GetObjectTypeCount();
		Snapshot.RegisteredTypes.Reserve(TypeCount);
		for (asUINT TypeIndex = 0; TypeIndex < TypeCount; ++TypeIndex)
		{
			asITypeInfo* TypeInfo = ScriptEngine.GetObjectTypeByIndex(TypeIndex);
			if (TypeInfo == nullptr)
			{
				continue;
			}

			FAngelscriptStateRegisteredTypeSnapshot TypeSnapshot;
			TypeSnapshot.TypeName = AnsiToString(TypeInfo->GetName());
			TypeSnapshot.Namespace = AnsiToString(TypeInfo->GetNamespace());
			TypeSnapshot.Declaration = TypeSnapshot.Namespace.IsEmpty()
				? TypeSnapshot.TypeName
				: FString::Printf(TEXT("%s::%s"), *TypeSnapshot.Namespace, *TypeSnapshot.TypeName);
			TypeSnapshot.BaseType = TypeInfo->GetBaseType() != nullptr ? AnsiToString(TypeInfo->GetBaseType()->GetName()) : FString();
			TypeSnapshot.Flags = FString::Printf(TEXT("0x%llx"), static_cast<unsigned long long>(TypeInfo->GetFlags()));
			TypeSnapshot.TypeId = TypeInfo->GetTypeId();
			TypeSnapshot.Size = static_cast<int32>(TypeInfo->GetSize());

			const asUINT PropertyCount = TypeInfo->GetPropertyCount();
			TypeSnapshot.Properties.Reserve(PropertyCount);
			for (asUINT PropertyIndex = 0; PropertyIndex < PropertyCount; ++PropertyIndex)
			{
				TypeSnapshot.Properties.Add(AnsiToString(TypeInfo->GetPropertyDeclaration(PropertyIndex, true)));
			}

			const asUINT MethodCount = TypeInfo->GetMethodCount();
			TypeSnapshot.Methods.Reserve(MethodCount);
			for (asUINT MethodIndex = 0; MethodIndex < MethodCount; ++MethodIndex)
			{
				if (asIScriptFunction* Method = TypeInfo->GetMethodByIndex(MethodIndex))
				{
					TypeSnapshot.Methods.Add(AnsiToString(Method->GetDeclaration(true, true, true, true)));
				}
			}

			TypeSnapshot.Properties.Sort();
			TypeSnapshot.Methods.Sort();
			Snapshot.RegisteredTypes.Add(MoveTemp(TypeSnapshot));
		}

		Snapshot.RegisteredTypes.Sort([](const FAngelscriptStateRegisteredTypeSnapshot& A, const FAngelscriptStateRegisteredTypeSnapshot& B)
		{
			return A.Declaration < B.Declaration;
		});
	}

	void CaptureBindDatabase(FAngelscriptEngineStateSnapshot& Snapshot)
	{
		const FAngelscriptBindDatabase& BindDatabase = FAngelscriptBindDatabase::Get();

		for (const FAngelscriptClassBind& ClassBind : BindDatabase.Classes)
		{
			FAngelscriptStateBindTypeSnapshot BindSnapshot;
			BindSnapshot.Kind = TEXT("Class");
			BindSnapshot.TypeName = ClassBind.TypeName;
			BindSnapshot.UnrealPath = ClassBind.UnrealPath;
			BindSnapshot.ResolvedTypePath = GetPathNameSafe(ClassBind.ResolvedClass);
			BindSnapshot.CppTypeName = ClassBind.ResolvedClass != nullptr ? ClassBind.ResolvedClass->GetName() : GetObjectNameFromPath(ClassBind.UnrealPath);
			BindSnapshot.CppTypePath = ClassBind.ResolvedClass != nullptr ? ClassBind.ResolvedClass->GetPathName() : ClassBind.UnrealPath;
			BindSnapshot.SourceHeader = ClassBind.ResolvedClass != nullptr ? FAngelscriptBindDatabase::GetSourceHeader(ClassBind.ResolvedClass) : FString();

			BindSnapshot.Properties.Reserve(ClassBind.Properties.Num());
			for (const FAngelscriptPropertyBind& PropertyBind : ClassBind.Properties)
			{
				BindSnapshot.Properties.Add(CapturePropertyBind(PropertyBind, ClassBind.ResolvedClass));
			}

			BindSnapshot.Methods.Reserve(ClassBind.Methods.Num());
			for (const FAngelscriptMethodBind& MethodBind : ClassBind.Methods)
			{
				FAngelscriptStateBindMethodSnapshot MethodSnapshot = CaptureMethodBind(MethodBind, ClassBind.ResolvedClass);
				AddMethodBindingCount(BindSnapshot, MethodSnapshot.BindingPath);
				BindSnapshot.Methods.Add(MoveTemp(MethodSnapshot));
			}

			BindSnapshot.Properties.Sort([](const FAngelscriptStateBindPropertySnapshot& A, const FAngelscriptStateBindPropertySnapshot& B)
			{
				return A.SortKey < B.SortKey;
			});
			BindSnapshot.Methods.Sort([](const FAngelscriptStateBindMethodSnapshot& A, const FAngelscriptStateBindMethodSnapshot& B)
			{
				if (A.SortKey != B.SortKey)
				{
					return A.SortKey < B.SortKey;
				}
				return A.Declaration < B.Declaration;
			});
			Snapshot.BindTypes.Add(MoveTemp(BindSnapshot));
		}

		for (const FAngelscriptStructBind& StructBind : BindDatabase.Structs)
		{
			FAngelscriptStateBindTypeSnapshot BindSnapshot;
			BindSnapshot.Kind = TEXT("Struct");
			BindSnapshot.TypeName = StructBind.TypeName;
			BindSnapshot.UnrealPath = StructBind.UnrealPath;
			BindSnapshot.ResolvedTypePath = GetPathNameSafe(StructBind.ResolvedStruct);
			BindSnapshot.CppTypeName = StructBind.ResolvedStruct != nullptr ? StructBind.ResolvedStruct->GetName() : GetObjectNameFromPath(StructBind.UnrealPath);
			BindSnapshot.CppTypePath = StructBind.ResolvedStruct != nullptr ? StructBind.ResolvedStruct->GetPathName() : StructBind.UnrealPath;
			BindSnapshot.SourceHeader = StructBind.ResolvedStruct != nullptr ? FAngelscriptBindDatabase::GetSourceHeader(StructBind.ResolvedStruct) : FString();

			BindSnapshot.Properties.Reserve(StructBind.Properties.Num());
			for (const FAngelscriptPropertyBind& PropertyBind : StructBind.Properties)
			{
				BindSnapshot.Properties.Add(CapturePropertyBind(PropertyBind, StructBind.ResolvedStruct));
			}

			BindSnapshot.Properties.Sort([](const FAngelscriptStateBindPropertySnapshot& A, const FAngelscriptStateBindPropertySnapshot& B)
			{
				return A.SortKey < B.SortKey;
			});
			Snapshot.BindTypes.Add(MoveTemp(BindSnapshot));
		}

		Snapshot.BindTypes.Sort([](const FAngelscriptStateBindTypeSnapshot& A, const FAngelscriptStateBindTypeSnapshot& B)
		{
			if (A.Kind != B.Kind)
			{
				return A.Kind < B.Kind;
			}
			return A.TypeName < B.TypeName;
		});
	}

	void CaptureBindRegistrations(FAngelscriptEngine& Engine, FAngelscriptEngineStateSnapshot& Snapshot)
	{
		const TSet<FName>& DisabledBindNames = Engine.GetRuntimeConfig().DisabledBindNames;
		TArray<FAngelscriptBinds::FBindInfo> BindInfos = FAngelscriptBinds::GetBindInfoList(DisabledBindNames);
		BindInfos.Sort([](const FAngelscriptBinds::FBindInfo& A, const FAngelscriptBinds::FBindInfo& B)
		{
			const FString AName = A.BindName.ToString();
			const FString BName = B.BindName.ToString();
			if (AName != BName)
			{
				return AName < BName;
			}
			return A.BindOrder < B.BindOrder;
		});

		for (const FAngelscriptBinds::FBindInfo& BindInfo : BindInfos)
		{
			FAngelscriptStateBindRegistrationSnapshot RegistrationSnapshot;
			RegistrationSnapshot.BindName = BindInfo.BindName.ToString();
			RegistrationSnapshot.BindOrder = BindInfo.BindOrder;
			RegistrationSnapshot.bEnabled = BindInfo.bEnabled;
			RegistrationSnapshot.SkipReason = !BindInfo.bEnabled && DisabledBindNames.Contains(BindInfo.BindName)
				? FString(TEXT("DisabledBindNames"))
				: FString();
			Snapshot.BindRegistrations.Add(MoveTemp(RegistrationSnapshot));
		}
	}

	void CaptureDiagnostics(FAngelscriptEngine& Engine, FAngelscriptEngineStateSnapshot& Snapshot)
	{
		TArray<FString> DiagnosticFiles;
		Engine.Diagnostics.GetKeys(DiagnosticFiles);
		DiagnosticFiles.Sort();

		for (const FString& DiagnosticFile : DiagnosticFiles)
		{
			const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(DiagnosticFile);
			if (Diagnostics == nullptr)
			{
				continue;
			}

			for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
			{
				FAngelscriptStateDiagnosticSnapshot DiagnosticSnapshot;
				DiagnosticSnapshot.Filename = DiagnosticFile;
				DiagnosticSnapshot.Row = Diagnostic.Row;
				DiagnosticSnapshot.Column = Diagnostic.Column;
				DiagnosticSnapshot.Severity = Diagnostic.bIsError ? TEXT("Error") : (Diagnostic.bIsInfo ? TEXT("Info") : TEXT("Warning"));
				DiagnosticSnapshot.Message = Diagnostic.Message;
				Snapshot.Diagnostics.Add(MoveTemp(DiagnosticSnapshot));
			}
		}
	}
}

FAngelscriptEngineStateSnapshot FAngelscriptEngineStateSnapshot::CaptureCurrent()
{
	return Capture(FAngelscriptEngine::TryGetCurrentEngine());
}

FAngelscriptEngineStateSnapshot FAngelscriptEngineStateSnapshot::Capture(FAngelscriptEngine* Engine)
{
	FAngelscriptEngineStateSnapshot Snapshot;
	Snapshot.Overview.Timestamp = FDateTime::Now().ToString(TEXT("%Y-%m-%d %H:%M:%S"));

	if (Engine == nullptr)
	{
		Snapshot.Overview.Status = TEXT("No active Angelscript engine.");
		return Snapshot;
	}

	Snapshot.Overview.bHasEngine = true;
	Snapshot.Overview.Status = TEXT("Ready");
	Snapshot.Overview.InstanceId = Engine->GetInstanceId();
	Snapshot.Overview.CreationMode = GetCreationModeString(Engine->GetCreationMode());
	Snapshot.Overview.bOwnsEngine = Engine->OwnsEngine();
	Snapshot.Overview.bInitialCompileFinished = Engine->bIsInitialCompileFinished;
	Snapshot.Overview.bInitialCompileSucceeded = Engine->bDidInitialCompileSucceed;
	Snapshot.Overview.bIsHotReloading = Engine->bIsHotReloading;
	Snapshot.Overview.bUseEditorScripts = Engine->bUseEditorScripts;
	Snapshot.Overview.bScriptDevelopmentMode = Engine->bScriptDevelopmentMode;
	Snapshot.Overview.RegisteredTypeCount = FAngelscriptType::GetTypes().Num();

	if (const FAngelscriptEngine* SourceEngine = Engine->GetSourceEngine())
	{
		Snapshot.Overview.SourceEngineId = SourceEngine->GetInstanceId();
	}

	CaptureModulesAndClasses(*Engine, Snapshot);
	CaptureBindDatabase(Snapshot);
	CaptureBindRegistrations(*Engine, Snapshot);
	CaptureDiagnostics(*Engine, Snapshot);

	if (asIScriptEngine* ScriptEngine = Engine->GetScriptEngine())
	{
		Snapshot.Overview.bHasScriptEngine = true;
		Snapshot.Overview.ScriptObjectTypeCount = static_cast<int32>(ScriptEngine->GetObjectTypeCount());
		CaptureRegisteredTypes(*ScriptEngine, Snapshot);
	}

	Snapshot.Overview.ModuleCount = Snapshot.Modules.Num();
	Snapshot.Overview.ScriptClassCount = Snapshot.ScriptClasses.Num();
	Snapshot.Overview.BindRegistrationCount = Snapshot.BindRegistrations.Num();
	Snapshot.Overview.DiagnosticCount = Snapshot.Diagnostics.Num();

	for (const FAngelscriptStateModuleSnapshot& Module : Snapshot.Modules)
	{
		Snapshot.Overview.ScriptPropertyCount += Module.PropertyCount;
		Snapshot.Overview.ScriptMethodCount += Module.MethodCount;
		Snapshot.Overview.ScriptEnumCount += Module.EnumCount;
		Snapshot.Overview.ScriptDelegateCount += Module.DelegateCount;
	}

	for (const FAngelscriptStateBindTypeSnapshot& BindType : Snapshot.BindTypes)
	{
		if (BindType.Kind == TEXT("Class"))
		{
			++Snapshot.Overview.BindDatabaseClassCount;
		}
		else if (BindType.Kind == TEXT("Struct"))
		{
			++Snapshot.Overview.BindDatabaseStructCount;
		}

		Snapshot.Overview.BindDatabaseMethodCount += BindType.Methods.Num();
		Snapshot.Overview.BindDatabasePropertyCount += BindType.Properties.Num();
	}

	return Snapshot;
}
