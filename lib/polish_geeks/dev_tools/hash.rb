module PolishGeeks
  module DevTools
    #
    # We don't put it directly into Hash, since it won't be used
    # outside of this gem
    #
    class Hash < ::Hash
      # Compare hash with other Hash
      #
      def diff(other)
        diffs = {}

        if other.nil?
          diffs.merge! diff_as_array(keys, {})
        elsif different_keys_than?(other)
          different_keys = keys - other.keys | other.keys - keys
          diffs.merge! diff_as_array(different_keys, other)
        end
        each_nested_hash_key do |inside_key|
          inner_hash = self.class.new.merge(self[inside_key])
          inner_diff = inner_hash.diff(other[inside_key])
          diffs[inside_key] = inner_diff unless inner_diff.empty?
        end

        diffs
      end

      private

      # Returns Hash where values represents differences with other hash
      def diff_as_array(keys, other_hash)
        keys.each_with_object({}) do |key, result|
          result[key] = [self[key], other_hash[key]]
        end
      end

      # Yield all keys for which corresponding values are instances of Hash
      def each_nested_hash_key
        keys.each do |inside|
          yield(inside) if self[inside].is_a?(::Hash)
        end
      end

      # Returns true if keys are different that in other hash
      def different_keys_than?(other_hash)
        !(keys == other_hash.keys &&
          keys.all? { |inside| inside.is_a?(Symbol) || inside.is_a?(String) })
      end
    end
  end
end
