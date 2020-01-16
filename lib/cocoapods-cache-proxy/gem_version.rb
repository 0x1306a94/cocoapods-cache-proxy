module CocoapodsCacheProxy
  VERSION = "0.0.2".freeze
end

module Pod
  def self.match_version?(*version)
    Gem::Dependency.new("", *version).match?('', Pod::VERSION) 
  end
end