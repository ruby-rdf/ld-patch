source "http://rubygems.org"

gemspec

gem 'rdf', git: "git://github.com/ruby-rdf/rdf.git", branch: "develop"
gem 'ebnf', git: "git://github.com/gkellogg/ebnf.git", branch: "develop"

group :debug do
  gem "wirble"
  gem "byebug", platforms: :mri
end

group :development, :test do
  gem "rdf-vocab",      git: "git://github.com/ruby-rdf/rdf-vocab.git", branch: "develop"
  gem 'rdf-turtle',     git: "git://github.com/ruby-rdf/rdf-turtle.git", branch: "develop"
  gem 'rest-client-components'
  gem 'simplecov',  require: false
  gem 'coveralls',  require: false
  gem 'psych',      platforms: [:mri, :rbx]
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
  gem 'json'
end
