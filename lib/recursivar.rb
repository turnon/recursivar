require "recursivar/version"
require "recursivar/tmp_file"
require "recursivar/formats"

class Object
  def recursivar(**opt)
    Recursivar.new(self, opt).print
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

  attr_reader :start

  def initialize(obj, out: false, name: nil, format: :Html)
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
