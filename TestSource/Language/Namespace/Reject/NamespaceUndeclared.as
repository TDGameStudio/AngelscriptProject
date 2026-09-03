/**
 * Reading through a namespace that was never declared is rejected. The
 * qualified name has a namespace part that resolves to nothing.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.Undeclared
 * @Harness CompileReject
 * @Tag Language.Namespace.NamespaceUndeclared
 * @Kind CompileReject
 * @Covers Namespace.QualifiedAccess
 * @Inputs Read FakeNamespace::Value where FakeNamespace was never declared
 * @Return does not compile; diagnostic "FakeNamespace does not exist"
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 6.
 * @Provenance sha256=f29a4b140b5febb4187ded16a177256e0a2a1c9850b4db2c473e408a1e3a0e98; lines 532-534.
 * @Provenance Expected diagnostic: FakeNamespace does not exist.
 * @Provenance CSV SourceShape is Positive / DefaultSafe; C++ uses AssertFailsToCompile.
 */

void Test()
{
	int X = FakeNamespace::Value;
}
