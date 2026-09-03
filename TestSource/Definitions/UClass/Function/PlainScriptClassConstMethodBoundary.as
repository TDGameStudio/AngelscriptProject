/**
 * A plain script class with const methods compiles. ConstMethodPlainClassBoundary
 * is the runtime entry C++ invokes, and a null-pointer access is the expected
 * exception when the const path is exercised against an unset object. Defaults
 * and copy independence are observed without calling the const methods.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.PlainScriptClassConstMethodBoundary
 * @Harness Function
 * @Tag Definitions.UClass.PlainScriptClassConstMethodBoundary
 * @Namespace UClassTest
 * @Provenance Theme: Definitions.UClass. Positive compile of a plain script class with const methods.
 * @Provenance C++: AngelscriptCoverageConstTests.cpp::PlainScriptClassConstMethodBoundary
 * @Provenance compiles then ExecuteAndExpectException ("Null pointer access") on ConstMethodPlainClassBoundary.
 * @Provenance CSV NegativeDiagnostic is wrong: this is a runtime const-member boundary, not a compile fail.
 * @Provenance Extra: default Value=0; assigned 30; copy independence without calling const methods. DefaultSafe.
 */

class ConstCounter
{
	int Value = 0;

	/**
	 * Observe the const getter: it returns the current Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstMethod
	 * @Inputs this.Value
	 * @Return the Value field
	 */
	int GetValue() const
	{
		return Value;
	}

	/**
	 * Observe a const method that adds a readonly amount without writing Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstMethod
	 * @Param Amount Read-only addend
	 * @Inputs Value + Amount
	 * @Return Value plus Amount
	 */
	int AddReadonly(const int&in Amount) const
	{
		return Value + Amount;
	}

	/**
	 * Observe the initialized default of Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstMethod
	 * @Inputs a freshly constructed ConstCounter
	 * @Return the Value field
	 */
	int DefaultValue()
	{
		return Value;
	}

	/**
	 * Observe a write of Value to 30.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstMethod
	 * @Inputs Value set to 30
	 * @Return the Value field
	 * @Boundary assigned 30
	 */
	int AssignedBoundary()
	{
		Value = 30;
		return Value;
	}

	/**
	 * Observe that writing this counter leaves another at its default.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstMethod
	 * @Inputs this.Value set to 30, compared against a second counter
	 * @Return true when this holds 30 and the other holds 0
	 * @Boundary copy independence
	 */
	bool CopyIndependence()
	{
		ConstCounter Other;
		Value = 30;
		if (Value != 30)
		{
			return false;
		}
		return Other.Value == 0;
	}
}

namespace UClassTest
{
	/**
	 * Observe the const-method path C++ invokes: Value 30 plus a const bonus of 4.
	 *
	 * @Kind Observe
	 * @Covers UClass.ConstMethod
	 * @Inputs ConstCounter.Value = 30; AddReadonly(4)
	 * @Return 34
	 */
	UFUNCTION()
	int ConstMethodPlainClassBoundary()
	{
		ConstCounter Counter;
		Counter.Value = 30;
		const int Bonus = 4;
		return Counter.GetValue() + Counter.AddReadonly(Bonus);
	}
}
