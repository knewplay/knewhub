module RenderMarkdownHelper
  def render_markdown(markdown_content)
    return if markdown_content.nil?

    extensions = {
      fenced_code_blocks: true,
      disable_indented_code_blocks: true
    }

    render_options = {
      escape_html: true,
      with_toc_data: true
    }

    Redcarpet::Markdown.new(CustomRender.new(render_options), extensions).render(markdown_content)
  end
end
