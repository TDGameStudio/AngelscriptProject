/**
 * A default statement at global scope is rejected. Default assignments belong
 * on a class body. This file is the illegal program itself; do not wrap it in a class.
 *
 * @Theme Feature.Default
 * @Subject Default.AtGlobalScope
 * @Harness CompileReject
 * @Tag Feature.Default.DefaultAtGlobalScope
 * @Kind CompileReject
 * @Covers Default.Attribute
 * @Inputs default SomeVar = 5 at file scope
 * @Return does not compile; diagnostic "Default statement at global scope should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: default statement at global scope.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_AttrGlobal. Expected diagnostic: "Default statement at global scope should fail".
 * @Provenance DiagnosticOnly. PlannedSymbols is empty. Do not wrap this in a class.
 */

default SomeVar = 5;
