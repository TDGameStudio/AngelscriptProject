#include "AngelscriptScriptExampleTestSupport.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Examples_AngelscriptScriptExampleAccessSpecifiersTest_Private
{
	const AngelscriptScriptExamples::FScriptExampleSource GAccessSpecifiersExample = {
		TEXT("Example_AccessSpecifiers.as"),
		TEXT(R"ANGELSCRIPT(/**
 * Access specifiers give more granular control over which
 * other classes can use specific functions and variables.
 *
 * This allows a component to only allow certain capabilities
 * to call functions on it, for example.
 */
class UAccessSpecifierExample_UnitTest
{
	// Access specifiers need to be declared in the class they are used in
	// All access specifiers start with private or protected as a base.
	access Internal = private;

	// This would be equivalent to `private`
	access:Internal
	float PrivateFloatValue = 0.0;



	// From there, you can add a list of classes that should also be granted access
	// on top of the private or protected access.
	access InternalWithCapability = private, UAccessSpecifierComponent_UnitTest, APlayerController;

	// This can be accessed as private, or by etiher of the two classes specified above
	access:InternalWithCapability
	float AccessibleFloatValue = 1.0;

	// Functions can also use access specifiers
	access:InternalWithCapability
	void AccessibleMethod()
	{
	}


	// It is also possible to restrict the type of access that a particular class
	// gets, using modifiers. Available modifiers are:
	//
	// editdefaults:
	//	The class can only set the property or call the function from a `default` statement or a ConstructionScript.
	//
	// readonly:
	//  The class can only read properties or call const methods, not do anything that can modify it.
	//
	access SpecifierCapabilityCanOnlyRead = private, UAccessSpecifierComponent_UnitTest (readonly);

	// This can be read from UAccessSpecifierComponent_UnitTest, but not changed
	access:SpecifierCapabilityCanOnlyRead
	float CapabilityReadOnlyValue = 0.0;



	// Normally, when specifying a class, only that specific class has access, not its children.
	// With the `inherited` modifier, you can give all child classes of the specified class the same access.
	access ReadableInAnySceneComponent = private, USceneComponent (inherited, readonly);

	// This value is private, but can be read (not written) from capabilities only
	access:ReadableInAnySceneComponent
	float CanBeReadBySceneComponents = 10.0;



	// Instead of writing a class name you can specify just `*` to give access to all classes.
	// This should be used in combination with modifiers.
	access EditAndReadOnly = private, * (editdefaults, readonly);

	// This value is read-only outside this class, but can be edited from `default` statements by any class
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Options")
	access:EditAndReadOnly
	bool bOptionOnlyEditable = false;



	// Global functions can also be given access just like classes
	//  Note that neither classes nor functions need to be imported to be given access
	access RestrictedToSpecificGlobalFunction = private, ExampleCallRestricted_UnitTest;

	access:RestrictedToSpecificGlobalFunction
	void RestrictedFunction()
	{
	}
};

void ExampleCallRestricted_UnitTest()
{
	UAccessSpecifierExample_UnitTest Example;
	Example.RestrictedFunction();
}

class UAccessSpecifierComponent_UnitTest : UActorComponent
{
};)ANGELSCRIPT"),
		nullptr,
		nullptr,
	};
}

using namespace AngelscriptTest_Examples_AngelscriptScriptExampleAccessSpecifiersTest_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(FAngelscriptScriptExampleAccessSpecifiersTest, "Angelscript.TestModule.ScriptExamples.AccessSpecifiers", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScriptExampleAccessSpecifiersTest::RunTest(const FString& Parameters)
{
	return AngelscriptScriptExamples::RunScriptExampleCompileTest(*this, GAccessSpecifiersExample);
}

#endif
