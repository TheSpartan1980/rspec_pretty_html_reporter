## [1.3.0] - 2026-11-23

- Added support for `parallel_tests`: the workers of one run share one report directory, and the overview lists the groups from every worker
- Fixed the browser console errors on the report pages: Tether is now loaded from the bundled `resources/tether-1.3.3-dist` folder, before Bootstrap
- The dependency constraints were widened so the gem installs in Rails 8 apps (`activesupport < 9.0`) and with Bundler 4 (`bundler >= 2.2, < 5`)
- Added a test that every resource the report pages reference exists
- CI now runs on every pull request, and on pushes to `main`; pull requests targeting `main` previously had no checks

Thanks to [@anthony0030](https://github.com/anthony0030) for the parallel_tests support, the Tether fix, and the Rails 8 and Bundler 4 support.

## [1.2.0] - 2025-07-02

- Raised minimum Ruby to 3.3.0
- Replaced deprecated `Rouge::Formatters::HTMLLegacy` with `HTML` and `HTMLTable` formatters
- Widened runtime dependency constraints (`activesupport <8.0`, `rouge ~> 5.0`)
- Widened dev dependency constraints (`byebug ~> 13.0`, `rdoc < 9`, `capybara < 4`, `cucumber < 12`, `rspec >= 3.11`)
- Updated CI workflow actions (checkout, upload-artifact)
- Registered a custom headless Chrome driver with 1920x1080 viewport to fix cucumber tests on small windows

## [1.1.5] - 2024-02-15

- Bumped required Ruby version to 3.0.6
- Updated gem dependencies
 
## [1.1.4] - 2022-07-22

- Added a row for totals to the Report Overview table
- Switched to using Cucumber for integration tests

## [1.1.3] - 2022-04-12

- Reports can generated using a selected theme
- Added 2 new themes that can be selected
- Created a helper to process theme selection
- Updated the readme with instructions on how to change the theme

## [1.1.2] - 2022-04-08

- Fixed an issue where if there are specs that have the same description a result now appears for each spec rather than
  just one
- Created integration tests for the duplicate specs and overview

## [1.1.1] - 2022-03-21

- Updated readme

## [1.1.0] - 2022-03-21

- Added a report table for each of the individual example files
- Updated theme to Boostrap 4
- Added darkly, materia and spacelab themes
- Updated chartjs to 3.7.1

## [1.0.4] - 2022-02-22

- Updated Gems
- Updated the Ruby version to 2.7.5
- Small changes to the formatter
- Added details to the gemspec file
- Refactored code to remove deprecation warnings
