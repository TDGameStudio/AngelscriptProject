/**
 * FColor packing and a deterministic FRandomStream. A colour is constructed
 * from four channels, survives a hex round trip, and converts to and from a
 * linear colour. A random stream seeded once produces a repeatable sequence,
 * so resetting it replays the same values and reseeding keeps the initial seed
 * readable. Linear channels are compared with a tolerance rather than exactly.
 * These are math struct expressions rather than arithmetic operators, so they
 * belong with the math subject; they sit here until moved to a Math
 * geometric-struct directory.
 *
 * @Theme Language.Operators
 * @Subject Operators.ColorAndRandomStreamExpressions
 * @Harness Function
 * @Tag Language.Operators.ColorAndRandomStreamExpressions
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::ColorAndRandomStreamStructExpressions ExpectGlobalReturn.
 * @Provenance sha256=e3ab53fdf45b32ecc721358863d528181c804e91807c2c4418140b417df50eaa; lines 1071-1146.
 * @Provenance Oracle: TestFColorConstruction == FColor(10,20,30,40);
 * @Provenance TestFColorConstantsAndHex == FColor::Red;
 * @Provenance TestFLinearColorToFColor == FColor(255,128,0,255);
 * @Provenance InitFromString/add/constants true; Reset/seed true; vector helpers true.
 * @Provenance RandomStream int range matches native sequence in C++; here observe inclusive [10,20].
 * @Provenance Extra: default FColor is (0,0,0,0); Transparent is the empty/zero color.
 * @Provenance DefaultSafe. Use Math:: for nearly-equal linear channels.
 */

namespace OperatorsTest
{
	/**
	 * Construct a colour from four explicit channels.
	 */
	FColor ColorFromChannels()
	{
		return FColor(10, 20, 30, 40);
	}

	/**
	 * Round a colour constant through hex and back.
	 */
	FColor ColorThroughHexRoundTrip()
	{
		return FColor::FromHex(FColor::Red.ToHex());
	}

	/**
	 * Reinterpret a colour as linear, keeping the same channel ratios.
	 */
	FLinearColor ColorReinterpretedAsLinear()
	{
		return FColor(128, 64, 32, 255).ReinterpretAsLinear();
	}

	/**
	 * Convert a linear colour back to a byte colour without sRGB.
	 */
	FColor LinearColorConvertedToColor()
	{
		return FLinearColor(1.0, 0.5, 0.0, 1.0).ToFColor(false);
	}

	/**
	 * Initialise a colour from text and add another onto it.
	 */
	bool ColorInitFromStringAndAddAssign()
	{
		FColor Color;
		bool bInitialized = Color.InitFromString("(R=10,G=20,B=30,A=40)");
		Color += FColor(1, 2, 3, 4);

		bool bAdded = (Color == FColor(11, 22, 33, 44));
		bool bWhite = (FColor::White == FColor(255, 255, 255, 255));
		bool bTransparent = (FColor::Transparent == FColor(0, 0, 0, 0));
		bool Result = (bInitialized && bAdded && bWhite && bTransparent);
		return Result;
	}

	/**
	 * Draw one integer from a seeded stream.
	 */
	int RandomStreamIntRange()
	{
		FRandomStream Stream(12345);
		return Stream.RandRange(10, 20);
	}

	/**
	 * Draw a double from a seeded stream after advancing it once.
	 */
	double RandomStreamDoubleRange()
	{
		FRandomStream Stream(12345);
		Stream.RandRange(10, 20);
		return Stream.RandRange(1.0, 2.0);
	}

	/**
	 * Draw an unsigned value from a seeded stream after advancing it twice.
	 */
	uint RandomStreamUnsigned()
	{
		FRandomStream Stream(12345);
		Stream.RandRange(10, 20);
		Stream.RandRange(1.0, 2.0);
		return Stream.GetUnsignedInt();
	}

	/**
	 * Reset a seeded stream and confirm it replays the same first value.
	 */
	bool RandomStreamResetReplaysSequence()
	{
		FRandomStream Stream(12345);
		int First = Stream.RandRange(10, 20);
		Stream.RandRange(1.0, 2.0);
		Stream.Reset();
		int ResetFirst = Stream.RandRange(10, 20);

		bool bSeedKept = (Stream.GetInitialSeed() == 12345);
		bool bReplayed = (First == ResetFirst);
		bool Result = (bSeedKept && bReplayed);
		return Result;
	}

	/**
	 * Draw three vectors from a seeded stream.
	 */
	bool RandomStreamVectorsAreUnitLength()
	{
		FRandomStream Stream(12345);
		FVector Unit = Stream.GetUnitVector();
		FVector Random = Stream.VRand();
		FVector Cone = Stream.VRandCone(FVector(1, 0, 0), 0.25f);

		bool bUnit = Unit.IsUnit(0.001);
		bool bRandom = Random.IsUnit(0.001);
		bool bCone = Cone.IsUnit(0.001);
		bool bForward = (Cone.X > 0.9);
		bool Result = (bUnit && bRandom && bCone && bForward);
		return Result;
	}

	/**
	 * Observe the colour forms: construction, the hex round trip, the linear
	 * conversion, and the string initialisation all match.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs All four colour forms
	 * @Return true when every result matches its oracle value
	 */
	UFUNCTION()
	bool ColorFormsProduceExpectedValues()
	{
		if (ColorFromChannels() != FColor(10, 20, 30, 40))
		{
			return false;
		}
		if (ColorThroughHexRoundTrip() != FColor::Red)
		{
			return false;
		}
		if (LinearColorConvertedToColor() != FColor(255, 128, 0, 255))
		{
			return false;
		}
		return ColorInitFromStringAndAddAssign();
	}

	/**
	 * Observe the linear reinterpretation: each channel keeps its ratio against
	 * the byte range.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs The reinterpreted linear colour
	 * @Return true when all four channels match within tolerance
	 */
	UFUNCTION()
	bool LinearReinterpretationKeepsChannelRatios()
	{
		FLinearColor Result = ColorReinterpretedAsLinear();
		if (!Math::IsNearlyEqual(Result.R, 128.0 / 255.0, 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(Result.G, 64.0 / 255.0, 0.001))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(Result.B, 32.0 / 255.0, 0.001))
		{
			return false;
		}
		return Math::IsNearlyEqual(Result.A, 1.0, 0.001);
	}

	/**
	 * Observe the random stream: resetting replays the sequence, and the vector
	 * helpers return unit-length results.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs The reset and vector stream forms
	 * @Return true when the sequence replays and every vector is unit length
	 */
	UFUNCTION()
	bool RandomStreamIsDeterministicAndVectorsAreUnit()
	{
		if (!RandomStreamResetReplaysSequence())
		{
			return false;
		}
		return RandomStreamVectorsAreUnitLength();
	}

	/**
	 * Observe the default boundary: a default colour is the zero colour, which
	 * matches Transparent.
	 *
	 * @Kind Observe
	 * @Covers Operators.Arithmetic
	 * @Inputs A default-constructed FColor
	 * @Return true when it equals Transparent and is not White
	 * @Boundary default colour
	 */
	UFUNCTION()
	bool DefaultColorIsTransparent()
	{
		FColor DefaultColor;
		if (DefaultColor != FColor::Transparent)
		{
			return false;
		}
		return DefaultColor != FColor::White;
	}
}
