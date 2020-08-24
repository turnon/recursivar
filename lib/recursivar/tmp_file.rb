class Recursivar

  class TmpFile
    def initialize(obj)
      name = [
        Time.now.strftime('%Y%m%d_%H%M%S_%L_'),
        obj.class.to_s.split('::').map(&:downcase).join('_'),
        '_',
        obj.object_id,
        '.html',
      ].join

      @path = File.join(Dir.tmpdir, name)
    end

    def puts(*content)
      File.open @path, 'a' do |f|
        f.puts *content
      end
    end
  end

end
