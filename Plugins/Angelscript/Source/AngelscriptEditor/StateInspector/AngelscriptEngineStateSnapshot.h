#pragma once

#include "CoreMinimal.h"

struct FAngelscriptEngine;

struct FAngelscriptStateMemberSnapshot
{
	FString Name;
	FString Declaration;
	FString Details;
	int32 LineNumber = 0;
};

struct FAngelscriptStateModuleSnapshot
{
	FString ModuleName;
	FString CodeFiles;
	int32 CodeFileCount = 0;
	int32 ImportedModuleCount = 0;
	int32 ClassCount = 0;
	int32 PropertyCount = 0;
	int32 MethodCount = 0;
	int32 EnumCount = 0;
	int32 DelegateCount = 0;
	bool bCompileError = false;
	bool bLoadedPrecompiledCode = false;
};

struct FAngelscriptStateScriptClassSnapshot
{
	FString ModuleName;
	FString ClassName;
	FString SuperClass;
	FString Namespace;
	FString UnrealTypePath;
	FString Flags;
	FString ConfigName;
	FString CodeSuperClass;
	int32 LineNumber = 0;
	TArray<FAngelscriptStateMemberSnapshot> Properties;
	TArray<FAngelscriptStateMemberSnapshot> Methods;
};

struct FAngelscriptStateRegisteredTypeSnapshot
{
	FString TypeName;
	FString Namespace;
	FString Declaration;
	FString BaseType;
	FString Flags;
	int32 TypeId = 0;
	int32 Size = 0;
	TArray<FString> Properties;
	TArray<FString> Methods;
};

struct FAngelscriptStateBindPropertySnapshot
{
	FString Declaration;
	FString UnrealPath;
	FString GeneratedName;
	FString DisplayName;
	FString Category;
	FString OwnerName;
	FString ToolTip;
	FString SearchText;
	FString SortKey;
	FString Flags;
	bool bCanWrite = false;
	bool bCanRead = false;
	bool bCanEdit = false;
	bool bGeneratedGetter = false;
	bool bGeneratedSetter = false;
	bool bGeneratedHandle = false;
	bool bGeneratedUnresolvedObject = false;
};

struct FAngelscriptStateBindMethodSnapshot
{
	FString Declaration;
	FString UnrealPath;
	FString ClassName;
	FString ScriptName;
	FString ResolvedFunctionPath;
	FString OwningCppClassPath;
	FString BindingPath;
	FString DisplayName;
	FString Category;
	FString OwnerName;
	FString ToolTip;
	FString SearchText;
	FString SortKey;
	FString Flags;
	int32 WorldContextArgument = -1;
	int32 DeterminesOutputTypeArgument = -1;
	bool bStaticInUnreal = false;
	bool bStaticInScript = false;
	bool bGlobalScope = false;
	bool bNotAngelscriptProperty = false;
	bool bTrivial = false;
	bool bHasNativeFunctionEntry = false;
	bool bHasDirectNativePointer = false;
	bool bReflectiveFallbackBound = false;
};

struct FAngelscriptStateBindTypeSnapshot
{
	FString Kind;
	FString TypeName;
	FString UnrealPath;
	FString ResolvedTypePath;
	FString CppTypeName;
	FString CppTypePath;
	FString SourceHeader;
	TArray<FAngelscriptStateBindPropertySnapshot> Properties;
	TArray<FAngelscriptStateBindMethodSnapshot> Methods;
	int32 DirectNativeMethodCount = 0;
	int32 ReflectiveFallbackMethodCount = 0;
	int32 NoFunctionPointerMethodCount = 0;
	int32 UnresolvedMethodCount = 0;
};

struct FAngelscriptStateBindRegistrationSnapshot
{
	FString BindName;
	int32 BindOrder = 0;
	bool bEnabled = true;
	FString SkipReason;
};

struct FAngelscriptStateDiagnosticSnapshot
{
	FString Filename;
	int32 Row = 0;
	int32 Column = 0;
	FString Severity;
	FString Message;
};

struct FAngelscriptEngineStateOverviewSnapshot
{
	bool bHasEngine = false;
	bool bHasScriptEngine = false;
	FString Status;
	FString InstanceId;
	FString CreationMode;
	FString SourceEngineId;
	FString Timestamp;
	bool bOwnsEngine = false;
	bool bInitialCompileFinished = false;
	bool bInitialCompileSucceeded = false;
	bool bIsHotReloading = false;
	bool bUseEditorScripts = false;
	bool bScriptDevelopmentMode = false;
	int32 ModuleCount = 0;
	int32 ScriptClassCount = 0;
	int32 ScriptPropertyCount = 0;
	int32 ScriptMethodCount = 0;
	int32 ScriptEnumCount = 0;
	int32 ScriptDelegateCount = 0;
	int32 RegisteredTypeCount = 0;
	int32 ScriptObjectTypeCount = 0;
	int32 BindRegistrationCount = 0;
	int32 BindDatabaseClassCount = 0;
	int32 BindDatabaseStructCount = 0;
	int32 BindDatabaseMethodCount = 0;
	int32 BindDatabasePropertyCount = 0;
	int32 DiagnosticCount = 0;
};

struct FAngelscriptEngineStateSnapshot
{
	FAngelscriptEngineStateOverviewSnapshot Overview;
	TArray<FAngelscriptStateModuleSnapshot> Modules;
	TArray<FAngelscriptStateScriptClassSnapshot> ScriptClasses;
	TArray<FAngelscriptStateRegisteredTypeSnapshot> RegisteredTypes;
	TArray<FAngelscriptStateBindTypeSnapshot> BindTypes;
	TArray<FAngelscriptStateBindRegistrationSnapshot> BindRegistrations;
	TArray<FAngelscriptStateDiagnosticSnapshot> Diagnostics;

	static FAngelscriptEngineStateSnapshot CaptureCurrent();
	static FAngelscriptEngineStateSnapshot Capture(FAngelscriptEngine* Engine);
};
