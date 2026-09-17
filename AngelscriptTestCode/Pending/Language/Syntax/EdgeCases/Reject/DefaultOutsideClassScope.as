/**
 * @version v1
 * @summary A `default` statement at global scope is rejected. This file is the illegal program itself; do not add a class wrapper, since being outside any class is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A `default` statement at global scope is rejected. This file is the illegal program itself; do not add a class wrapper, since being outside any class is the point.
 * @topic Negative
 */
int GlobalValue = 5;
default GlobalValue = 10;
/** @end */
