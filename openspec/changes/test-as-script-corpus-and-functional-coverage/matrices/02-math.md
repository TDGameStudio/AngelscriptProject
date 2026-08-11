# 02 — Math Corpus And Script Tests

| ID | User scenario / AS surface | Corpus target | Script-test target | Existing evidence to audit | Fixture / log policy | Initial disposition |
|---|---|---|---|---|---|---|
| MATH-01 | FMath absolute/min/max/clamp/sign/rounding | `Script/Math/ScalarMath.as` | `Script/Tests/Math/Test_ScalarMath.as` | `Bind_FMath*`; Math Bindings; Coverage MathNamespaceFunctions | Pure; table indexes exact `Math::` forms | `CorpusGap`, `ScriptTestGap` |
| MATH-02 | Lerp, inverse lerp, mapped ranges, easing | `Script/Math/InterpolationAndRanges.as` | `Script/Tests/Math/Test_InterpolationAndRanges.as` | FMath binds; Math FunctionLibrary tests; Coverage Math | Pure; assert tolerance and endpoints | `CorpusGap`, `ScriptTestGap` |
| MATH-03 | Trigonometry, degrees/radians, angle unwind/wrap | `Script/Math/AnglesAndTrigonometry.as` | `Script/Tests/Math/Test_AnglesAndTrigonometry.as` | FMath binds; Math orientation FunctionLibrary tests | Pure; use near assertions | `CorpusGap`, `ScriptTestGap` |
| MATH-04 | Random range and deterministic FRandomStream | `Script/Math/DeterministicRandom.as` | `Script/Tests/Math/Test_DeterministicRandom.as` | `Bind_FRandomStream*`, FMath random binds; RandomStream Bindings | Pure; fixed seed; bounded summary log only | `CorpusGap`, `ScriptTestGap` |
| MATH-05 | FVector construction, arithmetic, length, normalization, dot/cross | `Script/Math/VectorOperations.as` | `Script/Tests/Math/Test_VectorOperations.as` | FVector binds; Coverage FVector; Math FunctionLibraries | Pure; table and near assertions | `CorpusGap`, `ScriptTestGap` |
| MATH-06 | FVector2D and UI/gameplay plane calculations | `Script/Math/Vector2DOperations.as` | `Script/Tests/Math/Test_Vector2DOperations.as` | FVector2D binds; Coverage FVector2D | Pure | `CorpusGap`, `ScriptTestGap` |
| MATH-07 | FRotator normalization, direction, composition | `Script/Math/RotationWorkflows.as` | `Script/Tests/Math/Test_RotationWorkflows.as` | FRotator binds; Coverage FRotator; MathOrientation library | Pure; use near assertions | `CorpusGap`, `ScriptTestGap` |
| MATH-08 | FQuat construction, multiplication, slerp, vector rotation | `Script/Math/QuaternionWorkflows.as` | `Script/Tests/Math/Test_QuaternionWorkflows.as` | FQuat binds; Coverage FQuat; orientation tests | Pure; avoid raw component equality when semantic equality exists | `CorpusGap`, `ScriptTestGap` |
| MATH-09 | FTransform composition, inverse, position/direction conversion | `Script/Math/TransformWorkflows.as` | `Script/Tests/Math/Test_TransformWorkflows.as` | FTransform binds; Coverage FTransform; Transform Bindings | Pure; table and near assertions | `CorpusGap`, `ScriptTestGap` |
| MATH-10 | FMatrix transform and extraction paths | `Script/Math/MatrixOperations.as` | `Script/Tests/Math/Test_MatrixOperations.as` | `Bind_FMatrix`; Matrix Bindings; bind-surface parity wave | Pure; table labels current alias/precision | `CorpusGap`, `ScriptTestGap` |
| MATH-11 | FLinearColor/FColor conversion, interpolation, packing | `Script/Math/ColorWorkflows.as` | `Script/Tests/Math/Test_ColorWorkflows.as` | Color binds; Coverage FLinearColor; Color Bindings | Pure; assert channel/tolerance | `CorpusGap`, `ScriptTestGap` |
| MATH-12 | Boxes, spheres, planes, bounds, containment/intersection | `Script/Math/GeometryBounds.as` | `Script/Tests/Math/Test_GeometryBounds.as` | Box/Sphere/Plane/Bounds binds; Coverage geometric structs | Pure; table distinguishes float/default aliases | `CorpusGap`, `ScriptTestGap` |
| MATH-13 | Integer points/vectors and grid coordinates | `Script/Math/IntegerCoordinates.as` | `Script/Tests/Math/Test_IntegerCoordinates.as` | IntPoint/IntVector binds; IntVector Bindings | Pure | `CorpusGap`, `ScriptTestGap` |
| MATH-14 | FrameTime/frame-number arithmetic | `Script/Math/FrameTime.as` | `Script/Tests/Math/Test_FrameTime.as` | `Bind_FFrameTime`; FrameTime FunctionLibrary tests | Pure; table records rounding/precision effects | `CorpusGap`, `ScriptTestGap` |
| MATH-15 | Math API unsupported aliases/algorithms | No positive corpus row unless documenting a migration alternative | `Script/Tests/Math/Test_MathBoundaries.as` plus focused C++ negatives | Coverage gaps and Bindings negative contracts | `ExpectError*`; no log spam | `ScriptTestGap`, `Unsupported` |

## API Table Ownership

Every file in this matrix includes the source-local API usage table. The table must be derived from `Bind_FMath*`, the corresponding type bind providers, or verified FunctionLibrary declarations and must label precision/alias differences that are relevant to UE 5.x and this fork.

