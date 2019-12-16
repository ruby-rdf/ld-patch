source "http://rubygems.org"

gemspec

gem 'rdf',  github: "ruby-rdf/rdf",  branch: "develop"
gem 'ebnf', github: "dryruby/ebnf",  branch: "develop"

group :debug do
  gem "byebug", platforms: :mri
end

group :development, :test do
  gem 'json-ld',            github: "ruby-rdf/json-ld",             branch: "develop"
  gem 'rdf-aggregate-repo', github: "ruby-rdf/rdf-aggregate-repo",  branch: "develop"
  gem 'rdf-isomorphic',     github: "ruby-rdf/rdf-isomorphic",      branch: "develop"
  gem 'rdf-spec',           github: "ruby-rdf/rdf-spec",            branch: "develop"
  gem "rdf-vocab",          github: "ruby-rdf/rdf-vocab",           branch: "develop"
  gem 'rdf-turtle',         github: "ruby-rdf/rdf-turtle",          branch: "develop"
  gem 'rdf-xsd',            github: "ruby-rdf/rdf-xsd",             branch: "develop"
  gem 'sparql',             github: "ruby-rdf/sparql",              branch: "develop"
  gem 'sparql-client',      github: "ruby-rdf/sparql-client",       branch: "develop"
  gem 'sxp',                github: "dryruby/sxp.rb",               branch: "develop"
  gem 'rest-client-components'
  gem 'simplecov',  platforms: :mri
  gem 'coveralls',  '~> 0.8', platforms: :mri
  gem 'psych',      platforms: [:mri, :rbx]
end
