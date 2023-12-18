module ExtractFrontMatterHelper
  def extract_front_matter(absolute_path)
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date])
    FrontMatterParser::Parser.parse_file(absolute_path, loader:).front_matter
  end
end
