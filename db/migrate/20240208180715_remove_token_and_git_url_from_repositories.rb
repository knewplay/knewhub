class RemoveTokenAndGitUrlFromRepositories < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_columns :repositories, :token, :git_url, type: :string }
  end
end
