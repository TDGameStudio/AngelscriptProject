#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "GameFramework/Actor.h"
#include "CQTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

// Test Layer: UE Functional - Round1 deep-fill (Property meta specifier matrix)
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

TEST_CLASS_WITH_FLAGS(FAngelscriptPropertyMetaMatrixTests,
	"Angelscript.TestModule.Functional.Property.MetaSpecifiersMatrix",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(MetaSpecifiersAreReflectedOnFProperty)
	{
		using namespace AngelscriptFunctionalTestUtils;
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
		FAngelscriptEngineScope EngineScope(Engine);

		static const FName ModuleName(TEXT("FunctionalPropertyMetaMatrix"));
		ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };

		UClass* ActorClass = CompileScriptModule(
			*TestRunner,
			Engine,
			ModuleName,
			TEXT("FunctionalPropertyMetaMatrix.as"),
			TEXT(R"AS(
UCLASS()
class AFunctionalPropertyMetaMatrixActor : AActor
{
	UPROPERTY(EditAnywhere, meta = (InlineEditConditionToggle))
	bool bEnableHealth = true;

	UPROPERTY(EditAnywhere, meta = (EditCondition = "bEnableHealth", ClampMin = "0.0", ClampMax = "100.0", UIMin = "0.0", UIMax = "100.0"))
	float Health = 50.0;

	UPROPERTY(EditAnywhere, meta = (EditCondition = "bEnableHealth", EditConditionHides))
	int32 HealthRegenLevel = 1;

	UPROPERTY(EditAnywhere, meta = (MakeEditWidget))
	FVector EditableLocation = FVector::ZeroVector;
}
)AS"),
			TEXT("AFunctionalPropertyMetaMatrixActor"));
		if (ActorClass == nullptr) { return; }

		auto VerifyMeta = [&](const TCHAR* PropertyName, const TCHAR* MetaKey, const TCHAR* ExpectedValue)
		{
			FProperty* Prop = ActorClass->FindPropertyByName(PropertyName);
			if (!TestRunner->TestNotNull(*FString::Printf(TEXT("%s should be registered"), PropertyName), Prop)) { return; }

			TestRunner->TestTrue(
				*FString::Printf(TEXT("%s should carry meta '%s'"), PropertyName, MetaKey),
				Prop->HasMetaData(MetaKey));

			if (ExpectedValue != nullptr)
			{
				TestRunner->TestEqual(
					*FString::Printf(TEXT("%s meta '%s' should match expected literal"), PropertyName, MetaKey),
					Prop->GetMetaData(MetaKey),
					FString(ExpectedValue));
			}
		};

		VerifyMeta(TEXT("bEnableHealth"), TEXT("InlineEditConditionToggle"), nullptr);

		VerifyMeta(TEXT("Health"), TEXT("EditCondition"), TEXT("bEnableHealth"));
		VerifyMeta(TEXT("Health"), TEXT("ClampMin"), TEXT("0.0"));
		VerifyMeta(TEXT("Health"), TEXT("ClampMax"), TEXT("100.0"));
		VerifyMeta(TEXT("Health"), TEXT("UIMin"), TEXT("0.0"));
		VerifyMeta(TEXT("Health"), TEXT("UIMax"), TEXT("100.0"));

		VerifyMeta(TEXT("HealthRegenLevel"), TEXT("EditCondition"), TEXT("bEnableHealth"));
		VerifyMeta(TEXT("HealthRegenLevel"), TEXT("EditConditionHides"), nullptr);

		VerifyMeta(TEXT("EditableLocation"), TEXT("MakeEditWidget"), nullptr);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
