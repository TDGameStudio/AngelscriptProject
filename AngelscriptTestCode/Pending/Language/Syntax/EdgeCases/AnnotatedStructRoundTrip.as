/**
 * @version v1
 * @summary A USTRUCT carrying an annotated property. The struct is default-constructed, read, and copied, with the copy proven independent of the original.
 * @topic Language
 */
/**
 * @version root
 * @summary A USTRUCT carrying an annotated property. The struct is default-constructed, read, and copied, with the copy proven independent of the original.
 * @topic Baseline
 */
USTRUCT()
struct FAnnotatedCarrier
{
	UPROPERTY()
	int Value = 7;
}

namespace SyntaxTest
{
	/**
	 * Reads the default value out of the annotated struct.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed FAnnotatedCarrier
	 * @Return 7
	 */
	int Entry()
	{
		FAnnotatedCarrier Carrier;
		return Carrier.Value;
	}

	/**
	 * Observe that the struct round-trips its default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool AnnotatedStructRoundTripsDefault()
	{
		return Entry() == 7;
	}

	/**
	 * Observe the default state of a fresh struct.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed FAnnotatedCarrier
	 * @Return true when Value is 7
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AnnotatedStructDefaultsToSeven()
	{
		FAnnotatedCarrier Carrier;
		return Carrier.Value == 7;
	}

	/**
	 * Observe that copying the struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 7 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AnnotatedStructCopyIsIndependent()
	{
		FAnnotatedCarrier Original;
		FAnnotatedCarrier Copied = Original;
		Copied.Value = 0;

		if (Original.Value != 7)
		{
			return false;
		}

		return Copied.Value == 0;
	}
}
/** @end */
