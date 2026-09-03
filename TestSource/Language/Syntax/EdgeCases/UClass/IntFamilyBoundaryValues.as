/**
 * The int family's numeric min and max values surviving reflection: every signed
 * width's minimum, then every width's maximum, on eight UPROPERTYs.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.IntFamilyBoundaryValues
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.IntFamilyBoundaryValues
 * @Provenance C++: AngelscriptCoverageIntPropertyTests.cpp::IntFamilyBoundaryValues SetByPath/VerifyByPath
 * @Provenance sha256=96d736167c58657e45b3485264e48e92b66299bb3cd45dbaee861fef46571084; lines 341-369.
 * @Provenance Oracle: signed mins then signed maxes then unsigned maxes survive reflection.
 * @Provenance Extra: local construct is the empty 0 vector; script WriteMin/WriteMax match C++ limits.
 * @Provenance FixtureIsolated. Actor owns the reflected integers.
 */

UCLASS()
class ACoverageIntBoundaryActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 0;

	UPROPERTY()
	int16 Int16Value = 0;

	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	int64 Int64Value = 0;

	UPROPERTY()
	uint8 UInt8Value = 0;

	UPROPERTY()
	uint16 UInt16Value = 0;

	UPROPERTY()
	uint UInt32Value = 0;

	UPROPERTY()
	uint64 UInt64Value = 0;

	/**
	 * Writes each signed width's minimum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four signed UPROPERTYs hold their minima
	 */
	UFUNCTION()
	void WriteSignedMins()
	{
		Int8Value = -128;
		Int16Value = -32768;
		IntValue = -2147483647 - 1;
		Int64Value = int64(-9223372036854775807) - 1;
	}

	/**
	 * Writes each signed width's maximum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four signed UPROPERTYs hold their maxima
	 */
	UFUNCTION()
	void WriteSignedMaxes()
	{
		Int8Value = 127;
		Int16Value = 32767;
		IntValue = 2147483647;
		Int64Value = 9223372036854775807;
	}

	/**
	 * Writes each unsigned width's maximum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four unsigned UPROPERTYs hold their maxima
	 */
	UFUNCTION()
	void WriteUnsignedMaxes()
	{
		UInt8Value = 255;
		UInt16Value = 65535;
		UInt32Value = 4294967295;
		UInt64Value = 18446744073709551615;
	}

	/**
	 * Observe that a locally constructed actor holds the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the first and last properties are 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntFamilyBoundaryDefaultEmpty()
	{
		if (Int8Value != 0)
		{
			return false;
		}

		return UInt64Value == 0;
	}

	/**
	 * Observe that the signed minima survive a write and read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteSignedMins() then the signed properties
	 * @Return true when all three lower widths hold their minima
	 * @Boundary signed minima
	 */
	UFUNCTION()
	bool IntFamilyBoundarySignedMins()
	{
		WriteSignedMins();

		if (Int8Value != -128)
		{
			return false;
		}

		if (Int16Value != -32768)
		{
			return false;
		}

		return IntValue == -2147483647 - 1;
	}

	/**
	 * Observe that the unsigned maxima survive a write and read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteUnsignedMaxes() then the unsigned properties
	 * @Return true when all three lower widths hold their maxima
	 * @Boundary unsigned maxima
	 */
	UFUNCTION()
	bool IntFamilyBoundaryUnsignedMaxes()
	{
		WriteUnsignedMaxes();

		if (UInt8Value != 255)
		{
			return false;
		}

		if (UInt16Value != 65535)
		{
			return false;
		}

		return UInt32Value == 4294967295;
	}
}
