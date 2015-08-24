#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = "ld-patch"
  gem.homepage           = "http://github.com/ruby-rdf/ld-patch"
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = "W3C Linked Data Patch Format for RDF.rb."
  gem.rubyforge_project  = 'ld-patch'

  gem.authors            = ['Gregg Kellogg']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS README.md LICENSE VERSION bin/ldpatch) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)
  gem.has_rdoc           = false
  gem.description        = %(
    Implements the W3C Linked Data Patch Format and operations for RDF.rb.
    Makes use of the SPARQL gem for performing updates)

  gem.required_ruby_version      = '>= 2.0.0'
  gem.requirements               = []
  gem.add_runtime_dependency     'rdf',               '~> 1.1', '>= 1.1.15'
  gem.add_runtime_dependency     'ebnf',              '~> 0.3', '>= 0.3.9'
  gem.add_runtime_dependency     'sparql',            '~> 1.1', '>= 1.1.7'
  gem.add_runtime_dependency     'sxp',               '~> 0.1'
  gem.add_runtime_dependency     'rdf-xsd',           '~> 1.1'

  gem.add_development_dependency 'rack',              '~> 1.6'
  gem.add_development_dependency 'linkeddata',        '~> 1.1'
  gem.add_development_dependency 'rdf-spec',          '~> 1.1'
  gem.add_development_dependency 'open-uri-cached',   '~> 0.0', '>= 0.0.5'
  gem.add_development_dependency 'rspec',             '~> 3.2.0'
  gem.add_development_dependency 'rspec-its',         '~> 1.2'
  gem.add_development_dependency 'yard' ,             '~> 0.8'
  gem.add_development_dependency 'webmock',           '~> 1.17'

  gem.post_install_message       = nil
end
