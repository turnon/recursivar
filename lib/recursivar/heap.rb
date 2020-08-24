class Recursivar

  class Heap

    class Value
      attr_reader :obj, :values

      def initialize(obj)
        @obj = obj
        @values = {}
      end

      def inspect
        @inspect ||= "#<#{klass}:#{@obj.object_id}>"
      end

      def klass
        @klass ||= @obj.class
      end

      def ref_instance_variables(heap)
        return if @referred
        @referred = true

        obj.instance_variables.each do |name|
          value = obj.instance_variable_get(name)
          @values[name] = heap.ref(value)
        end
      end
    end

    attr_reader :heap

    def initialize(stack)
      @heap = {}

      stack.each do |callor|
        local_values = {}
        callor.lv.each_pair do |name, obj|
          local_values[name] = ref(obj)
        end

        callor_v = wrap_caller(callor)
        callor_v.values.merge!(local_values)
      end
    end

    def wrap_caller(callor)
      callor_obj = callor.send(:binding_self)
      ref(callor_obj)
    end

    def ref(obj)
      v = (@heap[obj.object_id] ||= Value.new(obj))
      v.ref_instance_variables(self)
      v
    end

    include Enumerable

    def each
      @heap.each_pair{ |_, v| yield(v) }
    end
  end

end
