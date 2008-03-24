$project = "methodchain"
$rcov_index_html = 'coverage/lib-methodchain-not_included_rb.html'

require 'tasks/helpers'

def __DIR__; "#{File.dirname(__FILE__)}" end

desc "test run all tests"
task :test => [:spec, 'readme:test']

namespace :readme do
  desc "create html for website using coderay, use --silent option"
  task :html do
    rm_rf 'doc'
    `rdoc --quiet README`
    require 'hpricot'
    require 'htmlentities'
    doc = open( 'doc/files/README.html' ) { |f| Hpricot(f) }
    # find example code
    doc.at('#description').search('pre').each do |ex|
      #select {|elem| elem.inner_html =~ /class |module /}.each do |ex|
      # add coderay and undo what rdoc has done in the example code
      ex.swap("<coderay lang='ruby'>#{HTMLEntities.new.decode ex.inner_html}</coderay>")
    end
    puts doc.at('#description').to_html
  end

  # run README through xmp
  desc "run README code through xmp filter"
  task :test do
    # grab example code from README
    cd_tmp do
      example_file = "#{Dir.pwd}/example.rb"

      File.write(example_file, (
        File.read("#{__DIR__}/lib/methodchain/not-included.rb") <<
        "class Object; include MethodChain end\n" <<
        File.readlines('../README').grep(/^  / ).
          reject {|l| l =~ /^\s*require/ or l.include?('Error') or l.include? 'gem install'}.
            join ))

      command = "ruby ../bin/xmpfilter -c #{example_file}"
      Dir.chdir '/home/greg/src/head/lib' do
        run "#{command}"
      end
      puts "README code successfully evaluated"
    end
  end
end

require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = $project
  s.rubyforge_project = $project
  s.version = "0.4.2"
  s.author = "Greg Weber"
  s.email = "greg@gregweber.info"
  s.homepage = "http://projects.gregweber.info/#{$project}"
  s.platform = Gem::Platform::RUBY
  s.summary = "convenience methods for method chaining"
  s.files =
  FileList.new('./**', '*/**', 'lib/methodchain/*') do |fl|
    fl.exclude('pkg','pkg/*','tmp','tmp/*', 'coverage', 'coverage/*')
  end
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
end
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = false
end
