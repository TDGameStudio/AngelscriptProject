/**
 * The FRotator arithmetic operators: add, subtract, scalar multiply, and the matching
 * compound assignments. C++ executes each entrypoint and checks the value it produces, so
 * those names are part of the contract and are kept verbatim.
 *
 * @Theme Gameplay.FRotator
 * @Subject FRotator.ArithmeticOperators
 * @Harness Function
 * @Tag Gameplay.FRotator.RotatorArithmeticOperators
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive arithmetic operator oracles.
 * @Provenance C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorArithmeticOperators
 * @Provenance Oracle: add (15,30,45); sub (90,180,270); *2 (20,40,60);
 * @Provenance += (15,25,35); -= (90,80,70); *= (30,60,90).
 * @Provenance Extra: default Zero add; copy independence of OpAdd inputs. DefaultSafe.
 */

namespace FRotatorTest
{
	/**
	 * Add two rotators.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return FRotator(15, 30, 45)
	 */
	UFUNCTION()
	FRotator OpAdd()
	{
		FRotator a = FRotator(10, 20, 30);
		FRotator b = FRotator(5, 10, 15);
		return a + b;
	}

	/**
	 * Subtract two rotators.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return FRotator(90, 180, 270)
	 */
	UFUNCTION()
	FRotator OpSubtract()
	{
		FRotator a = FRotator(100, 200, 300);
		FRotator b = FRotator(10, 20, 30);
		return a - b;
	}

	/**
	 * Multiply a rotator by a scalar.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return FRotator(20, 40, 60)
	 */
	UFUNCTION()
	FRotator OpMultiplyScalar()
	{
		FRotator r = FRotator(10, 20, 30);
		return r * 2.0;
	}

	/**
	 * Compound-add a rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return FRotator(15, 25, 35)
	 */
	UFUNCTION()
	FRotator OpCompoundAdd()
	{
		FRotator r = FRotator(10, 20, 30);
		r += FRotator(5, 5, 5);
		return r;
	}

	/**
	 * Compound-subtract a rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return FRotator(90, 80, 70)
	 */
	UFUNCTION()
	FRotator OpCompoundSubtract()
	{
		FRotator r = FRotator(100, 100, 100);
		r -= FRotator(10, 20, 30);
		return r;
	}

	/**
	 * Compound-multiply a rotator by a scalar.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return FRotator(30, 60, 90)
	 */
	UFUNCTION()
	FRotator OpCompoundMultiply()
	{
		FRotator r = FRotator(10, 20, 30);
		r *= 3.0;
		return r;
	}

	/**
	 * Observe that add yields (15, 30, 45).
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return true when OpAdd equals (15, 30, 45)
	 */
	UFUNCTION()
	bool OpAddNominal()
	{
		return OpAdd() == FRotator(15, 30, 45);
	}

	/**
	 * Observe that subtract yields (90, 180, 270).
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return true when OpSubtract equals (90, 180, 270)
	 */
	UFUNCTION()
	bool OpSubtractNominal()
	{
		return OpSubtract() == FRotator(90, 180, 270);
	}

	/**
	 * Observe that scalar multiply yields (20, 40, 60).
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return true when OpMultiplyScalar equals (20, 40, 60)
	 */
	UFUNCTION()
	bool OpMultiplyScalarNominal()
	{
		return OpMultiplyScalar() == FRotator(20, 40, 60);
	}

	/**
	 * Observe that compound add yields (15, 25, 35).
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return true when OpCompoundAdd equals (15, 25, 35)
	 */
	UFUNCTION()
	bool OpCompoundAddNominal()
	{
		return OpCompoundAdd() == FRotator(15, 25, 35);
	}

	/**
	 * Observe that compound subtract yields (90, 80, 70).
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return true when OpCompoundSubtract equals (90, 80, 70)
	 */
	UFUNCTION()
	bool OpCompoundSubtractNominal()
	{
		return OpCompoundSubtract() == FRotator(90, 80, 70);
	}

	/**
	 * Observe that compound multiply yields (30, 60, 90).
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs none
	 * @Return true when OpCompoundMultiply equals (30, 60, 90)
	 */
	UFUNCTION()
	bool OpCompoundMultiplyNominal()
	{
		return OpCompoundMultiply() == FRotator(30, 60, 90);
	}

	/**
	 * Observe that adding two empty rotators stays at zero.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs a default rotator plus ZeroRotator
	 * @Return true when the sum is ZeroRotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool OpAddDefaultEmpty()
	{
		FRotator Empty = FRotator();
		return (Empty + FRotator::ZeroRotator) == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating the sum leaves the addends untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ArithmeticOperators
	 * @Inputs two rotators and a mutated sum
	 * @Return true when A is still (10, 20, 30) and B is still (5, 10, 15)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool OpAddCopyIndependence()
	{
		FRotator A = FRotator(10, 20, 30);
		FRotator B = FRotator(5, 10, 15);
		FRotator Sum = A + B;
		Sum.Pitch = 0.0;

		if (!(A == FRotator(10, 20, 30)))
		{
			return false;
		}
		return B == FRotator(5, 10, 15);
	}
}
