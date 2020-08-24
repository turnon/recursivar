require "recursivar/version"
require "recursivar/tmp_file"
require "recursivar/formats"
require "binding_of_callers"

class Object
  def recursivar(**opt)
    Recursivar.new(binding.of_callers, opt).print
  end
end

class Recursivar

  class Var
    attr_reader :name, :klass, :obj, :ref, :vars, :location

    def initialize(name, obj, loc, seen)
      @name = name
      @klass = obj.class
      @obj = obj
      @vars = []
      @location = loc

      obj_id = obj.object_id
      return if @ref = seen[obj_id]
      seen[obj_id] = self

      klass = self.class
      obj.instance_variables.map do |name|
        value = obj.instance_variable_get(name)
        place = (location.dup << name)
        @vars << klass.new(name, value, place, seen)
      end
    end

    def location_str
      location.join(' > ')
    end
  end

  class Heap

    class Value
      attr_reader :obj, :values

      def initialize(obj)
        @obj = obj
        @values = {}
      end

      def inspect
        @inspect ||= "#<#{@obj.class}:#{@obj.object_id}>"
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

  attr_reader :start

  def initialize(stack, out: false, name: nil, format: :Html)
    if stack && false
      heap = Heap.new(stack)
      p heap.count

      heap.each do |v|
        p "#{v.inspect}"
        v.values.each_pair do |name, v|
          p " -- #{name} #{v.inspect}"
        end
      end
    end

    obj = stack.first.send(:binding_self)

    name ||= "#<#{obj.object_id}>"

    var_klass = Var.clone
    var_klass = var_klass.include Formats.const_get(format)

    @start = var_klass.new(name, obj, ['#'], {})
    @out = out || TmpFile.new(obj, format)
  end

  def print
    @out.puts start.to_s
  end

end
