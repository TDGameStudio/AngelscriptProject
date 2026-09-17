/**
 * @version v1
 * @summary FVector4f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FVector4f
 *
 * vector
 * surface-007
 * surface-008
 * surface-009
 * surface-010
 * surface-001
 * assignment
 * multiply-assign
 * add-assign
 * to-string
 * append
 * addition
 * subtraction
 * vector-2-doubles-w
 * vector-2-halves-w
 * index
 * equality
 */
/**
 * @begin vector
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary Expected observations:
 * @covers FVector4f.vector
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Default is (0,0,0,0). Copy preserves W 4. FVector3f
// conversion fills XYZ and the supplied W. FVector4 conversion keeps all
// four components. Fields match constructors.
// Boundary/ownership: Constructors copy values. Components are float32.
// FVector4f(X,Y,Z,W), default, copy, FVector3f+W, and FVector4 constructors.
bool ObserveVectorNominal()
{
	FVector4f Explicit(1.0f, 2.0f, 3.0f, 4.0f);
	FVector4f Zero;
	FVector4f Copied(Explicit);
	FVector4f From3(FVector3f(5.0f, 6.0f, 7.0f), 8.0f);
	FVector4f FromDouble(FVector4(9, 10, 11, 12));
	return Explicit.W == 4.0f &&
		Zero.X == 0.0f &&
		Zero.W == 0.0f &&
		Copied.Y == 2.0f &&
		From3.X == 5.0f &&
		From3.Z == 7.0f &&
		From3.W == 8.0f &&
		FromDouble.X == 9.0f &&
		FromDouble.W == 12.0f;
}
/** @end */
/**
 * @begin surface-007
 * @summary FVector4f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FVector4f.
 * @covers FVector4f.surface-007
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

X of (1,2,3,4) is 1. Field read does not mutate.
bool ObserveSurface007Nominal()
{
	return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).X == 1.0f;
}
/** @end */
/**
 * @begin surface-008
 * @summary FVector4f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FVector4f.
 * @covers FVector4f.surface-008
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Y of (1,2,3,4) is 2. Field read does not mutate.
bool ObserveSurface008Nominal()
{
	return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).Y == 2.0f;
}
/** @end */
/**
 * @begin surface-009
 * @summary FVector4f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FVector4f.
 * @covers FVector4f.surface-009
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Z of (1,2,3,4) is 3. Field read does not mutate.
bool ObserveSurface009Nominal()
{
	return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).Z == 3.0f;
}
/** @end */
/**
 * @begin surface-010
 * @summary FVector4f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary FVector4f.
 * @covers FVector4f.surface-010
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

W of (1,2,3,4) is 4. Field read does not mutate.
bool ObserveSurface010Nominal()
{
	return FVector4f(1.0f, 2.0f, 3.0f, 4.0f).W == 4.0f;
}
/** @end */
/**
 * @begin surface-001
 * @summary Default
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Default
 * @covers FVector4f.surface-001
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
 FVector4f is (0,0,0,0). Value type, no fixture.
bool ObserveSurface001Nominal()
{
	FVector4f Value;
	return Value.X == 0.0f && Value.Y == 0.0f && Value.Z == 0.0f && Value.W == 0.0f;
}
/** @end */
/**
 * @begin assignment
 * @summary Assignment copies independently.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Assignment copies independently.
 * @covers FVector4f.assignment
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	FVector4f Other(1.0f, 1.0f, 1.0f, 1.0f);
	Vector = Other;
	Vector.W = 9.0f;
	return Vector.W == 9.0f && Other.W == 1.0f && Other.X == 1.0f;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Vector *= 2 doubles each component, including W to 16.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Vector *= 2 doubles each component, including W to 16.
 * @covers FVector4f.multiply-assign
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	Vector *= 2.0f;
	return Vector.X == 4.0f && Vector.W == 16.0f;
}
/** @end */
/**
 * @begin add-assign
 * @summary FString += FVector4f appends formatted digits and leaves the vector unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary FString += FVector4f appends formatted digits and leaves the vector unchanged.
 * @covers FVector4f.add-assign
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	FString Text = "v:";
	Text += Vector;
	return Text.Len() > 2 && Vector.W == 8.0f;
}
/** @end */
/**
 * @begin to-string
 * @summary Boundary/ownership: ToString returns a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary Boundary/ownership: ToString returns a new FString.
 * @covers FVector4f.to-string
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FVector4f Vector(1.0f, 2.0f, 3.0f, 4.0f);
	FString Text = Vector.ToString();
	FVector4f Zero;
	FString ZeroText = Zero.ToString();
	return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.W == 4.0f;
}
/** @end */
/**
 * @begin append
 * @summary Boundary/ownership: Append copies formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary Boundary/ownership: Append copies formatted text.
 * @covers FVector4f.append
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAppendNominal()
{
	FString Text = "v:";
	FVector4f Vector(1.0f, 2.0f, 3.0f, 4.0f);
	int Before = Text.Len();
	Text.Append(Vector);
	int AfterFirst = Text.Len();
	Text.Append(Vector);
	int AfterSecond = Text.Len();
	Text.Empty();
	return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.W == 4.0f;
}
/** @end */
/**
 * @begin addition
 * @summary Vector +
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Vector +
 * @covers FVector4f.addition
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
 Other is (3,5,7,9). FString + Vector grows past the "v:" prefix.
bool ObserveAdditionNominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	FVector4f Sum = Vector + FVector4f(1.0f, 1.0f, 1.0f, 1.0f);
	FString Combined = FString("v:") + Vector;
	return Sum.X == 3.0f && Sum.W == 9.0f && Combined.Len() > 2 && Vector.W == 8.0f;
}
/** @end */
/**
 * @begin subtraction
 * @summary Vector -
 * @topic Unreal
 */
/**
 * @function ObserveSubtractionNominal
 * @summary Vector -
 * @covers FVector4f.subtraction
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
 Other is (1,3,5,7) and does not mutate Vector.
bool ObserveSubtractionNominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	FVector4f Difference = Vector - FVector4f(1.0f, 1.0f, 1.0f, 1.0f);
	return Difference.X == 1.0f && Difference.W == 7.0f && Vector.W == 8.0f;
}
/** @end */
/**
 * @begin vector-2-doubles-w
 * @summary Vector * 2 doubles W to 16 and does not mutate Vector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface014Nominal
 * @summary Vector * 2 doubles W to 16 and does not mutate Vector.
 * @covers FVector4f.vector-2-doubles-w
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface014Nominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	FVector4f Scaled = Vector * 2.0f;
	return Scaled.X == 4.0f && Scaled.W == 16.0f && Vector.W == 8.0f;
}
/** @end */
/**
 * @begin vector-2-halves-w
 * @summary Vector / 2 halves W to 4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface015Nominal
 * @summary Vector / 2 halves W to 4.
 * @covers FVector4f.vector-2-halves-w
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface015Nominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	FVector4f Quotient = Vector / 2.0f;
	return Quotient.X == 1.0f && Quotient.W == 4.0f;
}
/** @end */
/**
 * @begin index
 * @summary Subscript [0] is X, [3] is W, and writing [1] mutates Y.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Subscript [0] is X, [3] is W, and writing [1] mutates Y.
 * @covers FVector4f.index
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
	float32 X = Vector[0];
	float32 W = Vector[3];
	Vector[1] = 9.0f;
	return X == 2.0f && W == 8.0f && Vector.Y == 9.0f;
}
/** @end */
/**
 * @begin equality
 * @summary Copies compare true.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Copies compare true.
 * @covers FVector4f.equality
 * @inputs FVector4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FVector4f Left(2.0f, 4.0f, 6.0f, 8.0f);
	FVector4f Right(2.0f, 4.0f, 6.0f, 8.0f);
	FVector4f Different(2.0f, 4.0f, 6.0f, 9.0f);
	return (Left == Right) && !(Left == Different);
}
/** @end */
