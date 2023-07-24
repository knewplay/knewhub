# Custom renderer that sets a custom class for code blocks
class CustomRender < Redcarpet::Render::HTML
  def paragraph(text)
    process_custom_tags(text.strip)
  end

  private

  def process_custom_tags(text)
    # [codefile <relative_path>]
    if (t = text.match(/(\[codefile )(.+)(\])/))
      process_codefile(t[2])
    else
      text
    end
  end

  def process_codefile(relative_path)
    absolute_path = Rails.root.to_s + RequestPath.define_base_url + relative_path
    data = File.read(absolute_path)
    <<~CODE
      <pre class='code-block'>
      <p>File: #{relative_path}</p>
      <code>#{data}</code>
      </pre>
    CODE
  end
end
