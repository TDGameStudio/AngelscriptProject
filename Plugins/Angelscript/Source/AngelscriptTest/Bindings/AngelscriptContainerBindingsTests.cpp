#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "Misc/ScopeExit.h"
#if WITH_DEV_AUTOMATION_TESTS
using namespace AngelscriptTestSupport;
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptOptionalBindingsTest,
	"Angelscript.TestModule.Bindings.OptionalCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptOptionalGetValueUnsetErrorBindingsTest,
	"Angelscript.TestModule.Bindings.OptionalGetValueUnsetError",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSetBindingsTest,
	"Angelscript.TestModule.Bindings.SetCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMapBindingsTest,
	"Angelscript.TestModule.Bindings.MapCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMapFindFailureBindingsTest,
	"Angelscript.TestModule.Bindings.MapFindFailureAndFindOrAddRefCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptArrayForeachBindingsTest,
	"Angelscript.TestModule.Bindings.ArrayForeach",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSetForeachBindingsTest,
	"Angelscript.TestModule.Bindings.SetForeach",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSetForeachExactVisitBindingsTest,
	"Angelscript.TestModule.Bindings.SetForeachExactVisit",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMapForeachBindingsTest,
	"Angelscript.TestModule.Bindings.MapForeach",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMapForeachKeyValuePairingBindingsTest,
	"Angelscript.TestModule.Bindings.MapForeachKeyValuePairing",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
bool FAngelscriptOptionalBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASOptionalCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASOptionalCompat",
		TEXT(R"(
int Entry()
{
	TOptional<int> Empty;
	if (Empty.IsSet())
		return 10;
	if (Empty.Get(7) != 7)
		return 20;
	Empty.Set(42);
	if (!Empty.IsSet())
		return 30;
	if (Empty.GetValue() != 42)
		return 40;
	TOptional<int> Copy(Empty);
	if (!(Copy == Empty))
		return 50;
	Copy = 19;
	if (Copy.GetValue() != 19)
		return 60;
	Copy.Reset();
	if (Copy.IsSet())
		return 70;
	TOptional<FName> OptionalName(FName("Alpha"));
	if (!OptionalName.IsSet())
		return 80;
	if (!(OptionalName.GetValue() == FName("Alpha")))
		return 90;
	if (!(OptionalName.Get(FName("Fallback")) == FName("Alpha")))
		return 100;
	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(TEXT("Optional compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptOptionalGetValueUnsetErrorBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bExecuteFailedAsExpected = false;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASOptionalGetValueUnsetError"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASOptionalGetValueUnsetError",
		TEXT(R"(
int Entry()
{
	TOptional<int> Empty;
	return Empty.GetValue();
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	FAngelscriptEngineScope EngineScope(Engine);
	asIScriptContext* ScriptContext = Engine.CreateContext();
	if (!TestNotNull(TEXT("Unset Optional.GetValue should create a script execution context"), ScriptContext))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		UE_SET_LOG_VERBOSITY(Angelscript, Log);
		ScriptContext->Release();
	};

	UE_SET_LOG_VERBOSITY(Angelscript, Fatal);
	const int PrepareResult = ScriptContext->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? ScriptContext->Execute() : PrepareResult;
	const FString ExceptionString = UTF8_TO_TCHAR(
		ScriptContext->GetExceptionString() != nullptr ? ScriptContext->GetExceptionString() : "");
	const int32 ExceptionLine = ScriptContext->GetExceptionLineNumber();

	bExecuteFailedAsExpected = TestEqual(
		TEXT("Unset Optional.GetValue should prepare successfully before the runtime error path"),
		PrepareResult,
		static_cast<int32>(asSUCCESS));
	bExecuteFailedAsExpected &= TestEqual(
		TEXT("Unset Optional.GetValue should raise a script execution exception"),
		ExecuteResult,
		static_cast<int32>(asEXECUTION_EXCEPTION));
	bExecuteFailedAsExpected &= TestEqual(
		TEXT("Unset Optional.GetValue should surface the guard exception message"),
		ExceptionString,
		FString(TEXT("GetValue() called on Optional when not set! Check the optional with IsSet() first.")));
	bExecuteFailedAsExpected &= TestEqual(
		TEXT("Unset Optional.GetValue should report the throwing line number"),
		ExceptionLine,
		5);
	ASTEST_END_SHARE_CLEAN
	return bExecuteFailedAsExpected;
}
bool FAngelscriptSetBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASSetCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASSetCompat",
		TEXT(R"(
int Entry()
{
	TSet<int> Empty;
	if (!Empty.IsEmpty())
		return 10;
	Empty.Add(4);
	Empty.Add(4);
	if (Empty.Num() != 1)
		return 20;
	if (!Empty.Contains(4))
		return 30;
	TSet<int> Copy = Empty;
	if (!Copy.Contains(4) || Copy.Num() != Empty.Num())
		return 40;
	Copy.Add(7);
	if (Copy.Num() != 2)
		return 50;
	if (!Copy.Remove(4))
		return 60;
	if (Copy.Contains(4))
		return 70;
	Copy.Reset();
	if (!Copy.IsEmpty())
		return 80;
	TSet<FName> Names;
	Names.Add(FName("Alpha"));
	if (!Names.Contains(FName("Alpha")))
		return 90;
	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(TEXT("Set compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptMapBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASMapCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASMapCompat",
		TEXT(R"(
int Entry()
{
	TMap<FName, int> Empty;
	if (!Empty.IsEmpty())
		return 10;
	Empty.Add(FName("Alpha"), 4);
	Empty.Add(FName("Alpha"), 7);
	if (Empty.Num() != 1)
		return 20;
	if (!Empty.Contains(FName("Alpha")))
		return 30;
	int Value = 0;
	if (!Empty.Find(FName("Alpha"), Value))
		return 40;
	if (Value != 7)
		return 50;
	int FoundOrAdded = Empty.FindOrAdd(FName("Alpha"));
	if (FoundOrAdded != 7)
		return 55;
	int AddedDefaulted = Empty.FindOrAdd(FName("Beta"), 11);
	if (AddedDefaulted != 11)
		return 56;
	if (Empty.Num() != 2)
		return 57;
	if (!Empty.Contains(FName("Alpha")) || !Empty.Contains(FName("Beta")) || Empty.Num() != 2)
		return 58;
	TMap<FName, int> Copy = Empty;
	if (Copy.Num() != 2)
		return 60;
	if (!Copy.Contains(FName("Alpha")) || !Copy.Contains(FName("Beta")))
		return 61;
	if (!Copy.Remove(FName("Alpha")))
		return 70;
	if (Copy.Contains(FName("Alpha")))
		return 80;
	Copy.Reset();
	if (!Copy.IsEmpty())
		return 90;
	TMap<FName, FName> Names;
	Names.Add(FName("A"), FName("Alpha"));
	FName NameValue;
	if (!Names.Find(FName("A"), NameValue))
		return 100;
	if (!(NameValue == FName("Alpha")))
		return 110;
	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(TEXT("Map compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptMapFindFailureBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { Engine.DiscardModule(TEXT("ASMapFindFailureCompat")); };
	asIScriptModule* Module = BuildModule(*this, Engine, "ASMapFindFailureCompat", TEXT(R"(
int Entry()
{
	TMap<FName, int> Values;
	int MissingValue = 99;
	if (Values.Find(FName("Missing"), MissingValue))
		return 10;
	if (MissingValue != 99)
		return 20;
	int& Gamma = Values.FindOrAdd(FName("Gamma"));
	Gamma = 33;
	int& Delta = Values.FindOrAdd(FName("Delta"), 11);
	Delta = 12;
	int OutValue = 0;
	if (!Values.Find(FName("Gamma"), OutValue) || OutValue != 33)
		return 30;
	if (!Values.Find(FName("Delta"), OutValue) || OutValue != 12)
		return 40;
	return Values.Num() == 2 ? 1 : 50;
}
)"));
	if (Module == nullptr)
		return false;
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
		return false;
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
		return false;
	TestEqual(TEXT("TMap Find failure and FindOrAdd reference semantics should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptArrayForeachBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASArrayForeachCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASArrayForeachCompat",
		TEXT(R"(
int Entry()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(5);
	int Sum = 0;
	int IndexSum = 0;
	foreach (int Value, int Index : Values)
	{
		Sum += Value;
		IndexSum += Index;
	}
	return (Sum == 8 && IndexSum == 3) ? 1 : 10;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(TEXT("TArray should support foreach syntax with value and index"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptSetForeachBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASSetForeachCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASSetForeachCompat",
		TEXT(R"(
int Entry()
{
	TSet<int> Values;
	Values.Add(2);
	Values.Add(5);
	int Sum = 0;
	foreach (int Value : Values)
	{
		Sum += Value;
	}
	return Sum == 7 ? 1 : 10;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(TEXT("TSet should support foreach syntax with values"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptSetForeachExactVisitBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASSetForeachExactVisitCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASSetForeachExactVisitCompat",
		TEXT(R"(
int Entry()
{
	TSet<int> EmptyValues;
	int EmptyVisitCount = 0;
	foreach (int Value : EmptyValues)
	{
		EmptyVisitCount += 1;
	}
	if (EmptyVisitCount != 0)
		return 10;

	TSet<int> Values;
	Values.Add(2);
	Values.Add(5);
	Values.Add(11);

	TSet<int> Visited;
	int VisitCount = 0;
	foreach (int Value : Values)
	{
		Visited.Add(Value);
		VisitCount += 1;
	}

	if (Visited.Num() != 3)
		return 20;
	if (!Visited.Contains(2) || !Visited.Contains(5) || !Visited.Contains(11))
		return 30;
	if (VisitCount != 3)
		return 40;
	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(
		TEXT("TSet foreach should skip empty sets and visit each element exactly once"),
		Result,
		1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptMapForeachBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASMapForeachCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASMapForeachCompat",
		TEXT(R"(
int Entry()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 5);
	int Sum = 0;
	int KeyCount = 0;
	foreach (int Value, FName Key : Values)
	{
		Sum += Value;
		if (Key == FName("Alpha") || Key == FName("Beta"))
			KeyCount += 1;
	}
	return (Sum == 7 && KeyCount == 2) ? 1 : 10;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(TEXT("TMap should support foreach syntax with value and key"), Result, 1);
	ASTEST_END_SHARE_CLEAN
	return true;
}
bool FAngelscriptMapForeachKeyValuePairingBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASMapForeachKeyValuePairingCompat"));
	};
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASMapForeachKeyValuePairingCompat",
		TEXT(R"(
int Entry()
{
	TMap<FName, int> Empty;
	int EmptyVisits = 0;
	foreach (int Value, FName Key : Empty)
	{
		EmptyVisits += 1;
	}
	if (EmptyVisits != 0)
		return 10;

	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 9);
	Values.Add(FName("Gamma"), 17);

	TMap<FName, int> SeenCounts;
	int VisitCount = 0;
	foreach (int Value, FName Key : Values)
	{
		VisitCount += 1;

		int& SeenCount = SeenCounts.FindOrAdd(Key);
		SeenCount += 1;
		if (SeenCount != 1)
			return 20;

		if (Key == FName("Alpha"))
		{
			if (Value != 2)
				return 30;
		}
		else if (Key == FName("Beta"))
		{
			if (Value != 9)
				return 40;
		}
		else if (Key == FName("Gamma"))
		{
			if (Value != 17)
				return 50;
		}
		else
		{
			return 60;
		}
	}

	if (VisitCount != 3)
		return 70;
	if (SeenCounts.Num() != 3)
		return 80;

	int SeenCount = 0;
	if (!SeenCounts.Find(FName("Alpha"), SeenCount) || SeenCount != 1)
		return 90;
	if (!SeenCounts.Find(FName("Beta"), SeenCount) || SeenCount != 1)
		return 100;
	if (!SeenCounts.Find(FName("Gamma"), SeenCount) || SeenCount != 1)
		return 110;
	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}
	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}
	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}
	TestEqual(
		TEXT("TMap foreach should preserve exact key/value pairing and visit each key once"),
		Result,
		1);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Nested foreach: outer TArray<FName>, inner TMap<FName, int>
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachNestedArrayMapTest,
	"Angelscript.TestModule.Bindings.ForeachNestedArrayMap",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptForeachNestedArrayMapTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "ForeachNestedArrayMap", TEXT(R"AS(
int Entry()
{
	TArray<FName> Keys;
	Keys.Add(n"A");
	Keys.Add(n"B");

	TMap<FName, int> Data;
	Data.Add(n"A", 10);
	Data.Add(n"B", 20);

	int Total = 0;
	foreach (FName Key : Keys)
	{
		foreach (int Value, FName MapKey : Data)
		{
			if (MapKey == Key)
				Total += Value;
		}
	}
	return Total;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("Nested foreach should accumulate correct total (10+20=30)"), Result, 30);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Empty container foreach skips body
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachEmptyContainerTest,
	"Angelscript.TestModule.Bindings.ForeachEmptyContainerSkipsBody",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptForeachEmptyContainerTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "ForeachEmptyContainer", TEXT(R"AS(
int Entry()
{
	TArray<int> EmptyArray;
	TSet<int> EmptySet;
	TMap<FName, int> EmptyMap;

	int Count = 0;
	foreach (int V : EmptyArray)
		Count += 1;
	foreach (int V : EmptySet)
		Count += 1;
	foreach (int V, FName K : EmptyMap)
		Count += 1;

	return Count;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("Empty containers should never enter foreach body"), Result, 0);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Foreach with UObject array compiles and iterates
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachUObjectArrayTest,
	"Angelscript.TestModule.Bindings.ForeachUObjectArrayCompiles",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptForeachUObjectArrayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "ForeachUObjectArray", TEXT(R"AS(
int Entry()
{
	TArray<UObject> Objects;
	int Count = 0;
	foreach (UObject Obj : Objects)
	{
		Count += 1;
	}
	return Count;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("UObject array foreach should compile and iterate (empty = 0)"), Result, 0);
	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Foreach const ref preserves original array
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachConstRefPreservesTest,
	"Angelscript.TestModule.Bindings.ForeachConstRefPreservesOriginal",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptForeachConstRefPreservesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine, "ForeachConstRef", TEXT(R"AS(
int Entry()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 2, 3));
	Vectors.Add(FVector(4, 5, 6));

	float Sum = 0.0f;
	foreach (FVector V : Vectors)
	{
		Sum += V.X;
	}

	if (Sum < 4.9f || Sum > 5.1f)
		return 1;

	if (Vectors[0].X < 0.9f || Vectors[0].X > 1.1f)
		return 2;

	return 42;
}
)AS"), "int Entry()", Result);

	TestEqual(TEXT("const ref foreach should preserve original array unchanged"), Result, 42);
	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
