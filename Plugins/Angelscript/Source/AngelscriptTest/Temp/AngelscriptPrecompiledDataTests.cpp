#include "AngelscriptEngine.h"
#include "Misc/AutomationTest.h"
#include "StaticJIT/PrecompiledData.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_module.h"
#include "source/as_objecttype.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPrecompiledEditorOnlyFlagRoundtripTest,
	"Angelscript.TestModule.CppTests.StaticJIT.PrecompiledData.EditorOnlyFlagRoundtrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptModuleDiffHighBitFlagTest,
	"Angelscript.TestModule.CppTests.StaticJIT.ModuleDiff.HighBitFlags",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPrecompiledEditorOnlyFlagRoundtripTest::RunTest(const FString& Parameters)
{
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> OwnedEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	if (!TestNotNull(TEXT("A test script engine wrapper should be created for the precompiled flag roundtrip"), OwnedEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = *OwnedEngine;
	asCScriptEngine* ScriptEngine = static_cast<asCScriptEngine*>(Engine.GetScriptEngine());
	if (!TestNotNull(TEXT("A test script engine should exist for the precompiled flag roundtrip"), ScriptEngine))
	{
		return false;
	}

	asCModule SourceModule("PrecompiledFlagSource", ScriptEngine);
	asCObjectType SourceType(ScriptEngine);
	SourceType.name = "UPrecompiledFlagSourceType";
	SourceType.nameSpace = ScriptEngine->defaultNamespace;
	SourceType.module = &SourceModule;
	SourceType.flags = asOBJ_REF | asOBJ_EDITOR_ONLY;
	const asQWORD ExpectedFlags = SourceType.flags;

	FAngelscriptPrecompiledData Context(ScriptEngine);
	FAngelscriptPrecompiledClass PrecompiledClass;
	PrecompiledClass.InitFrom(Context, &SourceModule, &SourceType);
	if (!TestEqual(TEXT("Precompiled class storage should preserve high-bit editor-only flags"), PrecompiledClass.Flags, ExpectedFlags))
	{
		return false;
	}

	asCModule RecreatedModule("PrecompiledFlagRecreated", ScriptEngine);
	asCObjectType* RecreatedType = PrecompiledClass.Create(Context, &RecreatedModule);
	if (!TestNotNull(TEXT("Precompiled class recreation should produce an object type"), RecreatedType))
	{
		return false;
	}

	TestEqual(TEXT("Precompiled class recreation should preserve high-bit editor-only flags"), RecreatedType->flags, ExpectedFlags);
	return true;
}

bool FAngelscriptModuleDiffHighBitFlagTest::RunTest(const FString& Parameters)
{
	const FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> OwnedEngine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies, EAngelscriptEngineCreationMode::Clone);
	if (!TestNotNull(TEXT("A test script engine wrapper should be created for the module-diff regression"), OwnedEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = *OwnedEngine;
	asCScriptEngine* ScriptEngine = static_cast<asCScriptEngine*>(Engine.GetScriptEngine());
	if (!TestNotNull(TEXT("A script engine should exist for the module-diff regression"), ScriptEngine))
	{
		return false;
	}

	auto MakeModuleClass = [ScriptEngine](const char* ModuleName, const char* TypeName, asQWORD Flags)
	{
		asCModule* Module = asNEW(asCModule)(ModuleName, ScriptEngine);
		asCObjectType* Type = asNEW(asCObjectType)(ScriptEngine);
		Type->name = TypeName;
		Type->nameSpace = ScriptEngine->defaultNamespace;
		Type->module = Module;
		Type->flags = Flags;
		Module->classTypes.PushLast(Type);
		Module->allLocalTypes.Add(Type);
		return TPair<asCModule*, asCObjectType*>(Module, Type);
	};

	auto [OldModule, OldType] = MakeModuleClass("DiffOld", "UDiffType", asOBJ_REF | asOBJ_EDITOR_ONLY);
	auto [SameModule, SameType] = MakeModuleClass("DiffSame", "UDiffType", asOBJ_REF | asOBJ_EDITOR_ONLY);
	auto [ChangedModule, ChangedType] = MakeModuleClass("DiffChanged", "UDiffType", asOBJ_REF);

	ON_SCOPE_EXIT
	{
		asDELETE(OldModule, asCModule);
		asDELETE(SameModule, asCModule);
		asDELETE(ChangedModule, asCModule);
	};

	asModuleReferenceUpdateMap UpdateMap;
	UpdateMap.Types.Add(OldType, SameType);
	bool bHadStructuralChanges = false;
	SameModule->DiffForReferenceUpdate(OldModule, UpdateMap, bHadStructuralChanges);
	if (!TestFalse(TEXT("Module diff should not report a structural change when high-bit flags are identical"), bHadStructuralChanges))
	{
		return false;
	}

	asModuleReferenceUpdateMap ChangedUpdateMap;
	ChangedUpdateMap.Types.Add(OldType, ChangedType);
	bHadStructuralChanges = false;
	ChangedModule->DiffForReferenceUpdate(OldModule, ChangedUpdateMap, bHadStructuralChanges);
	TestTrue(TEXT("Module diff should report a structural change when a high-bit private flag differs"), bHadStructuralChanges);
	return true;
}

#endif
