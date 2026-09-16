# CQTest forbids Layer.Layer

Disposition: candidate. Origin: angelscript/refactor-testing-nativeengine-home, from the baseline Lexer rule and the Foundation class collision. Not promoted.

## Reusable Insight

CQTest public names are `TestDir.Class.Method`. If TestDir already ends in a layer token, the class token must not repeat that token. Nested layer identities require either a different class name or a different theme folder.

## Evidence

The testing baseline forbids `Angelscript.UnitTest.NativeEngine.Lexer.Lexer.*`. Class `Foundation` under a Foundation TestDir would have published `Foundation.Foundation.*`. The settled repair was theme `Basic` with class `Foundation` kept.

## Boundaries

Applies to replacement NativeEngine CQTest identities. Bindings and Framework prefixes have their own nesting rules and are not this collision.

## Application

When adding a nested TestDir, grep the class identifier against the last TestDir segment before registering. Prefer a simple theme rename over inventing a new class name when the existing class is already meaningful.

## Sources

`openspec/specs/angelscript/testing/baseline` Lexer nested-TestDir scenario. Talk: basic-foundation.
