#include "Misc/AutomationTest.h"
#include "StaticJIT/PrecompiledDataAllocator.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPrecompiledAllocatorResizeAndMoveTest,
	"Angelscript.TestModule.CppTests.StaticJIT.PrecompiledAllocator.ResizeAndMove",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPrecompiledAllocatorResizeAndMoveTest::RunTest(const FString& Parameters)
{
	FMemMark Mark(GScriptPreallocatedMemStack);

	using FIntAllocator = TPrecompiledAllocator<>::ForElementType<int32>;

	FIntAllocator SourceAllocator;
	SourceAllocator.ResizeAllocation(0, 2, sizeof(int32));

	int32* InitialAllocation = SourceAllocator.GetAllocation();
	if (!TestNotNull(TEXT("Precompiled allocator should allocate an initial buffer"), InitialAllocation))
	{
		return false;
	}

	InitialAllocation[0] = 17;
	InitialAllocation[1] = 42;

	SourceAllocator.ResizeAllocation(2, 4, sizeof(int32));
	int32* GrownAllocation = SourceAllocator.GetAllocation();
	if (!TestNotNull(TEXT("Precompiled allocator should keep a valid allocation after growing"), GrownAllocation))
	{
		return false;
	}

	if (!TestEqual(TEXT("Precompiled allocator should preserve the first element when growing"), GrownAllocation[0], 17))
	{
		return false;
	}
	if (!TestEqual(TEXT("Precompiled allocator should preserve the second element when growing"), GrownAllocation[1], 42))
	{
		return false;
	}
	if (!TestEqual(TEXT("Precompiled allocator should keep the allocation aligned for int32"), reinterpret_cast<UPTRINT>(GrownAllocation) % alignof(int32), static_cast<UPTRINT>(0)))
	{
		return false;
	}

	FIntAllocator TargetAllocator;
	TargetAllocator.MoveToEmpty(SourceAllocator);

	if (!TestNull(TEXT("Precompiled allocator should clear the source allocation after MoveToEmpty"), SourceAllocator.GetAllocation()))
	{
		return false;
	}
	if (!TestTrue(TEXT("Precompiled allocator should preserve the destination allocation pointer after MoveToEmpty"), TargetAllocator.GetAllocation() == GrownAllocation))
	{
		return false;
	}
	if (!TestEqual(TEXT("Precompiled allocator should preserve the first moved element"), TargetAllocator.GetAllocation()[0], 17))
	{
		return false;
	}

	return TestEqual(TEXT("Precompiled allocator should preserve the second moved element"), TargetAllocator.GetAllocation()[1], 42);
}

#endif
