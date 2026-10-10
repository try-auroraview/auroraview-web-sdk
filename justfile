set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

default:
    @just --list

install:
    vx bun install

build: install
    vx bun run build

# Inject scripts consumed by the AuroraView Rust core (assets/core, assets/plugins, assets/extensions).
build-assets: install
    vx bun run build:assets

build-all: install
    vx bun run build:all

typecheck: install
    vx bun run typecheck

test: install
    vx bun run test

test-cov: install
    vx bun run test:coverage

test-e2e: install
    vx bun run test:e2e

# Consume a prebuilt npm pack archive outside this checkout, without registry access.
check-package output="package-artifacts":
    vx node@22 scripts/check_package.mjs --output "{{output}}"

test-package output="package-artifacts": build (check-package output)

ci: typecheck test build-assets
