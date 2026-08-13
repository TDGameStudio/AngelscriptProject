# Test-first patch: `external_implicit_this` semantic receiver

## Status

This is an application-ready patch recipe, not an already-applied production
change. The executable OpenSpec fixture and Standalone probe establish current
behavior now. Apply the C++ test below immediately before implementing the HIR
function header/receiver adapter so the production change starts from a red or
characterization test with exact ownership.

Target file:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Language/AngelscriptNativeFunctionsTests.cpp`

Why this file:

- it already owns function syntax, mixin dispatch, standalone SDK execution,
  metadata, cleanup, and isolation evidence;
- `external_implicit_this` is language/compiler behavior, not UE asset
  lifecycle behavior;
- keeping the base language test here lets the existing literal-asset test
  remain the separate UE integration proof.

## Patch cell

First add the private function-trait header alongside the current includes:

```cpp
#include "StartAngelscriptHeaders.h"
#include "source/as_scriptfunction.h"
#include "EndAngelscriptHeaders.h"
```

Then add this method beside `FunctionsMixinNamespace`:

```cpp
TEST_METHOD(FunctionsExternalImplicitThisUsesDeclaredParameterZero)
{
	using namespace AngelscriptNativeTestSupport;

	AS_NATIVE_PRODUCT("LANG-FN-EXTERNAL-IMPLICIT-THIS",
		ENativeEvidence::Compile
			| ENativeEvidence::Runtime
			| ENativeEvidence::Metadata
			| ENativeEvidence::Cleanup
			| ENativeEvidence::Isolation);

	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT
	{
		Engine.Destroy();
	};
	asIScriptEngine* const ScriptEngine = Engine.Get();
	ASSERT_THAT(IsNotNull(
		ScriptEngine,
		TEXT("external implicit this test should create a standalone engine")));
	if (ScriptEngine == nullptr)
	{
		return;
	}

	FScopedNativeModule Module(
		*TestRunner,
		Engine,
		"SDKFunctionsExternalImplicitThis",
		ASTEST_AS_ANSI(R"AS(
			class Receiver
			{
				int Value = 1;

				int Read() const
				{
					return Value;
				}
			}

			int Evaluate(Receiver Target, int Delta) external_implicit_this
			{
				Value += Delta;
				if (Target.Value != Value)
					return -100;
				return Target.Value + Read();
			}

			int Entry()
			{
				Receiver Target = Receiver();
				const int Result = Evaluate(Target, 3);
				if (Target.Value != 4)
					return -200;
				return Result;
			}
			)AS"));
	ASSERT_THAT(IsTrue(
		Module.IsValid(),
		TEXT("external implicit this source should compile")));
	if (!Module.IsValid())
	{
		return;
	}

	asIScriptFunction* const PublicFunction =
		Module.Get()->GetFunctionByName("Evaluate");
	ASSERT_THAT(IsNotNull(
		PublicFunction,
		TEXT("external implicit this function should be published")));
	if (PublicFunction != nullptr)
	{
		ASSERT_THAT(AreEqual(
			2,
			static_cast<int32>(PublicFunction->GetParamCount()),
			TEXT("receiver parameter zero and Delta must remain in the public ABI")));
		ASSERT_THAT(IsNull(
			PublicFunction->GetObjectType(),
			TEXT("external implicit this function must remain a global function")));

		const asCScriptFunction* const InternalFunction =
			static_cast<const asCScriptFunction*>(PublicFunction);
		ASSERT_THAT(IsTrue(
			InternalFunction->traits.GetTrait(asTRAIT_EXTERNAL_IMPLICIT_THIS),
			TEXT("function metadata must retain the external implicit this trait")));
	}

	{
		AngelscriptSDKTestSupport::FSdkFunctionInvoker Invoker(
			*TestRunner,
			ScriptEngine,
			Module,
			"int Entry()");
		ASSERT_THAT(IsTrue(
			Invoker.IsValid(),
			TEXT("external implicit this entry should resolve")));
		if (Invoker.IsValid())
		{
			ASSERT_THAT(AreEqual(
				8,
				Invoker.CallAndReturn<int32>(INDEX_NONE),
				TEXT("named parameter, property lookup, method lookup, and mutation must share receiver zero")));
		}
	}

	ASSERT_THAT(AreEqual(
		asSUCCESS,
		Module.Discard(),
		TEXT("external implicit this module should be explicitly discarded")));
}
```

## Production patch that follows the test

The smallest safe production slice is deliberately narrow:

1. Add `FAsSemanticFunctionHeader` and `FAsSemanticReceiver` to the semantic
   function snapshot. Preserve the complete raw trait bitset.
2. During the post-typecheck adapter pass, map a global function carrying
   `asTRAIT_EXTERNAL_IMPLICIT_THIS` to:
   `InvocationKind=Global`,
   `ReceiverKind=ExplicitParameterAlias`,
   `ReceiverParameterIndex=0`.
3. Resolve the receiver symbol from declared parameter `0`; verify it exists,
   is object-capable, and agrees with the type used by `ExternalThisType`.
4. Lower unqualified property/method accesses with an explicit receiver
   expression that references that symbol. Never synthesize a native member
   `this`, and never remove parameter `0` from the entry plan.
5. Keep the first scalar backend conservative: a valid normalized external
   receiver with an object property/method produces
   `Fallback/UnsupportedReceiver`; malformed metadata produces
   `Fail/InvalidEffectiveReceiver` before eligibility.
6. Once object receiver/lifetime support lands, change only the eligibility
   result and emitter; the call ABI and HIR receiver representation stay the
   same.

## Exact verification commands

Fast research checks before compiling UE:

```powershell
& openspec/changes/feature-as-typed-semantic-aot/research/fixtures/semantic-aot-v1/Test-ValidateFixtures.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-FunctionTraitSourceEvidence.ps1
& openspec/changes/feature-as-typed-semantic-aot/research/probes/Test-ExternalImplicitThisRuntime.ps1
```

Focused UE Automation after applying the C++ test:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RunTests.ps1 -TestFilter "Angelscript.TestModule.AngelScriptSDK.Language.Functions" -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RunTests.ps1 -TestFilter "Angelscript.TestModule.Generator.Core.LiteralAsset" -TimeoutMs 600000
```

Then run the feature-specific semantic HIR/AOT prefix introduced by the
implementation. Do not use the literal-asset pass alone as proof that the
StaticJIT ABI preserved declared parameter `0`.
