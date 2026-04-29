#include "StateInspector/AngelscriptEngineStateSnapshot.h"
#include "StateInspector/AngelscriptStateDumpBrowserData.h"
#include "StateInspector/SAngelscriptEngineStateWidget.h"

#include "AngelscriptEngine.h"
#include "Core/AngelscriptBindDatabase.h"
#include "Core/angelscript.h"
#include "GameFramework/Actor.h"
#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Guid.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "Preprocessor/AngelscriptPreprocessor.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptEditor_StateInspectorTests_Private
{
	TUniquePtr<FAngelscriptEngine> MakeStateInspectorTestEngine()
	{
		const FAngelscriptEngineConfig Config;
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		return FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
	}

	struct FScopedAutomaticImportsOverride
	{
		explicit FScopedAutomaticImportsOverride(asIScriptEngine* InScriptEngine)
			: ScriptEngine(InScriptEngine)
			, PreviousValue(InScriptEngine != nullptr ? InScriptEngine->GetEngineProperty(asEP_AUTOMATIC_IMPORTS) : 0)
		{
			if (ScriptEngine != nullptr)
			{
				ScriptEngine->SetEngineProperty(asEP_AUTOMATIC_IMPORTS, 0);
			}
		}

		~FScopedAutomaticImportsOverride()
		{
			if (ScriptEngine != nullptr)
			{
				ScriptEngine->SetEngineProperty(asEP_AUTOMATIC_IMPORTS, PreviousValue);
			}
		}

		asIScriptEngine* ScriptEngine = nullptr;
		asPWORD PreviousValue = 0;
	};

	struct FScopedBindDatabaseOverride
	{
		FScopedBindDatabaseOverride()
			: SavedClasses(FAngelscriptBindDatabase::Get().Classes)
			, SavedStructs(FAngelscriptBindDatabase::Get().Structs)
		{
		}

		~FScopedBindDatabaseOverride()
		{
			FAngelscriptBindDatabase::Get().Classes = MoveTemp(SavedClasses);
			FAngelscriptBindDatabase::Get().Structs = MoveTemp(SavedStructs);
		}

		TArray<FAngelscriptClassBind> SavedClasses;
		TArray<FAngelscriptStructBind> SavedStructs;
	};

	bool CompileStateInspectorScript(FAutomationTestBase& Test, FAngelscriptEngine& Engine, const FString& ModuleName, const FString& ScriptSource)
	{
		const FString RelativeFilename = FString::Printf(TEXT("%s.as"), *ModuleName);
		const FString AbsoluteFilename = FPaths::Combine(
			FPaths::ProjectSavedDir(),
			TEXT("Automation"),
			TEXT("StateInspector"),
			FGuid::NewGuid().ToString(EGuidFormats::Digits),
			RelativeFilename);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsoluteFilename), true);
		if (!FFileHelper::SaveStringToFile(ScriptSource, *AbsoluteFilename))
		{
			Test.AddError(FString::Printf(TEXT("StateInspector test should write script file '%s'"), *AbsoluteFilename));
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(RelativeFilename, AbsoluteFilename);
		if (!Preprocessor.Preprocess())
		{
			Test.AddError(FString::Printf(TEXT("StateInspector test failed to preprocess script: %s"), *Engine.FormatDiagnostics()));
			return false;
		}

		TArray<TSharedRef<FAngelscriptModuleDesc>> ModulesToCompile = Preprocessor.GetModulesToCompile();
		TArray<TSharedRef<FAngelscriptModuleDesc>> CompiledModules;
		TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
		FScopedAutomaticImportsOverride AutomaticImportsOverride(Engine.GetScriptEngine());
		const ECompileResult CompileResult = Engine.CompileModules(ECompileType::Initial, ModulesToCompile, CompiledModules);
		if (CompileResult == ECompileResult::Error || CompileResult == ECompileResult::ErrorNeedFullReload)
		{
			Test.AddError(FString::Printf(TEXT("StateInspector test failed to compile script: %s"), *Engine.FormatDiagnostics()));
			return false;
		}

		return Test.TestTrue(TEXT("StateInspector test should compile at least one module"), CompiledModules.Num() > 0);
	}

	const FAngelscriptStateScriptClassSnapshot* FindScriptClass(const FAngelscriptEngineStateSnapshot& Snapshot, const FString& ClassName)
	{
		return Snapshot.ScriptClasses.FindByPredicate([&ClassName](const FAngelscriptStateScriptClassSnapshot& Candidate)
		{
			return Candidate.ClassName == ClassName;
		});
	}

	bool HasMemberNamed(const TArray<FAngelscriptStateMemberSnapshot>& Members, const FString& Name)
	{
		return Members.ContainsByPredicate([&Name](const FAngelscriptStateMemberSnapshot& Member)
		{
			return Member.Name == Name;
		});
	}

	bool IsKnownMethodBindingPath(const FString& BindingPath)
	{
		return BindingPath == TEXT("DirectNativePointer")
			|| BindingPath == TEXT("ReflectiveFallback")
			|| BindingPath == TEXT("NoFunctionPointer")
			|| BindingPath == TEXT("UnresolvedFunction");
	}

	void AddSyntheticActorBindDatabaseEntry()
	{
		FAngelscriptBindDatabase& BindDatabase = FAngelscriptBindDatabase::Get();

		FAngelscriptClassBind ClassBind;
		ClassBind.TypeName = TEXT("AActor");
		ClassBind.UnrealPath = AActor::StaticClass()->GetPathName();
		ClassBind.ResolvedClass = AActor::StaticClass();

		FAngelscriptPropertyBind PropertyBind;
		PropertyBind.Declaration = TEXT("TArray<FName> Tags");
		PropertyBind.UnrealPath = TEXT("Tags");
		PropertyBind.bCanRead = true;
		PropertyBind.bCanWrite = true;
		ClassBind.Properties.Add(PropertyBind);

		UFunction* GetActorLocationFunction = AActor::StaticClass()->FindFunctionByName(TEXT("K2_GetActorLocation"));
		FAngelscriptMethodBind MethodBind;
		MethodBind.Declaration = TEXT("FVector GetActorLocation() const");
		MethodBind.UnrealPath = GetActorLocationFunction != nullptr ? GetActorLocationFunction->GetName() : TEXT("K2_GetActorLocation");
		MethodBind.ClassName = TEXT("AActor");
		MethodBind.ScriptName = TEXT("GetActorLocation");
		MethodBind.ResolvedFunction = GetActorLocationFunction;
		MethodBind.bTrivial = true;
		ClassBind.Methods.Add(MethodBind);

		BindDatabase.Classes.Add(MoveTemp(ClassBind));
	}

	FString MakeUniqueStateDumpBrowserPath(const FString& Prefix)
	{
		return FPaths::ConvertRelativePathToFull(FPaths::Combine(
			FPaths::ProjectSavedDir(),
			TEXT("Automation"),
			TEXT("StateDumpBrowser"),
			FString::Printf(TEXT("%s_%s"), *Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits))));
	}

	bool SaveStateDumpBrowserCsv(FAutomationTestBase& Test, const FString& Filename, const FString& Content)
	{
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(Filename), true);
		return Test.TestTrue(
			*FString::Printf(TEXT("StateDumpBrowser test should write '%s'"), *Filename),
			FFileHelper::SaveStringToFile(Content, *Filename, FFileHelper::EEncodingOptions::ForceUTF8));
	}

	const FAngelscriptStateDumpTableDiff* FindDiffByTableName(const TArray<FAngelscriptStateDumpTableDiff>& Diffs, const FString& TableName)
	{
		return Diffs.FindByPredicate([&TableName](const FAngelscriptStateDumpTableDiff& Diff)
		{
			return Diff.TableName == TableName;
		});
	}
}

using namespace AngelscriptEditor_StateInspectorTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEditorStateInspectorNoEngineTest,
	"Angelscript.Editor.StateInspector.CaptureHandlesMissingEngine",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEditorStateInspectorNoEngineTest::RunTest(const FString& Parameters)
{
	const FAngelscriptEngineStateSnapshot Snapshot = FAngelscriptEngineStateSnapshot::Capture(nullptr);
	TestFalse(TEXT("StateInspector missing-engine snapshot should not report an engine"), Snapshot.Overview.bHasEngine);
	TestFalse(TEXT("StateInspector missing-engine snapshot should not report a script engine"), Snapshot.Overview.bHasScriptEngine);
	TestTrue(TEXT("StateInspector missing-engine snapshot should explain its status"), Snapshot.Overview.Status.Contains(TEXT("No active")));
	TestEqual(TEXT("StateInspector missing-engine snapshot should not report modules"), Snapshot.Modules.Num(), 0);
	return TestEqual(TEXT("StateInspector missing-engine snapshot should not report script classes"), Snapshot.ScriptClasses.Num(), 0);
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEditorStateInspectorScriptSnapshotTest,
	"Angelscript.Editor.StateInspector.CapturesScriptClassesAndMembers",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEditorStateInspectorScriptSnapshotTest::RunTest(const FString& Parameters)
{
	TArray<FAngelscriptEngine*> SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
	TUniquePtr<FAngelscriptEngine> Engine = MakeStateInspectorTestEngine();
	ON_SCOPE_EXIT
	{
		FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
	};

	if (!TestNotNull(TEXT("StateInspector script snapshot test should create a testing engine"), Engine.Get()))
	{
		return false;
	}

	const FString ModuleName = TEXT("Editor.StateInspector.Sample");
	const FString Script = TEXT(R"AS(
class AStateInspectorSampleActor : AActor
{
	UPROPERTY()
	int Value = 7;

	UFUNCTION()
	int AddValue(int Other) const
	{
		return Value + Other;
	}
}
)AS");

	if (!CompileStateInspectorScript(*this, *Engine, ModuleName, Script))
	{
		return false;
	}

	const FAngelscriptEngineStateSnapshot Snapshot = FAngelscriptEngineStateSnapshot::Capture(Engine.Get());
	const FAngelscriptStateScriptClassSnapshot* ClassSnapshot = FindScriptClass(Snapshot, TEXT("AStateInspectorSampleActor"));
	if (!TestNotNull(TEXT("StateInspector snapshot should include the compiled script class"), ClassSnapshot))
	{
		return false;
	}

	TestEqual(TEXT("StateInspector snapshot should record the script class module"), ClassSnapshot->ModuleName, ModuleName);
	TestTrue(TEXT("StateInspector snapshot should include the Value property"), HasMemberNamed(ClassSnapshot->Properties, TEXT("Value")));
	TestTrue(TEXT("StateInspector snapshot should include the AddValue method"), HasMemberNamed(ClassSnapshot->Methods, TEXT("AddValue")));
	TestTrue(TEXT("StateInspector snapshot should report at least one AS object type"), Snapshot.Overview.ScriptObjectTypeCount > 0);
	TestTrue(TEXT("StateInspector snapshot should report bind registrations"), Snapshot.BindRegistrations.Num() > 0);
	return TestTrue(TEXT("StateInspector snapshot should report registered AS type details"), Snapshot.RegisteredTypes.Num() > 0);
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEditorStateInspectorBindSnapshotTest,
	"Angelscript.Editor.StateInspector.CapturesBindDatabaseAndRegistrations",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEditorStateInspectorBindSnapshotTest::RunTest(const FString& Parameters)
{
	TArray<FAngelscriptEngine*> SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
	TUniquePtr<FAngelscriptEngine> Engine = MakeStateInspectorTestEngine();
	ON_SCOPE_EXIT
	{
		FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
	};

	if (!TestNotNull(TEXT("StateInspector bind snapshot test should create a testing engine"), Engine.Get()))
	{
		return false;
	}

	FScopedBindDatabaseOverride BindDatabaseOverride;
	AddSyntheticActorBindDatabaseEntry();

	const FAngelscriptEngineStateSnapshot Snapshot = FAngelscriptEngineStateSnapshot::Capture(Engine.Get());
	TestTrue(TEXT("StateInspector bind snapshot should report bind registrations"), Snapshot.BindRegistrations.Num() > 0);
	TestTrue(TEXT("StateInspector bind snapshot should report bound C++ types"), Snapshot.BindTypes.Num() > 0);
	TestTrue(TEXT("StateInspector bind snapshot should report bound C++ properties"), Snapshot.Overview.BindDatabasePropertyCount > 0);
	TestTrue(TEXT("StateInspector bind snapshot should report bound C++ methods"), Snapshot.Overview.BindDatabaseMethodCount > 0);

	for (int32 Index = 1; Index < Snapshot.BindRegistrations.Num(); ++Index)
	{
		if (!TestTrue(
			TEXT("StateInspector bind registrations should be sorted by name"),
			Snapshot.BindRegistrations[Index - 1].BindName <= Snapshot.BindRegistrations[Index].BindName))
		{
			return false;
		}
	}

	bool bFoundStructuredType = false;
	bool bFoundStructuredProperty = false;
	bool bFoundStructuredMethod = false;
	const FAngelscriptStateBindPropertySnapshot* SampleProperty = nullptr;
	const FAngelscriptStateBindMethodSnapshot* SampleMethod = nullptr;

	for (const FAngelscriptStateBindTypeSnapshot& BindType : Snapshot.BindTypes)
	{
		if (!BindType.TypeName.IsEmpty() && (!BindType.CppTypePath.IsEmpty() || !BindType.UnrealPath.IsEmpty()))
		{
			bFoundStructuredType = true;
		}

		if (BindType.Methods.Num() > 0)
		{
			const int32 ClassifiedMethodCount =
				BindType.DirectNativeMethodCount
				+ BindType.ReflectiveFallbackMethodCount
				+ BindType.NoFunctionPointerMethodCount
				+ BindType.UnresolvedMethodCount;
			TestEqual(
				TEXT("StateInspector bind snapshot should classify every method call path"),
				ClassifiedMethodCount,
				BindType.Methods.Num());
		}

		for (const FAngelscriptStateBindPropertySnapshot& Property : BindType.Properties)
		{
			if (!Property.Declaration.IsEmpty() && (!Property.UnrealPath.IsEmpty() || !Property.GeneratedName.IsEmpty() || !Property.Flags.IsEmpty()))
			{
				bFoundStructuredProperty = true;
				if (SampleProperty == nullptr || Property.UnrealPath == TEXT("Tags"))
				{
					SampleProperty = &Property;
				}
			}
		}

		for (const FAngelscriptStateBindMethodSnapshot& Method : BindType.Methods)
		{
			if (!Method.Declaration.IsEmpty() && !Method.UnrealPath.IsEmpty() && IsKnownMethodBindingPath(Method.BindingPath))
			{
				bFoundStructuredMethod = true;
				if (SampleMethod == nullptr || Method.Flags.Contains(TEXT("Trivial")))
				{
					SampleMethod = &Method;
				}
			}
		}
	}

	TestTrue(TEXT("StateInspector bind snapshot should include C++ type identity"), bFoundStructuredType);
	TestTrue(TEXT("StateInspector bind snapshot should include structured properties"), bFoundStructuredProperty);
	TestTrue(TEXT("StateInspector bind snapshot should include structured method call paths"), bFoundStructuredMethod);
	if (!TestNotNull(TEXT("StateInspector bind snapshot should expose a sample property"), SampleProperty))
	{
		return false;
	}
	if (!TestNotNull(TEXT("StateInspector bind snapshot should expose a sample method"), SampleMethod))
	{
		return false;
	}

	TestFalse(TEXT("StateInspector bind property should have a display name"), SampleProperty->DisplayName.IsEmpty());
	TestFalse(TEXT("StateInspector bind property should have an owner name"), SampleProperty->OwnerName.IsEmpty());
	TestFalse(TEXT("StateInspector bind property should have a category"), SampleProperty->Category.IsEmpty());
	TestFalse(TEXT("StateInspector bind property should have search text"), SampleProperty->SearchText.IsEmpty());
	TestFalse(TEXT("StateInspector bind property should have a sort key"), SampleProperty->SortKey.IsEmpty());
	TestFalse(TEXT("StateInspector bind method should have a display name"), SampleMethod->DisplayName.IsEmpty());
	TestFalse(TEXT("StateInspector bind method should have an owner name"), SampleMethod->OwnerName.IsEmpty());
	TestFalse(TEXT("StateInspector bind method should have a category"), SampleMethod->Category.IsEmpty());
	TestFalse(TEXT("StateInspector bind method should have search text"), SampleMethod->SearchText.IsEmpty());
	TestFalse(TEXT("StateInspector bind method should have a sort key"), SampleMethod->SortKey.IsEmpty());

	FAngelscriptStateInspectorBindDetailsFilter MethodFilter = FAngelscriptStateInspectorBindDetailsFilter::Parse(
		FString::Printf(TEXT("kind:method owner:%s category:%s path:%s flag:Trivial %s"), *SampleMethod->OwnerName, *SampleMethod->Category, *SampleMethod->BindingPath, *SampleMethod->ScriptName));
	TestTrue(TEXT("StateInspector bind filter should match method kind/owner/category/path/flag tokens"), MethodFilter.MatchesMethod(*SampleMethod));
	TestFalse(TEXT("StateInspector bind filter should not match properties for a method filter"), MethodFilter.MatchesProperty(*SampleProperty));

	FAngelscriptStateInspectorBindDetailsFilter PropertyFilter = FAngelscriptStateInspectorBindDetailsFilter::Parse(
		FString::Printf(TEXT("kind:property owner:%s category:%s path:%s %s"), *SampleProperty->OwnerName, *SampleProperty->Category, *SampleProperty->UnrealPath, *SampleProperty->DisplayName));
	TestTrue(TEXT("StateInspector bind filter should match property kind/owner/category/path/text tokens"), PropertyFilter.MatchesProperty(*SampleProperty));
	TestFalse(TEXT("StateInspector bind filter should not match methods for a property filter"), PropertyFilter.MatchesMethod(*SampleMethod));

	FAngelscriptStateInspectorBindDetailsFilter HiddenPathFilter = FAngelscriptStateInspectorBindDetailsFilter::Parse(FString());
	if (SampleMethod->BindingPath == TEXT("DirectNativePointer"))
	{
		HiddenPathFilter.bShowDirectMethods = false;
	}
	else if (SampleMethod->BindingPath == TEXT("ReflectiveFallback"))
	{
		HiddenPathFilter.bShowReflectiveFallbackMethods = false;
	}
	else if (SampleMethod->BindingPath == TEXT("UnresolvedFunction"))
	{
		HiddenPathFilter.bShowUnresolvedMethods = false;
	}
	else
	{
		HiddenPathFilter.bShowNoFunctionPointerMethods = false;
	}
	TestFalse(TEXT("StateInspector bind filter should respect call path toggles"), HiddenPathFilter.MatchesMethod(*SampleMethod));

	return TestEqual(
		TEXT("StateInspector bind snapshot should keep overview bind type counts consistent"),
		Snapshot.Overview.BindDatabaseClassCount + Snapshot.Overview.BindDatabaseStructCount,
		Snapshot.BindTypes.Num());
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEditorStateDumpBrowserCsvParserTest,
	"Angelscript.Editor.StateInspector.StateDumpBrowserLoadsQuotedCsvFields",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEditorStateDumpBrowserCsvParserTest::RunTest(const FString& Parameters)
{
	const FString RootDirectory = MakeUniqueStateDumpBrowserPath(TEXT("CsvParser"));
	ON_SCOPE_EXIT
	{
		IFileManager::Get().DeleteDirectory(*RootDirectory, false, true);
	};

	const FString CsvFilename = FPaths::Combine(RootDirectory, TEXT("Quoted.csv"));
	const FString CsvContent =
		TEXT("Id,Value,Notes\r\n")
		TEXT("one,\"a,b\",\"quote \"\"ok\"\"\"\r\n")
		TEXT("two,\"line one\nline two\",plain\r\n");
	if (!SaveStateDumpBrowserCsv(*this, CsvFilename, CsvContent))
	{
		return false;
	}

	const FAngelscriptCsvTable Table = AngelscriptEditor::StateInspector::LoadCsvTable(CsvFilename);
	if (!TestTrue(TEXT("StateDumpBrowser CSV parser should accept quoted commas, escaped quotes, and quoted newlines"), Table.IsValid()))
	{
		AddError(Table.ErrorMessage);
		return false;
	}

	if (!TestEqual(TEXT("StateDumpBrowser CSV parser should load the header"), Table.Header.Num(), 3)
		|| !TestEqual(TEXT("StateDumpBrowser CSV parser should load two data rows"), Table.Rows.Num(), 2))
	{
		return false;
	}

	TestEqual(TEXT("StateDumpBrowser CSV parser should unescape quoted comma fields"), Table.Rows[0][1], FString(TEXT("a,b")));
	TestEqual(TEXT("StateDumpBrowser CSV parser should unescape doubled quotes"), Table.Rows[0][2], FString(TEXT("quote \"ok\"")));
	return TestEqual(TEXT("StateDumpBrowser CSV parser should preserve quoted newline fields"), Table.Rows[1][1], FString(TEXT("line one\nline two")));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEditorStateDumpBrowserDiffTest,
	"Angelscript.Editor.StateInspector.StateDumpBrowserDiffsAddedRemovedChangedRows",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEditorStateDumpBrowserDiffTest::RunTest(const FString& Parameters)
{
	const FString RootDirectory = MakeUniqueStateDumpBrowserPath(TEXT("Diff"));
	ON_SCOPE_EXIT
	{
		IFileManager::Get().DeleteDirectory(*RootDirectory, false, true);
	};

	const FString LeftDirectory = FPaths::Combine(RootDirectory, TEXT("Left"));
	const FString RightDirectory = FPaths::Combine(RootDirectory, TEXT("Right"));

	if (!SaveStateDumpBrowserCsv(
			*this,
			FPaths::Combine(LeftDirectory, TEXT("Types.csv")),
			TEXT("Key,Value,Status\r\nA,1,old\r\nB,2,same\r\nC,3,removed\r\n"))
		|| !SaveStateDumpBrowserCsv(
			*this,
			FPaths::Combine(RightDirectory, TEXT("Types.csv")),
			TEXT("Key,Value,Status\r\nA,10,changed\r\nB,2,same\r\nD,4,added\r\n"))
		|| !SaveStateDumpBrowserCsv(
			*this,
			FPaths::Combine(LeftDirectory, TEXT("LeftOnly.csv")),
			TEXT("Key,Value\r\nL,1\r\n"))
		|| !SaveStateDumpBrowserCsv(
			*this,
			FPaths::Combine(RightDirectory, TEXT("RightOnly.csv")),
			TEXT("Key,Value\r\nR,1\r\n")))
	{
		return false;
	}

	const TArray<FAngelscriptStateDumpTableDiff> Diffs =
		AngelscriptEditor::StateInspector::DiffStateDumpDirectories(LeftDirectory, RightDirectory);

	const FAngelscriptStateDumpTableDiff* TypesDiff = FindDiffByTableName(Diffs, TEXT("Types.csv"));
	const FAngelscriptStateDumpTableDiff* LeftOnlyDiff = FindDiffByTableName(Diffs, TEXT("LeftOnly.csv"));
	const FAngelscriptStateDumpTableDiff* RightOnlyDiff = FindDiffByTableName(Diffs, TEXT("RightOnly.csv"));
	if (!TestNotNull(TEXT("StateDumpBrowser diff should include changed tables"), TypesDiff)
		|| !TestNotNull(TEXT("StateDumpBrowser diff should include left-only tables"), LeftOnlyDiff)
		|| !TestNotNull(TEXT("StateDumpBrowser diff should include right-only tables"), RightOnlyDiff))
	{
		return false;
	}

	TestEqual(TEXT("StateDumpBrowser diff should count added keyed rows"), TypesDiff->AddedRows, 1);
	TestEqual(TEXT("StateDumpBrowser diff should count removed keyed rows"), TypesDiff->RemovedRows, 1);
	TestEqual(TEXT("StateDumpBrowser diff should count changed keyed rows"), TypesDiff->ChangedRows, 1);
	TestEqual(TEXT("StateDumpBrowser diff should count removed rows for left-only tables"), LeftOnlyDiff->RemovedRows, 1);
	return TestEqual(TEXT("StateDumpBrowser diff should count added rows for right-only tables"), RightOnlyDiff->AddedRows, 1);
}

#endif
