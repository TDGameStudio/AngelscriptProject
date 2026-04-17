#include "AngelscriptSettings.h"
#include "AngelscriptType.h"
#include "ClassGenerator/ASClass.h"
#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Containers/StringConv.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Core_AngelscriptDebuggerAutoEvaluationTests_Private
{
	asITypeInfo* FindScriptTypeInfoForClass(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UClass* ScriptClass)
	{
		const FString BoundTypeName = FAngelscriptType::GetBoundClassName(ScriptClass);
		asITypeInfo* ScriptType = nullptr;
		if (const UASClass* ScriptASClass = Cast<UASClass>(ScriptClass))
		{
			ScriptType = static_cast<asITypeInfo*>(ScriptASClass->ScriptTypePtr);
		}

		if (ScriptType == nullptr)
		{
			const FTCHARToUTF8 BoundTypeNameUtf8(*BoundTypeName);
			ScriptType = Engine.GetScriptEngine()->GetTypeInfoByName(BoundTypeNameUtf8.Get());
		}

		Test.TestNotNull(
			*FString::Printf(TEXT("Debugger auto-evaluate test should resolve script type '%s'"), *BoundTypeName),
			ScriptType);
		return ScriptType;
	}

	asIScriptFunction* FindMethodByDecl(
		FAutomationTestBase& Test,
		asITypeInfo& ScriptType,
		const FString& Declaration)
	{
		const FTCHARToUTF8 DeclarationUtf8(*Declaration);
		asIScriptFunction* Function = ScriptType.GetMethodByDecl(DeclarationUtf8.Get());
		Test.TestNotNull(
			*FString::Printf(TEXT("Debugger auto-evaluate test should resolve method '%s'"), *Declaration),
			Function);
		return Function;
	}

	FString BuildDebuggerFunctionPath(const asIScriptFunction& ScriptFunction)
	{
		FString FunctionPath;
		if (ScriptFunction.GetObjectType() != nullptr)
		{
			FunctionPath = ANSI_TO_TCHAR(ScriptFunction.GetObjectType()->GetName());
			FunctionPath += TEXT(".");
		}

		FunctionPath += ANSI_TO_TCHAR(ScriptFunction.GetName());
		return FunctionPath;
	}
}

using namespace AngelscriptTest_Core_AngelscriptDebuggerAutoEvaluationTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerAutoEvaluateRespectsBlacklistAndTracksSourcePropertyTest,
	"Angelscript.TestModule.Engine.Debugger.AutoEvaluate.RespectsBlacklistAndTracksSourceProperty",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerAutoEvaluateRespectsBlacklistAndTracksSourcePropertyTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	static const FName ModuleName(TEXT("CoreDebuggerAutoEvaluateWorldless"));
	static const FName GeneratedClassName(TEXT("UDebuggerAutoEvaluateWorldlessProbe"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
		CollectGarbage(RF_NoFlags, true);
	};

	UAngelscriptSettings& Settings = UAngelscriptSettings::Get();
	const TSet<FString> SavedWithoutWorldBlacklist = Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext;
	ON_SCOPE_EXIT
	{
		Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext = SavedWithoutWorldBlacklist;
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("CoreDebuggerAutoEvaluateWorldless.as"),
		TEXT(R"AS(
UCLASS()
class UDebuggerAutoEvaluateWorldlessProbe : UObject
{
	UPROPERTY()
	int StoredValue = 42;

	UFUNCTION()
	int GetStoredValue() const
	{
		return StoredValue;
	}
}
)AS"),
		GeneratedClassName);

	if (ScriptClass != nullptr)
	{
		asITypeInfo* ScriptType = FindScriptTypeInfoForClass(*this, Engine, ScriptClass);
		asIScriptFunction* GetterFunction = ScriptType != nullptr
			? FindMethodByDecl(*this, *ScriptType, TEXT("int GetStoredValue() const"))
			: nullptr;
		FIntProperty* StoredValueProperty = FindFProperty<FIntProperty>(ScriptClass, TEXT("StoredValue"));
		UObject* Target = NewObject<UObject>(GetTransientPackage(), ScriptClass, TEXT("DebuggerAutoEvaluateWorldlessTarget"));

		if (!TestNotNull(TEXT("Debugger auto-evaluate test should expose the generated StoredValue property"), StoredValueProperty) ||
			!TestNotNull(TEXT("Debugger auto-evaluate test should instantiate the generated UObject"), Target) ||
			!TestNotNull(TEXT("Debugger auto-evaluate test should resolve the generated getter method"), GetterFunction))
		{
			bPassed = false;
		}
		else
		{
			bPassed &= TestTrue(
				TEXT("Debugger auto-evaluate test should keep the generated UObject worldless so the without-world blacklist path is reachable"),
				Target->GetWorld() == nullptr);

			void* const StoredValueAddress = StoredValueProperty->ContainerPtrToValuePtr<void>(Target);
			int32* const StoredValuePtr = static_cast<int32*>(StoredValueAddress);
			if (!TestNotNull(TEXT("Debugger auto-evaluate test should expose reflected StoredValue storage"), StoredValuePtr))
			{
				bPassed = false;
			}
			else
			{
				*StoredValuePtr = 42;

				FDebuggerValue EvaluatedValue;
				const bool bEvaluated = FAngelscriptType::GetDebuggerValueFromFunction(
					GetterFunction,
					Target,
					EvaluatedValue,
					ScriptType,
					ScriptClass,
					TEXT("StoredValue"));
				bPassed &= TestTrue(
					TEXT("Debugger auto-evaluate test should evaluate the generated getter before blacklist filtering"),
					bEvaluated);
				if (bEvaluated)
				{
					bPassed &= TestEqual(
						TEXT("Debugger auto-evaluate test should stringify the getter result as the current StoredValue"),
						EvaluatedValue.Value,
						FString(TEXT("42")));
					bPassed &= TestTrue(
						TEXT("Debugger auto-evaluate test should mark function-return debugger values as temporary"),
						EvaluatedValue.bTemporaryValue);
					bPassed &= TestTrue(
						TEXT("Debugger auto-evaluate test should track the non-temporary StoredValue address"),
						EvaluatedValue.GetNonTemporaryAddress() == StoredValueAddress);
					bPassed &= TestTrue(
						TEXT("Debugger auto-evaluate test should monitor the StoredValue address for refresh"),
						EvaluatedValue.GetAddressToMonitor() == StoredValueAddress);
					bPassed &= TestEqual(
						TEXT("Debugger auto-evaluate test should report the StoredValue monitor size as int32"),
						EvaluatedValue.GetAddressToMonitorValueSize(),
						static_cast<int32>(sizeof(int32)));
				}

				Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext.Add(
					BuildDebuggerFunctionPath(*GetterFunction));

				FDebuggerValue BlacklistedValue;
				bPassed &= TestFalse(
					TEXT("Debugger auto-evaluate test should reject the getter once it is blacklisted for objects without world context"),
					FAngelscriptType::GetDebuggerValueFromFunction(
						GetterFunction,
						Target,
						BlacklistedValue,
						ScriptType,
						ScriptClass,
						TEXT("StoredValue")));
			}
		}
	}

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

#endif
