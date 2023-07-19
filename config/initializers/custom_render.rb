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
    absolute_path = Rails.root.to_s + define_request_path + define_file_path(relative_path)
    data = File.read(absolute_path)
    <<~CODE
      <pre class='code-block'>
      <p>File: #{relative_path}</p>
      <code>#{data}</code>
      </pre>
    CODE
  end

  def define_request_path
    request_path = Thread.current[:request].fullpath
    match_data = request_path.match(%r{(.+/)(.+)})
    # Route GET /books uses RepositoriesController#show action
    # This action has all its views prepended by 'repos'
    match_data[1].gsub(%r{(/books/)}, '/repos/')
  end

  def define_file_path(relative_path)
    match_data = relative_path.match(%r{(./)(.+)})
    match_data[2]
  end
end
