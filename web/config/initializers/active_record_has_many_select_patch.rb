# This patch just replace the line 11 with line 12.
# Calling scope.count with passing the :all parameter cause
# an error when using custom select in has_many associations

module ActiveRecord
  module Associations
    class HasManyAssociation < CollectionAssociation
      private
         def count_records
          count = if reflection.has_cached_counter?
            owner._read_attribute(reflection.counter_cache_column).to_i
          else
            # scope.count
            scope.count(:all)
          end
          (@target ||= []) && loaded! if count == 0
          [association_scope.limit_value, count].compact.min
        end
    end
  end
end
