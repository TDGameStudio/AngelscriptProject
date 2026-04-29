// ============================================================================
// AngelscriptSyntaxContainerTests.cpp
//
// Syntax coverage tests for container types: TArray, TMap, TSet, TOptional.
// Tests declaration, initialization, access patterns, and common operations
// — CQTest refactor.
//
// Automation prefix: Angelscript.TestModule.Syntax.Container.*
// ============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"
#include "Syntax/AngelscriptSyntaxTestHelpers.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

// ----------------------------------------------------------------------------
// Profile
// ----------------------------------------------------------------------------

static const FBindingsCoverageProfile GSyntaxContainerProfile{
	TEXT("Syntax"),           // Theme
	TEXT("Container"),        // Variant
	TEXT("ASSyntaxCon"),      // ModulePrefix
	TEXT("Container"),        // CasePrefix
	TEXT("SyntaxContainer"),  // LogCategory
};

// ----------------------------------------------------------------------------
// Test class
// ----------------------------------------------------------------------------

TEST_CLASS_WITH_FLAGS(FAngelscriptSyntaxContainerTest,
	"Angelscript.TestModule.Syntax.Container",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	// ====================================================================
	// TArray — Positive
	// ====================================================================

	TEST_METHOD(TArray_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Declaration
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrDecl"),
			TEXT("void Test() { TArray<int> Arr; }"),
			TEXT("TArray declaration"));

		// Add
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrAdd"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(1); Arr.Add(2); }"),
			TEXT("TArray Add"));

		// Index access
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrAccess"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(5); int X = Arr[0]; }"),
			TEXT("TArray index access"));

		// Num
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrNum"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(1); int Count = Arr.Num(); }"),
			TEXT("TArray.Num()"));

		// RemoveAt
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrRemoveAt"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(1); Arr.Add(2); Arr.RemoveAt(0); }"),
			TEXT("TArray RemoveAt"));

		// Empty
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrEmpty"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(1); Arr.Empty(); }"),
			TEXT("TArray Empty"));

		// Struct array
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrStruct"),
			TEXT("void Test() { TArray<FVector> Vectors; Vectors.Add(FVector(1, 0, 0)); }"),
			TEXT("TArray of struct"));

		// String array
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrString"),
			TEXT("void Test() { TArray<FString> Names; Names.Add(\"Hello\"); }"),
			TEXT("TArray of FString"));

		// Contains
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_ArrContains"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(5); bool B = Arr.Contains(5); }"),
			TEXT("TArray.Contains"));
	}

	// ====================================================================
	// TArray — Negative
	// ====================================================================

	TEST_METHOD(TArray_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// No template parameter
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrNoTemplate"),
			TEXT("void Test() { TArray Arr; }"),
			TEXT("TArray without template type should fail"));

		// Wrong type add
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrWrongTypeAdd"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(\"hello\"); }"),
			TEXT("Adding wrong type to TArray should fail"));

		// Invalid element type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrBadType"),
			TEXT("void Test() { TArray<NonExistent> Arr; }"),
			TEXT("TArray with non-existent element type should fail"));

		// Nested TArray
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrNested"),
			TEXT("void Test() { TArray<TArray<int>> Arr; }"),
			TEXT("Nested TArray should fail"));

		// Void type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrVoid"),
			TEXT("void Test() { TArray<void> Arr; }"),
			TEXT("TArray<void> should fail"));

		// Index with string
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrIndexStr"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(1); int X = Arr[\"key\"]; }"),
			TEXT("TArray index with string should fail"));

		// Out of bounds type (float index)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrIndexFloat"),
			TEXT("void Test() { TArray<int> Arr; Arr.Add(1); int X = Arr[0.5f]; }"),
			TEXT("TArray index with float should fail"));

		// Assignment wrong type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_ArrAssignWrong"),
			TEXT("void Test() { TArray<int> A; TArray<FString> B; A = B; }"),
			TEXT("TArray assignment with wrong element type should fail"));
	}

	// ====================================================================
	// TMap — Positive
	// ====================================================================

	TEST_METHOD(TMap_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Declaration
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_MapDecl"),
			TEXT("void Test() { TMap<FString, int> Map; }"),
			TEXT("TMap declaration"));

		// Add
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_MapAdd"),
			TEXT("void Test() { TMap<FString, int> Map; Map.Add(\"key\", 42); }"),
			TEXT("TMap Add"));

		// Bracket access
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_MapAccess"),
			TEXT("void Test() { TMap<FString, int> Map; Map.Add(\"key\", 42); int Val = Map[\"key\"]; }"),
			TEXT("TMap bracket access"));

		// Contains
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_MapContains"),
			TEXT("void Test() { TMap<FString, int> Map; Map.Add(\"key\", 1); bool B = Map.Contains(\"key\"); }"),
			TEXT("TMap.Contains"));

		// Num
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_MapNum"),
			TEXT("void Test() { TMap<FString, int> Map; int N = Map.Num(); }"),
			TEXT("TMap.Num()"));
	}

	// ====================================================================
	// TMap — Negative
	// ====================================================================

	TEST_METHOD(TMap_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// No template params
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_MapNoTemplate"),
			TEXT("void Test() { TMap Map; }"),
			TEXT("TMap without template parameters should fail"));

		// One template param
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_MapOneParam"),
			TEXT("void Test() { TMap<int> Map; }"),
			TEXT("TMap with only one template param should fail"));

		// Wrong key type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_MapWrongKey"),
			TEXT("void Test() { TMap<FString, int> Map; Map.Add(42, 1); }"),
			TEXT("Adding wrong key type to TMap should fail"));

		// Wrong value type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_MapWrongVal"),
			TEXT("void Test() { TMap<FString, int> Map; Map.Add(\"key\", \"value\"); }"),
			TEXT("Adding wrong value type to TMap should fail"));

		// Bracket with wrong key type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_MapBracketWrong"),
			TEXT("void Test() { TMap<FString, int> Map; int X = Map[42]; }"),
			TEXT("TMap bracket access with wrong key type should fail"));

		// TMap of void
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_MapVoid"),
			TEXT("void Test() { TMap<FString, void> Map; }"),
			TEXT("TMap with void value type should fail"));
	}

	// ====================================================================
	// TSet — Positive
	// ====================================================================

	TEST_METHOD(TSet_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Declaration
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_SetDecl"),
			TEXT("void Test() { TSet<int> S; }"),
			TEXT("TSet declaration"));

		// Add
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_SetAdd"),
			TEXT("void Test() { TSet<int> S; S.Add(1); S.Add(2); }"),
			TEXT("TSet Add"));

		// Contains
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_SetContains"),
			TEXT("void Test() { TSet<FString> S; S.Add(\"hello\"); bool B = S.Contains(\"hello\"); }"),
			TEXT("TSet.Contains"));

		// Remove
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_SetRemove"),
			TEXT("void Test() { TSet<int> S; S.Add(1); S.Remove(1); }"),
			TEXT("TSet.Remove"));
	}

	// ====================================================================
	// TSet — Negative
	// ====================================================================

	TEST_METHOD(TSet_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// No template param
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_SetNoTemplate"),
			TEXT("void Test() { TSet S; }"),
			TEXT("TSet without template type should fail"));

		// Wrong type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_SetWrongType"),
			TEXT("void Test() { TSet<int> S; S.Add(\"hello\"); }"),
			TEXT("Adding wrong type to TSet should fail"));

		// Invalid element type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_SetBadType"),
			TEXT("void Test() { TSet<NonExistent> S; }"),
			TEXT("TSet with non-existent type should fail"));
	}

	// ====================================================================
	// TOptional — Mixed (Positive + Negative)
	// ====================================================================

	TEST_METHOD(TOptional_Mixed)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Positive: Declaration
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_OptDecl"),
			TEXT("void Test() { TOptional<int> Opt; }"),
			TEXT("TOptional declaration"));

		// Positive: Set value
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_OptSet"),
			TEXT("void Test() { TOptional<int> Opt; Opt = 42; }"),
			TEXT("TOptional set value"));

		// Positive: IsSet
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_OptIsSet"),
			TEXT("void Test() { TOptional<int> Opt; bool B = Opt.IsSet(); }"),
			TEXT("TOptional.IsSet()"));

		// Positive: GetValue
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxCon_OptGetValue"),
			TEXT("void Test() { TOptional<int> Opt; Opt = 5; int X = Opt.GetValue(); }"),
			TEXT("TOptional.GetValue()"));

		// Negative: No template param
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_OptNoTemplate"),
			TEXT("void Test() { TOptional Opt; }"),
			TEXT("TOptional without template type should fail"));

		// Negative: Wrong type assign
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine,
			TEXT("ASSyntaxCon_OptWrongType"),
			TEXT("void Test() { TOptional<int> Opt; Opt = \"hello\"; }"),
			TEXT("Assigning wrong type to TOptional should fail"));
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
