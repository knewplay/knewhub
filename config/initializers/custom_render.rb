# Custom renderer that sets a custom class for code blocks
class CustomRender < Redcarpet::Render::HTML
  def paragraph(text)
    process_custom_tags(text.strip)
  end

  def header(text, header_level)
    if @options[:with_toc_data]
      id = text.parameterize(separator: '-')
      <<~HEADER
        <h#{header_level} id=#{id}>
        <a href="##{id}" class="collections__anchor-link">#{text}</a>
        <i class="fa-solid fa-link" aria-hidden="true"></i>
        </h#{header_level}>\n
      HEADER
    else
      "<h#{header_level}>#{text}</h#{header_level}>\n"
    end
  end

  private

  def process_custom_tags(text)
    if (t = text.match(/(\[codefile )(.+)(\])/)) # [codefile <relative_path>]
      process_codefile(t[2])
    elsif (t = text.match(%r{(\[details )(.+)(\])(.+)(\[/details\])})) # [details Hint]content[/details]
      process_details(t[2], t[4])
    else
      "<p>#{text}</p>"
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

  def process_details(title, content)
    <<~DETAIL
      <details>
      <summary>#{title}</summary>#{content}
      </details>
    DETAIL
  end
end
