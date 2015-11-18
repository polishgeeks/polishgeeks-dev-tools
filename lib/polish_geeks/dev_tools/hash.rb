module PolishGeeks
  module DevTools
    # Hash extensions required only by rake tasks in this rake file
    # No need to add them to app itself
    # We don't put it directly into hash, since it won't be used outside of
    # this gem
    class Hash < ::Hash
      # @param other [Hash] different hash that we want to compare with
      # @return [Boolean] true if both hashes have same keys and same keys structure
      def same_key_structure?(other)
        return false unless keys == other.keys &&
            keys.all? { |inside| inside.is_a?(Symbol) || inside.is_a?(String) }

        keys.all? do |inside|
          if self[inside].is_a?(::Hash)
            self.class.new.merge(self[inside]).same_key_structure?(other[inside])
          else
            !other[inside].is_a?(::Hash)
          end
        end
      end
    end
  end
end
