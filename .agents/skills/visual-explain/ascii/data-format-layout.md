# Data & format layout

## Show packed bits or memory layout as a field box

```
FVTTranscodeKey (64-bit union)
┌────────────────────────────────────────────────────────────────┐
│ Bit 63-32 │ ProducerID  (32 bit) = ProducerHandle.PackedValue  │
│ Bit 31- 8 │ vAddress    (24 bit) = Morton Z-order virtual addr │
│ Bit  7- 4 │ vLevel      ( 4 bit) = Mip level (0 = highest res) │
│ Bit  3- 0 │ LayerMask   ( 4 bit) = which layers to decode      │
└────────────────────────────────────────────────────────────────┘
  Hash = MurmurFinalize64(Key) & 0xFFFF   # low 16 bits → hash-table index
```

When byte offsets and alignment are the story instead of bit packing:

```
FTransform  memory layout  (sizeof = 48, align = 16)
┌──────┬───────────────────────────────────────────────────────┐
│ +00  │  FQuat     Rotation     [16 bytes]  # 16B aligned      │
│ +16  │  FVector4  Translation  [16 bytes]  # W always 0.0     │
│ +32  │  FVector4  Scale3D      [16 bytes]  # W always 0.0     │
└──────┴───────────────────────────────────────────────────────┘
  Total: 48 bytes = 3 × 16B SIMD blocks
```

## Show regions packed into a 2D space as a coordinate-annotated layout

```
Page Table block for one full-size VSM   (Y, X = texel coords inside the block)

Y=0   ┌──────────────────────────────────────────────┐
      │                                              │
      │  Mip 0   128 × 128 pages                     │   # finest level
      │  (entries = ShadowEncodePageTable(...))      │
      │                                              │
Y=128 ├──────────────────────┬────────────┬────┬───┬─┤
      │  Mip 1   64 × 64     │ Mip 2 32×32│ M3 │M4 │M│   # Mip tail laid out
      │  (Y=128, X=0..63)    │ (X=64..95) │    │   │5│   # left-to-right via
Y=192 └──────────────────────┴────────────┴────┴───┴─┘   # CalcLevelOffsets()
      X→ 0                   64           96   112 124   128 (block right edge)

# Engine/Shaders/Private/VirtualShadowMaps/VirtualShadowMapPageAccessCommon.ush
# CalcPageTableLevelOffset(Handle, Mip) → (X, Y) texel start inside the block
# Why this packing works: tail widths sum to 64+32+16+8+4+2 = 126 < 128;
# the tail row therefore fits in the same X budget as Mip0.
```

Cell widths encode the real ratio of regions — don't equalize them for prettiness, that hides the packing story.

## Show a grammar or text format as a line-numbered spec box

Line numbers are prose anchors ("rule 12 covers repetition"), not source lines. Keep a production on one line when it fits; long alternations break across rows with `/` at a single shared column so they line up vertically. Right-column `#` comments explain the domain meaning, not the BNF syntax. Always close with a worked example. The same shape with sequence indexes also fits VM bytecode listings or ordered command traces.

```
┌──┬──────────────────────────────────────────────────────────────────────┐
│1 │  PCG Shape Grammar  (ABNF, simplified)                               │
│2 │                                                                      │
│3 │  grammar-string  = module-expr *( "," module-expr )                  │
│4 │                                                                      │
│5 │  module-expr     = module-symbol                                     │
│6 │                  / module-symbol repeat-op                           │
│7 │                  / "{" weighted-list "}"      # alternation, weighted│
│8 │                  / "[" stacked-list "]"       # spatial composition  │
│9 │                                                                      │
│10│  module-symbol   = ALPHA *( ALPHA / DIGIT )                          │
│11│                                                                      │
│12│  repeat-op       = "*"                        # fill remaining space │
│13│                  / "+" 1*DIGIT                # exact N repetitions  │
│14│                  / "?" 1*DIGIT                # probability weight   │
│15│                                                                      │
│16│  weighted-list   = weighted-item *( "," weighted-item )              │
│17│  weighted-item   = module-expr ":" 1*DIGIT                           │
│18│  stacked-list    = module-expr "," module-expr   # front + back      │
│19│                                                                      │
│20│  ; Example: "{[A,P]:2,[BL,P]:1,[BS,P]:1}*,[G,P]"                     │
│21│  ;          A,BL,BS = fence panels   P = post   G = gate             │
└──┴──────────────────────────────────────────────────────────────────────┘
```

## Show linked nodes or a ring buffer as a pointer diagram

Nodes are small boxes, pointers are labeled arrows; mark the head/tail cursors above and state the wrap or reuse rule beside the closing edge:

```
Feedback in-flight ring  (3 buffers; GPU writes ahead, CPU reads behind)

   Read cursor (CPU Map)              Write cursor (GPU copy)
         │                                  │
         ▼                                  ▼
  ┌────────────┐    ┌────────────┐    ┌────────────┐
  │ Buffer 0   │───▶│ Buffer 1   │───▶│ Buffer 2   │──┐
  │ CPU-read   │    │ idle       │    │ GPU-write  │  │
  └────────────┘    └────────────┘    └────────────┘  │
         ▲                                            │
         └────────────────────────────────────────────┘   // Wrap: oldest buffer is reused
```

Intrusive free-list variant — the link lives inside the freed payload itself:

```
FreeListHead ──▶ [Slot 7] ──▶ [Slot 3] ──▶ [Slot 12] ──▶ null
                   │
                   └─ NextFree index stored in the freed slot   // No extra memory per node
```
