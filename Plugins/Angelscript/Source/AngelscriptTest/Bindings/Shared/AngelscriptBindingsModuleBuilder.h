#pragma once

#include "CoreMinimal.h"
#include "AngelscriptEngine.h"
#include "Misc/AutomationTest.h"

#include "AngelscriptBindingsCoverage.h"
#include "../../Shared/AngelscriptTestUtilities.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_scriptengine.h"
#include "source/as_module.h"
#include "EndAngelscriptHeaders.h"

/**
 * FCoverageModuleScope — RAII wrapper around `AngelscriptTestSupport::BuildModule`
 * that automatically discards the module when the scope ends.
 *
 * Why this exists:
 *  - Legacy bindings tests scattered `Engine.DiscardModule(TEXT("ASXxx"))`
 *    across `ON_SCOPE_EXIT` blocks, with the module name duplicated as a
 *    string literal. This is fragile under refactor (rename the module,
 *    forget to rename the discard) and forces every test to know the
 *    convention.
 *  - The Coverage refactor (see `Plan_BindingsTestSuiteRefactor.md`) wants
 *    sections to be drop-in: declare scope, get the module, use it, return.
 *    The cleanup happens automatically.
 *
 * The module name is composed from the profile + section name; tests no
 * longer hard-code `"ASContainer"`-style strings.
 */

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTestBindings
{
	/**
	 * Build an AS module under the given coverage profile + section name and
	 * keep it alive for the lifetime of the scope. On destruction the module
	 * is discarded from the engine (idempotent — safe even if `BuildModule`
	 * itself failed).
	 *
	 * Typical usage in a Section function:
	 *
	 *   FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Optional"), TEXT(R"(
	 *       int EchoEmpty()         { TOptional<int> O; return O.IsSet() ? 1 : 0; }
	 *       int EchoEmptyFallback() { TOptional<int> O; return O.Get(7); }
	 *   )"));
	 *   if (!ModuleScope.IsValid()) { return false; }
	 *   asIScriptModule& Module = ModuleScope.GetModule();
	 *   ExpectGlobalInt(Test, Engine, Module, Profile,
	 *       TEXT("int EchoEmpty()"), TEXT("Empty Optional should not be set"), 0);
	 */
	struct FCoverageModuleScope
	{
		FCoverageModuleScope(
			FAutomationTestBase& InTest,
			FAngelscriptEngine& InEngine,
			const FBindingsCoverageProfile& Profile,
			const TCHAR* SectionName,
			const FString& Source)
			: Engine(InEngine)
			, ModuleName(MakeCoverageModuleName(Profile, SectionName))
		{
			const FString ModuleNameAnsi = ModuleName;
			const FTCHARToUTF8 ModuleNameUtf8(*ModuleNameAnsi);
			Module = AngelscriptTestSupport::BuildModule(InTest, InEngine, ModuleNameUtf8.Get(), Source);
		}

		~FCoverageModuleScope()
		{
			// BuildModule registers the module under `ModuleName` (the AS
			// preprocessor uses the requested filename stem as the module
			// name). Discarding by that same name is idempotent: even if
			// compile failed and Module is null, DiscardModule on a missing
			// name is a no-op in the engine.
			Engine.DiscardModule(*ModuleName);
		}

		FCoverageModuleScope(const FCoverageModuleScope&) = delete;
		FCoverageModuleScope& operator=(const FCoverageModuleScope&) = delete;

		bool IsValid() const { return Module != nullptr; }

		/** Resolved AS module. Caller must check IsValid() first. */
		asIScriptModule& GetModule() const
		{
			check(Module != nullptr);
			return *Module;
		}

		/** Composed module name (also queryable for AddExpectedError registrations). */
		const FString& GetModuleName() const { return ModuleName; }

	private:
		FAngelscriptEngine& Engine;
		FString ModuleName;
		asIScriptModule* Module = nullptr;
	};
}

#endif // WITH_DEV_AUTOMATION_TESTS
