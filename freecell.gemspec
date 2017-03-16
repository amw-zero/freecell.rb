# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'freecell/version'

Gem::Specification.new do |spec|
  spec.name          = "freecell"
  spec.version       = Freecell::VERSION
  spec.authors       = ["Alex Weisberger"]
  spec.email         = ["alex.m.weisberger@gmail.com"]

  spec.summary       = %q{Freecell Solitaire CLI}
  spec.description   = %q{Clone of the ncurses freecell version: https://www.linusakesson.net/software/freecell.php}
  spec.homepage      = "http://www.freecell.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["freecell"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "curses"
end
