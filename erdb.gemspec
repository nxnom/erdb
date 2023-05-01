require_relative "lib/erdb/version"

Gem::Specification.new do |s|
  s.name = "erdb"
  s.version = ERDB::VERSION
  s.authors = ["Wai Yan Phyo"]
  s.email = "oyhpnayiaw@gmail.com"
  s.required_ruby_version = ">= 2.7.0"
  s.description = "ERDB is a Ruby Gem for generation Entity-Relationship Diagrams (ERD)."
  s.summary = "ERDB is a Ruby Gem for generation Entity-Relationship Diagrams (ERD)."
  s.homepage = "https://github.com/oyhpnayiaw/erdb"
  s.bindir = "bin"
  s.executables = ["erdb"]
  s.license = "MIT"
  s.metadata = {
    "source_code_uri" => "https://github.com/oyhpnayiaw/erdb",
    "rubygems_mfa_required" => "true"
  }
  s.files = Dir["{bin,lib}/**/*", "LICENSE.txt", "README.md", "CHANGES.md"]
  s.add_runtime_dependency "activerecord", "~> 7.0"
  s.add_runtime_dependency "clipboard", "~> 1.3"
  s.add_runtime_dependency "sqlite3", "~> 1.6"
  s.add_runtime_dependency "watir", "~> 7.2"
  # for windows
  s.add_runtime_dependency "ffi", "~> 1.15" if Gem.win_platform?

  s.development_dependencies "rubocop", "~> 1.50"
end
