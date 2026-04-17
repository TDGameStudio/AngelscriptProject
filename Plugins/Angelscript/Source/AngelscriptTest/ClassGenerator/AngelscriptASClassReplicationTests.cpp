#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Containers/Set.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/CoreNet.h"
#include "UObject/FieldIterator.h"
#include "UObject/UnrealType.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ASClassReplicationTest
{
	static const FName ModuleName(TEXT("ASClassLifetimeScriptReplicationList"));
	static const FString ScriptFilename(TEXT("ASClassLifetimeScriptReplicationList.as"));
	static const FName ParentClassName(TEXT("AReplicationParent"));
	static const FName ChildClassName(TEXT("AReplicationChild"));
	static const FName ParentValueName(TEXT("ParentValue"));
	static const FName ChildValueName(TEXT("ChildValue"));
	static const FName ChildNotifiedValueName(TEXT("ChildNotifiedValue"));
	static const FName ChildRepNotifyFunctionName(TEXT("OnRep_ChildNotifiedValue"));

	FName ResolveReplicatedPropertyName(const UClass* OwnerClass, const FLifetimeProperty& LifetimeProperty)
	{
		for (TFieldIterator<FProperty> It(OwnerClass); It; ++It)
		{
			if (It->RepIndex == LifetimeProperty.RepIndex)
			{
				return It->GetFName();
			}
		}

		return NAME_None;
	}

	TArray<FName> CollectReplicatedPropertyNamesFromLifetimeProps(
		const UClass* OwnerClass,
		const TArray<FLifetimeProperty>& LifetimeProperties)
	{
		TArray<FName> PropertyNames;
		PropertyNames.Reserve(LifetimeProperties.Num());

		for (const FLifetimeProperty& LifetimeProperty : LifetimeProperties)
		{
			const FName PropertyName = ResolveReplicatedPropertyName(OwnerClass, LifetimeProperty);
			if (PropertyName != NAME_None)
			{
				PropertyNames.Add(PropertyName);
			}
		}

		return PropertyNames;
	}
}

using namespace ASClassReplicationTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassLifetimeScriptReplicationListIncludesInheritedReplicatedPropertiesTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.LifetimeScriptReplicationListIncludesInheritedReplicatedProperties",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassLifetimeScriptReplicationListIncludesInheritedReplicatedPropertiesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassReplicationTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class AReplicationParent : AActor
{
	default bReplicates = true;

	UPROPERTY(Replicated)
	int ParentValue = 7;
}

UCLASS()
class AReplicationChild : AReplicationParent
{
	UPROPERTY(Replicated)
	int ChildValue = 11;

	UPROPERTY(ReplicatedUsing=OnRep_ChildNotifiedValue)
	int ChildNotifiedValue = 29;

	UFUNCTION()
	void OnRep_ChildNotifiedValue()
	{
	}
}
)AS");

	UClass* ParentClass = CompileScriptModule(
		*this,
		Engine,
		ASClassReplicationTest::ModuleName,
		ASClassReplicationTest::ScriptFilename,
		ScriptSource,
		ASClassReplicationTest::ParentClassName);
	if (ParentClass == nullptr)
	{
		return false;
	}

	UClass* ChildClass = FindGeneratedClass(&Engine, ASClassReplicationTest::ChildClassName);
	if (!TestNotNull(TEXT("ASClass replication scenario should generate the child script class"), ChildClass))
	{
		return false;
	}

	UASClass* ChildASClass = Cast<UASClass>(ChildClass);
	if (!TestNotNull(TEXT("ASClass replication scenario should compile the child as a UASClass"), ChildASClass))
	{
		return false;
	}

	TestEqual(TEXT("ASClass replication scenario should keep the child superclass exact"), ChildClass->GetSuperClass(), ParentClass);

	FProperty* ParentValueProperty = FindFProperty<FProperty>(ChildClass, ASClassReplicationTest::ParentValueName);
	FProperty* ChildValueProperty = FindFProperty<FProperty>(ChildClass, ASClassReplicationTest::ChildValueName);
	FProperty* ChildNotifiedValueProperty = FindFProperty<FProperty>(ChildClass, ASClassReplicationTest::ChildNotifiedValueName);
	if (!TestNotNull(TEXT("ASClass replication scenario should expose the inherited ParentValue property"), ParentValueProperty)
		|| !TestNotNull(TEXT("ASClass replication scenario should expose the child ChildValue property"), ChildValueProperty)
		|| !TestNotNull(TEXT("ASClass replication scenario should expose the child ChildNotifiedValue property"), ChildNotifiedValueProperty))
	{
		return false;
	}

	TestTrue(TEXT("ASClass replication scenario should mark ParentValue as replicated"), ParentValueProperty->HasAnyPropertyFlags(CPF_Net));
	TestTrue(TEXT("ASClass replication scenario should mark ChildValue as replicated"), ChildValueProperty->HasAnyPropertyFlags(CPF_Net));
	TestTrue(TEXT("ASClass replication scenario should mark ChildNotifiedValue as replicated"), ChildNotifiedValueProperty->HasAnyPropertyFlags(CPF_Net));
	TestTrue(TEXT("ASClass replication scenario should mark ChildNotifiedValue as a RepNotify property"), ChildNotifiedValueProperty->HasAnyPropertyFlags(CPF_RepNotify));
	TestEqual(
		TEXT("ASClass replication scenario should preserve the RepNotify function name on the generated child property"),
		ChildNotifiedValueProperty->RepNotifyFunc,
		ASClassReplicationTest::ChildRepNotifyFunctionName);

	TArray<FLifetimeProperty> LifetimeProperties;
	ChildASClass->GetLifetimeScriptReplicationList(LifetimeProperties);

	const TArray<FName> ReplicatedPropertyNames =
		ASClassReplicationTest::CollectReplicatedPropertyNamesFromLifetimeProps(ChildClass, LifetimeProperties);

	TSet<FName> UniquePropertyNames;
	for (const FName PropertyName : ReplicatedPropertyNames)
	{
		UniquePropertyNames.Add(PropertyName);
	}

	TestEqual(
		TEXT("ASClass replication scenario should collect exactly the script replicated properties declared across the parent-child chain"),
		LifetimeProperties.Num(),
		3);
	TestEqual(
		TEXT("ASClass replication scenario should resolve every lifetime replication entry back to a concrete property name"),
		ReplicatedPropertyNames.Num(),
		LifetimeProperties.Num());
	TestEqual(
		TEXT("ASClass replication scenario should not duplicate inherited script replicated properties in the lifetime list"),
		UniquePropertyNames.Num(),
		ReplicatedPropertyNames.Num());
	TestTrue(
		TEXT("ASClass replication scenario should include the parent replicated property in the child lifetime list"),
		ReplicatedPropertyNames.Contains(ASClassReplicationTest::ParentValueName));
	TestTrue(
		TEXT("ASClass replication scenario should include the direct child replicated property in the child lifetime list"),
		ReplicatedPropertyNames.Contains(ASClassReplicationTest::ChildValueName));
	TestTrue(
		TEXT("ASClass replication scenario should include the child RepNotify property in the child lifetime list"),
		ReplicatedPropertyNames.Contains(ASClassReplicationTest::ChildNotifiedValueName));
	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
