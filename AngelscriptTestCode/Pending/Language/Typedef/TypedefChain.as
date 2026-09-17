/**
 * @version v1
 * @summary A typedef may alias another typedef.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary typedef Count Total lets Total Value = 4 assign and return 4.
 * @topic Baseline
 */
typedef int Count;
typedef Count Total;

int UseChain()
{
	Total Value = 4;
	return Value;
}
/** @end */
/**
 * @version valid-chain-as-parameter
 * @parent root
 * @summary The second alias can be a parameter type.
 * @topic Typedef
 */
typedef int Count;
typedef Count Total;

int Double(Total Amount)
{
	return Amount + Amount;
}

int UseParam()
{
	Total Value = 3;
	return Double(Value);
}
/** @end */
/**
 * @version invalid-chain-unknown-first-alias
 * @parent root
 * @summary The first name in a typedef chain must already exist.
 * @topic Negative
 */
typedef Missing Count;
typedef Count Total;
/** @end */
