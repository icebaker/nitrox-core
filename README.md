# Nitrox Core

Provides abstractions, common functions, and shared components for all [Nitrox](https://github.com/icebaker/nitrox) microservices.

Check the [Nitrox documentation](https://icebaker.github.io/nitrox) for more information.

## Usage

Add to your `Gemfile`:

```ruby
gem 'nitrox-core', git: 'git://github.com/icebaker/nitrox-core.git'
```

```ruby
require 'nitrox-core'

puts NitroxCore.version # => 0.0.1
```

## Development

```ruby
# Gemfile
gem 'nitrox-core', path: '../nitrox-core'

# demo.rb
require 'nitrox-core'

puts NitroxCore.version
```

```sh
bundle
rubocop -A
rspec
```
