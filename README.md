# laranail (GitHub organization)

A family of Laravel packages — runtime tooling for package authors.

## Packages

| Repo | Description |
|---|---|
| [`laranail/laranail`](https://github.com/laranail/laranail) | Utility toolbox (Gravatar, Captcha, Avatar, Archiver, Notifications). |
| [`laranail/package-tools`](https://github.com/laranail/package-tools) | Runtime base library — `Package` builder + abstract `PackageServiceProvider` with attribute-driven discovery. |
| [`laranail/package-scaffolder`](https://github.com/laranail/package-scaffolder) | Generator — Artisan commands + stubs to scaffold new packages. |
| [`laranail/database-tools`](https://github.com/laranail/database-tools) | Independent Laravel DB utilities (model traits, schema macros, observers). |

## Targets

PHP `^8.3 || ^8.4`. Laravel `^13.0`. Pest `^3.0`. Testbench `^10.0`.

## Documentation

- Primary: [`laranail.simtabi.com/docs/`](https://laranail.simtabi.com/docs/)
- Portal: [`opensource.simtabi.com/laranail/`](https://opensource.simtabi.com/laranail/)

## This `.github` repo

This is the organization profile + reusable workflow repo. The `.github/workflows/` directory holds **reusable GitHub Actions workflows** (`tests.yml`, `security.yml`, `static-analysis.yml`, `release.yml`) that every package's CI calls via:

```yaml
jobs:
  test:
    uses: laranail/.github/.github/workflows/tests.yml@main
    with:
      php-versions: '["8.3","8.4"]'
      laravel-versions: '["13.*"]'
```

Phase 13 of the suite cleanup populates this directory.

## License

MIT. See each repo's `LICENSE.md`.