# Custom handler to render Markdown files in HTML
module MarkdownHandler
  # erb template handler to allow support of embedded erb inside Markdown files
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template, source)
    loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date])
    parsed = FrontMatterParser::Parser.new(:md, loader:).call(source)
    erb_source = erb.call(template, parsed.content)
    extensions = {
      fenced_code_blocks: true,
      disable_indented_code_blocks: true
    }

    render_options = {
      escape_html: true,
      with_toc_data: true
    }

    "Redcarpet::Markdown.new(CustomRender.new(#{render_options}), #{extensions}).render(begin;#{erb_source};end)"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
