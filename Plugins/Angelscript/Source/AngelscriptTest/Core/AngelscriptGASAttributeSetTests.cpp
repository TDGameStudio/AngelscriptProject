#include "AngelscriptGASTestTypes.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/CoreNet.h"
#include "UObject/FieldIterator.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptGASAttributeSetTests_Private
{
	const FName HealthAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestReplicatedAttributeSet, Health);
	const FName ManaAttributeName = GET_MEMBER_NAME_CHECKED(UAngelscriptGASTestReplicatedAttributeSet, Mana);
	const FName ReplicationBlacklistPropertyName = GET_MEMBER_NAME_CHECKED(UAngelscriptAttributeSet, ReplicatedAttributeBlackList);
	const FName MissingAttributeName(TEXT("MissingAttribute"));

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

	TArray<FName> CollectReplicatedPropertyNames(const UClass* OwnerClass, const TArray<FLifetimeProperty>& LifetimeProperties)
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

using namespace AngelscriptTest_Core_AngelscriptGASAttributeSetTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASAttributeSetInitializationAndReplicationBlacklistTest,
	"Angelscript.TestModule.Engine.GAS.AttributeSet.InitializesAttributeNamesAndHonorsReplicationBlacklist",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASAttributeSetInitializationAndReplicationBlacklistTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	UAngelscriptGASTestReplicatedAttributeSet* ClassDefaultObject = GetMutableDefault<UAngelscriptGASTestReplicatedAttributeSet>();
	if (!TestNotNull(TEXT("GAS AttributeSet initialization test should access the replicated attribute-set CDO"), ClassDefaultObject))
	{
		return false;
	}

	const TArray<FName> OriginalBlacklist = ClassDefaultObject->ReplicatedAttributeBlackList;
	ON_SCOPE_EXIT
	{
		ClassDefaultObject->ReplicatedAttributeBlackList = OriginalBlacklist;
	};

	ClassDefaultObject->ReplicatedAttributeBlackList.Reset();
	ClassDefaultObject->ReplicatedAttributeBlackList.Add(ManaAttributeName);

	UAngelscriptGASTestReplicatedAttributeSet* AttributeSet =
		NewObject<UAngelscriptGASTestReplicatedAttributeSet>(GetTransientPackage(), NAME_None, RF_Transient);
	if (!TestNotNull(TEXT("GAS AttributeSet initialization test should create an attribute-set instance"), AttributeSet))
	{
		return false;
	}

	TestEqual(
		TEXT("PostInitProperties should stamp the reflected Health attribute name into the backing gameplay-attribute data"),
		AttributeSet->Health.AttributeName,
		HealthAttributeName);
	TestEqual(
		TEXT("PostInitProperties should stamp the reflected Mana attribute name into the backing gameplay-attribute data"),
		AttributeSet->Mana.AttributeName,
		ManaAttributeName);
	TestTrue(
		TEXT("The test should configure Mana on the class-default blacklist before querying lifetime replicated props"),
		ClassDefaultObject->ReplicatedAttributeBlackList.Contains(ManaAttributeName));

	FGameplayAttribute HealthAttribute;
	if (!TestTrue(
			TEXT("TryGetGameplayAttribute should resolve the reflected Health attribute by name"),
			UAngelscriptAttributeSet::TryGetGameplayAttribute(
				UAngelscriptGASTestReplicatedAttributeSet::StaticClass(),
				HealthAttributeName,
				HealthAttribute)))
	{
		return false;
	}

	TestEqual(
		TEXT("TryGetGameplayAttribute should preserve the reflected Health property name"),
		FName(*HealthAttribute.GetName()),
		HealthAttributeName);

	FGameplayAttribute MissingAttribute;
	TestFalse(
		TEXT("TryGetGameplayAttribute should fail closed for missing attribute names"),
		UAngelscriptAttributeSet::TryGetGameplayAttribute(
			UAngelscriptGASTestReplicatedAttributeSet::StaticClass(),
			MissingAttributeName,
			MissingAttribute));

	TArray<FLifetimeProperty> LifetimeProperties;
	ClassDefaultObject->GetLifetimeReplicatedProps(LifetimeProperties);

	const TArray<FName> ReplicatedPropertyNames =
		CollectReplicatedPropertyNames(UAngelscriptGASTestReplicatedAttributeSet::StaticClass(), LifetimeProperties);

	TestTrue(
		TEXT("GetLifetimeReplicatedProps should keep the non-blacklisted Health attribute in the replication list"),
		ReplicatedPropertyNames.Contains(HealthAttributeName));
	TestEqual(
		TEXT("GetLifetimeReplicatedProps should resolve exactly one replicated gameplay attribute after Mana is blacklisted"),
		ReplicatedPropertyNames.Num(),
		1);
	TestFalse(
		TEXT("GetLifetimeReplicatedProps should exclude Mana once it is listed in the replication blacklist"),
		ReplicatedPropertyNames.Contains(ManaAttributeName));
	TestFalse(
		TEXT("GetLifetimeReplicatedProps should never replicate the blacklist bookkeeping property itself"),
		ReplicatedPropertyNames.Contains(ReplicationBlacklistPropertyName));

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
