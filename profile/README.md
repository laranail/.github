<!-- Banner slot: add the <picture> block here when profile/banner-{light,dark}.svg
     land, per /opensource/simtabi-brand-design-standard.md (Crimson #D7263D):

<div align="center">
  <a href="https://opensource.simtabi.com">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="banner-dark.svg">
      <img alt="laranail — a family of Laravel packages by Simtabi" src="banner-light.svg" width="888">
    </picture>
  </a>
</div>
-->

<h1 align="center">laranail</h1>

<p align="center">
  <strong>A family of Laravel packages for building, scaffolding, and shipping
  your own Laravel packages — and the toolkit that grew around them.</strong><br>
  Modern PHP. Pure Composer tooling. No surprises.
</p>

<p align="center">
  <a href="https://opensource.simtabi.com"><img alt="Documentation" src="https://img.shields.io/badge/docs-opensource.simtabi.com-D7263D?style=flat-square"></a>
  <a href="https://github.com/laranail/package-tools/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-D7263D?style=flat-square"></a>
  <img alt="PHP" src="https://img.shields.io/badge/PHP-8.3%2B-777BB4?style=flat-square&logo=php&logoColor=white">
  <img alt="Laravel" src="https://img.shields.io/badge/Laravel-13.x-FF2D20?style=flat-square&logo=laravel&logoColor=white">
</p>

---

## What is laranail?

laranail is the package-development layer we use to build every Laravel package we
ship: a fluent package builder in the tradition of `spatie/laravel-package-tools`,
extended with attribute-driven discovery, a health-check command, SBOM and OSV.dev
audit tooling, and a scaffolder that generates publish-ready packages. Around that
core sits a growing toolkit — console foundations, database utilities, enums,
licensing, environment tooling, installers, and more.

## Start here

| Package | What it does |
| --- | --- |
| [`package-tools`](https://github.com/laranail/package-tools) | Runtime base library — fluent `Package` builder, attribute discovery, and doctor/sbom/audit/ide-helper commands |
| [`package-scaffolder`](https://github.com/laranail/package-scaffolder) | Artisan command suite and stubs for scaffolding new Laravel packages |
| [`toolkit`](https://github.com/laranail/toolkit) | Security-first Swiss-army toolkit — utilities, traits, middleware, macros, feature modules |
| [`console`](https://github.com/laranail/console) | Rich console toolkit — fluent output plus a prompts/forms layer with validators |
| [`database-tools`](https://github.com/laranail/database-tools) | Standalone database utilities — UUID/ULID traits, schema macros, soft-archive, backup/restore |

Beyond the core: licensing ([`license-kit`](https://github.com/laranail/license-kit),
[`license-verifier`](https://github.com/laranail/license-verifier),
[`demo-mode`](https://github.com/laranail/demo-mode),
[`product-updater`](https://github.com/laranail/product-updater)), environment
tooling ([`env-kit`](https://github.com/laranail/env-kit)), installers
([`installer-headless`](https://github.com/laranail/installer-headless),
[`installer-web`](https://github.com/laranail/installer-web)), and type-safe enums
([`enumerator`](https://github.com/laranail/enumerator)). Browse
[all repositories](https://github.com/orgs/laranail/repositories) for the full
family.

## Quick start

```bash
composer require laranail/package-tools
composer require --dev laranail/package-scaffolder

php artisan packager:generate vendor widget
php artisan laranail::package-tools.doctor
```

Documentation lives at [opensource.simtabi.com](https://opensource.simtabi.com)
and in each repository's `docs/` directory.

## Where to get help

- Questions and ideas: open an issue on the relevant package repository.
- Documentation fixes: pull requests welcome on any repository's `docs/` tree.
- Security: see each repository's `SECURITY.md` — please report privately, never
  via public issues.

## About Simtabi

laranail is maintained by the team at [Simtabi](https://simtabi.com), a software
design agency and design & branding studio based in Delaware, USA and Nairobi,
Kenya. Whenever we build something reusable, we extract it and release it as open
source — you'll find all of our projects at
[opensource.simtabi.com](https://opensource.simtabi.com).

All laranail packages are open-sourced software licensed under the
[MIT license](https://github.com/laranail/package-tools/blob/main/LICENSE).
