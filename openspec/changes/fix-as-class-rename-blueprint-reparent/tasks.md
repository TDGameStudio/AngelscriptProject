# Tasks

## 1. Runtime and Hot Reload

- [x] 1.1 <!-- TDD --> Add hot-reload rename redirect regression test.
- [x] 1.2 Register the regression through UE CoreRedirects.
- [x] 1.3 Resolve UE class redirects during class-generator reload.
- [x] 1.4 Verify targeted hot-reload class rename tests.
- [x] 1.5 <!-- TDD --> Add invalid class redirect hardening coverage.
- [x] 1.6 <!-- TDD --> Add two-step class rename redirect chain coverage.

## 2. Official UE Redirect Investigation

- [x] 2.1 Inspect UE CoreRedirects loading through knot and local source.
- [x] 2.2 Compare AS generated-class hot reload with UE class redirect responsibilities.
- [x] 2.3 Record the official AS class redirect `.ini` form in OpenSpec.

## 3. Follow-Up Validation

- [x] 3.1 Add or refactor coverage for physical `[CoreRedirects]` `.ini` ingestion.
- [x] 3.2 Document user-authored AS class rename redirects in plugin-facing docs.

## 4. Automatic Redirect Generation

- [x] 4.1 <!-- TDD --> Add hot-reload regression for automatic CoreRedirect write.
- [x] 4.2 Implement conservative single old/new AS class rename detection.
- [x] 4.3 Persist generated redirects to project `Config/DefaultEngine.ini` as `[CoreRedirects] +ClassRedirects`.
- [x] 4.4 Register generated redirects in `FCoreRedirects` for the current editor session.
- [x] 4.5 Avoid duplicate generated redirects and clean test override files.
- [x] 4.6 Verify `AngelscriptRuntime` build and HotReload class rename test source compile.
- [x] 4.7 Verify `Angelscript.TestModule.HotReload.ClassRename` automation after unrelated Coverage compile blockers are cleared.
