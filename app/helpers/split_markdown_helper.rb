module SplitMarkdownHelper
  def split_markdown(absolute_path)
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date])
    parsed = FrontMatterParser::Parser.parse_file(absolute_path, loader:)
    [parsed.front_matter, parsed.content]
  end
end
