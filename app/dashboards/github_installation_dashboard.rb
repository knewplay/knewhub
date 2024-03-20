require 'administrate/base_dashboard'

class GithubInstallationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    author: Field::BelongsTo,
    installation_id: Field::String,
    repositories: Field::HasMany,
    uid: Field::String,
    username: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    author
    installation_id
    repositories
    uid
    username
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[].freeze

  # Attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how github installations are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(github_installation)
  #   "GithubInstallation ##{github_installation.id}"
  # end
end
