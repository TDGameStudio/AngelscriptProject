/**
 * @version v1
 * @summary Typedef chains that do not compile.
 * @topic Language
 * @topic Typedef
 *
 * invalid-chain-unknown-first-alias    // The first name in a typedef chain must already exist.
 */
/**
 * @begin invalid-chain-unknown-first-alias
 * @summary The first name in a typedef chain must already exist.
 * @topic Negative
 */
typedef Missing Count;
typedef Count Total;
/** @end */
