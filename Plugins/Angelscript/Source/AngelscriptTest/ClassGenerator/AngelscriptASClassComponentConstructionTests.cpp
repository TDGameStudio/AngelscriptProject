#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Components/ActorComponent.h"
#include "Components/ActorTestSpawner.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/WeakObjectPtrTemplates.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASClassComponentConstructionTest
{
	static const FName ModuleName(TEXT("ASClassComponentConstruction"));
	static const FString ScriptFilename(TEXT("ASClassComponentConstruction.as"));
	static const FName GeneratedClassName(TEXT("UComponentConstructionCarrier"));
	static const FName CtorCountPropertyName(TEXT("CtorCount"));
	static const FName DefaultValuePropertyName(TEXT("DefaultValue"));
	static const FName DefaultLabelPropertyName(TEXT("DefaultLabel"));
	static const FString ExpectedDefaultLabel(TEXT("ComponentDefaults"));
	static constexpr int32 ExpectedCtorCount = 1;
	static constexpr int32 ExpectedDefaultValue = 9;

	struct FComponentConstructionSnapshot
	{
		int32 CtorCount = INDEX_NONE;
		int32 DefaultValue = INDEX_NONE;
		FString DefaultLabel;
	};

	UASClass* CompileComponentConstructionCarrier(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine)
	{
		const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UComponentConstructionCarrier : UActorComponent
{
	UPROPERTY()
	int CtorCount = 0;

	UPROPERTY()
	int DefaultValue = 0;

	UPROPERTY()
	FString DefaultLabel;

	UComponentConstructionCarrier()
	{
		CtorCount += 1;
	}

	default DefaultValue = 9;
	default DefaultLabel = "ComponentDefaults";
}
)AS");

		UClass* GeneratedClass = CompileScriptModule(
			Test,
			Engine,
			ModuleName,
			ScriptFilename,
			ScriptSource,
			GeneratedClassName);
		if (GeneratedClass == nullptr)
		{
			return nullptr;
		}

		UASClass* GeneratedASClass = Cast<UASClass>(GeneratedClass);
		if (!Test.TestNotNull(
				TEXT("ASClass component-construction scenario should compile the carrier into a UASClass"),
				GeneratedASClass))
		{
			return nullptr;
		}

		Test.TestNotNull(
			TEXT("ASClass component-construction scenario should bind the script constructor function"),
			GeneratedASClass->ConstructFunction);
		Test.TestNotNull(
			TEXT("ASClass component-construction scenario should bind the defaults function"),
			GeneratedASClass->DefaultsFunction);
		Test.TestNotNull(
			TEXT("ASClass component-construction scenario should keep a live script type pointer"),
			GeneratedASClass->ScriptTypePtr);

		return GeneratedASClass;
	}

	bool ReadConstructionSnapshot(
		FAutomationTestBase& Test,
		UObject* Object,
		FComponentConstructionSnapshot& OutSnapshot)
	{
		if (!ReadPropertyValue<FIntProperty>(Test, Object, CtorCountPropertyName, OutSnapshot.CtorCount))
		{
			return false;
		}

		if (!ReadPropertyValue<FIntProperty>(Test, Object, DefaultValuePropertyName, OutSnapshot.DefaultValue))
		{
			return false;
		}

		if (!ReadPropertyValue<FStrProperty>(Test, Object, DefaultLabelPropertyName, OutSnapshot.DefaultLabel))
		{
			return false;
		}

		return true;
	}

	bool VerifySnapshot(
		FAutomationTestBase& Test,
		const FString& ScopeLabel,
		const FComponentConstructionSnapshot& Snapshot,
		int32 ExpectedCtorCountForScope)
	{
		const bool bCtorCountMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should observe the expected constructor count"), *ScopeLabel),
			Snapshot.CtorCount,
			ExpectedCtorCountForScope);
		const bool bDefaultValueMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the scripted integer default"), *ScopeLabel),
			Snapshot.DefaultValue,
			ExpectedDefaultValue);
		const bool bDefaultLabelMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the scripted string default"), *ScopeLabel),
			Snapshot.DefaultLabel,
			ExpectedDefaultLabel);

		return bCtorCountMatches && bDefaultValueMatches && bDefaultLabelMatches;
	}

	UActorComponent* InstantiateScriptComponent(
		FAutomationTestBase& Test,
		AActor& OwnerActor,
		UClass* ComponentClass,
		const TCHAR* InstanceName,
		const TCHAR* Context)
	{
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should compile to a valid generated component class"), Context),
				ComponentClass))
		{
			return nullptr;
		}

		UActorComponent* Component = NewObject<UActorComponent>(&OwnerActor, ComponentClass, InstanceName);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should instantiate a runtime component"), Context),
				Component))
		{
			return nullptr;
		}

		Test.TestTrue(
			*FString::Printf(TEXT("%s should keep the host actor as the typed outer"), Context),
			Component->GetTypedOuter<AActor>() == &OwnerActor);
		Test.TestTrue(
			*FString::Printf(TEXT("%s should resolve the host actor as owner even before registration"), Context),
			Component->GetOwner() == &OwnerActor);

		return Component;
	}

	void ReleaseComponent(TWeakObjectPtr<UActorComponent>& WeakComponent)
	{
		if (!WeakComponent.IsValid())
		{
			return;
		}

		WeakComponent->RemoveFromRoot();
		WeakComponent->MarkAsGarbage();
		WeakComponent = nullptr;
	}
}

using namespace ASClassComponentConstructionTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassStaticComponentConstructorAppliesScriptConstructorAndDefaultsOnceTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.StaticComponentConstructorAppliesScriptConstructorAndDefaultsOnce",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassStaticComponentConstructorAppliesScriptConstructorAndDefaultsOnceTest::RunTest(const FString& Parameters)
{
	bool bVerified = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassComponentConstructionTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
		CollectGarbage(RF_NoFlags, true);
	};

	UASClass* GeneratedASClass = ASClassComponentConstructionTest::CompileComponentConstructionCarrier(*this, Engine);
	if (GeneratedASClass == nullptr)
	{
		return false;
	}

	UActorComponent* DefaultObject = Cast<UActorComponent>(GeneratedASClass->GetDefaultObject());
	if (!TestNotNull(
			TEXT("ASClass component-construction scenario should expose a generated component class default object"),
			DefaultObject))
	{
		return false;
	}

	ASClassComponentConstructionTest::FComponentConstructionSnapshot DefaultSnapshot;
	if (!ASClassComponentConstructionTest::ReadConstructionSnapshot(*this, DefaultObject, DefaultSnapshot))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor& HostActor = Spawner.SpawnActor<AActor>();

	UActorComponent* FirstInstance = ASClassComponentConstructionTest::InstantiateScriptComponent(
		*this,
		HostActor,
		GeneratedASClass,
		TEXT("ComponentConstructionCarrierA"),
		TEXT("ASClass component-construction scenario first instance"));
	UActorComponent* SecondInstance = ASClassComponentConstructionTest::InstantiateScriptComponent(
		*this,
		HostActor,
		GeneratedASClass,
		TEXT("ComponentConstructionCarrierB"),
		TEXT("ASClass component-construction scenario second instance"));
	if (FirstInstance == nullptr || SecondInstance == nullptr)
	{
		return false;
	}

	FirstInstance->AddToRoot();
	SecondInstance->AddToRoot();

	TWeakObjectPtr<UActorComponent> WeakFirstInstance = FirstInstance;
	TWeakObjectPtr<UActorComponent> WeakSecondInstance = SecondInstance;
	ON_SCOPE_EXIT
	{
		ASClassComponentConstructionTest::ReleaseComponent(WeakSecondInstance);
		ASClassComponentConstructionTest::ReleaseComponent(WeakFirstInstance);
	};

	ASClassComponentConstructionTest::FComponentConstructionSnapshot FirstSnapshot;
	ASClassComponentConstructionTest::FComponentConstructionSnapshot SecondSnapshot;
	if (!ASClassComponentConstructionTest::ReadConstructionSnapshot(*this, FirstInstance, FirstSnapshot)
		|| !ASClassComponentConstructionTest::ReadConstructionSnapshot(*this, SecondInstance, SecondSnapshot))
	{
		return false;
	}

	TestTrue(
		TEXT("ASClass component-construction scenario should compile a generated component class"),
		GeneratedASClass->IsChildOf(UActorComponent::StaticClass()));
	TestFalse(
		TEXT("ASClass component-construction scenario should keep the generated class out of the actor hierarchy"),
		GeneratedASClass->IsChildOf(AActor::StaticClass()));
	TestTrue(
		TEXT("ASClass component-construction scenario should create distinct runtime components"),
		FirstInstance != SecondInstance);
	TestTrue(
		TEXT("ASClass component-construction scenario should keep runtime components distinct from the class default object"),
		FirstInstance != DefaultObject && SecondInstance != DefaultObject);
	TestTrue(
		TEXT("ASClass component-construction scenario should keep both runtime components on the same generated class"),
		FirstInstance->GetClass() == GeneratedASClass && SecondInstance->GetClass() == GeneratedASClass);

	const bool bDefaultObjectVerified = ASClassComponentConstructionTest::VerifySnapshot(
		*this,
		TEXT("ASClass component-construction scenario class default object"),
		DefaultSnapshot,
		ASClassComponentConstructionTest::ExpectedCtorCount);
	const bool bFirstInstanceVerified = ASClassComponentConstructionTest::VerifySnapshot(
		*this,
		TEXT("ASClass component-construction scenario first instance"),
		FirstSnapshot,
		ASClassComponentConstructionTest::ExpectedCtorCount);
	const bool bSecondInstanceVerified = ASClassComponentConstructionTest::VerifySnapshot(
		*this,
		TEXT("ASClass component-construction scenario second instance"),
		SecondSnapshot,
		ASClassComponentConstructionTest::ExpectedCtorCount);

	TestEqual(
		TEXT("ASClass component-construction scenario should keep the second instance constructor count isolated from the first instance"),
		SecondSnapshot.CtorCount,
		ASClassComponentConstructionTest::ExpectedCtorCount);
	TestEqual(
		TEXT("ASClass component-construction scenario should keep the class default object on the same scripted integer default as runtime instances"),
		DefaultSnapshot.DefaultValue,
		FirstSnapshot.DefaultValue);
	TestEqual(
		TEXT("ASClass component-construction scenario should keep both runtime components on the same scripted integer default"),
		FirstSnapshot.DefaultValue,
		SecondSnapshot.DefaultValue);
	TestEqual(
		TEXT("ASClass component-construction scenario should keep the class default object on the same scripted string default as runtime instances"),
		DefaultSnapshot.DefaultLabel,
		FirstSnapshot.DefaultLabel);
	TestEqual(
		TEXT("ASClass component-construction scenario should keep both runtime components on the same scripted string default"),
		FirstSnapshot.DefaultLabel,
		SecondSnapshot.DefaultLabel);

	bVerified = bDefaultObjectVerified && bFirstInstanceVerified && bSecondInstanceVerified;

	ASTEST_END_SHARE_FRESH
	return bVerified;
}

#endif
