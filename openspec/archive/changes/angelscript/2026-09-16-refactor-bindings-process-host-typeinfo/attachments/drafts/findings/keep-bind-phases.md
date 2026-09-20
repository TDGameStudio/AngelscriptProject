# Direct construction retains bind phases

English rendering of the 2026-09-15 finding accepted as part of the final design.

Direct callbacks allocate and modify real objects immediately, so phase order is meaningful. Retain TypeDeclarations for shells, TypeInfrastructure for primitive/container infrastructure, ExplicitBindings as the author default, GeneratedBindings, ReflectionBindings, PostReflectionBindings for late extensions/mixins and Finalization.

The earlier recipe-model statement that TypeDeclarations existed only in installation is obsolete. Existing TArray declaration and method stages and AActor/mixin post-reflection extensions illustrate the dependency. Blueprint shell, base and member barriers are explicit inside these phases. Retaining phases does not authorize concurrent execution of different phases or replaying callbacks to produce a separate descriptor library.
