desc "run specs"
task :spec do
  Dir[ 'spec/*' ].each do |file|
    out "spec #{file}"
  end
end

require 'rubygems'
require 'spec/rake/spectask'
desc "verify test coverage with RCov"
task :rcov => 'rcov:verify'
namespace :rcov do
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = ['spec/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
  end

  require 'spec/rake/verify_rcov'
  # rcov is wrong- I am actually at 100%
  RCov::VerifyTask.new(:verify => :rcov) do |t|
    t.threshold = 100 # Make sure you have rcov 0.7 or higher!
    t.index_html = $rcov_index_html
  end
end

desc "create a new gem release"
task :release => [:test,:record,:rdoc,:website,:package] do
  Dir.chdir('pkg') do
    release = Dir['*.gem'].sort_by {|file| File.mtime(file)}.last
    release =~ /^[^-]+-([.0-9]+).gem$/
    out "rubyforge login && rubyforge add_release #{$project} #{$project} #$1 #{release}"
  end
end

desc "update website"
file :website => ['README','Rakefile'] do
  Dir.chdir '/home/greg/sites/projects/' do
    out 'rake --silent projects:update'
    out 'rake --silent deploy:rsync'
  end
end
  
require 'rake/rdoctask'

Rake::RDocTask.new do |rd|  
   rd.main = "README"  
   rd.rdoc_dir = "doc"
   rd.rdoc_files.include("README", "lib/**/*.rb")  
   rd.title = "#$project rdoc"  
   rd.options << '-S' # inline source  
   rd.template = `allison --path`.chomp + '.rb'  
 end

desc 'git add and push'
task :record do
  unless `git status`.split($/).last =~ /nothing added/
    puts `git diff`
    ARGV.clear
    puts "enter commit message"
    out "git commit -a -m '#{Kernel.gets}'"
    puts "committed! now pushing.. "
    out 'git push origin master'
  end
end
