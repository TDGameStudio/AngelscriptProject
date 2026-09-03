/**
 * DefaultComponent at global scope is rejected. The specifier belongs on a class
 * property, not a file-scope declaration; this file is the illegal program.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_OutsideClass
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_OutsideClass
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_OutsideClass
 * @Inputs UPROPERTY(DefaultComponent) USceneComponent Root at file scope
 * @Return does not compile; DefaultComponent at global scope should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_OutsideClass
 * @Provenance AssertFailsToCompile module DefCompGlobal.
 * @Provenance Expected diagnostic: DefaultComponent at global scope should fail.
 * @Provenance DiagnosticOnly. Isolation=none. PlannedSymbols empty. Do not wrap Root in a class.
 */

UPROPERTY(DefaultComponent) USceneComponent Root;
