# RuboCop Minitest

[![Gem Version](https://badge.fury.io/rb/rubocop-minitest.svg)](https://badge.fury.io/rb/rubocop-minitest)
[![CI](https://github.com/rubocop/rubocop-minitest/actions/workflows/test.yml/badge.svg)](https://github.com/rubocop/rubocop-minitest/actions/workflows/test.yml)

A [RuboCop](https://github.com/rubocop/rubocop) extension focused on enforcing [Minitest](https://github.com/minitest/minitest) best practices and coding conventions.
The library is based on the guidelines outlined in the community [Minitest Style Guide](https://minitest.rubystyle.guide).

## Installation

Just install the `rubocop-minitest` gem

```sh
$ gem install rubocop-minitest
```

or if you use bundler put this in your `Gemfile`

```ruby
gem 'rubocop-minitest', require: false
```

## Usage

You need to tell RuboCop to load the Minitest extension. There are three
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
plugins: rubocop-minitest
```

Alternatively, use the following array notation when specifying multiple extensions.

```yaml
plugins:
  - rubocop-other-extension
  - rubocop-minitest
```

Now you can run `rubocop` and it will automatically load the RuboCop Minitest
cops together with the standard cops.

> [!NOTE]
> The plugin system is supported in RuboCop 1.72+. In earlier versions, use `require` instead of `plugins`.

### Command line

```sh
$ rubocop --plugin rubocop-minitest
```

### Rake task

```ruby
require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.plugins << 'rubocop-minitest'
end
```

## The Cops

All cops are located under
[`lib/rubocop/cop/minitest`](lib/rubocop/cop/minitest), and contain
examples/documentation. The documentation is published [here](https://docs.rubocop.org/rubocop-minitest/).

In your `.rubocop.yml`, you may treat the Minitest cops just like any other
cop. For example:

```yaml
Minitest/AssertNil:
  Exclude:
    - test/my_file_to_ignore_test.rb
```

## Documentation

You can read a lot more about RuboCop Minitest in its [official docs](https://docs.rubocop.org/rubocop-minitest/).

## Readme Badge

If you use RuboCop Minitest in your project, you can include one of these badges in your readme to let people know that your code is written following the community Minitest Style Guide.

[![Minitest Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop-minitest)

[![Minitest Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://minitest.rubystyle.guide)

Here are the Markdown snippets for the two badges:

``` markdown
[![Minitest Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop-minitest)

[![Minitest Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://minitest.rubystyle.guide)
```

## Contributing

Checkout the [contribution guidelines](CONTRIBUTING.md).

## License

`rubocop-minitest` is MIT licensed. [See the accompanying file](LICENSE.txt) for
the full text.
