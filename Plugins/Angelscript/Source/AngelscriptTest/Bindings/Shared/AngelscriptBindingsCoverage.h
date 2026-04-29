#pragma once

#include "CoreMinimal.h"

/**
 * AngelscriptBindingsCoverage — shared infrastructure for the "Bindings
 * Coverage Section" pattern across `AngelscriptTest/Bindings/`.
 *
 * Goal: replace the legacy "single big `int Entry()` + `if (...) return N;`"
 * test style with parameterised, self-describing per-case assertions that
 * route through `FASGlobalFunctionInvoker`. See the main plan
 * `Documents/Plans/Plan_BindingsTestSuiteRefactor.md` and the example helpers
 * in `AngelscriptBindingsExampleSection.h` for the canonical usage.
 *
 * This header is intentionally tiny and dependency-free — it only carries the
 * shared profile/value descriptors. The mechanical bits live in the sibling
 * headers:
 *   - `AngelscriptBindingsModuleBuilder.h`  (FCoverageModuleScope RAII)
 *   - `AngelscriptBindingsAssertions.h`     (ExpectGlobalInt etc.)
 *
 * NOTE on namespacing: every helper is exposed in the `AngelscriptTestBindings`
 * namespace (a shorter-than-`AngelscriptTest::Bindings::Shared` form so that
 * the `using namespace` in test files stays manageable). The plan documents
 * the conceptual `AngelscriptTest::Bindings::Shared` namespace; the actual
 * symbol is `AngelscriptTestBindings`.
 */

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTestBindings
{
	/**
	 * Identifies one coverage execution for a single Automation ID. A test
	 * file declares one (or more, see double-Profile usage in
	 * `SubPlan_FileAndDelegate.md`) static instances and threads it through
	 * every section runner / assertion helper. The profile drives:
	 *
	 *   - the AS module name suffix (`<ModulePrefix>_<SectionName>`)
	 *   - human-readable case labels in `Test.AddInfo` / failure descriptions
	 *   - the optional log category tag for trace output
	 *
	 * Example:
	 *   const FBindingsCoverageProfile GContainerProfile{
	 *       TEXT("Container"), TEXT(""), TEXT("ASContainer"),
	 *       TEXT("Container"), TEXT("ContainerBindings"),
	 *   };
	 *
	 * The `Variant` slot is reserved for files that need to run the same
	 * coverage section under multiple semantic flavors (e.g. const-ref vs
	 * value, shorthand vs explicit syntax). Empty Variant means "no variant".
	 */
	struct FBindingsCoverageProfile
	{
		/** High-level theme name, e.g. TEXT("Container"). Used in case labels. */
		const TCHAR* Theme = TEXT("");

		/**
		 * Optional variant tag, e.g. TEXT("ConstRef"). Empty when the file
		 * only runs one variant. Used in module-name composition and labels.
		 */
		const TCHAR* Variant = TEXT("");

		/**
		 * Module-name prefix, e.g. TEXT("ASContainer"). Concatenated with
		 * Variant (when present) and the section name to form the unique AS
		 * module name. Must start with `AS` per project convention.
		 */
		const TCHAR* ModulePrefix = TEXT("");

		/**
		 * Friendly case-label prefix used in `Test.AddInfo` lines and the
		 * default assertion descriptions, e.g. TEXT("Container").
		 */
		const TCHAR* CasePrefix = TEXT("");

		/**
		 * Log category tag for trace output, e.g. TEXT("ContainerBindings").
		 * Reserved for future hookups to the Learning trace infrastructure;
		 * currently informational only.
		 */
		const TCHAR* LogCategory = TEXT("");
	};

	/**
	 * Compose the unique AS module name for a section under the given profile.
	 *
	 *   No variant : "<ModulePrefix>_<SectionName>"
	 *   With var   : "<ModulePrefix>_<Variant>_<SectionName>"
	 *
	 * Used by `FCoverageModuleScope` and any test that needs to assert
	 * against module names directly (e.g. `AddExpectedError` registrations).
	 */
	inline FString MakeCoverageModuleName(const FBindingsCoverageProfile& Profile, const TCHAR* SectionName)
	{
		const FString Variant = Profile.Variant != nullptr ? FString(Profile.Variant) : FString();
		if (Variant.IsEmpty())
		{
			return FString::Printf(TEXT("%s_%s"), Profile.ModulePrefix, SectionName);
		}
		return FString::Printf(TEXT("%s_%s_%s"), Profile.ModulePrefix, *Variant, SectionName);
	}

	/**
	 * Format a friendly case label, e.g. "[Container] Optional Empty Get fallback".
	 * Variants append in brackets: "[Container/ConstRef] ...".
	 */
	inline FString FormatCaseLabel(const FBindingsCoverageProfile& Profile, const TCHAR* CaseLabel)
	{
		const FString Variant = Profile.Variant != nullptr ? FString(Profile.Variant) : FString();
		if (Variant.IsEmpty())
		{
			return FString::Printf(TEXT("[%s] %s"), Profile.CasePrefix, CaseLabel);
		}
		return FString::Printf(TEXT("[%s/%s] %s"), Profile.CasePrefix, *Variant, CaseLabel);
	}
}

#endif // WITH_DEV_AUTOMATION_TESTS
