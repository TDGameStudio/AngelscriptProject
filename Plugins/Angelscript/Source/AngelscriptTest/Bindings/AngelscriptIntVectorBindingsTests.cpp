#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptIntVectorValueTypesCompatBindingsTest,
	"Angelscript.TestModule.Bindings.IntVectorValueTypesCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptIntVectorBindingsTests_Private
{
	static constexpr ANSICHAR IntVectorBindingsModuleName[] = "ASIntVectorValueTypesCompat";
}

using namespace AngelscriptTest_Bindings_AngelscriptIntVectorBindingsTests_Private;

bool FAngelscriptIntVectorValueTypesCompatBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASIntVectorValueTypesCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		IntVectorBindingsModuleName,
		TEXT(R"AS(
int Entry()
{
	FIntPoint Point(4, 9);
	if (Point.X != 4 || Point.Y != 9 || Point[0] != 4 || Point[1] != 9)
		return 10;
	if (!((-Point + FIntPoint(10, 20)) == FIntPoint(6, 11)))
		return 11;
	if (!(((Point * 2) / 2) == Point))
		return 12;
	if (Point.GetMax() != 9 || Point.GetMin() != 4)
		return 13;

	FIntVector ZeroVector = FIntVector();
	if (!ZeroVector.IsZero())
		return 20;

	FIntVector Vector(1, 2, 3);
	if (Vector.IsZero())
		return 21;
	if (Vector[2] != 3)
		return 22;
	Vector += FIntVector(4, 5, 6);
	if (!(Vector == FIntVector(5, 7, 9)))
		return 23;
	Vector -= FIntVector(4, 5, 6);
	if (!(Vector == FIntVector(1, 2, 3)))
		return 24;
	Vector *= 3;
	Vector /= 3;
	if (!(Vector == FIntVector(1, 2, 3)))
		return 25;

	FIntVector2 Uniform(7);
	if (Uniform.X != 7 || Uniform.Y != 7)
		return 30;
	FIntVector2 Copy(Uniform);
	if (!(Copy == Uniform))
		return 31;
	FIntVector2 Assigned = FIntVector2();
	Assigned = Uniform;
	if (!(Assigned == Uniform))
		return 32;
	if (Copy[1] != 7)
		return 33;

	FIntVector4 Quad(1, 2, 3, 4);
	if (!((-Quad) == FIntVector4(-1, -2, -3, -4)))
		return 40;
	if (!((Quad + FIntVector4(1, 1, 1, 1)) == FIntVector4(2, 3, 4, 5)))
		return 41;
	if (!((Quad - FIntVector4(1, 1, 1, 1)) == FIntVector4(0, 1, 2, 3)))
		return 42;
	if (!(((Quad * 2) / 2) == Quad))
		return 43;
	if (Quad[3] != 4)
		return 44;

	return 1;
}
)AS"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	bPassed = TestEqual(
		TEXT("Int vector value-type bindings should preserve the deterministic arithmetic matrix"),
		Result,
		1);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
