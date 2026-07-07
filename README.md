# laranail/.github

> Organization-wide community health files, the org profile, and reusable GitHub
> Actions workflows for the [laranail](https://github.com/laranail) organization.

`profile/README.md` renders at [github.com/laranail](https://github.com/laranail)
and is the canonical org index — this file deliberately duplicates none of it.
The default `SECURITY.md`, `SUPPORT.md`, `CONTRIBUTING.md`, and
`CODE_OF_CONDUCT.md` here apply to every laranail repository lacking its own copy.

## Reusable workflows

`.github/workflows/` holds the reusable CI workflows (`tests.yml`,
`static-analysis.yml`, `security.yml`, `release.yml`) that every package calls:

```yaml
jobs:
  test:
    uses: laranail/.github/.github/workflows/tests.yml@main
    with:
      php-versions: '["8.3","8.4"]'
      laravel-versions: '["13.*"]'
```

## License

MIT — see each repository's license file.
