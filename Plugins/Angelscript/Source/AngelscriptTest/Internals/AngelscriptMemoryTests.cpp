#include "Misc/AutomationTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_memory.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Internals_AngelscriptMemoryTests_Private
{
	class FMemoryManagerProbe final : public asCMemoryMgr
	{
	public:
		int32 GetScriptNodePoolSize() const
		{
			return scriptNodePool.Num();
		}

		int32 GetByteInstructionPoolSize() const
		{
			return byteInstructionPool.Num();
		}
	};
}

using namespace AngelscriptTest_Internals_AngelscriptMemoryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMemoryManagerConstructionTest,
	"Angelscript.TestModule.Internals.Memory.Construction",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMemoryManagerFreeUnusedTest,
	"Angelscript.TestModule.Internals.Memory.FreeUnused",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMemoryManagerScriptNodeReuseTest,
	"Angelscript.TestModule.Internals.Memory.ScriptNodeReuse",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMemoryManagerByteInstructionReuseTest,
	"Angelscript.TestModule.Internals.Memory.ByteInstructionReuse",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMemoryManagerPoolLeakTrackingTest,
	"Angelscript.TestModule.Internals.Memory.PoolLeakTracking",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptMemoryManagerConstructionTest::RunTest(const FString& Parameters)
{
	asCMemoryMgr Manager;
	TestTrue(TEXT("Constructing the internal memory manager should succeed"), true);
	return true;
}

bool FAngelscriptMemoryManagerFreeUnusedTest::RunTest(const FString& Parameters)
{
	FMemoryManagerProbe Manager;
	Manager.FreeUnusedMemory();
	TestTrue(TEXT("FreeUnusedMemory should be callable even when no pooled memory is tracked"), true);
	TestEqual(TEXT("FreeUnusedMemory should leave the script-node pool empty"), Manager.GetScriptNodePoolSize(), 0);
	TestEqual(TEXT("FreeUnusedMemory should leave the byte-instruction pool empty"), Manager.GetByteInstructionPoolSize(), 0);
	return true;
}

bool FAngelscriptMemoryManagerScriptNodeReuseTest::RunTest(const FString& Parameters)
{
	FMemoryManagerProbe Manager;
	void* FirstAllocation = Manager.AllocScriptNode();
	TestNotNull(TEXT("AllocScriptNode should return storage for a script node"), FirstAllocation);
	Manager.FreeScriptNode(FirstAllocation);
	TestEqual(TEXT("FreeScriptNode should retain exactly one script-node allocation in the pool"), Manager.GetScriptNodePoolSize(), 1);

	void* ReusedAllocation = Manager.AllocScriptNode();
	TestEqual(TEXT("AllocScriptNode should reuse the most recently freed script-node allocation"), ReusedAllocation, FirstAllocation);
	TestEqual(TEXT("Reusing a script-node allocation should remove it from the pool"), Manager.GetScriptNodePoolSize(), 0);
	Manager.FreeScriptNode(ReusedAllocation);
	return true;
}

bool FAngelscriptMemoryManagerByteInstructionReuseTest::RunTest(const FString& Parameters)
{
	FMemoryManagerProbe Manager;
	void* FirstAllocation = Manager.AllocByteInstruction();
	TestNotNull(TEXT("AllocByteInstruction should return storage for a bytecode instruction"), FirstAllocation);
	Manager.FreeByteInstruction(FirstAllocation);
	TestEqual(TEXT("FreeByteInstruction should retain exactly one byte-instruction allocation in the pool"), Manager.GetByteInstructionPoolSize(), 1);

	void* ReusedAllocation = Manager.AllocByteInstruction();
	TestEqual(TEXT("AllocByteInstruction should reuse the most recently freed bytecode instruction allocation"), ReusedAllocation, FirstAllocation);
	TestEqual(TEXT("Reusing a bytecode instruction allocation should remove it from the pool"), Manager.GetByteInstructionPoolSize(), 0);
	Manager.FreeByteInstruction(ReusedAllocation);
	return true;
}

bool FAngelscriptMemoryManagerPoolLeakTrackingTest::RunTest(const FString& Parameters)
{
	FMemoryManagerProbe Manager;
	void* ScriptNodeA = Manager.AllocScriptNode();
	void* ScriptNodeB = Manager.AllocScriptNode();
	void* Instruction = Manager.AllocByteInstruction();

	Manager.FreeScriptNode(ScriptNodeA);
	Manager.FreeScriptNode(ScriptNodeB);
	Manager.FreeByteInstruction(Instruction);

	TestEqual(TEXT("The script-node pool should track every freed script-node allocation"), Manager.GetScriptNodePoolSize(), 2);
	TestEqual(TEXT("The byte-instruction pool should track every freed bytecode allocation"), Manager.GetByteInstructionPoolSize(), 1);

	Manager.FreeUnusedMemory();
	TestEqual(TEXT("FreeUnusedMemory should release all tracked script-node allocations"), Manager.GetScriptNodePoolSize(), 0);
	TestEqual(TEXT("FreeUnusedMemory should release all tracked bytecode allocations"), Manager.GetByteInstructionPoolSize(), 0);
	return true;
}

#endif
