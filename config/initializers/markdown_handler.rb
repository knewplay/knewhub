# Custom handler to render Markdown files in HTML
module MarkdownHandler
  # Rendering is performed by `layouts/collections`.
  # This handler is still required to allow files with `md` extension to be rendered
  # as HTML by default and call CustomRender
  def self.call(_template, _source)
    ""
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
