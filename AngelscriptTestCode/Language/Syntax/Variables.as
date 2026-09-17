/**
 * @version v1
 * @summary Primitive locals, a module-level int, and width-specific declarators.
 * @topic Language
 * @topic Syntax
 *
 * variables               // Typed locals, a reference alias, and an inner-block variable.
 * global-int              // A module-level integer read from a function.
 * multi-declarator-int    // One int declaration names two initialized locals.
 * int8-local              // A local declared with the live int8 keyword.
 * uint16-local            // A local declared with the live uint16 keyword.
 * float64-local           // A local declared with the live float64 keyword.
 */
/**
 * @begin variables
 * @summary Typed locals, a reference alias, and an inner-block variable.
 */
int PrimitiveLocals()
{
	int Count = 1;
	float Scale = 2.0f;
	bool Flag = true;
	int Total = Count + int(Scale);
	if (Flag)
	{
		int Inner = 3;
		Total += Inner;
	}
	return Total;
}

int ReferenceLocal()
{
	int Value = 1;
	int& Alias = Value;
	Alias = 4;
	return Value;
}
/** @end */
/**
 * @begin global-int
 * @summary A module-level integer read from a function.
 * @topic Syntax
 */
int GlobalCount = 1;

int ReadGlobal()
{
	return GlobalCount;
}
/** @end */
/**
 * @begin multi-declarator-int
 * @summary One int declaration names two initialized locals.
 * @topic Syntax
 */
int MultiDeclarator()
{
	int Left = 1, Right = 2;
	return Left + Right;
}
/** @end */
/**
 * @begin int8-local
 * @summary A local declared with the live int8 keyword.
 * @topic Syntax
 */
int8 Narrow()
{
	int8 Value = 1;
	return Value;
}
/** @end */
/**
 * @begin uint16-local
 * @summary A local declared with the live uint16 keyword.
 * @topic Syntax
 */
uint16 WideUnsigned()
{
	uint16 Value = 1;
	return Value;
}
/** @end */
/**
 * @begin float64-local
 * @summary A local declared with the live float64 keyword.
 * @topic Syntax
 */
float64 WideFloat()
{
	float64 Value = 1.0;
	return Value;
}
/** @end */
