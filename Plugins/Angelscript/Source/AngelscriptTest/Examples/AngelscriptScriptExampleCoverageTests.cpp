#include "../Shared/AngelscriptScenarioTestUtils.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptComponent.h"
#include "Components/ActorTestSpawner.h"
#include "Components/BillboardComponent.h"
#include "Components/SceneComponent.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Examples_AngelscriptScriptExampleCoverageTests_Private
{
	constexpr float CoverageTickDeltaTime = 0.016f;

	FString GetCoverageExampleAbsolutePath(const TCHAR* RelativePath)
	{
		return FPaths::ConvertRelativePathToFull(FPaths::ProjectDir(), RelativePath);
	}

	bool ExpectCoverageExampleExists(FAutomationTestBase& Test, const TCHAR* RelativePath)
	{
		const FString AbsolutePath = GetCoverageExampleAbsolutePath(RelativePath);
		if (!Test.TestTrue(*FString::Printf(TEXT("Coverage example '%s' should exist on disk"), RelativePath), FPaths::FileExists(AbsolutePath)))
		{
			return false;
		}
		return true;
	}

	UClass* CompileCoverageExample(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		FName ModuleName,
		const TCHAR* RelativePath,
		FName GeneratedClassName)
	{
		if (!ExpectCoverageExampleExists(Test, RelativePath))
		{
			return nullptr;
		}

		FString ScriptSource;
		const FString AbsolutePath = GetCoverageExampleAbsolutePath(RelativePath);
		if (!Test.TestTrue(
			*FString::Printf(TEXT("Coverage example '%s' should load from disk"), RelativePath),
			FFileHelper::LoadFileToString(ScriptSource, *AbsolutePath)))
		{
			return nullptr;
		}

		return CompileScriptModule(Test, Engine, ModuleName, RelativePath, ScriptSource, GeneratedClassName);
	}

	template <typename ComponentType = UActorComponent>
	ComponentType* CreateCoverageRuntimeComponent(
		FAutomationTestBase& Test,
		AActor& OwnerActor,
		UClass* ComponentClass,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should compile to a valid component class"), Context), ComponentClass))
		{
			return nullptr;
		}

		UActorComponent* Component = NewObject<UActorComponent>(&OwnerActor, ComponentClass);
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should instantiate a runtime component"), Context), Component))
		{
			return nullptr;
		}

		OwnerActor.AddInstanceComponent(Component);
		Component->OnComponentCreated();
		Component->RegisterComponent();
		Component->Activate(true);

		ComponentType* TypedComponent = Cast<ComponentType>(Component);
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should produce the expected component type"), Context), TypedComponent))
		{
			return nullptr;
		}

		return TypedComponent;
	}

	FProperty* RequireProperty(FAutomationTestBase& Test, UClass* Class, const TCHAR* PropertyName)
	{
		FProperty* Property = FindFProperty<FProperty>(Class, PropertyName);
		Test.TestNotNull(*FString::Printf(TEXT("Coverage property '%s' should exist"), PropertyName), Property);
		return Property;
	}

	bool ExpectPropertyFlag(FAutomationTestBase& Test, FProperty* Property, EPropertyFlags Flags, const TCHAR* Message)
	{
		if (!Test.TestNotNull(TEXT("Coverage property should be valid before checking property flags"), Property))
		{
			return false;
		}

		return Test.TestTrue(Message, Property->HasAnyPropertyFlags(Flags));
	}

	bool ExpectPropertyMetadata(FAutomationTestBase& Test, FProperty* Property, const TCHAR* Key, const TCHAR* ExpectedValue)
	{
		if (!Test.TestNotNull(TEXT("Coverage property should be valid before checking metadata"), Property))
		{
			return false;
		}

		return Test.TestEqual(
			*FString::Printf(TEXT("Coverage property metadata '%s' should match"), Key),
			Property->GetMetaData(Key),
			FString(ExpectedValue));
	}

	bool ExpectPropertyMetadataExists(FAutomationTestBase& Test, FProperty* Property, const TCHAR* Key)
	{
		if (!Test.TestNotNull(TEXT("Coverage property should be valid before checking metadata existence"), Property))
		{
			return false;
		}

		return Test.TestTrue(
			*FString::Printf(TEXT("Coverage property should contain metadata key '%s'"), Key),
			Property->HasMetaData(Key));
	}
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleCoverageTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptExampleCoverageActorTest,
	"Angelscript.TestModule.ScriptExamples.Coverage.Actor",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#test-regression): UE 5.7 migration; verified still failing on full automation run. Needs individual root-cause analysis.

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptExampleCoverageComponentTest,
	"Angelscript.TestModule.ScriptExamples.Coverage.Component",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#test-regression): UE 5.7 migration; verified still failing on full automation run. Needs individual root-cause analysis.

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptExampleCoverageUObjectTest,
	"Angelscript.TestModule.ScriptExamples.Coverage.UObject",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#test-regression): UE 5.7 migration; verified still failing on full automation run. Needs individual root-cause analysis.

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptExampleCoveragePropertySpecifiersTest,
	"Angelscript.TestModule.ScriptExamples.Coverage.PropertySpecifiers",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#test-regression): UE 5.7 migration; verified still failing on full automation run. Needs individual root-cause analysis.

bool FAngelscriptScriptExampleCoverageActorTest::RunTest(const FString& Parameters)
{
	DestroySharedTestEngine();
	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	FAngelscriptEngine* ProductionEngine = RequireRunningProductionEngine(*this, TEXT("Coverage actor example tests require a production engine after subsystem initialization."));
	if (ProductionEngine == nullptr)
	{
		return false;
	}

	FAngelscriptEngine& Engine = *ProductionEngine;
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("CompanionScriptExampleCoverageActor"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileCoverageExample(*this, Engine, ModuleName, TEXT("Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_Actor.as"), TEXT("ACoverageExampleActor"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	int32 Health = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("Health"), Health))
	{
		return false;
	}

	FString DisplayName;
	if (!ReadPropertyValue<FStrProperty>(*this, Actor, TEXT("DisplayName"), DisplayName))
	{
		return false;
	}

	bool bBeginPlayTriggered = false;
	if (!ReadPropertyValue<FBoolProperty>(*this, Actor, TEXT("bBeginPlayTriggered"), bBeginPlayTriggered))
	{
		return false;
	}

	TestEqual(TEXT("Coverage actor example should preserve reflected int defaults"), Health, 125);
	TestEqual(TEXT("Coverage actor example should preserve reflected string defaults"), DisplayName, FString(TEXT("CoverageActor")));
	TestTrue(TEXT("Coverage actor example should execute BeginPlay override"), bBeginPlayTriggered);
	TestTrue(TEXT("Coverage actor example should enable replication through default statements"), Actor->GetIsReplicated());
	TestTrue(TEXT("Coverage actor example should preserve actor tags from default statements"), Actor->ActorHasTag(TEXT("CoverageActor")));
	TestTrue(TEXT("Coverage actor example should preserve tick interval defaults"), FMath::IsNearlyEqual(Actor->PrimaryActorTick.TickInterval, 0.25f));

	UFunction* GetHealthValueFunction = FindGeneratedFunction(ScriptClass, TEXT("GetHealthValue"));
	if (!TestNotNull(TEXT("Coverage actor example should expose helper UFUNCTION"), GetHealthValueFunction))
	{
		return false;
	}

	int32 FunctionResult = 0;
	if (!TestTrue(
		TEXT("Coverage actor example helper UFUNCTION should execute successfully"),
		ExecuteGeneratedIntEventOnGameThread(&Engine, Actor, GetHealthValueFunction, FunctionResult)))
	{
		return false;
	}

	TestEqual(TEXT("Coverage actor example helper UFUNCTION should return the reflected property value"), FunctionResult, 125);

	return true;
}

bool FAngelscriptScriptExampleCoverageComponentTest::RunTest(const FString& Parameters)
{
	DestroySharedTestEngine();
	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	FAngelscriptEngine* ProductionEngine = RequireRunningProductionEngine(*this, TEXT("Coverage component example tests require a production engine after subsystem initialization."));
	if (ProductionEngine == nullptr)
	{
		return false;
	}

	FAngelscriptEngine& Engine = *ProductionEngine;
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("CompanionScriptExampleCoverageComponent"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* OwnerActorClass = CompileCoverageExample(*this, Engine, ModuleName, TEXT("Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_Component.as"), TEXT("ACoverageComponentOwnerActor"));
	if (OwnerActorClass == nullptr)
	{
		return false;
	}

	UClass* ComponentClass = FindGeneratedClass(&Engine, TEXT("UCoverageExampleComponent"));
	if (!TestNotNull(TEXT("Coverage component example should generate the component class"), ComponentClass))
	{
		return false;
	}

	AActor* HostActor = SpawnScriptActor(*this, Spawner, OwnerActorClass);
	if (HostActor == nullptr)
	{
		return false;
	}

	UActorComponent* Component = CreateCoverageRuntimeComponent(*this, *HostActor, ComponentClass, TEXT("ScriptExamples.Coverage.Component"));
	if (Component == nullptr)
	{
		return false;
	}

	Component->PrimaryComponentTick.bCanEverTick = true;
	Component->SetComponentTickEnabled(true);
	BeginPlayActor(Engine, *HostActor);
	TickWorld(Engine, Spawner.GetWorld(), CoverageTickDeltaTime, 5);

	bool bReady = false;
	if (!ReadPropertyValue<FBoolProperty>(*this, Component, TEXT("bReady"), bReady))
	{
		return false;
	}

	int32 TickCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Component, TEXT("TickCount"), TickCount))
	{
		return false;
	}

	int32 ReadOwnerValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Component, TEXT("ReadOwnerValue"), ReadOwnerValue))
	{
		return false;
	}

	TestTrue(TEXT("Coverage component example should execute BeginPlay"), bReady);
	TestTrue(TEXT("Coverage component example should increment Tick during manual world ticks"), TickCount >= 5);
	TestEqual(TEXT("Coverage component example should read the owning actor's reflected property"), ReadOwnerValue, 77);

	return true;
}

bool FAngelscriptScriptExampleCoverageUObjectTest::RunTest(const FString& Parameters)
{
	DestroySharedTestEngine();
	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	FAngelscriptEngine* ProductionEngine = RequireRunningProductionEngine(*this, TEXT("Coverage UObject example tests require a production engine after subsystem initialization."));
	if (ProductionEngine == nullptr)
	{
		return false;
	}

	FAngelscriptEngine& Engine = *ProductionEngine;
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("CompanionScriptExampleCoverageUObject"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileCoverageExample(*this, Engine, ModuleName, TEXT("Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_UObject.as"), TEXT("UCoverageExampleObject"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UObject* Object = NewObject<UObject>(GetTransientPackage(), ScriptClass);
	if (!TestNotNull(TEXT("Coverage UObject example should instantiate a runtime UObject"), Object))
	{
		return false;
	}

	int32 Counter = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Object, TEXT("Counter"), Counter))
	{
		return false;
	}

	FString ObjectLabel;
	if (!ReadPropertyValue<FStrProperty>(*this, Object, TEXT("ObjectLabel"), ObjectLabel))
	{
		return false;
	}

	TestEqual(TEXT("Coverage UObject example should preserve reflected int defaults"), Counter, 9);
	TestEqual(TEXT("Coverage UObject example should preserve reflected string defaults"), ObjectLabel, FString(TEXT("CoverageObject")));

	UFunction* ComputeMarkerFunction = FindGeneratedFunction(ScriptClass, TEXT("ComputeMarker"));
	if (!TestNotNull(TEXT("Coverage UObject example should expose helper UFUNCTION"), ComputeMarkerFunction))
	{
		return false;
	}

	int32 FunctionResult = 0;
	if (!TestTrue(
		TEXT("Coverage UObject example helper UFUNCTION should execute successfully"),
		ExecuteGeneratedIntEventOnGameThread(&Engine, Object, ComputeMarkerFunction, FunctionResult)))
	{
		return false;
	}

	TestEqual(TEXT("Coverage UObject example helper UFUNCTION should read reflected state"), FunctionResult, 14);

	return true;
}

bool FAngelscriptScriptExampleCoveragePropertySpecifiersTest::RunTest(const FString& Parameters)
{
	DestroySharedTestEngine();
	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	FAngelscriptEngine* ProductionEngine = RequireRunningProductionEngine(*this, TEXT("Coverage property example tests require a production engine after subsystem initialization."));
	if (ProductionEngine == nullptr)
	{
		return false;
	}

	FAngelscriptEngine& Engine = *ProductionEngine;
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("CompanionScriptExampleCoveragePropertySpecifiers"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
	};

	UClass* ScriptClass = CompileCoverageExample(*this, Engine, ModuleName, TEXT("Documents/Plans/Plan_ScriptExamplesExpansion/Coverage/Example_Coverage_PropertySpecifiers.as"), TEXT("ACoveragePropertySpecifierActor"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	FProperty* CategorizedFloat = RequireProperty(*this, ScriptClass, TEXT("CategorizedFloat"));
	FProperty* HiddenToggle = RequireProperty(*this, ScriptClass, TEXT("bHiddenToggle"));
	FProperty* LockedToggle = RequireProperty(*this, ScriptClass, TEXT("bLockedToggle"));
	FProperty* BlueprintReadable = RequireProperty(*this, ScriptClass, TEXT("bBlueprintReadable"));
	FProperty* DefaultsOnlyValue = RequireProperty(*this, ScriptClass, TEXT("DefaultsOnlyValue"));
	FProperty* ClampedValue = RequireProperty(*this, ScriptClass, TEXT("ClampedValue"));
	FProperty* ConditionalFloat = RequireProperty(*this, ScriptClass, TEXT("ConditionalFloat"));
	FProperty* EditConditionToggle = RequireProperty(*this, ScriptClass, TEXT("bCanEditConditional"));
	FProperty* WidgetEditableVector = RequireProperty(*this, ScriptClass, TEXT("WidgetEditableVector"));

	if (CategorizedFloat == nullptr || HiddenToggle == nullptr || LockedToggle == nullptr || BlueprintReadable == nullptr || DefaultsOnlyValue == nullptr
		|| ClampedValue == nullptr || ConditionalFloat == nullptr || EditConditionToggle == nullptr || WidgetEditableVector == nullptr)
	{
		return false;
	}

	if (!ExpectPropertyMetadata(*this, CategorizedFloat, TEXT("Category"), TEXT("Coverage|Property")))
	{
		return false;
	}

	TestFalse(TEXT("Coverage NotEditable property should not be marked editable"), HiddenToggle->HasAnyPropertyFlags(CPF_Edit));
	if (!ExpectPropertyFlag(*this, LockedToggle, CPF_EditConst, TEXT("Coverage EditConst property should carry CPF_EditConst")))
	{
		return false;
	}

	if (!ExpectPropertyFlag(*this, BlueprintReadable, CPF_BlueprintVisible, TEXT("Coverage BlueprintReadOnly property should be Blueprint-visible"))
		|| !ExpectPropertyFlag(*this, BlueprintReadable, CPF_BlueprintReadOnly, TEXT("Coverage BlueprintReadOnly property should be Blueprint read-only"))
		|| !ExpectPropertyFlag(*this, DefaultsOnlyValue, CPF_DisableEditOnInstance, TEXT("Coverage EditDefaultsOnly property should disable instance editing")))
	{
		return false;
	}

	if (!ExpectPropertyMetadata(*this, ClampedValue, TEXT("ClampMin"), TEXT("0.0"))
		|| !ExpectPropertyMetadata(*this, ClampedValue, TEXT("ClampMax"), TEXT("1.0"))
		|| !ExpectPropertyMetadata(*this, ConditionalFloat, TEXT("EditCondition"), TEXT("bCanEditConditional"))
		|| !ExpectPropertyMetadataExists(*this, EditConditionToggle, TEXT("InlineEditConditionToggle"))
		|| !ExpectPropertyMetadataExists(*this, WidgetEditableVector, TEXT("MakeEditWidget")))
	{
		return false;
	}

	UClass* RootComponentClass = FindGeneratedClass(&Engine, TEXT("UCoveragePropertyRootComponent"));
	UClass* BillboardClass = FindGeneratedClass(&Engine, TEXT("UCoveragePropertyBillboardComponent"));
	if (!TestNotNull(TEXT("Coverage property example should generate the scripted root component class"), RootComponentClass)
		|| !TestNotNull(TEXT("Coverage property example should generate the scripted billboard component class"), BillboardClass))
	{
		return false;
	}

	USceneComponent* RootComponent = Actor->GetRootComponent();
	if (!TestNotNull(TEXT("Coverage property example should create the scripted root component"), RootComponent))
	{
		return false;
	}

	if (!TestTrue(TEXT("Coverage property example root component should use the scripted root component class"), RootComponent->IsA(RootComponentClass)))
	{
		return false;
	}

	UBillboardComponent* BillboardComponent = nullptr;
	for (UActorComponent* Component : Actor->GetComponents())
	{
		if (Component != nullptr && Component->IsA(BillboardClass))
		{
			BillboardComponent = Cast<UBillboardComponent>(Component);
			break;
		}
	}

	if (!TestNotNull(TEXT("Coverage property example should create the attached billboard component"), BillboardComponent))
	{
		return false;
	}

	TestTrue(TEXT("Coverage property example attached billboard should preserve the scripted hierarchy"), BillboardComponent->GetAttachParent() == RootComponent);
	return true;
}

#endif
