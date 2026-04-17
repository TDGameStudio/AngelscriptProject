#include "AngelscriptEngine.h"
#include "Angelscript/AngelscriptTestSupport.h"
#include "ClassGenerator/ASClass.h"
#include "Shared/AngelscriptNativeScriptTestObject.h"
#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "Misc/AutomationTest.h"
#include "UObject/UObjectGlobals.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptScriptObjectTypeTests_Private
{
	struct FScriptObjectTypeFixture
	{
		FName ModuleName;
		FName GeneratedClassName;
		const TCHAR* Filename;
		const TCHAR* ScriptSource;
	};

	UASClass* CompileGeneratedObjectClass(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		bool& bPassed,
		const FScriptObjectTypeFixture& Fixture)
	{
		bPassed &= Test.TestTrue(
			*FString::Printf(TEXT("%s should compile the annotated script object module"), *Fixture.ModuleName.ToString()),
			AngelscriptTestSupport::CompileAnnotatedModuleFromMemory(&Engine, Fixture.ModuleName, Fixture.Filename, Fixture.ScriptSource));

		UClass* GeneratedClass = AngelscriptTestSupport::FindGeneratedClass(&Engine, Fixture.GeneratedClassName);
		bPassed &= Test.TestNotNull(
			*FString::Printf(TEXT("%s should resolve the generated class"), *Fixture.GeneratedClassName.ToString()),
			GeneratedClass);

		UASClass* GeneratedASClass = Cast<UASClass>(GeneratedClass);
		bPassed &= Test.TestNotNull(
			*FString::Printf(TEXT("%s should resolve as a generated UASClass"), *Fixture.GeneratedClassName.ToString()),
			GeneratedASClass);

		if (GeneratedASClass != nullptr)
		{
			bPassed &= Test.TestNotNull(
				*FString::Printf(TEXT("%s should publish a non-null ScriptTypePtr"), *Fixture.GeneratedClassName.ToString()),
				reinterpret_cast<asITypeInfo*>(GeneratedASClass->ScriptTypePtr));
		}

		return GeneratedASClass;
	}
}

using namespace AngelscriptTest_Core_AngelscriptScriptObjectTypeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptObjectGetObjectTypeMatchesGeneratedASClassTest,
	"Angelscript.TestModule.Engine.ObjectModel.ScriptObjectGetObjectTypeMatchesGeneratedASClass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptObjectGetObjectTypeMatchesGeneratedASClassTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	static const FScriptObjectTypeFixture FirstFixture = {
		TEXT("ObjectTypeProbeA"),
		TEXT("UObjectTypeProbeObjectA"),
		TEXT("ObjectTypeProbeA.as"),
		TEXT(R"(
UCLASS()
class UObjectTypeProbeObjectA : UObject
{
	UPROPERTY()
	int Value = 7;

	UFUNCTION()
	int GetValue()
	{
		return Value;
	}
}
)"),
	};

	static const FScriptObjectTypeFixture SecondFixture = {
		TEXT("ObjectTypeProbeB"),
		TEXT("UObjectTypeProbeObjectB"),
		TEXT("ObjectTypeProbeB.as"),
		TEXT(R"(
UCLASS()
class UObjectTypeProbeObjectB : UObject
{
	UPROPERTY()
	int Value = 11;

	UFUNCTION()
	int GetValue()
	{
		return Value;
	}
}
)"),
	};

	UASClass* FirstASClass = CompileGeneratedObjectClass(*this, Engine, bPassed, FirstFixture);
	if (!bPassed || FirstASClass == nullptr)
	{
		return false;
	}

	UObject* FirstScriptObject = NewObject<UObject>(GetTransientPackage(), FirstASClass);
	if (!TestNotNull(TEXT("Script object type test should instantiate the first generated UObject"), FirstScriptObject))
	{
		return false;
	}

	asIScriptObject* FirstScriptInterface = FAngelscriptEngine::UObjectToAngelscript(FirstScriptObject);
	if (!TestNotNull(TEXT("Script object type test should expose the generated UObject through the script-object view"), FirstScriptInterface))
	{
		return false;
	}

	asITypeInfo* FirstObjectType = FirstScriptInterface->GetObjectType();
	asITypeInfo* FirstExpectedType = reinterpret_cast<asITypeInfo*>(FirstASClass->ScriptTypePtr);
	bPassed &= TestNotNull(TEXT("Script object type test should return a script type for the generated UObject instance"), FirstObjectType);
	if (FirstObjectType != nullptr && FirstExpectedType != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("Script object type test should map the generated UObject instance to the owning UASClass ScriptTypePtr"),
			FirstObjectType == FirstExpectedType);
		bPassed &= TestEqual(
			TEXT("Script object type test should preserve the generated class name in the returned type info"),
			FString(UTF8_TO_TCHAR(FirstObjectType->GetName())),
			FirstFixture.GeneratedClassName.ToString());
	}

	UObject* NativeObject = NewObject<UAngelscriptNativeScriptTestObject>(GetTransientPackage());
	if (!TestNotNull(TEXT("Script object type test should instantiate a native UObject control case"), NativeObject))
	{
		return false;
	}

	asIScriptObject* NativeScriptView = FAngelscriptEngine::UObjectToAngelscript(NativeObject);
	if (!TestNotNull(TEXT("Script object type test should expose the native UObject through the script-object view"), NativeScriptView))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Script object type test should not report a script type for a native UObject control case"),
		NativeScriptView->GetObjectType() == nullptr);

	FirstScriptObject = nullptr;
	NativeObject = nullptr;
	CollectGarbage(RF_NoFlags, true);

	{
		FAngelscriptEngineScope Scope(Engine);
		bPassed &= TestTrue(
			TEXT("Script object type test should discard the first generated module before compiling the next epoch"),
			Engine.DiscardModule(*FirstFixture.ModuleName.ToString()));
	}
	CollectGarbage(RF_NoFlags, true);

	UASClass* SecondASClass = CompileGeneratedObjectClass(*this, Engine, bPassed, SecondFixture);
	if (!bPassed || SecondASClass == nullptr)
	{
		return false;
	}

	UObject* SecondScriptObject = NewObject<UObject>(GetTransientPackage(), SecondASClass);
	if (!TestNotNull(TEXT("Script object type test should instantiate the recompiled generated UObject"), SecondScriptObject))
	{
		return false;
	}

	asIScriptObject* SecondScriptInterface = FAngelscriptEngine::UObjectToAngelscript(SecondScriptObject);
	if (!TestNotNull(TEXT("Script object type test should expose the recompiled UObject through the script-object view"), SecondScriptInterface))
	{
		return false;
	}

	asITypeInfo* SecondObjectType = SecondScriptInterface->GetObjectType();
	asITypeInfo* SecondExpectedType = reinterpret_cast<asITypeInfo*>(SecondASClass->ScriptTypePtr);
	bPassed &= TestNotNull(TEXT("Script object type test should return a script type for the recompiled generated UObject instance"), SecondObjectType);
	if (SecondObjectType != nullptr && SecondExpectedType != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("Script object type test should map the recompiled UObject instance to the current UASClass ScriptTypePtr"),
			SecondObjectType == SecondExpectedType);
		bPassed &= TestTrue(
			TEXT("Script object type test should return the current epoch type info instead of the discarded pointer"),
			SecondObjectType != FirstObjectType);
		bPassed &= TestEqual(
			TEXT("Script object type test should preserve the recompiled generated class name in the returned type info"),
			FString(UTF8_TO_TCHAR(SecondObjectType->GetName())),
			SecondFixture.GeneratedClassName.ToString());
	}

	ASTEST_END_FULL
	return bPassed;
}

#endif
