require 'her/webmock'
require 'webmock'
require 'json'

module Her
  module WebMock
    module Helper
      def self.attributes_without_embedded_associations(klass, object)
        attributes = object.respond_to?(:attributes) ? object.attributes.dup : object.dup

        klass.associations.each do |type, association_metadata_ary|
          association_metadata_ary.each do |association_metadata|
            association = attributes.delete(association_metadata[:name])

            attributes[association_metadata[:foreign_key]] = association.id if association
          end
        end

        attributes
      end

      def self.request_params(options = {})
        request_params = {}

        request_params[:query] = options[:query]

        headers_hash = default_headers.merge(options.fetch(:headers, {}))
        request_params[:headers] = headers_hash unless headers_hash.empty?

        request_params
      end

      def self.default_headers
        WebMock.config.default_request_test_headers
      end
    end

    module Model
      include ::WebMock::API

      def stub_associations(klass, object)
        attributes = object.respond_to?(:attributes) ? object.attributes : object

        klass.associations.each do |type, association_metadata_ary|
          association_metadata_ary.each do |association_metadata|
            association = attributes[association_metadata[:name]]

            if association
              case type
              when :belongs_to
                Object.const_get(association_metadata[:class_name]).stub_find(association)
              else
                # TODO
                fail NotImplementedError
              end
            end
          end
        end
      end

      def stub_create(object, options = {})
        model_class = self
        attributes = object.is_a?(Her::Model) ? Helper.attributes_without_embedded_associations(model_class, object) : object

        fail "Must pass in an object with an id attribute" unless attributes[:id]

        if model_class.parsed_root_element
          response = {
            model_class.parsed_root_element => attributes
          }
        else
          response = attributes
        end

        attributes_without_id = attributes.except(:id)

        request_stub = stub_request(:post, model_class.use_api.base_uri + model_class.build_request_path(attributes_without_id)).
          to_return(body: JSON.generate(response), status: 200)

        request_params = Helper.request_params(options)
        request_stub.with(request_params) unless request_params.empty?

        if options[:stub_related]
          stub_find(object)
          stub_all([object])
        end

        stub_associations(model_class, object)

        request_stub
      end

      def stub_find(object, options = {})
        model_class = self
        attributes = object.is_a?(Her::Model) ? Helper.attributes_without_embedded_associations(model_class, object) : object

        if model_class.parsed_root_element
          response = {
            model_class.parsed_root_element => attributes
          }
        else
          response = attributes
        end

        request_stub = stub_request(:get, model_class.use_api.base_uri + model_class.build_request_path(attributes)).
          to_return(body: JSON.generate(response), status: 200)

        request_params = Helper.request_params(options)
        request_stub.with(request_params) unless request_params.empty?

        stub_associations(model_class, object)

        request_stub
      end

      def stub_all(collection, options = {})
        model_class = self

        collection_attributes = collection.map { |object| Helper.attributes_without_embedded_associations(model_class, object) }
        response = {
          model_class.pluralized_parsed_root_element => collection_attributes
        }

        response = options[:response_body].merge(response) if options[:response_body]

        request_stub = stub_request(:get, model_class.use_api.base_uri + model_class.collection_path).
          to_return(body: JSON.generate(response), status: 200)

        request_params = Helper.request_params(options)
        request_stub.with(request_params) unless request_params.empty?

        collection.each { |object| stub_associations(model_class, object) }

        request_stub
      end
    end
  end
end
