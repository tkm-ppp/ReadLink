# -*- encoding: utf-8 -*-
# stub: schmooze 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "schmooze".freeze
  s.version = "0.2.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bouke van der Bijl".freeze]
  s.date = "2017-12-18"
  s.description = "Schmooze allows a Ruby library writer to succintly interoperate between Ruby and JavaScript code. It has a clever DSL to make this possible.".freeze
  s.email = ["bouke@shopify.com".freeze]
  s.homepage = "https://github.com/Shopify/schmooze".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.5.3".freeze
  s.summary = "Schmooze lets Ruby and Node.js work together intimately.".freeze

  s.installed_by_version = "3.5.3".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, ["~> 10.0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0".freeze])
end
