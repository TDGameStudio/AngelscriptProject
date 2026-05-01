#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Core/GAS/AngelscriptAttributeSet.h"
#include "CQTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

// Test Layer: UE Functional - Round1 vacuum-fill (UAngelscriptAttributeSet script subclassing)
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

TEST_CLASS_WITH_FLAGS(FAngelscriptGASScriptAttributeSetTests,
	"Angelscript.TestModule.Functional.GAS.ScriptAttributeSet",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(SubclassRegistersAttributeFieldsAndOnRepFunction)
	{
		using namespace AngelscriptFunctionalTestUtils;
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
		FAngelscriptEngineScope EngineScope(Engine);

		static const FName ModuleName(TEXT("FunctionalScriptAttributeSet"));
		ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };

		UClass* AttributeSetClass = CompileScriptModule(
			*TestRunner,
			Engine,
			ModuleName,
			TEXT("FunctionalScriptAttributeSet.as"),
			TEXT(R"AS(
UCLASS()
class UFunctionalCharacterAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData MaxHealth;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Stamina;
}
)AS"),
			TEXT("UFunctionalCharacterAttributes"));
		if (AttributeSetClass == nullptr) { return; }

		TestRunner->TestTrue(
			TEXT("UFunctionalCharacterAttributes should derive from UAngelscriptAttributeSet"),
			AttributeSetClass->IsChildOf(UAngelscriptAttributeSet::StaticClass()));

		auto VerifyAttributeField = [&](const TCHAR* FieldName)
		{
			FStructProperty* Prop = FindFProperty<FStructProperty>(AttributeSetClass, FieldName);
			if (TestRunner->TestNotNull(*FString::Printf(TEXT("%s FStructProperty should be registered"), FieldName), Prop))
			{
				TestRunner->TestTrue(
					*FString::Printf(TEXT("%s should hold an FAngelscriptGameplayAttributeData"), FieldName),
					Prop->Struct != nullptr
					&& Prop->Struct->IsChildOf(FAngelscriptGameplayAttributeData::StaticStruct()));
			}
		};

		VerifyAttributeField(TEXT("Health"));
		VerifyAttributeField(TEXT("MaxHealth"));
		VerifyAttributeField(TEXT("Stamina"));

		UFunction* OnRepAttribute = AttributeSetClass->FindFunctionByName(TEXT("OnRep_Attribute"));
		TestRunner->TestNotNull(
			TEXT("OnRep_Attribute UFunction should be inherited from UAngelscriptAttributeSet"),
			OnRepAttribute);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
