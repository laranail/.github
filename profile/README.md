<h1 align="center">laranail</h1>

<p align="center">
  <strong>A focused suite of Laravel 13+ packages for building, scaffolding, and shipping your own Laravel packages.</strong><br>
  Modern PHP. Pure Composer tooling. No Python. No surprises.
</p>

<p align="center">
  <a href="https://opensource.simtabi.com/"><img alt="Documentation" src="https://img.shields.io/badge/docs-opensource.simtabi.com-0ea5e9?style=flat-square"></a>
  <a href="https://github.com/laranail/package-tools/blob/main/LICENSE.md"><img alt="License" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square"></a>
  <a href="https://www.php.net/"><img alt="PHP" src="https://img.shields.io/badge/PHP-8.3%20%7C%208.4-777BB4?style=flat-square&logo=php&logoColor=white"></a>
  <a href="https://laravel.com/"><img alt="Laravel" src="https://img.shields.io/badge/Laravel-13.x-FF2D20?style=flat-square&logo=laravel&logoColor=white"></a>
</p>

---

## What is laranail?

`laranail` is a four-package suite that lets you build Laravel 13+ packages the way Spatie made popular — but with a few opinionated extras: **attribute-driven discovery**, a **`package:doctor`** health-check command, an **append-only `.env` writer**, an **OSV.dev audit** wrapper, a **CycloneDX SBOM** generator, and a **`#[AsFacade]`-driven IDE-helper** generator.

Every package targets PHP 8.3+ and Laravel 13+. Tooling is pure PHP/Composer — exactly **one** bash script per repo (`scripts/init.sh`), enforced by a CI gate.

## The packages

| Package | Purpose | Status |
| --- | --- | --- |
| 🧰 [`package-tools`](https://github.com/laranail/package-tools) | Runtime base library — fluent `Package` builder, abstract `PackageServiceProvider`, attribute-driven discovery, ship-with Artisan commands (`package:doctor` / `:sbom` / `:audit` / `:ide-helper`) | v1.0 ready |
| 🏗️ [`package-scaffolder`](https://github.com/laranail/package-scaffolder) | Artisan generator that scaffolds new Laravel packages built on `package-tools`. 13 commands, 139 stubs | v1.0 ready |
| 🗄️ [`database-tools`](https://github.com/laranail/database-tools) | Independent Laravel DB utilities — `HasUuid` / `HasNanoid` / `HasUlid` traits, `Blueprint::auditColumns()`, `softDeletesWithUndo()`. **No `package-tools` dependency** | v1.0 ready |
| 📚 [`documentation`](https://github.com/laranail/documentation) | VitePress source for [opensource.simtabi.com](https://opensource.simtabi.com/) — aggregates per-package docs at build time | live |

Plus this `.github` repo — reusable GitHub Actions workflows (tests, static-analysis, security, release) consumed by every PHP package via 20-line caller workflows.

## Quick start

```bash
# 1. Add the runtime base to a Laravel 13+ app
composer require laranail/package-tools

# 2. Scaffold a new package (uses `package-tools` under the hood)
composer require --dev laranail/package-scaffolder
php artisan make:package vendor/awesome-package

# 3. Run the bundled health check
php artisan package:doctor

# 4. Generate a CycloneDX SBOM for the host project
php artisan package:sbom --output=sbom.json

# 5. Audit composer.lock against OSV.dev
php artisan package:audit
```

Full guides at [opensource.simtabi.com/getting-started](https://opensource.simtabi.com/getting-started).

## Architectural decisions

Every non-trivial design choice is recorded as an [ADR](https://adr.github.io/) in `package-tools/docs/adr/`. The current set:

1. **Four packages, not one** — different audiences, different release cadences
2. **Polyrepo** — each package its own git repo; reusable workflows in `laranail/.github`
3. **PHP 8.3+ / Laravel 13+** target floor
4. **Trait aggregator pattern** — `Package` composes 13 domain aggregators wrapping 44 leaf traits
5. **Fluent `$this` for chaining, `static` for terminal** — IDE-friendly, Spatie-compatible
6. **`.env` is append-only** — `EnvFileService` never destroys consumer files
7. **Bash banished** except `scripts/init.sh` — CI gate enforces
8. **Plans live in `.plans/`** — historical context off the working surface
9. **Attribute-driven discovery** — `#[AsArtisanCommand]`, `#[AsRoute]`, `#[AsFacade]`, `#[AsViewComposer]`
10. **`database-tools` is genuinely independent** — usable by any Laravel app
11. **Six leaf traits stay unwired by design** — collision-by-design, see ADR-0011

## Contributing

- 🐛 **Bug?** Open an issue on the relevant package repo.
- ✨ **Feature?** Discuss in [GitHub Discussions](https://github.com/orgs/laranail/discussions) before opening a PR.
- 📝 **Docs?** PRs welcome at [`laranail/documentation`](https://github.com/laranail/documentation).
- 🔒 **Security?** See `SECURITY.md` in each package — please don't open public issues for vulnerabilities.

Each package has populated `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md`.

## CI/CD

All four PHP packages share four reusable workflows (`tests` / `static-analysis` / `security` / `release`) maintained here:

- **Tests** — Pest matrix across PHP 8.3/8.4 × Laravel 13.* × `prefer-lowest`/`prefer-stable`
- **Static analysis** — Pint + PHPStan level 8 + Rector dry-run + bash-elimination gate
- **Security** — `composer audit --locked` + OSV.dev scan, weekly cron
- **Release** — tag-triggered, emits CycloneDX SBOM + Conventional Commits CHANGELOG

## License

All `laranail/*` packages are released under the [MIT License](https://github.com/laranail/package-tools/blob/main/LICENSE.md).

## Maintainer

Maintained by [Simtabi](https://simtabi.com). Spiritual successor to (and inspired by) [`spatie/laravel-package-tools`](https://github.com/spatie/laravel-package-tools).

<!-- Profile rendered at github.com/laranail. Source: .github/profile/README.md on `main`. -->

