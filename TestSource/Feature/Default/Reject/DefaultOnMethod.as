/**
 * A default statement targeting a method is rejected. Defaults apply to
 * properties, not functions. This file is the illegal program itself;
 * do not replace Foo with a property.
 *
 * @Theme Feature.Default
 * @Subject Default.OnMethod
 * @Harness CompileReject
 * @Tag Feature.Default.DefaultOnMethod
 * @Kind CompileReject
 * @Covers Default.Attribute
 * @Inputs default Foo = 0 where Foo is a UFUNCTION
 * @Return does not compile; diagnostic "Default on method should fail"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: default targeting a method.
 * @Provenance C++: AngelscriptSyntaxDefaultStatementTests.cpp::AttributeDefault_Negative AssertFailsToCompile
 * @Provenance ASSyntaxDS_AttrOnMethod. Expected diagnostic: "Default on method should fail".
 * @Provenance DiagnosticOnly. Do not replace Foo with a property.
 */

class AAttrOnMethodActor : AActor
{
	/**
	 * A method that is not a valid default-statement target.
	 *
	 * @Kind CompileReject
	 * @Covers Default.Attribute
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void Foo()
	{
	}

	default Foo = 0;
}
