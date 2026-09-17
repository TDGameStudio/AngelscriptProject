/**
 * @version v1
 * @summary Auto infers a local type from a call, member, subscript, ternary, or cast.
 * @topic Language
 * @topic Auto
 *
 * infer-from-constructor        // auto Object = AHost() infers AHost and writes Score.
 * default-score                 // A default-constructed auto host keeps Score at 0.
 * infer-from-function-return    // auto Value = Make() infers the callee return type.
 * infer-from-method-return      // auto Value = Object.Read() infers the method return type.
 * infer-from-member-read        // auto Value = Object.Score infers the field type.
 * infer-from-subscript          // auto Value = Values[0] infers the opIndex result type.
 * infer-from-ternary            // auto Value = Flag ? 1 : 2 infers the common arm type.
 * infer-from-cast               // auto Derived = Cast<ADerived>(Object) infers the cast target.
 */
/**
 * @begin infer-from-constructor
 * @summary auto Object = AHost() infers AHost and writes Score.
 * @topic Auto
 */
class AHost
{
	int Score;

	AHost()
	{
		Score = 0;
	}
}

int Constructed()
{
	auto Object = AHost();
	Object.Score = 4;
	return Object.Score;
}
/** @end */
/**
 * @begin default-score
 * @summary A default-constructed auto host keeps Score at 0.
 * @topic Auto
 */
class AHost
{
	int Score;

	AHost()
	{
		Score = 0;
	}
}

int DefaultScore()
{
	auto Object = AHost();
	return Object.Score;
}
/** @end */
/**
 * @begin infer-from-function-return
 * @summary auto Value = Make() infers the callee return type.
 * @topic Auto
 */
int Make()
{
	return 3;
}

int FromFunction()
{
	auto Value = Make();
	return Value;
}
/** @end */
/**
 * @begin infer-from-method-return
 * @summary auto Value = Object.Read() infers the method return type.
 * @topic Auto
 */
class AHost
{
	int Score;

	int Read() const
	{
		return Score;
	}
}

int FromMethod()
{
	AHost Object;
	Object.Score = 4;
	auto Value = Object.Read();
	return Value;
}
/** @end */
/**
 * @begin infer-from-member-read
 * @summary auto Value = Object.Score infers the field type.
 * @topic Auto
 */
class AHost
{
	int Score;
}

int FromMember()
{
	AHost Object;
	Object.Score = 4;
	auto Value = Object.Score;
	return Value;
}
/** @end */
/**
 * @begin infer-from-subscript
 * @summary auto Value = Values[0] infers the opIndex result type.
 * @topic Auto
 */
struct FValues
{
	int First = 3;

	int opIndex(int Index) const
	{
		return First;
	}
}

int FromSubscript()
{
	FValues Values;
	auto Value = Values[0];
	return Value;
}
/** @end */
/**
 * @begin infer-from-ternary
 * @summary auto Value = Flag ? 1 : 2 infers the common arm type.
 * @topic Auto
 */
int FromTernary(bool Flag)
{
	auto Value = Flag ? 1 : 2;
	return Value;
}
/** @end */
/**
 * @begin infer-from-cast
 * @summary auto Derived = Cast<ADerived>(Object) infers the cast target.
 * @topic Auto
 */
class ABase
{
	int Score;
}

class ADerived : ABase
{
}

int FromCast(ABase@ Object)
{
	auto Derived = Cast<ADerived>(Object);
	return Derived.Score;
}
/** @end */
