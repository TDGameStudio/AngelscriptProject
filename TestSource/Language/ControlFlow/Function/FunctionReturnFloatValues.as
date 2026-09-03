/**
 * Float and double returns are compared with a tolerance rather than equality,
 * since a decimal value rarely survives a round trip bit-for-bit. An
 * uninitialised float or double holds zero, and the two returners stay
 * distinct from each other.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.FunctionReturnFloatValues
 * @Harness Function
 * @Tag Language.ControlFlow.FunctionReturnFloatValues
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionReturnValues
 * @Provenance sha256=5e6099558618051d82c84a64cee01daab63c31ffc8f951191186248278ee0283; lines 301-311.
 * @Provenance Oracle: ReturnFloat 42.25; ReturnDouble 84.5 (tolerance 0.001).
 * @Provenance Extra: default float/double are 0; values stay distinct.
 */

namespace ControlFlowTest
{
	/**
	 * A function returning a float value.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs A function body returning 42.25f
	 * @Return 42.25
	 */
	float FloatReturn()
	{
		return 42.25f;
	}

	/**
	 * A function returning a double value.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs A function body returning 84.5
	 * @Return 84.5
	 */
	double DoubleReturn()
	{
		return 84.5;
	}

	/**
	 * Observe that both returners deliver their values within tolerance.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Call both returners and compare against their expected values
	 * @Return true when both match within a tolerance of 0.001
	 */
	UFUNCTION()
	bool FloatReturnersDeliverTheirValues()
	{
		if (!Math::IsNearlyEqual(FloatReturn(), 42.25, 0.001))
		{
			return false;
		}
		return Math::IsNearlyEqual(DoubleReturn(), 84.5, 0.001);
	}

	/**
	 * Observe the zero default: uninitialised floats and doubles hold zero, and
	 * the returned float is not zero.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare uninitialised values against zero, and the return against zero
	 * @Return true when the defaults are zero and the return is not
	 * @Boundary default float and double
	 */
	UFUNCTION()
	bool FloatReturnersDifferFromZeroDefault()
	{
		float EmptyFloat;
		double EmptyDouble;
		if (!Math::IsNearlyEqual(EmptyFloat, 0.0, 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(EmptyDouble, 0.0, 0.001))
		{
			return false;
		}
		return !Math::IsNearlyEqual(FloatReturn(), 0.0, 0.001);
	}

	/**
	 * Observe that the two returners stay distinct.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare the float return against the double return
	 * @Return true when the two values differ beyond the tolerance
	 */
	UFUNCTION()
	bool FloatReturnersStayDistinct()
	{
		return !Math::IsNearlyEqual(FloatReturn(), DoubleReturn(), 0.001);
	}
}
