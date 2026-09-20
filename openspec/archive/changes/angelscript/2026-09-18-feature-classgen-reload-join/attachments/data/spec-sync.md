# Spec sync

Date: 2026-09-18. Change: angelscript/feature-classgen-reload-join.

- `angelscript/runtime/class-generation`: MODIFIED `Initial compile materializes Unreal reflection from preprocessor descriptors` to per-file Register and ADDED `Hot reload rematerializes Unreal reflection from preprocessor descriptors` with FullReload, SoftReloadOnly, and failed-reload last-generation cards. `harness.specs.write` sha `d79231800793947d4d63e14a4a656f0bb04669cd1a6c7bd7e290f7ba2981ac9c`. Strict spec validation passed.
- Change strict validation passed. Knowledge `per-file-definition-sets-enable-reload-retire` stays change-local.
