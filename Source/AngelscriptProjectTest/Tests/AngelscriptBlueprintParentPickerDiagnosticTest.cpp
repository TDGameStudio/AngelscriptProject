#include "ClassGenerator/ASClass.h"
#include "ClassViewerFilter.h"
#include "ClassViewerModule.h"
#include "EdGraphSchema_K2.h"
#include "Editor.h"
#include "GameFramework/Actor.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"
#include "Modules/ModuleManager.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "UObject/UObjectIterator.h"

#if WITH_DEV_AUTOMATION_TESTS && WITH_EDITOR

namespace AngelscriptProjectBlueprintParentPickerDiagnostic
{
constexpr const TCHAR* TargetClassName = TEXT("AExampleActorType");

static FString BoolText(bool bValue)
{
	return bValue ? TEXT("true") : TEXT("false");
}

static FString ObjectPath(UObject* Object)
{
	return Object != nullptr ? Object->GetPathName() : TEXT("<null>");
}

static FString ClassFlagsText(const UClass* Class)
{
	TArray<FString> Names;
	if (Class->HasAnyClassFlags(CLASS_Abstract))
	{
		Names.Add(TEXT("Abstract"));
	}
	if (Class->HasAnyClassFlags(CLASS_Deprecated))
	{
		Names.Add(TEXT("Deprecated"));
	}
	if (Class->HasAnyClassFlags(CLASS_NewerVersionExists))
	{
		Names.Add(TEXT("NewerVersionExists"));
	}
	if (Class->HasAnyClassFlags(CLASS_HideDropDown))
	{
		Names.Add(TEXT("HideDropDown"));
	}
	if (Class->HasAnyClassFlags(CLASS_Hidden))
	{
		Names.Add(TEXT("Hidden"));
	}
	if (Class->HasAnyClassFlags(CLASS_NotPlaceable))
	{
		Names.Add(TEXT("NotPlaceable"));
	}
	if (Class->HasAnyClassFlags(CLASS_Transient))
	{
		Names.Add(TEXT("ClassTransient"));
	}
	if (Class->HasAnyClassFlags(CLASS_Native))
	{
		Names.Add(TEXT("Native"));
	}

	return Names.Num() > 0 ? FString::Join(Names, TEXT("|")) : TEXT("<none>");
}

static void LogClassState(FAutomationTestBase& Test, const UClass* Class)
{
	const UASClass* ASClass = Cast<UASClass>(Class);
	const bool bCanCreateBlueprint = FKismetEditorUtilities::CanCreateBlueprintOfClass(Class);
	const bool bIsBlueprintBase = Class->GetBoolMetaDataHierarchical(FBlueprintMetadata::MD_IsBlueprintBase);
	const bool bBlueprintType = Class->GetBoolMetaDataHierarchical(TEXT("BlueprintType"));

	Test.AddInfo(FString::Printf(TEXT("[AExampleActorType candidate] path=%s"), *Class->GetPathName()));
	Test.AddInfo(FString::Printf(TEXT("  super=%s package=%s outermost=%s"),
		*ObjectPath(Class->GetSuperClass()),
		*ObjectPath(Class->GetPackage()),
		*ObjectPath(Class->GetOutermost())));
	Test.AddInfo(FString::Printf(TEXT("  isUASClass=%s source=%s relativeSource=%s"),
		*BoolText(ASClass != nullptr),
		ASClass != nullptr ? *ASClass->GetSourceFilePath() : TEXT("<not-as-class>"),
		ASClass != nullptr ? *ASClass->GetRelativeSourceFilePath() : TEXT("<not-as-class>")));
	Test.AddInfo(FString::Printf(TEXT("  metadata BlueprintType=%s IsBlueprintBase=%s hasNotBlueprintable=%s"),
		*BoolText(bBlueprintType),
		*BoolText(bIsBlueprintBase),
		*BoolText(Class->HasMetaData(TEXT("NotBlueprintable")))));
	Test.AddInfo(FString::Printf(TEXT("  flags class=0x%08X [%s] object=0x%08X RF_Transient=%s"),
		static_cast<uint32>(Class->ClassFlags),
		*ClassFlagsText(Class),
		static_cast<uint32>(Class->GetFlags()),
		*BoolText(Class->HasAnyFlags(RF_Transient))));
	Test.AddInfo(FString::Printf(TEXT("  ClassGeneratedBy=%s transientPackage=%s CanCreateBlueprintOfClass=%s"),
		*ObjectPath(Class->ClassGeneratedBy),
		*BoolText(Class->GetOutermost() == GetTransientPackage()),
		*BoolText(bCanCreateBlueprint)));
}

static UClass* FindTargetClass(FAutomationTestBase& Test, TArray<UClass*>& OutMatchingClasses)
{
	for (TObjectIterator<UClass> It; It; ++It)
	{
		UClass* Class = *It;
		if (Class->GetFName() == FName(TargetClassName))
		{
			OutMatchingClasses.Add(Class);
		}
	}

	Test.AddInfo(FString::Printf(TEXT("Found %d loaded UClass object(s) named %s"),
		OutMatchingClasses.Num(),
		TargetClassName));

	UClass* FirstUsableASClass = nullptr;
	UClass* FirstClass = nullptr;
	for (UClass* Class : OutMatchingClasses)
	{
		LogClassState(Test, Class);
		if (FirstClass == nullptr)
		{
			FirstClass = Class;
		}
		if (FirstUsableASClass == nullptr
			&& Cast<UASClass>(Class) != nullptr
			&& !Class->HasAnyClassFlags(CLASS_NewerVersionExists)
			&& !Class->HasAnyFlags(RF_Transient))
		{
			FirstUsableASClass = Class;
		}
	}

	return FirstUsableASClass != nullptr ? FirstUsableASClass : FirstClass;
}

static bool IsAllowedByStandardBlueprintPicker(UClass* Class)
{
	FClassViewerInitializationOptions Options;
	Options.Mode = EClassViewerMode::ClassPicker;
	Options.DisplayMode = EClassViewerDisplayMode::TreeView;
	Options.bShowObjectRootClass = true;
	Options.bIsBlueprintBaseOnly = true;
	Options.bShowUnloadedBlueprints = true;
	Options.bEnableClassDynamicLoading = true;
	Options.NameTypeToDisplay = EClassViewerNameTypeToDisplay::Dynamic;

	class FBlueprintFactoryParentFilter final : public IClassViewerFilter
	{
	public:
		bool IsClassAllowed(
			const FClassViewerInitializationOptions& InInitOptions,
			const UClass* InClass,
			TSharedRef<FClassViewerFilterFuncs> InFilterFuncs) override
		{
			return InFilterFuncs->IfInChildOfClassesSet(DisallowedChildrenOfClasses, InClass) != EFilterReturn::Passed
				&& !InClass->HasAnyClassFlags(CLASS_Deprecated);
		}

		bool IsUnloadedClassAllowed(
			const FClassViewerInitializationOptions& InInitOptions,
			const TSharedRef<const IUnloadedBlueprintData> InUnloadedClassData,
			TSharedRef<FClassViewerFilterFuncs> InFilterFuncs) override
		{
			return InFilterFuncs->IfInChildOfClassesSet(DisallowedChildrenOfClasses, InUnloadedClassData) != EFilterReturn::Passed
				&& !InUnloadedClassData->HasAnyClassFlags(CLASS_Deprecated);
		}

		TSet<const UClass*> DisallowedChildrenOfClasses;
	};

	TSharedRef<FBlueprintFactoryParentFilter> ParentFilter = MakeShared<FBlueprintFactoryParentFilter>();
	ParentFilter->DisallowedChildrenOfClasses.Add(UInterface::StaticClass());
	Options.ClassFilters.Add(ParentFilter);

	FClassViewerModule& ClassViewerModule = FModuleManager::LoadModuleChecked<FClassViewerModule>(TEXT("ClassViewer"));
	TSharedRef<IClassViewerFilter> StandardFilter = ClassViewerModule.CreateClassFilter(Options);
	TSharedRef<FClassViewerFilterFuncs> FilterFuncs = ClassViewerModule.CreateFilterFuncs();
	return StandardFilter->IsClassAllowed(Options, Class, FilterFuncs);
}

}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintParentPickerDiagnosticTest,
	"AngelscriptProject.Diagnostic.BlueprintParentPicker.AExampleActorTypeEligibility",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBlueprintParentPickerDiagnosticTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptProjectBlueprintParentPickerDiagnostic;

	FAngelscriptEngine* CurrentEngine = FAngelscriptEngine::TryGetCurrentEngine();
	if (CurrentEngine != nullptr)
	{
		if (UClass* HelperClass = FindGeneratedClass(CurrentEngine, FName(TargetClassName)))
		{
			AddInfo(FString::Printf(TEXT("AngelscriptTest helper FindGeneratedClass resolved %s"), *HelperClass->GetPathName()));
		}
		else
		{
			AddInfo(TEXT("AngelscriptTest helper FindGeneratedClass did not resolve AExampleActorType from the current engine"));
		}
	}
	else
	{
		AddInfo(TEXT("No current FAngelscriptEngine was installed; falling back to loaded UObject class scan"));
	}

	TArray<UClass*> MatchingClasses;
	UClass* TargetClass = FindTargetClass(*this, MatchingClasses);
	if (!TestNotNull(TEXT("AExampleActorType should be loaded as a UClass"), TargetClass))
	{
		return false;
	}

	LogClassState(*this, TargetClass);

	TestTrue(TEXT("AExampleActorType should be an Angelscript UASClass"), Cast<UASClass>(TargetClass) != nullptr);
	TestTrue(TEXT("AExampleActorType should derive from AActor"), TargetClass->IsChildOf(AActor::StaticClass()));
	TestTrue(TEXT("AExampleActorType should keep IsBlueprintBase metadata"), TargetClass->GetBoolMetaDataHierarchical(FBlueprintMetadata::MD_IsBlueprintBase));
	TestFalse(TEXT("AExampleActorType should not be Abstract"), TargetClass->HasAnyClassFlags(CLASS_Abstract));
	TestFalse(TEXT("AExampleActorType should not be Deprecated"), TargetClass->HasAnyClassFlags(CLASS_Deprecated));
	TestFalse(TEXT("AExampleActorType should not have a newer generated version"), TargetClass->HasAnyClassFlags(CLASS_NewerVersionExists));
	TestFalse(TEXT("AExampleActorType should not be HideDropDown"), TargetClass->HasAnyClassFlags(CLASS_HideDropDown));
	TestFalse(TEXT("AExampleActorType should not be Hidden"), TargetClass->HasAnyClassFlags(CLASS_Hidden));
	TestFalse(TEXT("AExampleActorType should not be transient"), TargetClass->HasAnyFlags(RF_Transient));
	TestTrue(TEXT("AExampleActorType should pass FKismetEditorUtilities::CanCreateBlueprintOfClass"), FKismetEditorUtilities::CanCreateBlueprintOfClass(TargetClass));
	TestTrue(TEXT("AExampleActorType should pass the standard Blueprint parent class viewer filter"), IsAllowedByStandardBlueprintPicker(TargetClass));

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintParentPickerRefreshSignalTest,
	"AngelscriptProject.Diagnostic.BlueprintParentPicker.ScriptClassRefreshSignal",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBlueprintParentPickerRefreshSignalTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptProjectBlueprintParentPickerDiagnostic;

	if (!TestNotNull(TEXT("Blueprint parent picker refresh test should expose GEditor"), GEditor))
	{
		return false;
	}

	FAngelscriptEngine* Engine = FAngelscriptEngine::TryGetCurrentEngine();
	if (!TestNotNull(TEXT("Blueprint parent picker refresh test should run with a current Angelscript engine"), Engine))
	{
		return false;
	}

	const FString UniqueSuffix = FGuid::NewGuid().ToString(EGuidFormats::Digits);
	const FName ModuleName(*FString::Printf(TEXT("Project.BlueprintParentPicker.RefreshSignal.%s"), *UniqueSuffix));
	const FString Filename = FString::Printf(TEXT("Project/BlueprintParentPickerRefreshSignal_%s.as"), *UniqueSuffix);
	const FString ClassName = FString::Printf(TEXT("AProjectPickerRefreshSignal_%s"), *UniqueSuffix.Left(12));
	const FString Script = FString::Printf(TEXT(R"(
class %s : AActor
{
}
)"), *ClassName);

	int32 ClassPackageRefreshCalls = 0;
	const FDelegateHandle ClassPackageRefreshHandle = GEditor->OnClassPackageLoadedOrUnloaded().AddLambda([&ClassPackageRefreshCalls]()
	{
		++ClassPackageRefreshCalls;
	});

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		Filename,
		Script,
		CompileResult);
	ON_SCOPE_EXIT
	{
		if (GEditor != nullptr)
		{
			GEditor->OnClassPackageLoadedOrUnloaded().Remove(ClassPackageRefreshHandle);
		}
		Engine->DiscardModule(*ModuleName.ToString());
	};

	if (!TestTrue(TEXT("Soft reload should compile a brand-new script Actor class"), bCompiled))
	{
		AddError(FString::Printf(TEXT("Compile result: %d"), static_cast<int32>(CompileResult)));
		return false;
	}

	UClass* GeneratedClass = FindGeneratedClass(Engine, FName(*ClassName));
	if (!TestNotNull(TEXT("Soft reload should materialize the script Actor class"), GeneratedClass))
	{
		return false;
	}

	TestTrue(TEXT("Generated script Actor should pass Blueprint creation eligibility"), FKismetEditorUtilities::CanCreateBlueprintOfClass(GeneratedClass));
	TestTrue(TEXT("Generated script Actor should pass the standard Blueprint parent picker filter"), IsAllowedByStandardBlueprintPicker(GeneratedClass));
	TestTrue(TEXT("Script class creation should request a standard ClassViewer hierarchy refresh"), ClassPackageRefreshCalls > 0);

	return true;
}

#endif
