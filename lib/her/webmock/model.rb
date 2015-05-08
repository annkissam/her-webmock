require 'her/webmock'
require 'webmock'
require 'json'

module Her
  module WebMock
    module Helper
      def self.attributes_without_embedded_associations(object)
        attributes = object.attributes.dup

        object.class.associations.each do |type, association_metadata_ary|
          association_metadata_ary.each do |association_metadata|
            association = attributes.delete(association_metadata[:name])

            attributes[association_metadata[:foreign_key]] = association.id if association
          end
        end

        attributes
      end
    end

    module Model
      include ::WebMock::API

      def default_headers
        WebMock.config.default_request_test_headers
      end

      def stub_associations(object)
        object.class.associations.each do |type, association_metadata_ary|
          association_metadata_ary.each do |association_metadata|
            association = object.attributes[association_metadata[:name]]

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

      def stub_find(object, options = {})
        model_class = object.class

        response = {
          model_class.parsed_root_element => Helper.attributes_without_embedded_associations(object)
        }

        request_stub = stub_request(:get, model_class.use_api.base_uri + object.request_path).
          to_return(body: JSON.generate(response), status: 200)

        request_params = {}

        query_hash = options.fetch(:query, {})
        request_params[:query] = query_hash unless query_hash.empty?

        headers_hash = default_headers.merge(options.fetch(:headers, {}))
        request_params[:headers] = headers_hash unless headers_hash.empty?

        request_stub.with(request_params) unless request_params.empty?

        stub_associations(object)
      end

      def stub_all(collection, options = {})
        model_class = collection.first.class

        collection_attributes = collection.map { |object| Helper.attributes_without_embedded_associations(object) }
        response = {
          model_class.pluralized_parsed_root_element => collection_attributes
        }

        request_stub = stub_request(:get, model_class.use_api.base_uri + model_class.collection_path).
          to_return(body: JSON.generate(response), status: 200)

        request_params = {}

        query_hash = options.fetch(:query, {})
        request_params[:query] = query_hash unless query_hash.empty?

        headers_hash = default_headers.merge(options.fetch(:headers, {}))
        request_params[:headers] = headers_hash unless headers_hash.empty?

        request_stub.with(request_params) unless request_params.empty?

        collection.each { |object| stub_associations(object) }
      end
    end
  end
end
