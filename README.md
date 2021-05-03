# Vitals Image

Vitals Image is a lib that makes it easier to create image tags that follow best practices for fast loading web pages in rails projects. It does that by adding a new view helper (`vitals_image_tag`) that can take a string or an active storage attachment and automatically set width, height and a few other recommended attributes.

This gem was extracted from FestaLab's app and replaced the original code ([see it in action](https://festalab.com.br/modelo-de-convite?referer=github)).

[![vitals-image-main](https://github.com/FestaLab/vitals_image/actions/workflows/main.yml/badge.svg)](https://github.com/FestaLab/vitals_image/actions/workflows/main.yml)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vitals_image'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install vitals_image

## Usage


## Configuration
The following configuration options are available. The defaults were chosen for maximum compatibility and least surprises, while the values under "Recommended" are what the app from which this gem was extracted uses. 

| Options                         | Default        | Recommended             | Description |
| --------------------------------|----------------|-------------------------|-------------|
| image_library                   | `:mini_magick` | `:vips`                 | The image library that will be used to analyze and optimize images. While `mini_magick` is available in most PaaS and CIs, `vips` is faster and uses less resources. |
| mobile_width                    | `:original`    | `410`                   | If set to a number, active storage images will be automatically downsized to `mobile_width * resolution` if no `width` is given. `410` should cover all mobile phones currently available. To determine the type of device of the user, `request.variant` will be used. If it is not set, it will use an internal algorithm for that. |  
| desktop_width                   | `:original`    | Your css grid width     | Same as `mobile_width`, but for desktop. I recommend you use the width of your CSS Grid as the value. |
| resolution                      | `2`            | `2`                     | The resolution that downsized images will have. While some phones are capable of `3` or `4`, `2` should be [good enough for most people](https://blog.twitter.com/engineering/en_us/topics/infrastructure/2019/capping-image-fidelity-on-ultra-high-resolution-devices.html) |
| lazy_loading                    | `:native`      | `:lozad` or `:lazyload` | If left at `:native`, the tags `loading` and `decoding` will be added. Otherwise, the value of this option will be added to the `class` attribute and `src` moved to `data-src`. I recommend either [lozad](https://apoorv.pro/lozad.js/) or [lazysizes](https://github.com/aFarkas/lazysizes)
| lazy_loading_placeholder        | Blank GIF      | Blank GIF               | When using a lazy load library, this image will be used as the placeholder in the `src` attribute so that users don't see a broken image. See it [here](https://github.com/FestaLab/vitals_image/blob/main/lib/vitals_image/engine.rb#L36). |
| require_alt_attribute           | `false`        | `true`                  | Will raise in exception if the `alt` attribute is not supplied to the helper. Useful to ensure no one ever forgets it again. |
| replace_active_storage_analyzer | `false`        | `true`                  | Requires `image_library = :vips`. This will replace Active Storage's default `image_analyzer` with one that uses `vips`, making it faster and less resource hungry. |
| check_for_white_background      | `false`        | `true`                  | Requires `image_library = :vips`. Same as above, but the analyzer will also try to deduce if the image is a photo, or a product on a white background. This will help define if `resize_to_limit` or `resize_and_pad` should be used when you supply both `width` and `height` to the helper. |
| convert_to_jpeg                 | `false`        | `true`                  | If set to `true`, images will be converted to JPEG, unless the keyword `alpha: true` was used in the helper. |
| jpeg_conversion                 | see below      | see below               | Hash of options to pass to active storage when converting other image formats to JPEG and optimizing. |
| jpeg_optimization               | see below      | see below               | Hash of options to pass to active storage when optimizing a JPEG. |
| png_optimization                | see below      | see below               | Hash of options to pass to active storage when optimizing a PNG. |
| active_storage_route            | `:inherited`   | `:inherited`            | Defines how urls of active storage images will be generated. If `inherited` it will use the same as active storage. Other valid options are `redirect`, `proxy` and `public`. Whatever is set here can be overriden in the helper. |

```ruby
# jpeg_conversion
{ sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80, format: "jpg", background: :white, flatten: true, alpha: :off }

# jpeg_optimization:
{ sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80 }

# png_optimization:
{ strip: true, quality: 00 }
```

These can be configured in your environment files, just like any other rails settings:

```
Rails.application.configure do |config|
  config.vitals_image.image_library = :vips
  config.vitals_image.mobile_width = 410
  config.vitals_image.desktop_width = 1264
  config.vitals_image.lazy_loading = :lozad
  config.vitals_image.require_alt_attribute = true
  config.vitals_image.check_for_white_background = true
  config.vitals_image.convert_to_jpeg = true
end
```

Heads up! If you are already on Rails 7.0.0.alpha, make sure you are not using  `image_decoding` and `image_loading` config options below, as they will forcibly add native lazy loading and async decoding to the tags.

### TODO

- Check ACCEPT headers and serve modern file formats if possible (webp and avif)
- Add support for `srcset`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FestaLab/vitals_image. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/FestaLab/vitals_image/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the VitalsImage project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/FestaLab/vitals_image/blob/main/CODE_OF_CONDUCT.md).
