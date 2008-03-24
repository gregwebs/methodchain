def exit_msg(msg, code=1)
  puts msg
  exit(code)
end
def run command
  res = `#{command}`
  exit_msg res, $?.exitstatus if $?.exitstatus != 0
  res
end
def out command
  (puts (run command))
end

def cd_tmp
  Dir.mkdir 'tmp' unless File.directory? 'tmp'
  Dir.chdir('tmp') do |dir|
    yield dir
  end
  rm_rf 'tmp'
end

class IO
  def self.write( file, str )
    self.open( file, 'w' ) { |fh| fh.print str }
  end
  def self.read_write( file, write_file=file )
    self.write(write_file, (yield( self.read( file ))))
  end
end

Dir.glob('tasks/*.rake').sort.each {|fn| import fn}
