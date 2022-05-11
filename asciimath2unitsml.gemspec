# coding: utf-8

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "asciimath2unitsml/version"

Gem::Specification.new do |spec|
  spec.name          = "asciimath2unitsml"
  spec.version       = Asciimath2UnitsML::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Convert Asciimath via MathML to UnitsML"
  spec.description   = <<~DESCRIPTION
    Convert Asciimath via MathML to UnitsML
  DESCRIPTION

  spec.homepage      = "https://github.com/plurimath/asciimath2unitsml"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  # get an array of submodule dirs relatively to root repo
  `git config --file .gitmodules --get-regexp '\\.path$'`
    .split("\n")
    .map { |kv_str| kv_str.split(" ") }
    .each do |(_, submodule_path)|
    # for each submodule, change working directory to that submodule
    Dir.chdir(submodule_path) do
      # issue git ls-files in submodule's directory
      submodule_files = `git ls-files | grep -i '.yaml$'`.split($\)

      submodule_files_paths = submodule_files.map do |filename|
        File.join submodule_path, filename
      end

      # add relative paths to gem.files
      spec.files += submodule_files_paths
    end
  end

  spec.add_dependency "asciimath"
  spec.add_dependency "htmlentities"
  spec.add_dependency "nokogiri", "~> 1"
  spec.add_dependency "rsec", "~> 1.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rexml"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 1.5.2"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
end
