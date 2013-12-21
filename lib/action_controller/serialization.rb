require 'active_support/core_ext/class/attribute'

module ActionController
=begin rdoc

Serializers integrate with Rails' +ActionController+ overriding the JSON
renderer so that calls to <tt>ActionController::Base#render</tt> use a
serializer instance instead of <tt>Object#to_json</tt>.

For example:

    class PostsController < ApplicationController
      def show
        @post = Post.find params[:id]
        render json: @post # serialize using PostSerializer
      end
    end

The above +render+ call uses a +PostSerializer+ instance to generate JSON.

By default, the +PostSerializer+ class is inferred from the <tt>@post</tt>
instance. If a matching serializer class can't be found, rendering falls back
to the default renderer. You can override the serializer class using a
<tt>:serializer</tt> option:

    class PostsController < ApplicationController
      def show
        @post = Post.find params[:id]
        render json: @post, serializer: OtherPostSerializer
      end
    end

Serializers also provide +ActionController+ with a convenience
+serialization_scope+ class method that allows specifying a method name to be
used as scope for the serializer. In most cases, applications will scope the
serialization to the current user:

   class ApplicationController < ActionController::Base
     serialization_scope :current_user
   end

If you need more complex scope rules, you can override the
+serialization_scope+ controller instance method instead:

   class ApplicationController < ActionController::Base
     private

     def serialization_scope
       current_user || guest_user
     end
   end

=end
  module Serialization
    extend ActiveSupport::Concern

    include ActionController::Renderers

    included do
      class_attribute :_serialization_scope
      self._serialization_scope = :current_user
    end

    module ClassMethods
      # Specify a method name to be used as +serialization_scope+ in
      # serializers.
      def serialization_scope(scope)
        self._serialization_scope = scope
      end
    end

    def _render_option_json(resource, options)
      serializer = build_json_serializer(resource, options)

      if serializer
        super(serializer, options)
      else
        super
      end
    end

    private

    def default_serializer_options
      {}
    end

    def serialization_scope
      _serialization_scope = self.class._serialization_scope
      send(_serialization_scope) if _serialization_scope && respond_to?(_serialization_scope, true)
    end

    def build_json_serializer(resource, options)
      options = default_serializer_options.merge(options || {})

      if serializer = options.fetch(:serializer, ActiveModel::Serializer.serializer_for(resource))
        options[:scope] = serialization_scope unless options.has_key?(:scope)
        options[:resource_name] = self.controller_name if resource.respond_to?(:to_ary)

        serializer.new(resource, options)
      end
    end
  end
end
