/**
 * @version v1
 * @summary Typedef aliases that name another alias.
 * @topic Language
 * @topic Typedef
 *
 * typedef-chain         // typedef Count Total lets Total Value = 4 assign and return 4.
 * chain-as-parameter    // The second alias can be a parameter type.
 */
/**
 * @begin typedef-chain
 * @summary typedef Count Total lets Total Value = 4 assign and return 4.
 * @topic Typedef
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
 * @begin chain-as-parameter
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
