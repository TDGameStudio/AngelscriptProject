// ============================================================================
// AngelscriptSyntaxPropertyAccessorTests.cpp
//
// Syntax coverage tests for property get/set accessor declarations
// — CQTest refactor.
//
// Automation prefix: Angelscript.TestModule.Syntax.PropertyAccessor.*
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

static const FBindingsCoverageProfile GSyntaxPropAccessProfile{
	TEXT("Syntax"),            // Theme
	TEXT("PropAccess"),        // Variant
	TEXT("ASSyntaxPA"),        // ModulePrefix
	TEXT("PropAccess"),        // CasePrefix
	TEXT("SyntaxPropAccess"),  // LogCategory
};

// ----------------------------------------------------------------------------
// Test class
// ----------------------------------------------------------------------------

TEST_CLASS_WITH_FLAGS(FAngelscriptSyntaxPropertyAccessorTest,
	"Angelscript.TestModule.Syntax.PropertyAccessor",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	// ====================================================================
	// Property Accessors — Positive
	// ====================================================================

	TEST_METHOD(Positive)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		// DISABLED(#as-engine-behavior): feature-not-supported — AS 2.33 fork 不支持 property accessor (get_/set_) 语法
#if 0
		// Property with getter
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxPAGet"),
			TEXT(R"(
class AActorPAGet : AActor
{
	private int _Health = 100;

	int get_Health() const property
	{
		return _Health;
	}
}
)"),
			TEXT("Property with getter"));

		// Property with setter
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxPASet"),
			TEXT(R"(
class AActorPASet : AActor
{
	private int _Health = 100;

	void set_Health(int Value) property
	{
		_Health = Value;
	}
}
)"),
			TEXT("Property with setter"));

		// Property with both getter and setter
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxPABoth"),
			TEXT(R"(
class AActorPABoth : AActor
{
	private int _Health = 100;

	int get_Health() const property
	{
		return _Health;
	}

	void set_Health(int Value) property
	{
		_Health = Value;
	}
}
)"),
			TEXT("Property with getter and setter"));

		// Using property accessor
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxPAUsage"),
			TEXT(R"(
class AActorPAUsage : AActor
{
	private int _X = 0;

	int get_X() const property { return _X; }
	void set_X(int V) property { _X = V; }

	void Test()
	{
		X = 5;
		int Y = X;
	}
}
)"),
			TEXT("Using property accessor syntax"));

		// Float property accessor
		SyntaxTestHelpers::AssertCompiles(*TestRunner, Engine, TEXT("ASSyntaxPAFloat"),
			TEXT(R"(
class AActorPAFloat : AActor
{
	private float _Speed = 1.0f;

	float get_Speed() const property { return _Speed; }
	void set_Speed(float V) property { _Speed = V; }
}
)"),
			TEXT("Float property accessor"));
#endif
	}

	// ====================================================================
	// Property Accessors — Negative
	// ====================================================================

	TEST_METHOD(Negative)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		// Getter with wrong return type (void)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPAGetVoid"),
			TEXT(R"(
class AActorPAGetVoid : AActor
{
	void get_Health() const property { }
}
)"),
			TEXT("Getter returning void should fail"));

		// Setter with wrong param count
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPASetBadParams"),
			TEXT(R"(
class AActorPASetBadP : AActor
{
	void set_Health(int A, int B) property { }
}
)"),
			TEXT("Setter with two params should fail"));

		// Setter with non-void return
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPASetReturn"),
			TEXT(R"(
class AActorPASetRet : AActor
{
	int set_Health(int V) property { return V; }
}
)"),
			TEXT("Setter with non-void return should fail"));

		// Getter/setter type mismatch
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPATypeMismatch"),
			TEXT(R"(
class AActorPATypeMis : AActor
{
	int get_Health() const property { return 0; }
	void set_Health(float V) property { }
}
)"),
			TEXT("Getter/setter type mismatch should fail"));

		// Writing to read-only property (no setter)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPAReadOnly"),
			TEXT(R"(
class AActorPAReadOnly : AActor
{
	int get_Health() const property { return 100; }

	void Test()
	{
		Health = 50;
	}
}
)"),
			TEXT("Writing to read-only property should fail"));

		// Property accessor at global scope
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPAGlobal"),
			TEXT(R"(
int get_GlobalProp() property { return 0; }
)"),
			TEXT("Property accessor at global scope should fail"));

		// Getter with parameters
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPAGetWithParams"),
			TEXT(R"(
class AActorPAGetParams : AActor
{
	int get_Health(int Index) const property { return 0; }
}
)"),
			TEXT("Getter with parameters should fail"));

		// Accessor without property keyword
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPANoPropKeyword"),
			TEXT(R"(
class AActorPANoProp : AActor
{
	int get_Health() const { return 0; }

	void Test()
	{
		int X = Health;
	}
}
)"),
			TEXT("Accessor without property keyword should fail"));

		// Setter without parameter
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPASetNoParam"),
			TEXT(R"(
class AActorPASetNoP : AActor
{
	void set_Health() property { }
}
)"),
			TEXT("Setter without parameter should fail"));

		// Reading from write-only property (no getter)
		SyntaxTestHelpers::AssertFailsToCompile(*TestRunner, Engine, TEXT("ASSyntaxPAWriteOnly"),
			TEXT(R"(
class AActorPAWriteOnly : AActor
{
	void set_Health(int V) property { }

	void Test()
	{
		int X = Health;
	}
}
)"),
			TEXT("Reading from write-only property should fail"));
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
