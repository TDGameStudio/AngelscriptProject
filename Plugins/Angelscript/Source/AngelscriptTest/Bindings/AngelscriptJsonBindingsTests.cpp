#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptJsonObjectRoundTripBindingsTest,
	"Angelscript.TestModule.Bindings.JsonObjectRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptJsonErrorPathsBindingsTest,
	"Angelscript.TestModule.Bindings.JsonErrorPaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptJsonBindingsTests_Private
{
	static constexpr ANSICHAR JsonObjectRoundTripModuleName[] = "ASJsonObjectRoundTrip";
	static constexpr ANSICHAR JsonErrorPathsModuleName[] = "ASJsonErrorPaths";

	bool ExecuteFunctionExpectingException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		const TCHAR* ContextLabel,
		FString& OutExceptionString,
		int32& OutExceptionLine)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
				*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
				PrepareResult,
				static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
				*FString::Printf(TEXT("%s should fail with a script exception"), ContextLabel),
				ExecuteResult,
				static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return false;
		}

		OutExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		OutExceptionLine = Context->GetExceptionLineNumber();
		const bool bHasExceptionString = Test.TestFalse(
			*FString::Printf(TEXT("%s should report a non-empty exception string"), ContextLabel),
			OutExceptionString.IsEmpty());
		const bool bHasExceptionLine = Test.TestTrue(
			*FString::Printf(TEXT("%s should report a positive exception line"), ContextLabel),
			OutExceptionLine > 0);
		return bHasExceptionString && bHasExceptionLine;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptJsonBindingsTests_Private;

bool FAngelscriptJsonObjectRoundTripBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASJsonObjectRoundTrip"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		JsonObjectRoundTripModuleName,
		TEXT(R"(
int Entry()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	Root.SetNumberField("Score", 1337.0);
	Root.SetBoolField("Enabled", true);

	FJsonObject Child = Root.CreateObjectField("Child");
	Child.SetStringField("Label", "Nested");
	Child.SetNumberField("Count", 2.0);

	FJsonArray Values;
	Values.AddString("First");
	Values.AddNumber(42);
	Root.SetArrayField("Values", Values);

	FString Serialized = Root.SaveToString(false);
	if (Serialized.IsEmpty())
		return 10;

	FJsonObject Parsed = Json::ParseString(Serialized);
	if (!Parsed.IsValid())
		return 20;

	if (Parsed.GetStringField("Name") != "Alice")
		return 30;
	if (Parsed.GetNumberField("Score") != 1337.0)
		return 40;
	if (!Parsed.GetBoolField("Enabled"))
		return 50;

	FJsonArray ParsedValues = Parsed.GetArrayField("Values");
	if (ParsedValues.Num() != 2)
		return 60;

	FJsonObjectFieldIterator Iterator = Parsed.Iterator();
	bool bSawEnabled = false;
	bool bIteratorBoolValue = false;
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
		if (Iterator.GetFieldName() == "Enabled")
		{
			bSawEnabled = Iterator.GetValue().TryGetBool(bIteratorBoolValue);
			break;
		}
	}
	if (!bSawEnabled || !bIteratorBoolValue)
		return 65;

	FJsonValue FirstValue = ParsedValues.GetValueAt(0);
	FString FirstString;
	if (!FirstValue.TryGetString(FirstString))
		return 70;
	if (FirstString != "First")
		return 80;

	FJsonValue SecondValue = ParsedValues.GetValueAt(1);
	int32 SecondNumber = 0;
	if (!SecondValue.TryGetNumber(SecondNumber))
		return 90;
	if (SecondNumber != 42)
		return 100;

	FJsonObject ParsedChild;
	if (!Parsed.TryGetObjectField("Child", ParsedChild))
		return 110;
	if (ParsedChild.GetStringField("Label") != "Nested")
		return 120;
	if (ParsedChild.GetNumberField("Count") != 2.0)
		return 130;

	FJsonArray ParsedValuesAgain;
	if (!Parsed.TryGetArrayField("Values", ParsedValuesAgain))
		return 140;
	if (ParsedValuesAgain.Num() != 2)
		return 150;

	if (Json::ValueTypeToString(EJsonType::Array) != "Array")
		return 160;

	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, Result))
	{
		return false;
	}

	bPassed = TestEqual(
		TEXT("Json object round-trip operations should preserve field values and JSON type strings"),
		Result,
		1);
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptJsonErrorPathsBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASJsonErrorPaths"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		JsonErrorPathsModuleName,
		TEXT(R"(
void TriggerTypeError()
{
	FJsonObject Root;
	FJsonObject Child = Root.CreateObjectField("Child");
	Child.SetNumberField("Score", 3.5);

	FJsonArray Values;
	Values.AddNumber(1);
	Root.SetArrayField("Values", Values);

	FString WrongTypeValue = Root.GetStringField("Child");
	if (WrongTypeValue == "NeverReached")
	{
		Root.SetStringField("Unreachable", WrongTypeValue);
	}
}

void TriggerOutOfBounds()
{
	FJsonArray Values;
	Values.AddNumber(1);

	FJsonValue MissingValue = Values.GetValueAt(1);
	if (MissingValue.IsNull())
	{
		Values.AddString("NeverReached");
	}
}

void TriggerIteratorMutation()
{
	FJsonObject Root;
	Root.SetNumberField("Score", 3.5);

	FJsonArray Values;
	Values.AddNumber(1);
	Root.SetArrayField("Values", Values);

	auto Iterator = Root.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
		Root.SetStringField("Injected", "bad");
	}
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	AddExpectedError(TEXT("Json Value of type 'Object' used as a 'String'."), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("ASJsonErrorPaths"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("void TriggerTypeError()"), EAutomationExpectedErrorFlags::Contains, 0, false);

	FString ExceptionString;
	int32 ExceptionLine = INDEX_NONE;
	if (!ExecuteFunctionExpectingException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerTypeError()"),
			TEXT("Json type-error path"),
			ExceptionString,
			ExceptionLine))
	{
		return false;
	}

	bPassed = TestEqual(
		TEXT("Json GetStringField type mismatch should surface the expected runtime exception"),
		ExceptionString,
		FString(TEXT("Json Value of type 'Object' used as a 'String'.")));
	bPassed &= TestTrue(
		TEXT("Json GetStringField type mismatch should report a script source line"),
		ExceptionLine > 0);

	AddExpectedError(TEXT("Array index is out of bounds"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("ASJsonErrorPaths"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("void TriggerOutOfBounds()"), EAutomationExpectedErrorFlags::Contains, 0, false);

	if (!ExecuteFunctionExpectingException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerOutOfBounds()"),
			TEXT("Json out-of-bounds path"),
			ExceptionString,
			ExceptionLine))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Json GetValueAt out-of-bounds access should surface the expected runtime exception"),
		ExceptionString,
		FString(TEXT("Array index is out of bounds")));
	bPassed &= TestTrue(
		TEXT("Json GetValueAt out-of-bounds access should report a script source line"),
		ExceptionLine > 0);

	AddExpectedError(TEXT("FJsonObject is being modified during for loop iteration"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("ASJsonErrorPaths"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("void TriggerIteratorMutation()"), EAutomationExpectedErrorFlags::Contains, 0, false);

	if (!ExecuteFunctionExpectingException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerIteratorMutation()"),
			TEXT("Json iterator-mutation path"),
			ExceptionString,
			ExceptionLine))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Json iterator mutation should surface the expected runtime exception"),
		ExceptionString,
		FString(TEXT("FJsonObject is being modified during for loop iteration")));
	bPassed &= TestTrue(
		TEXT("Json iterator mutation should report a script source line"),
		ExceptionLine > 0);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
