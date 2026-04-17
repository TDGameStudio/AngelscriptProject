#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/WeakObjectPtrTemplates.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASClassObjectConstructionTest
{
	static const FName ModuleName(TEXT("ASClassObjectConstruction"));
	static const FString ScriptFilename(TEXT("ASClassObjectConstruction.as"));
	static const FName GeneratedClassName(TEXT("UObjectConstructionCarrier"));
	static const FName CtorCountPropertyName(TEXT("CtorCount"));
	static const FName DefaultValuePropertyName(TEXT("DefaultValue"));
	static const FName DefaultLabelPropertyName(TEXT("DefaultLabel"));
	static const FString ExpectedDefaultLabel(TEXT("ObjectDefaults"));
	static constexpr int32 ExpectedCtorCount = 1;
	static constexpr int32 ExpectedDefaultValue = 7;

	struct FObjectConstructionSnapshot
	{
		int32 CtorCount = INDEX_NONE;
		int32 DefaultValue = INDEX_NONE;
		FString DefaultLabel;
	};

	UASClass* CompileObjectConstructionCarrier(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine)
	{
		const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UObjectConstructionCarrier : UObject
{
	UPROPERTY()
	int CtorCount = 0;

	UPROPERTY()
	int DefaultValue = 0;

	UPROPERTY()
	FString DefaultLabel;

	UObjectConstructionCarrier()
	{
		CtorCount += 1;
	}

	default DefaultValue = 7;
	default DefaultLabel = "ObjectDefaults";
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
				TEXT("ASClass object-construction scenario should compile the carrier into a UASClass"),
				GeneratedASClass))
		{
			return nullptr;
		}

		Test.TestNotNull(
			TEXT("ASClass object-construction scenario should bind the script constructor function"),
			GeneratedASClass->ConstructFunction);
		Test.TestNotNull(
			TEXT("ASClass object-construction scenario should bind the defaults function"),
			GeneratedASClass->DefaultsFunction);
		Test.TestNotNull(
			TEXT("ASClass object-construction scenario should keep a live script type pointer"),
			GeneratedASClass->ScriptTypePtr);

		return GeneratedASClass;
	}

	bool ReadConstructionSnapshot(
		FAutomationTestBase& Test,
		UObject* Object,
		FObjectConstructionSnapshot& OutSnapshot)
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
		const FObjectConstructionSnapshot& Snapshot,
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

	void ReleaseObject(TWeakObjectPtr<UObject>& WeakObject)
	{
		if (!WeakObject.IsValid())
		{
			return;
		}

		WeakObject->RemoveFromRoot();
		WeakObject->MarkAsGarbage();
		WeakObject = nullptr;
	}
}

using namespace ASClassObjectConstructionTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassStaticObjectConstructorAppliesScriptConstructorAndDefaultsOnceTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.StaticObjectConstructorAppliesScriptConstructorAndDefaultsOnce",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassStaticObjectConstructorAppliesScriptConstructorAndDefaultsOnceTest::RunTest(const FString& Parameters)
{
	bool bVerified = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassObjectConstructionTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
		CollectGarbage(RF_NoFlags, true);
	};

	UASClass* GeneratedASClass = ASClassObjectConstructionTest::CompileObjectConstructionCarrier(*this, Engine);
	if (GeneratedASClass == nullptr)
	{
		return false;
	}

	UObject* DefaultObject = GeneratedASClass->GetDefaultObject();
	if (!TestNotNull(
			TEXT("ASClass object-construction scenario should expose a generated class default object"),
			DefaultObject))
	{
		return false;
	}

	ASClassObjectConstructionTest::FObjectConstructionSnapshot DefaultSnapshot;
	if (!ASClassObjectConstructionTest::ReadConstructionSnapshot(*this, DefaultObject, DefaultSnapshot))
	{
		return false;
	}

	UObject* FirstInstance = NewObject<UObject>(GetTransientPackage(), GeneratedASClass, TEXT("ObjectConstructionCarrierA"));
	UObject* SecondInstance = NewObject<UObject>(GetTransientPackage(), GeneratedASClass, TEXT("ObjectConstructionCarrierB"));
	if (!TestNotNull(
			TEXT("ASClass object-construction scenario should create the first generated UObject instance"),
			FirstInstance)
		|| !TestNotNull(
			TEXT("ASClass object-construction scenario should create the second generated UObject instance"),
			SecondInstance))
	{
		return false;
	}

	FirstInstance->AddToRoot();
	SecondInstance->AddToRoot();

	TWeakObjectPtr<UObject> WeakFirstInstance = FirstInstance;
	TWeakObjectPtr<UObject> WeakSecondInstance = SecondInstance;
	ON_SCOPE_EXIT
	{
		ASClassObjectConstructionTest::ReleaseObject(WeakSecondInstance);
		ASClassObjectConstructionTest::ReleaseObject(WeakFirstInstance);
	};

	ASClassObjectConstructionTest::FObjectConstructionSnapshot FirstSnapshot;
	ASClassObjectConstructionTest::FObjectConstructionSnapshot SecondSnapshot;
	if (!ASClassObjectConstructionTest::ReadConstructionSnapshot(*this, FirstInstance, FirstSnapshot)
		|| !ASClassObjectConstructionTest::ReadConstructionSnapshot(*this, SecondInstance, SecondSnapshot))
	{
		return false;
	}

	TestTrue(
		TEXT("ASClass object-construction scenario should compile a plain UObject-generated class"),
		GeneratedASClass->IsChildOf(UObject::StaticClass()));
	TestFalse(
		TEXT("ASClass object-construction scenario should keep the generated class out of the actor hierarchy"),
		GeneratedASClass->IsChildOf(AActor::StaticClass()));
	TestTrue(
		TEXT("ASClass object-construction scenario should create distinct runtime instances"),
		FirstInstance != SecondInstance);
	TestTrue(
		TEXT("ASClass object-construction scenario should keep runtime instances distinct from the class default object"),
		FirstInstance != DefaultObject && SecondInstance != DefaultObject);

	const bool bDefaultObjectVerified = ASClassObjectConstructionTest::VerifySnapshot(
		*this,
		TEXT("ASClass object-construction scenario class default object"),
		DefaultSnapshot,
		ASClassObjectConstructionTest::ExpectedCtorCount);
	const bool bFirstInstanceVerified = ASClassObjectConstructionTest::VerifySnapshot(
		*this,
		TEXT("ASClass object-construction scenario first instance"),
		FirstSnapshot,
		ASClassObjectConstructionTest::ExpectedCtorCount);
	const bool bSecondInstanceVerified = ASClassObjectConstructionTest::VerifySnapshot(
		*this,
		TEXT("ASClass object-construction scenario second instance"),
		SecondSnapshot,
		ASClassObjectConstructionTest::ExpectedCtorCount);

	TestEqual(
		TEXT("ASClass object-construction scenario should keep the second instance constructor count isolated from the first instance"),
		SecondSnapshot.CtorCount,
		ASClassObjectConstructionTest::ExpectedCtorCount);
	TestEqual(
		TEXT("ASClass object-construction scenario should keep both runtime instances on the same scripted integer default"),
		FirstSnapshot.DefaultValue,
		SecondSnapshot.DefaultValue);
	TestEqual(
		TEXT("ASClass object-construction scenario should keep both runtime instances on the same scripted string default"),
		FirstSnapshot.DefaultLabel,
		SecondSnapshot.DefaultLabel);

	bVerified = bDefaultObjectVerified && bFirstInstanceVerified && bSecondInstanceVerified;

	ASTEST_END_SHARE_FRESH
	return bVerified;
}

#endif
