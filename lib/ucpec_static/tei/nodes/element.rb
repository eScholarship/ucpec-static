# frozen_string_literal: true

module UCPECStatic
  module TEI
    module Nodes
      class Element < Abstract
        attribute :children, NodeList

        attribute :name, Types::String

        attribute? :content, Types::String.optional
      end
    end
  end
end
