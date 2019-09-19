# frozen_string_literal: true


lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buddy_translatable/version'

Gem::Specification.new do |spec|
  spec.name          = 'buddy_translatable'
  spec.version       = BuddyTranslatable::VERSION
  spec.authors       = ['Owen']
  spec.email         = ['owenperedo@gmail.com']

  spec.summary       = 'Manages translations and sales data fields'
  spec.description   = 'Manages translations and sales data fields'
  spec.homepage      = 'https://github.com/owen2345/buddy_translatable'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  #   into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'activerecord', '>= 5.0'
  spec.add_dependency 'activesupport', '>= 5.0'
  spec.add_dependency 'i18n'
  spec.add_dependency 'pg'
end
