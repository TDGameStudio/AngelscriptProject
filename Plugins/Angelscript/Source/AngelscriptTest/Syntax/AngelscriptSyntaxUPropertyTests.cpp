// ============================================================================
// AngelscriptSyntaxUPropertyTests.cpp
//
// Syntax coverage tests for UPROPERTY declarations — CQTest edition.
// Tests specifiers (positive/negative) and property types (positive/negative).
//
// Automation prefix: Angelscript.TestModule.Syntax.UProperty.*
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

static const FBindingsCoverageProfile GSyntaxUPropProfile{
	TEXT("Syntax"),          // Theme
	TEXT("UProp"),           // Variant
	TEXT("ASSyntaxUP"),      // ModulePrefix
	TEXT("UProp"),           // CasePrefix
	TEXT("SyntaxUProp"),     // LogCategory
};

// ====================================================================
// Test Class
// ====================================================================

TEST_CLASS_WITH_FLAGS(FAngelscriptSyntaxUPropertyTest,
	"Angelscript.TestModule.Syntax.UProperty",
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
	// Specifiers — Positive
	// ====================================================================

	TEST_METHOD(Specifiers_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Basic UPROPERTY
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_Basic"),
			TEXT("class AUPropBasicActor : AActor { UPROPERTY() int Health = 100; }"),
			TEXT("Basic UPROPERTY"));

		// EditAnywhere
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_EditAnywhere"),
			TEXT("class AUPropEditActor : AActor { UPROPERTY(EditAnywhere) int Health = 100; }"),
			TEXT("EditAnywhere specifier"));

		// BlueprintReadWrite
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_BPReadWrite"),
			TEXT("class AUPropBPRWActor : AActor { UPROPERTY(BlueprintReadWrite) int Health = 100; }"),
			TEXT("BlueprintReadWrite specifier"));

		// BlueprintReadOnly
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_BPReadOnly"),
			TEXT("class AUPropBPROActor : AActor { UPROPERTY(BlueprintReadOnly) int Health = 100; }"),
			TEXT("BlueprintReadOnly specifier"));

		// Replicated
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_Replicated"),
			TEXT("class AUPropRepActor : AActor { UPROPERTY(Replicated) int Health = 100; }"),
			TEXT("Replicated specifier"));

		// ReplicatedUsing
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_ReplicatedUsing"),
			TEXT("class AUPropRepUsingActor : AActor { UPROPERTY(ReplicatedUsing = OnRep_Health) int Health = 100; UFUNCTION() void OnRep_Health() { } }"),
			TEXT("ReplicatedUsing specifier"));

		// Transient
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_Transient"),
			TEXT("class AUPropTransActor : AActor { UPROPERTY(Transient) int TempVal = 0; }"),
			TEXT("Transient specifier"));

		// Category
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_Category"),
			TEXT("class AUPropCatActor : AActor { UPROPERTY(Category = \"Stats\") int Health = 100; }"),
			TEXT("Category specifier"));

		// Multiple specifiers
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_Multiple"),
			TEXT("class AUPropMultiActor : AActor { UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = \"Combat\") float Damage = 10.0f; }"),
			TEXT("Multiple specifiers combined"));

		// NotEditable
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_NotEditable"),
			TEXT("class AUPropNotEditActor : AActor { UPROPERTY(NotEditable) int InternalVal = 0; }"),
			TEXT("NotEditable specifier"));

		// Meta
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropSP_Meta"),
			TEXT("class AUPropMetaActor : AActor { UPROPERTY(Meta = (ClampMin = 0, ClampMax = 100)) int Health = 50; }"),
			TEXT("Meta specifier"));
	}

	// ====================================================================
	// Specifiers — Negative
	// ====================================================================

	TEST_METHOD(Specifiers_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Invalid specifier
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_Invalid"),
			TEXT("class AUPropInvalidActor : AActor { UPROPERTY(InvalidSpecifier) int X = 0; }"),
			TEXT("Invalid specifier should fail"));

		// Conflicting ReadOnly + ReadWrite
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_ConflictRORW"),
			TEXT("class AUPropConflictRWActor : AActor { UPROPERTY(BlueprintReadOnly, BlueprintReadWrite) int X = 0; }"),
			TEXT("Conflicting BlueprintReadOnly and BlueprintReadWrite should fail"));

		// Conflicting Replicated + NotReplicated
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_ConflictRepNotRep"),
			TEXT("class AUPropConflictRepActor : AActor { UPROPERTY(Replicated, NotReplicated) int X = 0; }"),
			TEXT("Conflicting Replicated and NotReplicated should fail"));

		// UPROPERTY on local variable
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_LocalVar"),
			TEXT("class AUPropLocalVarActor : AActor { void Foo() { UPROPERTY() int X = 0; } }"),
			TEXT("UPROPERTY on local variable should fail"));

		// UPROPERTY at global scope
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_GlobalScope"),
			TEXT("UPROPERTY() int GlobalVar = 0;"),
			TEXT("UPROPERTY at global scope should fail"));

		// Duplicate specifier
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_DuplicateSpec"),
			TEXT("class AUPropDupSpecActor : AActor { UPROPERTY(EditAnywhere, EditAnywhere) int X = 0; }"),
			TEXT("Duplicate specifier should fail"));

		// Missing parenthesis
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_MissingParen"),
			TEXT("class AUPropMisParenActor : AActor { UPROPERTY( int X = 0; }"),
			TEXT("Missing closing parenthesis should fail"));

		// UPROPERTY on function
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_OnFunction"),
			TEXT("class AUPropOnFuncActor : AActor { UPROPERTY() void Foo() { } }"),
			TEXT("UPROPERTY on function should fail"));

		// EditAnywhere on non-USTRUCT member
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_EditNonClass"),
			TEXT("struct FPlain { UPROPERTY(EditAnywhere) int X = 0; }"),
			TEXT("UPROPERTY EditAnywhere on non-USTRUCT member should fail"));

		// Specifier typo / case sensitivity
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_CaseSensitive"),
			TEXT("class AUPropCaseActor : AActor { UPROPERTY(editanywhere) int X = 0; }"),
			TEXT("Lowercase specifier (case sensitivity) should fail"));

		// Trailing garbage after UPROPERTY
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_TrailingGarbage"),
			TEXT("class AUPropGarbageActor : AActor { UPROPERTY() garbage int X = 0; }"),
			TEXT("Trailing garbage after UPROPERTY should fail"));

		// Invalid meta key
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_BadMetaKey"),
			TEXT("class AUPropBadMetaActor : AActor { UPROPERTY(Meta = (NonExistentMetaKey = true)) int X = 0; }"),
			TEXT("Invalid meta key should fail"));

		// Empty specifier with lone comma
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_EmptyComma"),
			TEXT("class AUPropEmptyCommaActor : AActor { UPROPERTY(,) int X = 0; }"),
			TEXT("Empty specifier with lone comma should fail"));

		// ReplicatedUsing without function name
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_RepUsingNoFunc"),
			TEXT("class AUPropRepNoFuncActor : AActor { UPROPERTY(ReplicatedUsing) int X = 0; }"),
			TEXT("ReplicatedUsing without function name should fail"));

		// Numeric literal as specifier
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropSN_NumberSpec"),
			TEXT("class AUPropNumSpecActor : AActor { UPROPERTY(123) int X = 0; }"),
			TEXT("Numeric literal as specifier should fail"));
	}

	// ====================================================================
	// Types — Positive
	// ====================================================================

	TEST_METHOD(Types_Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// int
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropTP_Int"),
			TEXT("class AUPropIntActor : AActor { UPROPERTY() int Health = 100; }"),
			TEXT("UPROPERTY int type"));

		// float
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropTP_Float"),
			TEXT("class AUPropFloatActor : AActor { UPROPERTY() float Speed = 5.0f; }"),
			TEXT("UPROPERTY float type"));

		// bool
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropTP_Bool"),
			TEXT("class AUPropBoolActor : AActor { UPROPERTY() bool bIsAlive = true; }"),
			TEXT("UPROPERTY bool type"));

		// FString
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropTP_FString"),
			TEXT("class AUPropStrActor : AActor { UPROPERTY() FString Name = \"Default\"; }"),
			TEXT("UPROPERTY FString type"));

		// FVector
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropTP_FVector"),
			TEXT("class AUPropVecActor : AActor { UPROPERTY() FVector Location; }"),
			TEXT("UPROPERTY FVector type"));

		// TArray
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropTP_TArray"),
			TEXT("class AUPropArrActor : AActor { UPROPERTY() TArray<int> Scores; }"),
			TEXT("UPROPERTY TArray type"));

		// TSubclassOf
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("UPropTP_TSubclassOf"),
			TEXT("class AUPropSubclassActor : AActor { UPROPERTY() TSubclassOf<AActor> ActorClass; }"),
			TEXT("UPROPERTY TSubclassOf type"));
	}

	// ====================================================================
	// Types — Negative
	// ====================================================================

	TEST_METHOD(Types_Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);

		// Non-existent type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_NonExistent"),
			TEXT("class AUPropNonExistActor : AActor { UPROPERTY() FNonExistentType X; }"),
			TEXT("Non-existent UPROPERTY type should fail"));

		// void type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_Void"),
			TEXT("class AUPropVoidActor : AActor { UPROPERTY() void X; }"),
			TEXT("void UPROPERTY type should fail"));

		// auto type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_Auto"),
			TEXT("class AUPropAutoActor : AActor { UPROPERTY() auto X = 5; }"),
			TEXT("auto UPROPERTY type should fail"));

		// Raw pointer
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_RawPointer"),
			TEXT("class AUPropRawPtrActor : AActor { UPROPERTY() AActor Ptr = nullptr; }"),
			TEXT("Raw pointer UPROPERTY type should fail"));

		// TArray with non-existent element type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_TArrayBadElem"),
			TEXT("class AUPropArrBadActor : AActor { UPROPERTY() TArray<FNonExistent> Items; }"),
			TEXT("TArray with non-existent element type should fail"));

		// TSubclassOf with non-UObject type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_SubclassNonObj"),
			TEXT("class AUPropSubNonObjActor : AActor { UPROPERTY() TSubclassOf<int> BadClass; }"),
			TEXT("TSubclassOf with non-UObject type should fail"));

		// Multiple declarations on one UPROPERTY line
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_MultiDecl"),
			TEXT("class AUPropMultiDeclActor : AActor { UPROPERTY() int X, Y; }"),
			TEXT("Multiple declarations on one UPROPERTY should fail"));

		// Function type as property
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_FuncType"),
			TEXT("class AUPropFuncTypeActor : AActor { UPROPERTY() void() Callback; }"),
			TEXT("Function type as UPROPERTY should fail"));

		// Nested TArray with non-existent inner type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_NestedBad"),
			TEXT("class AUPropNestedBadActor : AActor { UPROPERTY() TArray<TArray<FBogus>> Nested; }"),
			TEXT("Nested TArray with bad inner type should fail"));

		// Reference type as UPROPERTY
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_RefType"),
			TEXT("class AUPropRefTypeActor : AActor { UPROPERTY() int& RefProp; }"),
			TEXT("Reference type as UPROPERTY should fail"));

		// Const property with UPROPERTY
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_ConstProp"),
			TEXT("class AUPropConstPropActor : AActor { UPROPERTY() const int ConstVal = 5; }"),
			TEXT("Const variable as UPROPERTY should fail"));

		// TMap with non-existent key type
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("UPropTN_TMapBadKey"),
			TEXT("class AUPropMapBadKeyActor : AActor { UPROPERTY() TMap<FNonExistent, int> BadMap; }"),
			TEXT("TMap with non-existent key type should fail"));
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
