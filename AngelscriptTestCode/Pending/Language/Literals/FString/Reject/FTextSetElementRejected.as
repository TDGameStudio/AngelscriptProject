/**
 * @version v1
 * @summary Using an FText as a TSet element is rejected: text has no hash function in this fork. This file is the illegal program itself; do not store ToString(), since the missing hash is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Using an FText as a TSet element is rejected: text has no hash function in this fork. This file is the illegal program itself; do not store ToString(), since the missing hash is the point.
 * @topic Negative
 */
/**
 * Attempt to store FText in a set, which lacks a hash function.
 */
int UseTextSetElement()
{
	TSet<FText> Values;
	Values.Add(FText::FromString("Value"));
	return Values.Num();
}
/** @end */
