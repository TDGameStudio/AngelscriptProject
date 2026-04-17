#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleMapTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GMapExample = {
		TEXT("Example_Map.as"),
		TEXT(R"ANGELSCRIPT(/*
 * TMap<KeyType,ValueType> is used to store a key->value lookup table,
 * this works similar to C++ TMap<>, with a few small differences
 * because there are no pointers in angelscript.
 */
UFUNCTION()
void ExecuteExampleMap()
{
	// A local variable holding a map.
	TMap<FString, int> LocalStringToIntMap;

	// Adds an association between a specific string and its integer.
	LocalStringToIntMap.Add("TestString", 2);
	LocalStringToIntMap.Add("Three", 3);
	LocalStringToIntMap.Add("Four", 4);
	LocalStringToIntMap.Add("ChangeThis", 5);

	// Check whether the given key has anything associated with it
	if (!LocalStringToIntMap.Contains("TestString"))
	{
		Throw("Map did not contain TestString.");
	}

	// Find() returns whether a value with that key was found,
	// if it was, then the value is copied into the passed value.
	int FoundValue = -1;
	if (!LocalStringToIntMap.Find("Four", FoundValue))
	{
		Throw("Map did not contain Four.");
	}

	// FoundValue is now 4, since Find() sets the value it gets passed.
	if (FoundValue != 4)
	{
		Throw("Map contained wrong value for Four.");
	}

	// You can also use the [] operator to get a value, but that will throw an exception
	// if the key does not exist, so be sure to us Contains before if that might be the case
	if (LocalStringToIntMap.Contains("ChangeThis"))
	{
		int& Value = LocalStringToIntMap["ChangeThis"];
		check(Value == 5);

		// The [] operator returns a reference, so you can set the value this way as well
		LocalStringToIntMap["ChangeThis"] = 12;
		check(LocalStringToIntMap["ChangeThis"] == 12);
		check(Value == 12); // Since it's an int&
	}

	// Looping over elements can be done with a range-based loop.
	//  Note that the type of auto here is an iterator type,
	//  which supports access to .Key and .Value.
	for (auto Element : LocalStringToIntMap)
	{
		Log("Map contained "+Element.Key+" => "+Element.Value);
	}

	// The iterated values are references, so can be changed
	for (auto Element : LocalStringToIntMap)
	{
		if (Element.Key == "ChangeThis")
			Element.Value = 27;
	}
	check(LocalStringToIntMap["ChangeThis"] == 27);

	// The FindOrAdd function will return a reference, initially set to default value
	int& Value = LocalStringToIntMap.FindOrAdd("Newb");
	check(Value == 0);
	Value = 9;
	check(LocalStringToIntMap["Newb"] == 9);
	// Alternatively you can just do
	LocalStringToIntMap.FindOrAdd("Noob") = 21;
	check(LocalStringToIntMap["Noob"] == 21);

	// Remove everything from the map that was in there
	LocalStringToIntMap.Empty();
}

/*
 * Example of a TMap<> added as a UPROPERTY().
 *  This will let you select actors from the level
 *  to associate strings with.
 */
class AExampleMapActor_UnitTest : AActor
{
	UPROPERTY()
	TMap<AActor, FString> ActorMap;

	UFUNCTION()
	void PrintActorMap()
	{
		// Range based for loop to iterate all elements
		for (auto Element : ActorMap)
		{
			Log("Actor Map: "+Element.Key+" => "+Element.Value);
		}
	}
};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleMapTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleMapTest, "Angelscript.TestModule.ScriptExamples.Map", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleMapTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GMapExample);
}

#endif
