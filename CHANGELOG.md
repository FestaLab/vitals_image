## [Unreleased]

## [0.5]

- Add `domains` config to allow limiting from which domains images will be analyzed
- User `after_commit` to enqueued analyze job

## [0.4.1] - 2021-07-22

- Do not discard the specified `style` attribute

## [0.4.0] - 2021-07-06

- Fixed resize and pad in vips
- Fixed image quality in vips
- Reduced JPEG quality from 85 to 80
- Removed optimal quality
- Updated Vitals Image to 0.5

## [0.3.0] - 2021-05-22

- Redo the image helper
- Redo the active storage optimizer 

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
