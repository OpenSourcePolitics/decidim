# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "rails", git: "https://github.com/rails/rails", branch: "6-0-stable"

gem "decidim", path: "."
gem "decidim-conferences", path: "."
gem "decidim-consultations", path: "."
gem "decidim-initiatives", path: "."

gem "activesupport", "6.0.1"
gem "bootsnap", "~> 1.4"
gem "railties", "6.0.1"

gem "puma", "~> 4.1"
gem "uglifier", "~> 4.1"

gem "faker", "~> 1.9"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", path: "."
end

group :development do
  gem "jbuilder", "~> 2.7"
  gem "sass-rails", ">= 6"
  gem "sqlite3", "~> 1.4"
  gem "turbolinks", "~> 5"
  gem "webdrivers"
  gem "webpacker", "~> 4.0"

  gem "letter_opener_web", "~> 1.3"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.0.1"
end
