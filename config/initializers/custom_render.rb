# Custom renderer that sets a custom class for code blocks
require 'rouge/plugins/redcarpet'

class CustomRender < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet

  def paragraph(text)
    process_custom_tags(text.strip)
  end

  def header(text, header_level)
    # If header already includes a link, do not add an anchor link
    if @options[:with_toc_data] && text.exclude?('a href')
      id = text.parameterize(separator: '-')
      <<~HEADER
        <h#{header_level} id=#{id} class="collections__anchor-link">
        <a href="##{id}" class="collections__anchor-link__text">#{text}</a>
        <i class="fa-solid fa-link collections__anchor-link__icon" aria-hidden="true"></i>
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
