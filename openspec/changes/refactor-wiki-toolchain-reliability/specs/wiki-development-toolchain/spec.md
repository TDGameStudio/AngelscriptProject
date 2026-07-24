## ADDED Requirements

### Requirement: Standard Wiki workflow validates the supported toolchain

The integrated Wiki's standard development, build, test, artifact-test, browser-test, and aggregate-verification commands SHALL validate Node major version `24` and pnpm version `11.8.0` before executing product work. A failing validation SHALL identify the detected version and provide a supported remediation command.

#### Scenario: Maintainer runs a standard command on the pinned toolchain
- **WHEN** Node 24 and pnpm 11.8.0 invoke a standard Wiki workflow command
- **THEN** toolchain validation SHALL succeed
- **AND** the requested workflow SHALL continue using pnpm-composed subcommands

#### Scenario: Maintainer runs a standard command on an unsupported toolchain
- **WHEN** Node is not major version 24 or pnpm is not version 11.8.0
- **THEN** the workflow SHALL stop before product preparation or browser startup
- **AND** the diagnostic SHALL name the supported versions and show a command that invokes pnpm 11.8.0

### Requirement: Offline artifact validation invokes the publisher without a shell package-manager dependency

The offline artifact test SHALL prepare product sources and invoke the repository publisher through its module interface. It SHALL NOT require a bare `pnpm` executable in the shell PATH or recursively start a package-manager command to validate the produced artifact.

#### Scenario: Artifact test runs through the standard test command
- **WHEN** a maintainer runs the Wiki artifact-test command on the supported toolchain
- **THEN** the test SHALL prepare generated product sources, publish the offline Wiki, and validate the resulting artifact
- **AND** it SHALL not spawn `pnpm run build:wiki` as a child process

### Requirement: Product browser tests have an explicit isolated offline-artifact server owner

When `PLAYWRIGHT_BASE_URL` is absent, product Playwright tests SHALL build a unique offline Wiki artifact from a unique isolated generated product-source root and start and manage a local server that serves that artifact. The default server SHALL NOT serve a development preview or reuse a previously running server. Product Playwright tests SHALL use an external server only when `PLAYWRIGHT_BASE_URL` is explicitly supplied.

#### Scenario: Default product browser test run
- **WHEN** a maintainer runs the browser-test command without `PLAYWRIGHT_BASE_URL`
- **THEN** Playwright SHALL build a unique offline Wiki artifact from a unique isolated generated product-source root
- **AND** it SHALL start and manage a local server that serves that artifact rather than a development preview
- **AND** it SHALL not silently reuse a previously running server

#### Scenario: Maintainer explicitly supplies a preview URL
- **WHEN** `PLAYWRIGHT_BASE_URL` is supplied to the browser-test command
- **THEN** Playwright SHALL test that URL
- **AND** it SHALL not build or start the default isolated offline-artifact server
