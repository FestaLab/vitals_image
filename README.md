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

Finally copy over the migration:

    $ bin/rails vitals_image:install:migrations

## Usage

### Basics 
The simplest usage for `vitals_image` is to replace a normal `image_tag` with it.

Before:
```rhtml
<%= image_tag "icon.svg" %>
<img src="icon.svg" />
```

After:
```rhtml
<%= vitals_image_tag "icon.svg" %>

<!-- First time the image is seem -->
<img src="icon.svg" loading="lazy" decoding="async" />

<!-- Second time the image is seem -->
<img src="icon.svg" width="20" height="40" loading="lazy" decoding="async" style="height: auto;" />
```

If the supplied source is an external url, or the url of an asset, `vitals_image` will, in a background job, download the image, analyze it and store its width and height, so that the next time it is seem, they can be applied, reducing the page's CLS. As for the extra tags:

- `loading`: setting it to `lazy` allows Chrome to lazy load images that are not in the viewport without the need for a lazy load library.
- `decoding`: another optimization similar to `loading`, which allows image to the decoded asynchronously.
- `style`: setting `height: auto` allows your CSS to choose a different `width` for your image (`width: 100%;`) while keeping its aspect ratio intact and still benefitting from no impact on the CLS

The same can be done with an active storage image:

Before:
```rhtml
<%= image_tag user.avatar %>
<img src="/rails/active_storage/blobs/redirect/(...).photo.jpeg" />
```

After:
```rhtml
<%= vitals_image_tag user.avatar %>

<!-- Before active storage has analyzed the image -->
<img src="/rails/active_storage/blobs/redirect/(...).photo.jpeg" loading="lazy" decoding="async" />

<!-- After active storage has analyzed the image -->
<img src="/rails/active_storage/blobs/redirect/(...).photo.jpeg" width="200" height="200" loading="lazy" decoding="async" style="height: auto;" />
```

### Setting width and height
You might however decide to use a different width or height for your images. No problem, give one dimension, and `vitals_image` will figure out the other.
```rhtml
<%= vitals_image_tag "icon.svg", width: 10 %>
<img src="icon.svg" width="10" height="20" loading="lazy" decoding="async" style="height: auto;" />
```

If you do the same in active storage, instead of the original image, you will get an optimized variant:
```rhtml
<%= vitals_image_tag user.avatar width: 100 %>
<img src="/rails/active_storage/representations/redirect/(...).photo.jpeg" width="100" height="100" loading="lazy" decoding="async" style="height: auto;" />
```

To see which optimizations will be applied (and change them if you wish, check the "Configuration" section.)

If you set both a width and a height and end up with a different aspect ratio than the image has, Vitals Image will make a "best guess" at what you want.

For an image from an url, which it cannot apply transformations to, it will use `object-fit`
```rhtml
<%= vitals_image_tag "icon.svg", width: 100, height: 40 %>
<img src="icon.svg" width="100" height="40" style="object-fit: contain" />
```

For an active storage image, it has two possible strategies for the resize:

- `resize_to_limit`: This is the default. Downsizes the image to fit within the specified dimensions while retaining the original aspect ratio. Will only resize the image if it's larger than the specified dimensions.
- `resize_and_pad`: This only be used if Vitals Image know that this image is an object in a white background. For that to work you must set `image_library = :vips` and `check_for_white_background = true` in your configuration. This will cause Vitals Image to replace the normal `analyze_job` that Active Storage uses, with a custom one that will add the attribute `isolated` to the blobs metadata,  

### Advanced options
You can disable lazy loading if you want:
```rhtml
<%= vitals_image_tag "icon.svg", lazy_load: false %>
<img src="icon.svg" width="20" height="40" style="height: auto;" />
```

You can also choose a different route strategy for active storage, than the one it uses by default:
```rhtml
<%= vitals_image_tag user.avatar, active_storage_route: :proxy %>
<img src="/rails/active_storage/representations/proxy/(...).photo.jpeg" width="100" height="100" loading="lazy" decoding="async" style="height: auto;" />
```

If you set the height, you will not get the `auto` added to it:
```rhtml
<%= vitals_image_tag "icon.svg", height: 20 %>
<img src="icon.svg" width="10" height="20" />
```



## Configuration
The following configuration options are available. The defaults were chosen for maximum compatibility and least surprises, while the values under "Recommended" are what the app from which this gem was extracted uses. 

| Options                         | Default        | Recommended             | Description |
| --------------------------------|----------------|-------------------------|-------------|
| image_library                   | `:mini_magick` | `:vips`                 | The image library that will be used to analyze and optimize images. While `mini_magick` is available in most PaaS and CIs, `vips` is faster and uses less resources. |
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

### Customization
If your use case requires it, you can easily add extra `optimizers` and `analyzers`, just like you would in Active Storage. Start by inheriting the abstract classes.

```ruby
class Base64ImageOptimizer < VitalsImage::Optimizer; end
class Base64ImageAnalyzer < VitalsImage::Analyzer; end
```

And them during config add them ahead of others:
```ruby
Rails.application.configure do |config|
  config.vitals_image.optimizers.prepend Base64ImageOptimizer
  config.vitals_image.analyzers.prepend Base64ImageAnalyzer
end
```

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
