# Local source evidence and limits

## Startup

Current plugin sources: AngelscriptRuntime/Core/AngelscriptBinds.cpp:432 records constructors; :505 PrepareForEngineInitialization loads required binding modules before finalization. Historical plugin Git object 4899ff5e37725ef32ba78329d28f62a763360b32 has FBind/RegisterBinds storing callbacks, engine initialization loading BindModules.Cache entries, then BindScriptTypes/CallBinds. CallBinds itself is not a process-wide once gate. Dormant legacy initialization is reference, not active support.

UE 5.8 local engine Source/Runtime/Launch/Private/LaunchEngineLoop.cpp:4837 broadcasts GetOnPostEngineInit, :4863 loads PostEngineInit modules, :4871 marks startup module loading complete. The inspected commandlet engine-init path also marks completion at :4072. Core/Public/Misc/CoreDelegates.h:236-244 documents the distinction; Core/Private/Misc/CoreGlobals.cpp:295-310 publishes the completion flag and broadcasts OnAllModuleLoadingPhasesComplete. Custom engine-less entry points require independent proof.

## Resources

Local UE 5.8 UEBuildModuleCPP.cs:3153 discovers RCFiles; :1190 combines ResourceFiles. UEBuildBinary.cs:849 and :874-923 compile/link Windows resource inputs. Windows/VCToolChain.cs:2878 builds resource actions and does not receive a complete compiler-generated include dependency graph. ModuleRules.ExternalDependencies alone is insufficient proof that .as file-set changes invalidate the RC/link actions. Engine source is read-only and no exact UBT integration hook is claimed proven.

Official background: https://learn.microsoft.com/en-us/windows/win32/menurc/resource-functions and https://learn.microsoft.com/en-us/windows/win32/menurc/rcdata-resource . The implementation proof must use correct owner-module handles and explicit byte lengths.

## Current project and CQTest

AngelscriptTest/AngelscriptTestModule.cpp:23 is a replacement shell with legacy startup gated off. AngelscriptTest.Build.cs:21 defines module dependencies; :80 onward gates replacement dependencies, including CQTest. AngelscriptTestJIT.Build.cs currently depends on Core, CoreUObject, AngelscriptRuntime, not AngelscriptTest; any secondary fixture dependency must be replacement-gated and must not introduce a cycle.

Local CQTest/Public/Impl/CQTest.inl:290 enumerates fixed TestNames; :332 forwards AddError. A fixed integrity TEST_METHOD is therefore independent of successful material enumeration. NewVersion/NativeEngine/VM/VMScalarTests.cpp:6 demonstrates the current CQTest convention. Framework code and fixtures planned here do not yet exist.

## Ownership

Core/Public/Templates/SharedPointer.h documents non-null TSharedRef and shared ownership. ThreadSafe protects refcounts rather than TMap mutation. Core/Public/UObject/NameTypes.h describes case-insensitive FName semantics; explicit case-sensitive Tags must not silently use those semantics.

## Proof boundary

Evidence was inspected during the design conversation and reconfirmed where needed for this creation. No resource build, source parser, test registration, runtime load or automation acceptance was executed as part of record creation.
