#include "AngelscriptSourceCodeNavigation.h"
#include "SourceCodeNavigation.h"
#include "AngelscriptEngine.h"
#include "ClassGenerator/ASClass.h"
#include "ClassGenerator/ASStruct.h"

namespace
{
	AngelscriptSourceNavigation::FOpenLocationOverride GOpenLocationOverrideForTesting;
	ISourceCodeNavigationHandler* GAngelscriptSourceCodeNavigationHandler = nullptr;

	bool TryHandleOpenLocationOverride(const FString& Path, int32 LineNo)
	{
		if (!GOpenLocationOverrideForTesting)
		{
			return false;
		}

		FAngelscriptSourceNavigationLocation Location;
		Location.Path = Path;
		Location.LineNumber = LineNo;
		GOpenLocationOverrideForTesting(Location);
		return true;
	}

	TSharedPtr<FAngelscriptPropertyDesc> FindPropertyDesc(
		const TSharedPtr<FAngelscriptClassDesc>& ClassDesc,
		const FProperty* InProperty)
	{
		if (!ClassDesc.IsValid() || InProperty == nullptr)
		{
			return nullptr;
		}

		if (TSharedPtr<FAngelscriptPropertyDesc> PropertyDesc = ClassDesc->GetProperty(InProperty->GetNameCPP());
			PropertyDesc.IsValid())
		{
			return PropertyDesc;
		}

		if (TSharedPtr<FAngelscriptPropertyDesc> PropertyDesc = ClassDesc->GetProperty(InProperty->GetAuthoredName());
			PropertyDesc.IsValid())
		{
			return PropertyDesc;
		}

		return ClassDesc->GetProperty(InProperty->GetName());
	}

	TSharedPtr<FAngelscriptClassDesc> FindClassDescByScriptType(
		asITypeInfo* ScriptType,
		TSharedPtr<FAngelscriptModuleDesc>* OutModule)
	{
		if (ScriptType == nullptr)
		{
			return nullptr;
		}

		FAngelscriptEngine& Engine = FAngelscriptEngine::Get();
		TSharedPtr<FAngelscriptModuleDesc> Module = Engine.GetModule(ScriptType->GetModule());
		if (!Module.IsValid())
		{
			return nullptr;
		}

		if (OutModule != nullptr)
		{
			*OutModule = Module;
		}

		return Module->GetClass(ScriptType);
	}
}

namespace AngelscriptSourceNavigation
{
	void SetOpenLocationOverrideForTesting(FOpenLocationOverride InOverride)
	{
		GOpenLocationOverrideForTesting = MoveTemp(InOverride);
	}

	void ResetOpenLocationOverrideForTesting()
	{
		GOpenLocationOverrideForTesting = nullptr;
	}
}

class FAngelscriptSourceCodeNavigation : public ISourceCodeNavigationHandler
{
public:
	virtual bool CanNavigateToClass(const UClass* InClass) override
	{
		auto ClassDesc = GetClassDesc(InClass);
		return ClassDesc.IsValid();
	}

	virtual bool NavigateToClass(const UClass* InClass) override
	{
		TSharedPtr<FAngelscriptModuleDesc> Module;
		auto ClassDesc = GetClassDesc(InClass, &Module);
		if (!ClassDesc.IsValid())
			return false;

		OpenModule(Module, ClassDesc->LineNumber);
		return true;
	}

	virtual bool CanNavigateToFunction(const UFunction* InFunction) override
	{
		auto* ASFunc = Cast<const UASFunction>(InFunction);
		if (ASFunc == nullptr)
			return false;
		return true;
	};

	virtual bool NavigateToFunction(const UFunction* InFunction) override
	{
		auto* ASFunc = Cast<const UASFunction>(InFunction);
		if (ASFunc == nullptr)
			return false;
		FString Path = ASFunc->GetSourceFilePath();
		if (Path.Len() == 0)
			return false;

		OpenFile(Path, ASFunc->GetSourceLineNumber());
		return true;
	};

	virtual bool CanNavigateToProperty(const FProperty* InProperty) override
	{
		auto ClassDesc = GetClassDesc(InProperty->GetOwnerStruct());
		return ClassDesc.IsValid();
	}

	virtual bool NavigateToProperty(const FProperty* InProperty) override
	{
		TSharedPtr<FAngelscriptModuleDesc> Module;
		auto ClassDesc = GetClassDesc(InProperty->GetOwnerStruct(), &Module);
		if (!ClassDesc.IsValid())
			return false;

		auto PropertyDesc = FindPropertyDesc(ClassDesc, InProperty);
		if (!PropertyDesc.IsValid())
			return false;

		OpenModule(Module, PropertyDesc->LineNumber);
		return true;
	}

	virtual bool CanNavigateToStruct(const UStruct* InStruct) override
	{
		auto ClassDesc = GetClassDesc(InStruct);
		return ClassDesc.IsValid();
	}

	virtual bool NavigateToStruct(const UStruct* InStruct) override
	{
		TSharedPtr<FAngelscriptModuleDesc> Module;
		auto ClassDesc = GetClassDesc(InStruct, &Module);
		if (!ClassDesc.IsValid())
			return false;

		OpenModule(Module, ClassDesc->LineNumber);
		return true;
	}

	virtual bool CanNavigateToStruct(const UScriptStruct* InStruct) override
	{
		return CanNavigateToStruct(Cast<UStruct>(InStruct));
	}

	virtual bool NavigateToStruct(const UScriptStruct* InStruct) override
	{
		return NavigateToStruct(Cast<UStruct>(InStruct));
	}

private:
	void OpenModule(TSharedPtr<FAngelscriptModuleDesc> Module, int LineNo = -1)
	{
		if (!Module.IsValid())
			return;
		if (Module->Code.Num() == 0)
			return;

		FString Path = Module->Code[0].AbsoluteFilename;
		if (TryHandleOpenLocationOverride(Path, LineNo))
			return;
		if (LineNo != -1)
			FPlatformMisc::OsExecute(nullptr, TEXT("code"), *FString::Printf(TEXT("--goto \"%s:%d\""), *Path, LineNo));
		else
			FPlatformMisc::OsExecute(nullptr, TEXT("code"), *FString::Printf(TEXT("\"%s\""), *Path));
	}

	void OpenFile(const FString& Path, int LineNo = -1)
	{
		if (TryHandleOpenLocationOverride(Path, LineNo))
			return;
		if (LineNo != -1)
			FPlatformMisc::OsExecute(nullptr, TEXT("code"), *FString::Printf(TEXT("--goto \"%s:%d\""), *Path, LineNo));
		else
			FPlatformMisc::OsExecute(nullptr, TEXT("code"), *FString::Printf(TEXT("\"%s\""), *Path));
	}

	TSharedPtr<FAngelscriptClassDesc> GetClassDesc(const UStruct* Struct, TSharedPtr<FAngelscriptModuleDesc>* OutModule = nullptr)
	{
		auto* ASClass = Cast<const UASClass>(Struct);
		if (ASClass != nullptr)
		{
			if (TSharedPtr<FAngelscriptClassDesc> ClassDesc = FindClassDescByScriptType(static_cast<asITypeInfo*>(ASClass->ScriptTypePtr), OutModule);
				ClassDesc.IsValid())
			{
				return ClassDesc;
			}

			return FAngelscriptEngine::Get().GetClass(ASClass->GetPrefixCPP() + ASClass->GetName(), OutModule);
		}

		auto* ASStruct = Cast<const UASStruct>(Struct);
		if (ASStruct != nullptr)
		{
			if (TSharedPtr<FAngelscriptClassDesc> ClassDesc = FindClassDescByScriptType(ASStruct->ScriptType, OutModule);
				ClassDesc.IsValid())
			{
				return ClassDesc;
			}

			return FAngelscriptEngine::Get().GetClass(ASStruct->GetPrefixCPP() + ASStruct->GetName(), OutModule);
		}

		return nullptr;
	}
};

namespace AngelscriptSourceNavigation
{
	bool NavigateToFunctionForTesting(const UFunction* InFunction)
	{
		return GAngelscriptSourceCodeNavigationHandler != nullptr
			? GAngelscriptSourceCodeNavigationHandler->NavigateToFunction(InFunction)
			: false;
	}

	bool NavigateToPropertyForTesting(const FProperty* InProperty)
	{
		return GAngelscriptSourceCodeNavigationHandler != nullptr
			? GAngelscriptSourceCodeNavigationHandler->NavigateToProperty(InProperty)
			: false;
	}

	bool NavigateToStructForTesting(const UStruct* InStruct)
	{
		return GAngelscriptSourceCodeNavigationHandler != nullptr
			? GAngelscriptSourceCodeNavigationHandler->NavigateToStruct(InStruct)
			: false;
	}
}

void RegisterAngelscriptSourceNavigation()
{
	if (GAngelscriptSourceCodeNavigationHandler == nullptr)
	{
		GAngelscriptSourceCodeNavigationHandler = new FAngelscriptSourceCodeNavigation;
	}

	FSourceCodeNavigation::AddNavigationHandler(GAngelscriptSourceCodeNavigationHandler);
}
