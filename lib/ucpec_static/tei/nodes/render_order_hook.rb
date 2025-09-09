# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      # @api private
      class RenderOrderHook < Module
        include Dry::Initializer[undefined: false].define -> do
          param :base, Types::Symbol

          option :hook, Types::Symbol, default: proc { :"#{base}!" }

          option :order_attr, Types::Symbol, default: proc { :"#{base}_order" }
          option :before_predicate, Types::Symbol, default: proc { :"#{base}_before_content?" }
          option :after_predicate, Types::Symbol, default: proc { :"#{base}_after_content?" }
          option :skip_predicate, Types::Symbol, default: proc { :"skip_#{base}?" }

          option :order_hook, Types::Symbol, default: proc { :"#{base}_in_order!" }
        end

        def initialize(...)
          super

          @klass_methods = KlassMethods.new(self)

          add_methods!
        end

        def included(klass)
          super

          klass.defines order_attr, type: Types::RenderOrder

          klass.__send__(order_attr, :after_content)

          klass.extend @klass_methods

          klass.define_model_callbacks base

          klass.around_html_content order_hook
        end

        private

        # @return [void]
        def add_methods!
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{order_attr}
            self.class.#{order_attr}
          end

          def #{before_predicate}
            #{order_attr} == :before_content
          end

          def #{after_predicate}
            #{order_attr} == :after_content
          end

          def #{skip_predicate}
            #{order_attr} == :skip
          end

          def #{order_hook}
            # :nocov:
            return yield if #{skip_predicate}
            # :nocov:

            #{hook} if #{before_predicate}

            yield

            #{hook} if #{after_predicate}
          end
          RUBY
        end

        class KlassMethods < Module
          include Dry::Initializer[undefined: false].define -> do
            param :origin, Types.Instance(RenderOrderHook)

            option :before_dsl, Types::Symbol, default: proc { :"#{base}_before_content!" }
            option :after_dsl, Types::Symbol, default: proc { :"#{base}_after_content!" }
            option :skip_dsl, Types::Symbol, default: proc { :"skip_#{base}!" }
          end

          delegate :base, :order_attr, to: :origin

          def initialize(...)
            super

            add_methods!
          end

          private

          # @return [void]
          def add_methods!
            class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{before_dsl}
              #{order_attr} :before_content
            end

            def #{after_dsl}
              #{order_attr} :after_content
            end

            def #{skip_dsl}
              #{order_attr} :skip
            end
            RUBY
          end
        end
      end
    end
  end
end
