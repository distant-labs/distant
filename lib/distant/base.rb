
module Distant
  class ApiError < StandardError; end
  class Base

    def initialize(attrs={})
      attrs.each do |key, val|
        send "#{key}=", val
      end
    end

    def self.inherited(klass)
      klass.extend(ClassMethods)
      klass.init_class_vars
    end

    def connection
      self.class.connection
    end

    def has_many?(plural)
      self.class.has_many_rels.include? plural.to_sym
    end

    def belongs_to?(singular)
      self.class.belongs_to_rels.include? singular.to_sym
    end

    module ClassMethods
      def init_class_vars
        @has_many = [ ]
        @belongs_to = [ ]
        @translator = Distant::Translator.new
      end

      def connection
        @@connection ||= Distant::Connection.configure( Distant.config )
      end

      def has_many_rels
        @has_many
      end

      def belongs_to_rels
        @belongs_to
      end

      def marshal(data)
        self.new(data)
      end

      def get(name, route)
        define_singleton_method(name) do |*args|
          path_generator, captures = self.path_closure_generator(route)
          path = path_generator.call(*args)
          headers = Distant.config.default_headers('')
                      .merge(Distant.config.auth_headers(''))
          response_data = preprocess_response connection.get(path, headers: headers)
          if response_data.is_a? Array
            response_data.map{ |item| marshal(item) }
          else
            marshal(response_data)
          end
        end
      end

      def has_many(plural, route)
        @has_many << plural.to_sym
        define_method(plural) do
          path_generator, captures = self.class.path_closure_generator(route)
          path_args = captures.map{|x| {x.to_sym => send(x)}}.reduce({}, :merge)
          path = path_generator.call(path_args)
          headers = Distant.config.default_headers('')
                      .merge(Distant.config.auth_headers(''))
          class_ref = Kernel.const_get self.class.to_s.deconstantize + '::' + plural.to_s.singularize.classify
          response_data = class_ref.preprocess_response connection.get(path, headers: headers)
          response_data.map{ |item| class_ref.marshal(item) }
        end
      end

      def belongs_to(singular, route)
        @belongs_to << singular.to_sym
        define_method(singular) do
          foreign_key_attr = singular.to_s + '_id'
          foreign_key_value = self.send(foreign_key_attr)
          path_generator, captures = self.class.path_closure_generator(route)
          path_args = captures.map{|x| {x.to_sym => send(x)}}.reduce({}, :merge)
          path = path_generator.call(path_args)
          headers = Distant.config.default_headers('')
                      .merge(Distant.config.auth_headers(''))
          class_ref = Kernel.const_get self.class.to_s.deconstantize + '::' + singular.to_s.classify
          response_data = class_ref.preprocess_response connection.get(path, headers: headers)
          class_ref.marshal(response_data)
        end
      end

      def path_closure_generator(route)
        # Look for /foo/:bar/:bux and return ['bar', 'bux']
        captures = route.scan(%r{:([^/\{\}\:\-]+)}).flatten

        # Look for /foo/:bar/:bux and return '/foo/%{bar}/%{bux}'
        template = route.gsub(%r{:([^/\{\}\:\-]+)}, "%{#{$1}}")

        # Convert '/foo/%{bar}/%{bux}' to /foo/123/456 with {bar: 123, bux: 456}
        proc = class_eval <<-EOF
          Proc.new do |#{captures.map{|cap| "#{cap}:"}.join(', ')}|
            template % {
              #{captures.map{ |cap| cap + ": " + cap }.join(', ')}
            }
          end
        EOF

        return proc, captures
      end

      def preprocess_response(response)
        case response.code
        when 200..299
          parsed = JSON.parse(response.body, symbolize_names: true)
          parsed.is_a?(Array) ?
            parsed.map{ |item| translator.translate_from_hash(item) }
            : translator.translate_from_hash(parsed)
        else
          raise Distant::ApiError.new response
        end
      end

      def translator
        @translator
      end

      def translate(&block)
        @translator = Distant::Translator.new
        translator.instance_eval(&block)
      end
    end

  end
end
