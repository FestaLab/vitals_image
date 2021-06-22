## [Unreleased]

## [0.2.1] - 2021-05-22

- Do not attempt to transform invariable images

## [0.2.0] - 2021-05-18

- Use the `optimal_quality` value of blob metadata instead of fixed `85` if its available;
- Remove some unecessary configs;
- Drop analyzers and use `active_analysis` gem instead;
- Use "retry once" strategy instead of `create_or_find_by`; 
- Fix 'can't be referred' error;
- Do not cache development unless cache is enabled;

## [0.1.1] - 2021-05-05

- Relax dependencies

## [0.1.0] - 2021-05-01

- Initial release
