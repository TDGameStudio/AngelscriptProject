# Streaming tokenization boundary

## Context

The current AngelScript Parser owns the source cursor and asks an Engine-owned tokenizer to classify the next token. A proposed replacement could either pretokenize every file or make the tokenizer itself a pull stream.

## Evidence

- `as_tokenizer.h` already exports the class and public `GetToken`, but the object stores `const asCScriptEngine*`.
- `as_tokenizer.cpp` reads `engine->ep.allowUnicodeIdentifiers` in identifier classification.
- `as_parser.cpp` retains `sourcePos`, a one-slot rewind value, filters trivia, and calls `engine->tok.GetToken`.
- Clang `Lexer` advances through immutable buffer pointers and fills one compact `Token`; Parser and Preprocessor determine how much lookahead or retention they need.
- Temp research after the user correction at [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 1401 specifically asks about pull token output, token-stream ownership, diagnostics, and Clang hot-path design around lines 3685-4045.

## Options

1. Pretokenize every file into an owning vector before preprocessing or parsing.
2. Keep Parser-owned byte cursors and expose more old tokenizer helpers.
3. Let an engine-independent tokenizer own the byte cursor and expose one pull operation; consumers buffer only explicit lookahead or retained records.

## Settled Decision

Use option 3. It establishes one advancement and recovery authority, keeps the common path allocation-free, and still permits Preprocessor or tooling to retain tokens when provenance requires it. Making protected scanners public without moving cursor/options ownership would leave the original coupling intact.

## Consequences and Flip Condition

Parser must later use bounded lookahead and recovery checkpoints instead of arbitrary source-pointer rewinds. Full token capture is an optional consumer product. Reconsider broader default buffering only if the accepted grammar proves unbounded lookahead is necessary or measurements show retention is cheaper without compromising memory and provenance boundaries.

## Visual

```text
SourceSnapshot + LexOptions
             |
             v
       asCTokenizer -- Lex(Token&) --> consumer
                                         |-- bounded Parser lookahead
                                         |-- selected PP retention
                                         `-- optional test/tool capture
```

## Sources

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokenizer.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
- `D:/LLVM/llvm-project-22.1.8.src/clang/include/clang/Lex/Lexer.h`
- `D:/LLVM/llvm-project-22.1.8.src/clang/lib/Lex/Lexer.cpp`
- [Temp reconstruction transcript 1](../../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 3685-4045
