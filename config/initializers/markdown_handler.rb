# Custom handler to render Markdown files in HTML
module MarkdownHandler
  # Rendering is performed by `collections.html.erb`
  def self.call(_template, _source)
    ""
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
