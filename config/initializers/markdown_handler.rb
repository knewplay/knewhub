# Custom handler to render Markdown files in HTML
module MarkdownHandler
  # erb template handler to allow support of embedded erb inside Markdown files
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template, source)
    erb_source = erb.call(template, source)
    extensions = {
      fenced_code_blocks: true,
      disable_indented_code_blocks: true,
      escape_html: true
    }

    "Redcarpet::Markdown.new(CustomRender, #{extensions}).render(begin;#{erb_source};end).html_safe"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
