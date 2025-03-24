# -*- encoding: utf-8 -*-
# stub: japanese_address_parser 3.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "japanese_address_parser".freeze
  s.version = "3.2.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/yamat47/japanese_address_parser/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/yamat47/japanese_address_parser", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/yamat47/japanese_address_parser" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Yamaguchi Takuya".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-11-26"
  s.description = "JapaneseAddressParser is a Ruby gem that parses Japanese address. To detect the address, it uses geolonia/japanese-addresses (https://github.com/geolonia/japanese-addresses) CSV data.".freeze
  s.email = ["yamat47.thirddown@gmail.com".freeze]
  s.homepage = "https://github.com/yamat47/japanese_address_parser".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.5.3".freeze
  s.summary = "Japanese address parser written in Ruby.".freeze

  s.installed_by_version = "3.5.3".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<schmooze>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<activesupport>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<factory_bot>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop-rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<steep>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<typeprof>.freeze, [">= 0".freeze])
end
