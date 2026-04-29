// ============================================================================
// AngelscriptSyntaxCastingTests.cpp
//
// Syntax coverage tests for type casting and conversions in AngelScript.
// Tests Cast<T>, implicit/explicit conversions, numeric type promotions,
// and nullptr handling — CQTest refactor.
//
// Automation prefix: Angelscript.TestModule.Syntax.Casting.*
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

static const FBindingsCoverageProfile GSyntaxCastingProfile{
	TEXT("Syntax"),          // Theme
	TEXT("Casting"),         // Variant
	TEXT("ASSyntaxCast"),    // ModulePrefix
	TEXT("Casting"),         // CasePrefix
	TEXT("SyntaxCasting"),   // LogCategory
};

// ----------------------------------------------------------------------------
// Test class
// ----------------------------------------------------------------------------

TEST_CLASS_WITH_FLAGS(FAngelscriptSyntaxCastingTest,
	"Angelscript.TestModule.Syntax.Casting",
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
	// Cast<T> — Positive
	// ====================================================================

	TEST_METHOD(Cast_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Cast to parent class
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("CastP_ToParent"),
			TEXT("void Test(APawn P) { AActor A = Cast<AActor>(P); }"),
			TEXT("Cast to parent class"));

		// Cast to derived class (downcast)
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("CastP_Downcast"),
			TEXT("void Test(AActor A) { APawn P = Cast<APawn>(A); }"),
			TEXT("Downcast with Cast<T>"));

		// Cast with null check
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("CastP_NullCheck"),
			TEXT("void Test(AActor A) { APawn P = Cast<APawn>(A); if (P != nullptr) { } }"),
			TEXT("Cast with null check"));
	}

	// ====================================================================
	// Cast<T> — Negative
	// ====================================================================

	TEST_METHOD(Cast_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Cast to non-existent type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_BadType"),
			TEXT("void Test(AActor A) { auto X = Cast<NonExistentClass>(A); }"),
			TEXT("Cast to non-existent type should fail"));

		// Cast without template argument
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_NoTemplate"),
			TEXT("void Test(AActor A) { auto X = Cast(A); }"),
			TEXT("Cast without template argument should fail"));

		// Cast on primitive type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_Primitive"),
			TEXT("void Test() { int X = 5; auto Y = Cast<float>(X); }"),
			TEXT("Cast on primitive type should fail"));

		// Cast with wrong number of arguments
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_NoArgs"),
			TEXT("void Test() { auto X = Cast<AActor>(); }"),
			TEXT("Cast without argument should fail"));

		// Cast between unrelated types
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_Unrelated"),
			TEXT("void Test() { FString S = \"hello\"; auto X = Cast<AActor>(S); }"),
			TEXT("Cast between unrelated types should fail"));

		// Cast to struct type (Cast<T> is only for UObject hierarchy)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_ToStruct"),
			TEXT("void Test(AActor A) { auto X = Cast<FVector>(A); }"),
			TEXT("Cast to struct type should fail"));

		// Cast with multiple template arguments
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_MultiTemplate"),
			TEXT("void Test(AActor A) { auto X = Cast<APawn, AActor>(A); }"),
			TEXT("Cast with multiple template arguments should fail"));

		// Cast with too many function arguments
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_TooManyArgs"),
			TEXT("void Test(AActor A, AActor B) { auto X = Cast<APawn>(A, B); }"),
			TEXT("Cast with too many arguments should fail"));

		// Cast from nullptr literal directly
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_FromNullLiteral"),
			TEXT("void Test() { auto X = Cast<APawn>(nullptr); }"),
			TEXT("Cast from nullptr literal should fail"));

		// Cast used as lvalue
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_AsLvalue"),
			TEXT("void Test(AActor A) { Cast<APawn>(A) = nullptr; }"),
			TEXT("Cast result as lvalue should fail"));

		// Cast to enum type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("CastN_ToEnum"),
			TEXT("void Test(AActor A) { auto X = Cast<ENetRole>(A); }"),
			TEXT("Cast to enum type should fail"));
	}

	// ====================================================================
	// Implicit Conversions — Positive
	// ====================================================================

	TEST_METHOD(Implicit_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// int to float
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ImplP_IntToFloat"),
			TEXT("void Test() { int X = 5; float Y = X; }"),
			TEXT("Implicit int to float conversion"));

		// int to int64
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ImplP_IntToInt64"),
			TEXT("void Test() { int X = 5; int64 Y = X; }"),
			TEXT("Implicit int to int64 widening"));

		// uint8 to int
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ImplP_Uint8ToInt"),
			TEXT("void Test() { uint8 X = 5; int Y = X; }"),
			TEXT("Implicit uint8 to int widening"));

		// Derived to base pointer
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ImplP_DerivedToBase"),
			TEXT("void TakeActor(AActor A) { } void Test(APawn P) { TakeActor(P); }"),
			TEXT("Implicit derived to base conversion"));

		// Literal number to float
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ImplP_LiteralToFloat"),
			TEXT("void Test() { float X = 5; }"),
			TEXT("Implicit integer literal to float"));
	}

	// ====================================================================
	// Implicit Conversions — Negative
	// ====================================================================

	TEST_METHOD(Implicit_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// String to int
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_StrToInt"),
			TEXT("void Test() { FString S = \"5\"; int X = S; }"),
			TEXT("Implicit string to int should fail"));

		// float to int (narrowing)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_FloatToInt"),
			TEXT("void Test() { float X = 5.5f; int Y = X; }"),
			TEXT("Implicit float to int narrowing should fail"));

		// Base to derived (without Cast)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_BaseToDerived"),
			TEXT("void TakePawn(APawn P) { } void Test(AActor A) { TakePawn(A); }"),
			TEXT("Implicit base to derived should fail"));

		// Bool to int implicit
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_BoolToInt"),
			TEXT("void Test() { bool B = true; int X = B; }"),
			TEXT("Implicit bool to int should fail"));

		// int to bool implicit
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_IntToBool"),
			TEXT("void Test() { int X = 1; bool B = X; }"),
			TEXT("Implicit int to bool should fail"));

		// Struct to unrelated struct
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_StructToStruct"),
			TEXT("void Test() { FVector V = FVector(1,0,0); FRotator R = V; }"),
			TEXT("Implicit conversion between unrelated structs should fail"));

		// Array to single element
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_ArrayToElement"),
			TEXT("void Test() { TArray<int> Arr; int X = Arr; }"),
			TEXT("Implicit array to element should fail"));

		// int64 to int (narrowing)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_Int64ToInt"),
			TEXT("void Test() { int64 X = 999999999999; int Y = X; }"),
			TEXT("Implicit int64 to int narrowing should fail"));

		// float to uint8 (narrowing)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ImplN_FloatToUint8"),
			TEXT("void Test() { float X = 3.14f; uint8 Y = X; }"),
			TEXT("Implicit float to uint8 narrowing should fail"));
	}

	// ====================================================================
	// Explicit Numeric Conversions — Positive
	// ====================================================================

	TEST_METHOD(Explicit_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Explicit float to int
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ExplP_FloatToInt"),
			TEXT("void Test() { float X = 5.5f; int Y = int(X); }"),
			TEXT("Explicit float to int cast"));

		// Explicit int to uint8
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ExplP_IntToUint8"),
			TEXT("void Test() { int X = 300; uint8 Y = uint8(X); }"),
			TEXT("Explicit int to uint8 narrowing cast"));

		// Explicit int to float
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ExplP_IntToFloat"),
			TEXT("void Test() { int X = 5; float Y = float(X); }"),
			TEXT("Explicit int to float cast"));
	}

	// ====================================================================
	// Explicit Conversions — Negative
	// ====================================================================

	TEST_METHOD(Explicit_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Explicit cast string to int (no conversion path)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ExplN_StrToInt"),
			TEXT("void Test() { FString S = \"hello\"; int X = int(S); }"),
			TEXT("Explicit string to int cast should fail"));

		// Explicit cast with wrong constructor arg count
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ExplN_BadArgs"),
			TEXT("void Test() { int X = int(1, 2, 3); }"),
			TEXT("Explicit cast with wrong number of args should fail"));

		// Cast to void
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ExplN_ToVoid"),
			TEXT("void Test() { int X = 5; void(X); }"),
			TEXT("Cast to void should fail"));

		// Explicit cast object to int
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ExplN_ObjectToInt"),
			TEXT("void Test(AActor A) { int X = int(A); }"),
			TEXT("Explicit object to int cast should fail"));

		// Explicit cast bool to FString
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ExplN_BoolToString"),
			TEXT("void Test() { bool B = true; FString S = FString(B); }"),
			TEXT("Explicit bool to FString cast should fail"));
	}

	// ====================================================================
	// Nullptr — Mixed (Positive + Negative)
	// ====================================================================

	TEST_METHOD(Nullptr_Mixed)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// --- Positive ---

		// Assign nullptr to object reference
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("NullP_Assign"),
			TEXT("void Test() { AActor A = nullptr; }"),
			TEXT("Assign nullptr to object reference"));

		// Compare with nullptr
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("NullP_Compare"),
			TEXT("void Test(AActor A) { if (A == nullptr) { } if (A != nullptr) { } }"),
			TEXT("Compare with nullptr"));

		// --- Negative ---

		// Assign nullptr to int
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NullN_ToInt"),
			TEXT("void Test() { int X = nullptr; }"),
			TEXT("Assign nullptr to primitive should fail"));

		// Assign nullptr to struct
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NullN_ToStruct"),
			TEXT("void Test() { FVector V = nullptr; }"),
			TEXT("Assign nullptr to value type should fail"));

		// Assign nullptr to float
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NullN_ToFloat"),
			TEXT("void Test() { float X = nullptr; }"),
			TEXT("Assign nullptr to float should fail"));

		// Assign nullptr to bool
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NullN_ToBool"),
			TEXT("void Test() { bool B = nullptr; }"),
			TEXT("Assign nullptr to bool should fail"));

		// Arithmetic with nullptr
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("NullN_Arithmetic"),
			TEXT("void Test() { int X = nullptr + 1; }"),
			TEXT("Arithmetic with nullptr should fail"));
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
