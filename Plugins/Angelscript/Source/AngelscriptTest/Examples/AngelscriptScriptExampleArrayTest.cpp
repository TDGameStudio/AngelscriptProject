#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleArrayTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GArrayExample = {
		TEXT("Example_Array.as"),
		TEXT(R"ANGELSCRIPT(/*
 * Arrays in angelscript are managed with TArray<Type> variables.
 * These function almost identically to TArray<> in C++.
 */
UFUNCTION()
void ExecuteExampleArray()
{
	// A local variable holding an array.
	TArray<int> LocalIntArray;

	// Values can be added to the array with .Add()
	LocalIntArray.Add(2);
	LocalIntArray.Add(8);
	LocalIntArray.Add(255);

	// Arrays can be looped using a range-based for
	for (int Value : LocalIntArray)
	{
		Log("Array contained "+Value);
	}

	// Or they can be looped over by index
	for (int Index = 0, Count = LocalIntArray.Num(); Index < Count; ++Index)
	{
		int Value = LocalIntArray[Index];
		Log("Array["+Index+"] = "+Value);
	}

	// You can check if an array contains a particular item. This is a linear search.
	if (!LocalIntArray.Contains(8))
		Throw("Array did not contain 8.");

	// It is possible to find the index. This is a linear search.
	int Index = LocalIntArray.FindIndex(255);

	// Index should now be 2, since that is the index we added 255 at.
	if (Index != 2)
		Throw("Array did not contain 255 at index 2.");

	// Elements can be removed by index
	LocalIntArray.RemoveAt(Index);

	// Or the element can be removed directly. This performs a linear search.
	LocalIntArray.Remove(8);

	// Alternatively we can completely empty the array and remove everything from it.
	LocalIntArray.Empty();
})ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleArrayTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleArrayTest, "Angelscript.TestModule.ScriptExamples.Array", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleArrayTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GArrayExample);
}

#endif
