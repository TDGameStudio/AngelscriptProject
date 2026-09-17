/**
 * @version v1
 * @summary Every integer width UFUNCTION echo-plus-offset. EchoInt8(41) is 42, EchoInt16(29998) is 30000, EchoInt(39) is 42, EchoInt64(9999999996) is 10000000000, EchoUInt8(250) is 255, EchoUInt16(59994) is 60000.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Every integer width UFUNCTION echo-plus-offset. EchoInt8(41) is 42, EchoInt16(29998) is 30000, EchoInt(39) is 42, EchoInt64(9999999996) is 10000000000, EchoUInt8(250) is 255, EchoUInt16(59994) is 60000.
 * @topic Baseline
 */
UCLASS()
class ACoverageIntFunctionWidthsActor : AActor
{
	/**
	 * Echo an int8 plus 1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 1
	 */
	UFUNCTION()
	int8 EchoInt8(int8 Value)
	{
		return Value + 1;
	}

	/**
	 * Echo an int16 plus 2.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 2
	 */
	UFUNCTION()
	int16 EchoInt16(int16 Value)
	{
		return Value + 2;
	}

	/**
	 * Echo an int plus 3.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 3
	 */
	UFUNCTION()
	int EchoInt(int Value)
	{
		return Value + 3;
	}

	/**
	 * Echo an int64 plus 4.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 4
	 */
	UFUNCTION()
	int64 EchoInt64(int64 Value)
	{
		return Value + 4;
	}

	/**
	 * Echo a uint8 plus 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 5
	 */
	UFUNCTION()
	uint8 EchoUInt8(uint8 Value)
	{
		return Value + 5;
	}

	/**
	 * Echo a uint16 plus 6.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 6
	 */
	UFUNCTION()
	uint16 EchoUInt16(uint16 Value)
	{
		return Value + 6;
	}

	/**
	 * Echo a uint plus 7.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 7
	 */
	UFUNCTION()
	uint EchoUInt(uint Value)
	{
		return Value + 7;
	}

	/**
	 * Echo a uint64 plus 8.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return Value + 8
	 */
	UFUNCTION()
	uint64 EchoUInt64(uint64 Value)
	{
		return Value + 8;
	}

	/**
	 * Observe the live integer-width echo matrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs EchoInt8(41), EchoInt16(29998), EchoInt(39), EchoInt64(9999999996), EchoUInt8(250), EchoUInt16(59994), EchoUInt(2999999993), EchoUInt64(11999999999999999992)
	 * @Return true when every width matches its oracle
	 */
	UFUNCTION()
	bool IntegerWidthsLiveMatrix()
	{
		if (EchoInt8(41) != 42)
		{
			return false;
		}
		if (EchoInt16(29998) != 30000)
		{
			return false;
		}
		if (EchoInt(39) != 42)
		{
			return false;
		}
		if (EchoInt64(9999999996) != 10000000000)
		{
			return false;
		}
		if (EchoUInt8(250) != 255)
		{
			return false;
		}
		if (EchoUInt16(59994) != 60000)
		{
			return false;
		}
		if (EchoUInt(2999999993) != 3000000000)
		{
			return false;
		}
		return EchoUInt64(11999999999999999992) == 12000000000000000000;
	}

	/**
	 * Observe zero seeds across representative widths.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs EchoInt8(0), EchoInt(0), EchoUInt8(0), EchoUInt64(0)
	 * @Return true when the results are 1, 3, 5, and 8
	 * @Boundary zero seeds
	 */
	UFUNCTION()
	bool IntegerWidthsZeroEmpty()
	{
		if (EchoInt8(0) != 1)
		{
			return false;
		}
		if (EchoInt(0) != 3)
		{
			return false;
		}
		if (EchoUInt8(0) != 5)
		{
			return false;
		}
		return EchoUInt64(0) == 8;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageIntFunctionWidthsActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageIntFunctionWidthsActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe uint8 250 as the near-max boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs EchoUInt8(250) and EchoUInt8(0)
	 * @Return true when the results are 255 and 5
	 * @Boundary uint8 near max
	 */
	UFUNCTION()
	bool Uint8MaxBoundary()
	{
		if (EchoUInt8(250) != 255)
		{
			return false;
		}
		return EchoUInt8(0) == 5;
	}
}
/** @end */
