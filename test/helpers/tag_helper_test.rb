# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class TagHelperTest < ActionView::TestCase
    test "it works for blank without lazy load" do
      with_lazy_loading_set_to(nil) do
        assert_dom_equal '<img class="vitals-image" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />', vitals_image_tag(nil)
      end

      with_lazy_loading_set_to(:native) do
        assert_dom_equal '<img class="vitals-image" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />', vitals_image_tag(nil)
      end

      with_lazy_loading_set_to(:lozad) do
        assert_dom_equal '<img class="vitals-image" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />', vitals_image_tag(nil)
      end
    end

    test "it works for unanalyzed urls" do
      with_lazy_loading_set_to(nil) do
        assert_dom_equal '<img class="vitals-image" src="https://festalab-fixtures.s3.amazonaws.com/cat.jpg" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/cat.jpg")
      end

      with_lazy_loading_set_to(:native) do
        assert_dom_equal '<img class="vitals-image" loading="lazy" decoding="async" src="https://festalab-fixtures.s3.amazonaws.com/cat.jpg" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/cat.jpg")
      end

      with_lazy_loading_set_to(:lozad) do
        assert_dom_equal '<img class="lozad vitals-image" data-src="https://festalab-fixtures.s3.amazonaws.com/cat.jpg" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/cat.jpg")
      end
    end

    test "it works for analyzed urls" do
      with_lazy_loading_set_to(nil) do
        assert_dom_equal '<img width="1401" height="2102" style="height:auto;" class="vitals-image" src="https://festalab-fixtures.s3.amazonaws.com/dog.jpg" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/dog.jpg")
      end

      with_lazy_loading_set_to(:native) do
        assert_dom_equal '<img width="1401" height="2102" style="height:auto;" class="vitals-image" loading="lazy" decoding="async" src="https://festalab-fixtures.s3.amazonaws.com/dog.jpg" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/dog.jpg")
      end

      with_lazy_loading_set_to(:lozad) do
        assert_dom_equal '<img width="1401" height="2102" style="height:auto;" class="lozad vitals-image" data-src="https://festalab-fixtures.s3.amazonaws.com/dog.jpg" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/dog.jpg")
      end
    end

    test "it works for unanalyzed variable blobs without lazy load" do
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: false })

      with_lazy_loading_set_to(nil) do
        assert_dom_equal %{<img class="vitals-image" src="#{url_for(blob)}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:native) do
        assert_dom_equal %{<img class="vitals-image" loading="lazy" decoding="async" src="#{url_for(blob)}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:lozad) do
        assert_dom_equal %{<img class="lozad vitals-image" data-src="#{url_for(blob)}" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />}, vitals_image_tag(blob)
      end
    end

    test "it works for analyzed variable blobs without lazy load" do
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: true, width: 100, height: 100 })
      optimizer = VitalsImage::Base.optimizer(blob)
      url = vitals_image_url(optimizer.src, optimizer.html_options)

      with_lazy_loading_set_to(nil) do
        assert_dom_equal %{<img width="100" height="100" style="height:auto;" class="vitals-image" src="#{url}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:native) do
        assert_dom_equal %{<img width="100" height="100" style="height:auto;" class="vitals-image" loading="lazy" decoding="async" src="#{url}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:lozad) do
        assert_dom_equal %{<img width="100" height="100" style="height:auto;" class="lozad vitals-image" data-src="#{url}" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />}, vitals_image_tag(blob)
      end
    end

    test "it works for unanalyzed invariable blobs without lazy load" do
      blob = create_file_blob(filename: "icon.svg", content_type: "image/svg+xml", metadata: { analyzed: false })

      with_lazy_loading_set_to(nil) do
        assert_dom_equal %{<img class="vitals-image" src="#{url_for(blob)}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:native) do
        assert_dom_equal %{<img class="vitals-image" loading="lazy" decoding="async" src="#{url_for(blob)}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:lozad) do
        assert_dom_equal %{<img class="lozad vitals-image" data-src="#{url_for(blob)}" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />}, vitals_image_tag(blob)
      end
    end

    test "it works for analyzed invariable blobs without lazy load" do
      blob = create_file_blob(filename: "icon.svg", content_type: "image/svg+xml", metadata: { analyzed: true, width: 100, height: 100 })
      optimizer = VitalsImage::Base.optimizer(blob)
      url = vitals_image_url(optimizer.src, optimizer.html_options)

      with_lazy_loading_set_to(nil) do
        assert_dom_equal %{<img width="100" height="100" style="height:auto;" class="vitals-image" src="#{url}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:native) do
        assert_dom_equal %{<img width="100" height="100" style="height:auto;" class="vitals-image" loading="lazy" decoding="async" src="#{url}" />}, vitals_image_tag(blob)
      end

      with_lazy_loading_set_to(:lozad) do
        assert_dom_equal %{<img width="100" height="100" style="height:auto;" class="lozad vitals-image" data-src="#{url}" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />}, vitals_image_tag(blob)
      end
    end

    test "that different route strategies can be used" do
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: false })

      assert_equal %{<img class="vitals-image" loading="lazy" decoding="async" src="#{rails_storage_redirect_path(blob)}" />}, vitals_image_tag(blob, active_storage_route: :redirect)
      assert_equal %{<img class="vitals-image" loading="lazy" decoding="async" src="#{rails_storage_proxy_path(blob)}" />}, vitals_image_tag(blob, active_storage_route: :proxy)
    end

    private
      def with_lazy_loading_set_to(value)
        previous_option = VitalsImage.lazy_loading
        VitalsImage.lazy_loading = value

        yield
      ensure
        VitalsImage.lazy_loading = previous_option
      end
  end
end
