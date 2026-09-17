/**
 * @version v1
 * @summary Using an FText as a TMap key is rejected: text has no hash function in this fork. This file is the illegal program itself; do not key on ToString(), since the missing hash is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Using an FText as a TMap key is rejected: text has no hash function in this fork. This file is the illegal program itself; do not key on ToString(), since the missing hash is the point.
 * @topic Negative
 */
/**
 * Attempt to key a map on FText, which lacks a hash function.
 */
int UseTextMapKey()
{
	TMap<FText, int> Values;
	Values.Add(FText::FromString("Key"), 1);
	return Values.Num();
}
/** @end */
