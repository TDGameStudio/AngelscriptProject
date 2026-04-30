#include "Debugging/AngelscriptDebugClientModel.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugClientModelScopePathTest,
	"Angelscript.CppTests.Debug.ClientModel.ScopePaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugClientModelBreakpointAckTest,
	"Angelscript.CppTests.Debug.ClientModel.BreakpointAck",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugClientModelSourcePathTest,
	"Angelscript.CppTests.Debug.ClientModel.SourcePaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugClientModelBreakpointVisibleStateTest,
	"Angelscript.CppTests.Debug.ClientModel.BreakpointVisibleState",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugClientModelBreakpointLookupTest,
	"Angelscript.CppTests.Debug.ClientModel.BreakpointLookup",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugClientModelBreakpointConditionUpdateTest,
	"Angelscript.CppTests.Debug.ClientModel.BreakpointConditionUpdate",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebugClientModelScopePathTest::RunTest(const FString& Parameters)
{
	TestEqual(TEXT("Local scope path should match DebugServer scope syntax"),
		AngelscriptDebugClient::MakeScopePath(2, AngelscriptDebugClient::EScopeKind::Local),
		FString(TEXT("2:%local%")));
	TestEqual(TEXT("This scope path should match DebugServer scope syntax"),
		AngelscriptDebugClient::MakeScopePath(3, AngelscriptDebugClient::EScopeKind::This),
		FString(TEXT("3:%this%")));
	TestEqual(TEXT("Module scope path should match DebugServer scope syntax"),
		AngelscriptDebugClient::MakeScopePath(4, AngelscriptDebugClient::EScopeKind::Module),
		FString(TEXT("4:%module%")));
	TestEqual(TEXT("Member child paths should use dot syntax"),
		AngelscriptDebugClient::CombineDebuggerPath(TEXT("0:%this%"), TEXT("Health")),
		FString(TEXT("0:%this%.Health")));
	TestEqual(TEXT("Array child paths should use subscript syntax without an extra dot"),
		AngelscriptDebugClient::CombineDebuggerPath(TEXT("0:Items"), TEXT("[3]")),
		FString(TEXT("0:Items[3]")));
	return true;
}

bool FAngelscriptDebugClientModelBreakpointAckTest::RunTest(const FString& Parameters)
{
	AngelscriptDebugClient::FBreakpointStore Store;
	const int32 Id = Store.SetBreakpoint(TEXT("C:/Project/Script/Foo.as"), TEXT("Foo"), 10, TEXT("Value == 3"));

	const TArray<AngelscriptDebugClient::FBreakpointEntry> InitialEntries = Store.GetBreakpoints();
	if (!TestEqual(TEXT("Breakpoint store should contain the requested breakpoint"), InitialEntries.Num(), 1))
	{
		return false;
	}

	TestEqual(TEXT("Requested breakpoint should preserve its initial line"), InitialEntries[0].LineNumber, 10);
	TestTrue(TEXT("Requested breakpoint should start verified before server ack"), InitialEntries[0].bVerified);

	FAngelscriptBreakpoint MoveAck;
	MoveAck.Filename = TEXT("C:/Project/Script/Foo.as");
	MoveAck.ModuleName = TEXT("Foo");
	MoveAck.LineNumber = 12;
	MoveAck.Id = Id;
	MoveAck.Condition = TEXT("Value == 3");
	TestTrue(TEXT("Breakpoint store should apply moved breakpoint ack"), Store.ApplyServerAck(MoveAck));

	const TArray<AngelscriptDebugClient::FBreakpointEntry> MovedEntries = Store.GetBreakpoints();
	TestEqual(TEXT("Moved breakpoint ack should update the active line"), MovedEntries[0].LineNumber, 12);
	TestTrue(TEXT("Moved breakpoint ack should keep breakpoint verified"), MovedEntries[0].bVerified);

	FAngelscriptBreakpoint RemovalAck;
	RemovalAck.Filename = TEXT("C:/Project/Script/Foo.as");
	RemovalAck.ModuleName = TEXT("Foo");
	RemovalAck.LineNumber = -1;
	RemovalAck.Id = Id;
	TestTrue(TEXT("Breakpoint store should apply removal ack"), Store.ApplyServerAck(RemovalAck));

	const TArray<AngelscriptDebugClient::FBreakpointEntry> RemovedEntries = Store.GetBreakpoints();
	TestEqual(TEXT("Removal ack should keep a visible unverified breakpoint"), RemovedEntries.Num(), 1);
	TestFalse(TEXT("Removal ack should mark breakpoint unverified"), RemovedEntries[0].bVerified);
	TestEqual(TEXT("Removal ack should preserve the requested line"), RemovedEntries[0].LineNumber, 10);
	TestTrue(TEXT("Unverified breakpoints should remain visible at their requested line"), Store.HasBreakpointAtLine(TEXT("C:/Project/Script/Foo.as"), 10));

	return true;
}

bool FAngelscriptDebugClientModelSourcePathTest::RunTest(const FString& Parameters)
{
	const TArray<FString> Roots = {
		TEXT("C:/Project/Script"),
		TEXT("D:/Other/Script")
	};

	TestEqual(TEXT("Module names should be relative to script roots"),
		AngelscriptDebugClient::MakeModuleNameFromScriptPath(TEXT("C:/Project/Script/Gameplay/Actor.as"), Roots),
		FString(TEXT("Gameplay.Actor")));
	TestEqual(TEXT("Already absolute source paths should be normalized"),
		AngelscriptDebugClient::ResolveSourcePath(TEXT("C:\\Project\\Script\\Gameplay\\Actor.as"), TEXT("Gameplay.Actor"), Roots),
		FString(TEXT("C:/Project/Script/Gameplay/Actor.as")));
	TestEqual(TEXT("Missing source paths should fall back through module names and script roots"),
		AngelscriptDebugClient::ResolveSourcePath(TEXT("Gameplay/Actor.as"), TEXT("Gameplay.Actor"), Roots),
		FString(TEXT("C:/Project/Script/Gameplay/Actor.as")));

	return true;
}

bool FAngelscriptDebugClientModelBreakpointVisibleStateTest::RunTest(const FString& Parameters)
{
	AngelscriptDebugClient::FBreakpointStore Store;
	const int32 FirstId = Store.SetBreakpoint(TEXT("C:/Project/Script/Foo.as"), TEXT("Foo"), 10, FString());
	const int32 SecondId = Store.SetBreakpoint(TEXT("C:/Project/Script/Foo.as"), TEXT("Foo"), 11, FString());

	FAngelscriptBreakpoint DuplicateLineAck;
	DuplicateLineAck.Filename = TEXT("C:/Project/Script/Foo.as");
	DuplicateLineAck.ModuleName = TEXT("Foo");
	DuplicateLineAck.LineNumber = 10;
	DuplicateLineAck.Id = SecondId;
	TestTrue(TEXT("Breakpoint store should apply duplicate-line ack"), Store.ApplyServerAck(DuplicateLineAck));

	const TArray<AngelscriptDebugClient::FBreakpointEntry> EntriesAfterDuplicateAck = Store.GetBreakpoints();
	TestEqual(TEXT("Duplicate-line ack should leave one visible breakpoint"), EntriesAfterDuplicateAck.Num(), 1);
	TestEqual(TEXT("Original breakpoint should keep ownership of the executable line"), EntriesAfterDuplicateAck[0].Id, FirstId);
	TestEqual(TEXT("Duplicate-line ack should keep the executable line visible"), EntriesAfterDuplicateAck[0].LineNumber, 10);

	AngelscriptDebugClient::FBreakpointEntry RemovedBreakpoint;
	TestTrue(TEXT("Breakpoint store should remove selected breakpoint by id"), Store.RemoveBreakpointById(FirstId, &RemovedBreakpoint));
	TestEqual(TEXT("Removed breakpoint should report its original line"), RemovedBreakpoint.LineNumber, 10);
	TestEqual(TEXT("Removing selected breakpoint should leave the store empty"), Store.GetBreakpoints().Num(), 0);

	return true;
}

bool FAngelscriptDebugClientModelBreakpointLookupTest::RunTest(const FString& Parameters)
{
	AngelscriptDebugClient::FBreakpointStore Store;
	const int32 Id = Store.SetBreakpoint(TEXT("C:/Project/Script/Foo.as"), TEXT("Foo"), 10, TEXT("Value == 3"));

	FAngelscriptBreakpoint RemovalAck;
	RemovalAck.Filename = TEXT("C:/Project/Script/Foo.as");
	RemovalAck.ModuleName = TEXT("Foo");
	RemovalAck.LineNumber = -1;
	RemovalAck.Id = Id;
	TestTrue(TEXT("Breakpoint lookup test should apply removal ack"), Store.ApplyServerAck(RemovalAck));

	AngelscriptDebugClient::FBreakpointEntry Lookup;
	TestTrue(TEXT("Breakpoint lookup should find an unverified visible breakpoint at the requested line"),
		Store.TryGetBreakpointAtLine(TEXT("C:/Project/Script/Foo.as"), 10, Lookup));
	TestEqual(TEXT("Breakpoint lookup should preserve the breakpoint id"), Lookup.Id, Id);
	TestFalse(TEXT("Breakpoint lookup should expose unverified state"), Lookup.bVerified);
	TestEqual(TEXT("Breakpoint lookup should preserve the condition"), Lookup.Condition, FString(TEXT("Value == 3")));
	TestFalse(TEXT("Breakpoint lookup should not find an unrelated line"),
		Store.TryGetBreakpointAtLine(TEXT("C:/Project/Script/Foo.as"), 11, Lookup));

	return true;
}

bool FAngelscriptDebugClientModelBreakpointConditionUpdateTest::RunTest(const FString& Parameters)
{
	AngelscriptDebugClient::FBreakpointStore Store;
	const int32 FirstId = Store.SetBreakpoint(TEXT("C:/Project/Script/Foo.as"), TEXT("Foo"), 10, TEXT("Value == 3"));
	const int32 SecondId = Store.SetBreakpoint(TEXT("C:/Project/Script/Foo.as"), TEXT("Foo"), 12, TEXT("Other == 7"));

	FAngelscriptBreakpoint Ack;
	Ack.Filename = TEXT("C:/Project/Script/Foo.as");
	Ack.ModuleName = TEXT("Foo");
	Ack.LineNumber = 14;
	Ack.Id = FirstId;
	TestTrue(TEXT("Breakpoint condition update test should apply server ack first"), Store.ApplyServerAck(Ack));

	AngelscriptDebugClient::FBreakpointEntry UpdatedBreakpoint;
	TestTrue(TEXT("Breakpoint store should update a condition by id"),
		Store.UpdateBreakpointCondition(FirstId, TEXT("Value > 10"), &UpdatedBreakpoint));
	TestEqual(TEXT("Updated breakpoint should keep its id"), UpdatedBreakpoint.Id, FirstId);
	TestEqual(TEXT("Updated breakpoint should keep its normalized filename"), UpdatedBreakpoint.Filename, FString(TEXT("C:/Project/Script/Foo.as")));
	TestEqual(TEXT("Updated breakpoint should keep its module"), UpdatedBreakpoint.ModuleName, FString(TEXT("Foo")));
	TestEqual(TEXT("Updated breakpoint should keep its requested line"), UpdatedBreakpoint.RequestedLineNumber, 10);
	TestEqual(TEXT("Updated breakpoint should keep its resolved line"), UpdatedBreakpoint.LineNumber, 14);
	TestTrue(TEXT("Updated breakpoint should keep verified state"), UpdatedBreakpoint.bVerified);
	TestEqual(TEXT("Updated breakpoint should store the new condition"), UpdatedBreakpoint.Condition, FString(TEXT("Value > 10")));

	AngelscriptDebugClient::FBreakpointEntry ClearedBreakpoint;
	TestTrue(TEXT("Breakpoint store should clear a condition by id"),
		Store.UpdateBreakpointCondition(FirstId, FString(), &ClearedBreakpoint));
	TestEqual(TEXT("Cleared breakpoint should keep the same id"), ClearedBreakpoint.Id, FirstId);
	TestEqual(TEXT("Cleared breakpoint should have an empty condition"), ClearedBreakpoint.Condition, FString());

	TestFalse(TEXT("Breakpoint store should reject unknown condition updates"),
		Store.UpdateBreakpointCondition(999, TEXT("Missing"), nullptr));

	const TArray<AngelscriptDebugClient::FBreakpointEntry> Entries = Store.GetBreakpoints();
	TestEqual(TEXT("Rejected condition update should not change breakpoint count"), Entries.Num(), 2);

	const AngelscriptDebugClient::FBreakpointEntry* SecondBreakpoint = Entries.FindByPredicate([SecondId](const AngelscriptDebugClient::FBreakpointEntry& Entry)
	{
		return Entry.Id == SecondId;
	});
	if (!TestNotNull(TEXT("Second breakpoint should remain present"), SecondBreakpoint))
	{
		return false;
	}
	TestEqual(TEXT("Rejected condition update should not mutate other breakpoints"), SecondBreakpoint->Condition, FString(TEXT("Other == 7")));

	return true;
}

#endif
