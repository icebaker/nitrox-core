# frozen_string_literal: true

require_relative 'static/spec'

Gem::Specification.new do |spec|
  spec.name    = Static::SPEC[:name]
  spec.version = Static::SPEC[:version]
  spec.authors = [Static::SPEC[:author]]

  spec.summary = Static::SPEC[:summary]
  spec.description = Static::SPEC[:description]

  spec.homepage = Static::SPEC[:github]

  spec.license = Static::SPEC[:license]

  spec.required_ruby_version = Gem::Requirement.new('>= 3.2.0')

  spec.metadata['allowed_push_host'] = Static::SPEC[:gem_server]

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = Static::SPEC[:github]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end

  spec.require_paths = ['ports/dsl']

  spec.add_dependency 'lighstorm', '~> 0.0.15'
  spec.add_dependency 'dalli', '~> 3.2', '>= 3.2.4'
  spec.add_dependency 'faraday', '~> 2.7', '>= 2.7.4'
  spec.add_dependency 'rainbow', '~> 3.1', '>= 3.1.1'
  spec.add_dependency 'rdkafka', '~> 0.13.0.beta.3'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
