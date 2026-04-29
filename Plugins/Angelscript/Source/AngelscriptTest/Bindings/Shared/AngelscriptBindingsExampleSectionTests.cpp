#include "AngelscriptBindingsExampleSection.h"

#include "../../Shared/AngelscriptTestEngineHelper.h"
#include "../../Shared/AngelscriptTestUtilities.h"
#include "../../Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

/**
 * AngelscriptBindingsExampleSectionTests — registers a single Automation ID
 * that drives `RunBindingsExampleSection` end-to-end. This is the
 * "self-test" for the Bindings/Shared/ base layer: if this test stays
 * green across the rest of the refactor, the base layer is sound.
 *
 * The Automation ID is intentionally namespaced under
 * `Bindings.SharedExample` (not `Bindings.Example` or any topic name) so
 * that test discovery clearly distinguishes it from real coverage tests.
 *
 * Per the main plan's "保留旧 ID" rule this test does NOT replace any
 * existing ID — it is purely additive, paid back by zero-cost validation
 * of the base layer.
 */

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindingsSharedExampleTest,
	"Angelscript.TestModule.Bindings.SharedExample",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBindingsSharedExampleTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };

	static const FBindingsCoverageProfile GExampleProfile{
		TEXT("Example"),
		TEXT(""),
		TEXT("ASBindingsSharedExample"),
		TEXT("Example"),
		TEXT("BindingsSharedExample"),
	};

	bPassed &= RunBindingsExampleSection(*this, Engine, GExampleProfile);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif // WITH_DEV_AUTOMATION_TESTS
