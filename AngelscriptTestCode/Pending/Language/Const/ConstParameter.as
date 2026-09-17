/**
 * @version v1
 * @summary A const value parameter can be read in the function body.
 * @topic Language
 * @topic Const
 */
/**
 * @version root
 * @summary Identity returns the const int parameter unchanged.
 * @topic Baseline
 */
int Identity(const int Value)
{
	return Value;
}

int UseParam()
{
	return Identity(3);
}
/** @end */
/**
 * @version valid-const-param-zero
 * @parent root
 * @summary A const parameter may be zero.
 * @topic Const
 */
int Identity(const int Value)
{
	return Value;
}

int UseZero()
{
	return Identity(0);
}
/** @end */
/**
 * @version valid-const-param-in-expression
 * @parent root
 * @summary A const parameter can be used in an arithmetic expression.
 * @topic Const
 */
int PlusOne(const int Value)
{
	return Value + 1;
}

int UseAdded()
{
	return PlusOne(3);
}
/** @end */
