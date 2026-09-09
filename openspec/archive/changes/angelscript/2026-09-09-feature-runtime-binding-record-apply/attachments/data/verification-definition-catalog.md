# Native definition catalog verification

Task 4.2 adds `RecordRuntimeTypeDeclarations`, a serial prepass over the sealed compiled provider collection. It executes TypeDeclarations providers and explicitly marked declaration-bearing providers into a writable detached Store. `FAngelscriptBinds` declaration-only mode records types while suppressing member bodies. Primitive width, aliases and adapters are copied as Store facts; templated `ValueClassForTarget<T>` records real size/alignment, native owner, construct/copy/destroy callbacks and triviality. Reflection declarations keep their owning snapshot recipes.

Two legacy declaration couplings were removed based on observed failures. `Delegates.Declarations` now has a declaration-only path for its native storage types instead of querying the live bind database. `FFileHelper.Types` uses the Store-aware namespace guard. The two compiled ExplicitBindings providers that declare native types are marked in their owning files, so `FAngelscriptGameThreadScopeWorldContext` and `FScopedMovementUpdate` join the prepass without recording their methods.

## RED and diagnosis

Harness run `24a84ee9e2a94e3181f71549d3dcbd65` ran seven catalog cases: six controls passed and the compiled-provider prepass failed. After collection finalization exposed the real path, run `41f27e9c187d49c986574a43bb107347` terminated at the prohibited `Delegates.Declarations -> GetTargetBindDatabase` query. The next run located the same issue in the FFileHelper namespace guard. Later shared run `d399105c72ea46c3b7073c92e854696b` passed 131/132 and exposed incompatible duplicate admission caused by adding lifecycle facts after the first declaration; Store admission now permits an incomplete repeat to merge through the bounded update while still rejecting conflicting non-null recipes and layouts.

## Final GREEN

- Final build Harness run `b58b7baacb414624b97a1487c84e0297`: succeeded, exit code 0.
- Exact catalog Automation run `28c39dcd593045998ec6b6141164dd51`: 7/7 succeeded with zero warnings and errors.
- Final shared RuntimeBindings run `3db2718b5f0441a8ac8cf5d743d233b3`: 132/132 succeeded with zero warnings and errors.

The seven cases prove primitive bool/int8/int32/uint64/float32/float64 width and aliases, the actual compiled declaration inventory without a current Engine, declaration-only suppression of member bodies, real FString/FText construct-copy-destroy behavior, incompatible layout rejection, declaration-bearing ExplicitBindings participation, and closed/worker-invalid admission. Full family methods remain owned by tasks 4.3 onward.

## Identities

Source hashes: `AngelscriptTypeBindInfo.h` `E72D793E...845C`; Store header/source `A94FB7F3...B73A` / `9DF1AA7F...371B`; Catalog header/source `2593787B...20BA` / `9C372B99...2988`; Binds header/source `A0E48E8B...B588` / `2C238E4F...D20C`; BindsInternal `F1F91528...BA94`; Delegates `76B275A5...7FED`; FFileHelper `A51B4DE5...09B1`; WorldContext `320EAC8F...8763`; USceneComponent `0AD99DDB...1B9E`; catalog tests `C67FE878...96BB`. Runtime/Test DLL hashes are `351CE50A...84AA` and `4F75F321...E3D9`. Full SHA-256 values were captured in the task run log immediately before this record.
