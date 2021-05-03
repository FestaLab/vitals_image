# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class TagHelperTest < ActionView::TestCase
    test "that the image tag works for blank" do
      assert_dom_equal '<img class="vitals-image" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />', vitals_image_tag(nil)
    end

    test "that the image tag works for urls" do
      assert_dom_equal '<img class="vitals-image" loading="lazy" decoding="async" src="https://festalab-fixtures.s3.amazonaws.com/cat.jpg" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/cat.jpg")
    end

    test "that the image tag works for active_storage" do
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: false })
      assert_dom_equal %{<img class="vitals-image" loading="lazy" decoding="async" src="#{url_for(blob)}" />}, vitals_image_tag(blob)
    end

    test "that non native lazy image tag works for blank" do
      with_lazy_loading_set_to("lozad") do
        assert_dom_equal '<img class="vitals-image" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" />', vitals_image_tag(nil)
      end
    end

    test "that non native lazy image tag works for url" do
      with_lazy_loading_set_to("lozad") do
        assert_dom_equal '<img class="lozad vitals-image" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" data-src="https://festalab-fixtures.s3.amazonaws.com/cat.jpg" />', vitals_image_tag("https://festalab-fixtures.s3.amazonaws.com/cat.jpg")
      end
    end

    test "that non native lazy load image tag works for active_storage" do
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: false })

      with_lazy_loading_set_to("lozad") do
        assert_dom_equal %{<img class="lozad vitals-image" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" data-src="#{url_for(blob)}" />}, vitals_image_tag(blob)
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
