#include "SourceNavigation/AngelscriptSourceCodeNavigation.h"
#include "SourceCodeNavigation.h"
#include "AngelscriptEngine.h"
#include "AngelscriptSettings.h"
#include "ClassGenerator/ASClass.h"
#include "ClassGenerator/ASStruct.h"
#include "Misc/Paths.h"

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

	FString BuildVSCodeOpenParametersInternal(FString Params, const FString& VSCodeWorkspacePath, bool bOpenFolderOnVSCodeSourceLinks, const FString& ScriptRootDirectory)
	{
		if (!VSCodeWorkspacePath.IsEmpty())
		{
			const FString WorkspacePath = FPaths::ConvertRelativePathToFull(FPaths::ProjectDir(), VSCodeWorkspacePath);
			return FString::Printf(TEXT("\"%s\" %s"), *WorkspacePath, *Params);
		}

		if (bOpenFolderOnVSCodeSourceLinks && !ScriptRootDirectory.IsEmpty())
		{
			return FString::Printf(TEXT("\"%s\" %s"), *ScriptRootDirectory, *Params);
		}

		return Params;
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

	FString BuildVSCodeOpenParametersForTesting(FString Params, const FString& VSCodeWorkspacePath, bool bOpenFolderOnVSCodeSourceLinks, const FString& ScriptRootDirectory)
	{
		return BuildVSCodeOpenParameters(MoveTemp(Params), VSCodeWorkspacePath, bOpenFolderOnVSCodeSourceLinks, ScriptRootDirectory);
	}

	FString BuildVSCodeOpenParameters(FString Params, const FString& VSCodeWorkspacePath, bool bOpenFolderOnVSCodeSourceLinks, const FString& ScriptRootDirectory)
	{
		return BuildVSCodeOpenParametersInternal(MoveTemp(Params), VSCodeWorkspacePath, bOpenFolderOnVSCodeSourceLinks, ScriptRootDirectory);
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

		auto PropertyDesc = ClassDesc->GetProperty(InProperty->GetNameCPP());
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
			OpenVsCode(FString::Printf(TEXT("--goto \"%s:%d\""), *Path, LineNo));
		else
			OpenVsCode(FString::Printf(TEXT("\"%s\""), *Path));
	}

	void OpenFile(const FString& Path, int LineNo = -1)
	{
		if (TryHandleOpenLocationOverride(Path, LineNo))
			return;
		if (LineNo != -1)
			OpenVsCode(FString::Printf(TEXT("--goto \"%s:%d\""), *Path, LineNo));
		else
			OpenVsCode(FString::Printf(TEXT("\"%s\""), *Path));
	}

	void OpenVsCode(FString Params)
	{
		const UAngelscriptSettings* Settings = GetDefault<UAngelscriptSettings>();
		FString ScriptRootDirectory;
		if (Settings != nullptr && Settings->bOpenFolderOnVSCodeSourceLinks)
		{
			if (FAngelscriptEngine::TryGetCurrentEngine() != nullptr)
			{
				ScriptRootDirectory = FAngelscriptEngine::GetScriptRootDirectory();
			}
			else
			{
				UE_LOG(Angelscript, Warning, TEXT("[SourceNavigation] No Angelscript engine is current; opening source file without Script workspace folder."));
			}
		}

		const FString VSCodeWorkspacePath = Settings != nullptr ? Settings->VSCodeWorkspacePath : FString();
		const bool bOpenFolderOnVSCodeSourceLinks = Settings != nullptr && Settings->bOpenFolderOnVSCodeSourceLinks;
		Params = BuildVSCodeOpenParametersInternal(MoveTemp(Params), VSCodeWorkspacePath, bOpenFolderOnVSCodeSourceLinks, ScriptRootDirectory);
		FPlatformMisc::OsExecute(nullptr, TEXT("code"), *Params);
	}

	TSharedPtr<FAngelscriptClassDesc> GetClassDesc(const UStruct* Struct, TSharedPtr<FAngelscriptModuleDesc>* OutModule = nullptr)
	{
		auto* ASClass = Cast<const UASClass>(Struct);
		if (ASClass != nullptr)
		{
			return FAngelscriptEngine::Get().GetClass(ASClass->GetPrefixCPP() + ASClass->GetName(), OutModule);
		}

		auto* ASStruct = Cast<const UASStruct>(Struct);
		if (ASStruct != nullptr)
		{
			return FAngelscriptEngine::Get().GetClass(ASStruct->GetPrefixCPP() + ASStruct->GetName(), OutModule);
		}

		return nullptr;
	}
};

namespace AngelscriptSourceNavigation
{
	bool NavigateToFunction(const UFunction* InFunction)
	{
		return GAngelscriptSourceCodeNavigationHandler != nullptr
			? GAngelscriptSourceCodeNavigationHandler->NavigateToFunction(InFunction)
			: false;
	}

	bool NavigateToProperty(const FProperty* InProperty)
	{
		return GAngelscriptSourceCodeNavigationHandler != nullptr
			? GAngelscriptSourceCodeNavigationHandler->NavigateToProperty(InProperty)
			: false;
	}

	bool NavigateToStruct(const UStruct* InStruct)
	{
		return GAngelscriptSourceCodeNavigationHandler != nullptr
			? GAngelscriptSourceCodeNavigationHandler->NavigateToStruct(InStruct)
			: false;
	}

	bool NavigateToFunctionForTesting(const UFunction* InFunction)
	{
		return NavigateToFunction(InFunction);
	}

	bool NavigateToPropertyForTesting(const FProperty* InProperty)
	{
		return NavigateToProperty(InProperty);
	}

	bool NavigateToStructForTesting(const UStruct* InStruct)
	{
		return NavigateToStruct(InStruct);
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
