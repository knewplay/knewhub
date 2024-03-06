# Custom renderer for Markdown files
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
    # [codefile <relative_path>]
    if (t = text.match(/(\[codefile )(.+)(\])/))
      process_codefile(t[2])
    # [codegist <gist_url>]
    elsif (t = text.match(/(\[codegist )(.+)(\])/)) 
      process_codegist(t[2])
    # [details Hint]content[/details]
    elsif (t = text.match(%r{(\[details )(.+)(\])(.+)(\[/details\])}))
      process_details(t[2], t[4])
    elsif (t = text.match(/(\[3d-viewer )(.+)(\])/))
      # [3d-viewer <relative_path>]
      process_3d_file(t[2])
    else
      "<p>#{text}</p>"
    end
  end

  # Allow code blocks to be created from a separate file in the same repository
  def process_codefile(relative_path)
    absolute_path = Rails.root.to_s + RequestPath.define_base_url + relative_path
    code = File.read(absolute_path)
    extension = File.extname(relative_path)
    language = extension.delete_prefix(".")

    block_code(code, language)
  end

  # Allow code from GitHub gists to be displayed
  def process_codegist(gist_url)
    <<~SCRIPT
      <script src="#{gist_url}.js"></script>
    SCRIPT
  end

  def process_details(title, content)
    <<~DETAIL
      <details>
      <summary>#{title}</summary>#{content}
      </details>
    DETAIL
  end

  # Allow 3D files to be rendered using Autodesk Viewer SDK
  def process_3d_file(relative_path)
    filepath = Pathname.new(RequestPath.define_base_url).join(relative_path).to_s
    filepath = filepath.delete_prefix('/')
    autodesk_file = AutodeskFile.find_by(filepath:)
    
    if autodesk_file&.urn
      <<~HTML
        <div data-controller="autodesk-viewer" data-autodesk-viewer-urn-value="#{autodesk_file.urn}">
        <link rel="stylesheet" href="https://developer.api.autodesk.com/modelderivative/v2/viewers/style.min.css" type="text/css">
        <script src='https://developer.api.autodesk.com/modelderivative/v2/viewers/7.*/viewer3D.min.js'></script>
        <button type="button" data-action="click->autodesk-viewer#display" data-autodesk-viewer-target="displayBtn">Display</button>
        <button type="button" data-action="click->autodesk-viewer#hide" data-autodesk-viewer-target="hideBtn">Hide</button>
        <div class="autodesk-viewer" data-autodesk-viewer-target="viewerDiv" ></div>
        </div>
      HTML
    else
      "<div>Error rendering Autodesk viewer</div>"
    end
  end
end
