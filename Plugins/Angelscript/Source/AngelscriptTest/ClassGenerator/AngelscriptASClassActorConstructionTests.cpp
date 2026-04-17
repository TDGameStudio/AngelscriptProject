#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Components/ActorTestSpawner.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASClassActorConstructionTest
{
	static const FName ModuleName(TEXT("ASClassActorConstruction"));
	static const FString ScriptFilename(TEXT("ASClassActorConstruction.as"));
	static const FName GeneratedClassName(TEXT("AActorConstructionCarrier"));
	static const FName CtorCountPropertyName(TEXT("CtorCount"));
	static const FName DefaultValuePropertyName(TEXT("DefaultValue"));
	static const FName DefaultLabelPropertyName(TEXT("DefaultLabel"));
	static const FString ExpectedDefaultLabel(TEXT("ActorDefaults"));
	static constexpr int32 ExpectedCtorCount = 1;
	static constexpr int32 ExpectedDefaultValue = 11;

	struct FActorConstructionSnapshot
	{
		int32 CtorCount = INDEX_NONE;
		int32 DefaultValue = INDEX_NONE;
		FString DefaultLabel;
	};

	UASClass* CompileActorConstructionCarrier(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine)
	{
		const FString ScriptSource = TEXT(R"AS(
UCLASS()
class AActorConstructionCarrier : AActor
{
	UPROPERTY()
	int CtorCount = 0;

	UPROPERTY()
	int DefaultValue = 0;

	UPROPERTY()
	FString DefaultLabel;

	AActorConstructionCarrier()
	{
		CtorCount += 1;
	}

	default DefaultValue = 11;
	default DefaultLabel = "ActorDefaults";
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
				TEXT("ASClass actor-construction scenario should compile the carrier into a UASClass"),
				GeneratedASClass))
		{
			return nullptr;
		}

		Test.TestNotNull(
			TEXT("ASClass actor-construction scenario should bind the script constructor function"),
			GeneratedASClass->ConstructFunction);
		Test.TestNotNull(
			TEXT("ASClass actor-construction scenario should bind the defaults function"),
			GeneratedASClass->DefaultsFunction);
		Test.TestNotNull(
			TEXT("ASClass actor-construction scenario should keep a live script type pointer"),
			GeneratedASClass->ScriptTypePtr);

		return GeneratedASClass;
	}

	bool ReadConstructionSnapshot(
		FAutomationTestBase& Test,
		UObject* Object,
		FActorConstructionSnapshot& OutSnapshot)
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

	bool VerifyDefaults(
		FAutomationTestBase& Test,
		const FString& ScopeLabel,
		const FActorConstructionSnapshot& Snapshot)
	{
		const bool bDefaultValueMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the scripted integer default"), *ScopeLabel),
			Snapshot.DefaultValue,
			ExpectedDefaultValue);
		const bool bDefaultLabelMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the scripted string default"), *ScopeLabel),
			Snapshot.DefaultLabel,
			ExpectedDefaultLabel);

		return bDefaultValueMatches && bDefaultLabelMatches;
	}

	bool VerifyInstanceSnapshot(
		FAutomationTestBase& Test,
		const FString& ScopeLabel,
		const FActorConstructionSnapshot& Snapshot)
	{
		const bool bCtorCountMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should observe the expected constructor count"), *ScopeLabel),
			Snapshot.CtorCount,
			ExpectedCtorCount);

		return bCtorCountMatches
			&& VerifyDefaults(Test, ScopeLabel, Snapshot);
	}
}

using namespace ASClassActorConstructionTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassStaticActorConstructorAppliesScriptConstructorAndDefaultsOnceTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.StaticActorConstructorAppliesScriptConstructorAndDefaultsOnce",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassStaticActorConstructorAppliesScriptConstructorAndDefaultsOnceTest::RunTest(const FString& Parameters)
{
	bool bVerified = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassActorConstructionTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
		CollectGarbage(RF_NoFlags, true);
	};

	UASClass* GeneratedASClass = ASClassActorConstructionTest::CompileActorConstructionCarrier(*this, Engine);
	if (GeneratedASClass == nullptr)
	{
		return false;
	}

	AActor* DefaultObject = Cast<AActor>(GeneratedASClass->GetDefaultObject());
	if (!TestNotNull(
			TEXT("ASClass actor-construction scenario should expose a generated actor class default object"),
			DefaultObject))
	{
		return false;
	}

	ASClassActorConstructionTest::FActorConstructionSnapshot DefaultSnapshot;
	if (!ASClassActorConstructionTest::ReadConstructionSnapshot(*this, DefaultObject, DefaultSnapshot))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor* FirstActor = SpawnScriptActor(*this, Spawner, GeneratedASClass);
	AActor* SecondActor = SpawnScriptActor(*this, Spawner, GeneratedASClass);
	if (!TestNotNull(TEXT("ASClass actor-construction scenario should spawn the first generated actor"), FirstActor)
		|| !TestNotNull(TEXT("ASClass actor-construction scenario should spawn the second generated actor"), SecondActor))
	{
		return false;
	}

	ASClassActorConstructionTest::FActorConstructionSnapshot FirstSnapshot;
	ASClassActorConstructionTest::FActorConstructionSnapshot SecondSnapshot;
	if (!ASClassActorConstructionTest::ReadConstructionSnapshot(*this, FirstActor, FirstSnapshot)
		|| !ASClassActorConstructionTest::ReadConstructionSnapshot(*this, SecondActor, SecondSnapshot))
	{
		return false;
	}

	TestTrue(
		TEXT("ASClass actor-construction scenario should compile a generated actor class"),
		GeneratedASClass->IsChildOf(AActor::StaticClass()));
	TestTrue(
		TEXT("ASClass actor-construction scenario should keep runtime actors on the generated class"),
		FirstActor->GetClass() == GeneratedASClass && SecondActor->GetClass() == GeneratedASClass);
	TestTrue(
		TEXT("ASClass actor-construction scenario should create distinct runtime actor instances"),
		FirstActor != SecondActor);
	TestTrue(
		TEXT("ASClass actor-construction scenario should keep runtime actors distinct from the class default object"),
		FirstActor != DefaultObject && SecondActor != DefaultObject);

	const bool bDefaultObjectVerified = ASClassActorConstructionTest::VerifyDefaults(
		*this,
		TEXT("ASClass actor-construction scenario class default object"),
		DefaultSnapshot);
	const bool bFirstActorVerified = ASClassActorConstructionTest::VerifyInstanceSnapshot(
		*this,
		TEXT("ASClass actor-construction scenario first spawned actor"),
		FirstSnapshot);
	const bool bSecondActorVerified = ASClassActorConstructionTest::VerifyInstanceSnapshot(
		*this,
		TEXT("ASClass actor-construction scenario second spawned actor"),
		SecondSnapshot);

	TestEqual(
		TEXT("ASClass actor-construction scenario should keep the second actor constructor count isolated from the first actor"),
		SecondSnapshot.CtorCount,
		ASClassActorConstructionTest::ExpectedCtorCount);
	TestEqual(
		TEXT("ASClass actor-construction scenario should keep the class default object on the same scripted integer default as spawned actors"),
		DefaultSnapshot.DefaultValue,
		FirstSnapshot.DefaultValue);
	TestEqual(
		TEXT("ASClass actor-construction scenario should keep both spawned actors on the same scripted integer default"),
		FirstSnapshot.DefaultValue,
		SecondSnapshot.DefaultValue);
	TestEqual(
		TEXT("ASClass actor-construction scenario should keep the class default object on the same scripted string default as spawned actors"),
		DefaultSnapshot.DefaultLabel,
		FirstSnapshot.DefaultLabel);
	TestEqual(
		TEXT("ASClass actor-construction scenario should keep both spawned actors on the same scripted string default"),
		FirstSnapshot.DefaultLabel,
		SecondSnapshot.DefaultLabel);

	bVerified = bDefaultObjectVerified && bFirstActorVerified && bSecondActorVerified;

	ASTEST_END_SHARE_FRESH
	return bVerified;
}

#endif
