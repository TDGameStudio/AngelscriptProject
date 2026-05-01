#include "Debugging/AngelscriptDebugServer.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace
{
	struct FScopedDebugAdapterVersionOverride
	{
		explicit FScopedDebugAdapterVersionOverride(int32 InVersion)
			: PreviousVersion(AngelscriptDebugServer::DebugAdapterVersion)
		{
			AngelscriptDebugServer::DebugAdapterVersion = InVersion;
		}

		~FScopedDebugAdapterVersionOverride()
		{
			AngelscriptDebugServer::DebugAdapterVersion = PreviousVersion;
		}

		int32 PreviousVersion = 0;
	};

	template <typename T>
	T RoundTripMessage(T Message)
	{
		TArray<uint8> Buffer;
		FMemoryWriter Writer(Buffer);
		Writer << Message;

		T Result;
		FMemoryReader Reader(Buffer);
		Reader << Result;
		return Result;
	}
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolStartDebuggingRoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.StartDebugging.RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolDebugServerVersionRoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.DebugServerVersion.RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolBreakpointRoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.Breakpoint.RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolVariablesVersion1RoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.Variables.Version1RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolVariablesVersion2RoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.Variables.Version2RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolDataBreakpointsRoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.DataBreakpoints.RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolBreakFiltersRoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.BreakFilters.RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugProtocolDatabaseSettingsRoundTripTest,
	"Angelscript.TestModule.CppTests.Debug.Protocol.DatabaseSettings.RoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebugProtocolStartDebuggingRoundTripTest::RunTest(const FString& Parameters)
{
	FStartDebuggingMessage Message;
	Message.DebugAdapterVersion = 2;

	const FStartDebuggingMessage RoundTripped = RoundTripMessage(Message);
	TestEqual(TEXT("Debug.Protocol.StartDebugging.RoundTrip should preserve the adapter version"), RoundTripped.DebugAdapterVersion, 2);

	TArray<uint8> EmptyPayload;
	FMemoryReader Reader(EmptyPayload);
	FStartDebuggingMessage DefaultMessage;
	Reader << DefaultMessage;
	TestEqual(TEXT("Debug.Protocol.StartDebugging.RoundTrip should leave empty payloads at version 0"), DefaultMessage.DebugAdapterVersion, 0);
	return true;
}

bool FAngelscriptDebugProtocolDebugServerVersionRoundTripTest::RunTest(const FString& Parameters)
{
	FDebugServerVersionMessage Message;
	Message.DebugServerVersion = DEBUG_SERVER_VERSION;

	const FDebugServerVersionMessage RoundTripped = RoundTripMessage(Message);
	TestEqual(TEXT("Debug.Protocol.DebugServerVersion.RoundTrip should preserve the server version"), RoundTripped.DebugServerVersion, DEBUG_SERVER_VERSION);
	return true;
}

bool FAngelscriptDebugProtocolBreakpointRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptBreakpoint Message;
	Message.Filename = TEXT("DebuggerCallstackFixture.as");
	Message.LineNumber = 17;
	Message.Id = 42;
	Message.ModuleName = TEXT("DebuggerCallstackFixture");

	const FAngelscriptBreakpoint RoundTripped = RoundTripMessage(Message);
	TestEqual(TEXT("Debug.Protocol.Breakpoint.RoundTrip should preserve the filename"), RoundTripped.Filename, Message.Filename);
	TestEqual(TEXT("Debug.Protocol.Breakpoint.RoundTrip should preserve the line number"), RoundTripped.LineNumber, Message.LineNumber);
	TestEqual(TEXT("Debug.Protocol.Breakpoint.RoundTrip should preserve the breakpoint id"), RoundTripped.Id, Message.Id);
	TestEqual(TEXT("Debug.Protocol.Breakpoint.RoundTrip should preserve the module name"), RoundTripped.ModuleName, Message.ModuleName);
	return true;
}

bool FAngelscriptDebugProtocolVariablesVersion1RoundTripTest::RunTest(const FString& Parameters)
{
	FScopedDebugAdapterVersionOverride AdapterVersionScope(1);

	FAngelscriptVariable Message;
	Message.Name = TEXT("LocalValue");
	Message.Value = TEXT("42");
	Message.Type = TEXT("int");
	Message.bHasMembers = false;
	Message.ValueAddress = 0xDEADBEEF;
	Message.ValueSize = 8;

	TArray<uint8> Buffer;
	FMemoryWriter Writer(Buffer);
	Writer << Message;

	FAngelscriptVariable RoundTripped;
	RoundTripped.ValueAddress = 0;
	RoundTripped.ValueSize = 0;
	FMemoryReader Reader(Buffer);
	Reader << RoundTripped;

	TestEqual(TEXT("Debug.Protocol.Variables.Version1RoundTrip should preserve the variable name"), RoundTripped.Name, Message.Name);
	TestEqual(TEXT("Debug.Protocol.Variables.Version1RoundTrip should preserve the variable value"), RoundTripped.Value, Message.Value);
	TestEqual(TEXT("Debug.Protocol.Variables.Version1RoundTrip should preserve the variable type"), RoundTripped.Type, Message.Type);
	TestEqual(TEXT("Debug.Protocol.Variables.Version1RoundTrip should preserve the has-members flag"), RoundTripped.bHasMembers, Message.bHasMembers);
	TestEqual(TEXT("Debug.Protocol.Variables.Version1RoundTrip should leave ValueAddress at the default when V1 omits it"), RoundTripped.ValueAddress, uint64{0});
	TestEqual(TEXT("Debug.Protocol.Variables.Version1RoundTrip should leave ValueSize at the default when V1 omits it"), RoundTripped.ValueSize, uint8{0});
	return true;
}

bool FAngelscriptDebugProtocolVariablesVersion2RoundTripTest::RunTest(const FString& Parameters)
{
	FScopedDebugAdapterVersionOverride AdapterVersionScope(2);

	FAngelscriptVariable Message;
	Message.Name = TEXT("Combined");
	Message.Value = TEXT("15");
	Message.Type = TEXT("int");
	Message.bHasMembers = true;
	Message.ValueAddress = 0x12345678;
	Message.ValueSize = 4;

	const FAngelscriptVariable RoundTripped = RoundTripMessage(Message);
	TestEqual(TEXT("Debug.Protocol.Variables.Version2RoundTrip should preserve the variable name"), RoundTripped.Name, Message.Name);
	TestEqual(TEXT("Debug.Protocol.Variables.Version2RoundTrip should preserve the variable value"), RoundTripped.Value, Message.Value);
	TestEqual(TEXT("Debug.Protocol.Variables.Version2RoundTrip should preserve the variable type"), RoundTripped.Type, Message.Type);
	TestEqual(TEXT("Debug.Protocol.Variables.Version2RoundTrip should preserve the has-members flag"), RoundTripped.bHasMembers, Message.bHasMembers);
	TestEqual(TEXT("Debug.Protocol.Variables.Version2RoundTrip should preserve the value address"), RoundTripped.ValueAddress, Message.ValueAddress);
	TestEqual(TEXT("Debug.Protocol.Variables.Version2RoundTrip should preserve the value size"), RoundTripped.ValueSize, Message.ValueSize);
	return true;
}

bool FAngelscriptDebugProtocolDataBreakpointsRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptDataBreakpoint First;
	First.Id = 1;
	First.Address = 0x1000;
	First.AddressSize = 4;
	First.HitCount = 3;
	First.bCppBreakpoint = false;
	First.Name = TEXT("Counter");

	FAngelscriptDataBreakpoint Second;
	Second.Id = 2;
	Second.Address = 0x2000;
	Second.AddressSize = 8;
	Second.HitCount = 1;
	Second.bCppBreakpoint = true;
	Second.Name = TEXT("GlobalCounter");

	FAngelscriptDataBreakpoints Message;
	Message.Breakpoints = { First, Second };

	const FAngelscriptDataBreakpoints RoundTripped = RoundTripMessage(Message);
	if (!TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the breakpoint count"), RoundTripped.Breakpoints.Num(), 2))
	{
		return false;
	}

	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the first id"), RoundTripped.Breakpoints[0].Id, First.Id);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the first address"), RoundTripped.Breakpoints[0].Address, First.Address);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the first address size"), RoundTripped.Breakpoints[0].AddressSize, First.AddressSize);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the first hit count"), RoundTripped.Breakpoints[0].HitCount, First.HitCount);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the first C++ flag"), RoundTripped.Breakpoints[0].bCppBreakpoint, First.bCppBreakpoint);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the first name"), RoundTripped.Breakpoints[0].Name, First.Name);

	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the second id"), RoundTripped.Breakpoints[1].Id, Second.Id);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the second address"), RoundTripped.Breakpoints[1].Address, Second.Address);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the second address size"), RoundTripped.Breakpoints[1].AddressSize, Second.AddressSize);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the second hit count"), RoundTripped.Breakpoints[1].HitCount, Second.HitCount);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the second C++ flag"), RoundTripped.Breakpoints[1].bCppBreakpoint, Second.bCppBreakpoint);
	TestEqual(TEXT("Debug.Protocol.DataBreakpoints.RoundTrip should preserve the second name"), RoundTripped.Breakpoints[1].Name, Second.Name);
	return true;
}

bool FAngelscriptDebugProtocolBreakFiltersRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptBreakFilters Message;
	Message.Filters = { TEXT("Server"), TEXT("Client") };
	Message.FilterTitles = { TEXT("Break On Server"), TEXT("Break On Client") };

	const FAngelscriptBreakFilters RoundTripped = RoundTripMessage(Message);
	TestEqual(TEXT("Debug.Protocol.BreakFilters.RoundTrip should preserve the filter count"), RoundTripped.Filters.Num(), 2);
	TestEqual(TEXT("Debug.Protocol.BreakFilters.RoundTrip should preserve the first filter"), RoundTripped.Filters[0], Message.Filters[0]);
	TestEqual(TEXT("Debug.Protocol.BreakFilters.RoundTrip should preserve the second filter title"), RoundTripped.FilterTitles[1], Message.FilterTitles[1]);
	return true;
}

bool FAngelscriptDebugProtocolDatabaseSettingsRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptDebugDatabaseSettings Message;
	Message.bAutomaticImports = true;
	Message.bFloatIsFloat64 = true;
	Message.bUseAngelscriptHaze = false;
	Message.bDeprecateStaticClass = true;
	Message.bDisallowStaticClass = false;

	const FAngelscriptDebugDatabaseSettings RoundTripped = RoundTripMessage(Message);
	TestEqual(TEXT("Debug.Protocol.DatabaseSettings.RoundTrip should preserve automatic imports"), RoundTripped.bAutomaticImports, Message.bAutomaticImports);
	TestEqual(TEXT("Debug.Protocol.DatabaseSettings.RoundTrip should preserve float width"), RoundTripped.bFloatIsFloat64, Message.bFloatIsFloat64);
	TestEqual(TEXT("Debug.Protocol.DatabaseSettings.RoundTrip should preserve haze usage"), RoundTripped.bUseAngelscriptHaze, Message.bUseAngelscriptHaze);
	TestEqual(TEXT("Debug.Protocol.DatabaseSettings.RoundTrip should preserve static class deprecation"), RoundTripped.bDeprecateStaticClass, Message.bDeprecateStaticClass);
	TestEqual(TEXT("Debug.Protocol.DatabaseSettings.RoundTrip should preserve static class disallow state"), RoundTripped.bDisallowStaticClass, Message.bDisallowStaticClass);
	return true;
}

#endif
