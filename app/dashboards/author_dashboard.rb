require 'administrate/base_dashboard'

class AuthorDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    github_installations: Field::HasMany,
    github_uid: Field::String,
    github_username: Field::String,
    name: Field::String,
    repositories: Field::HasMany,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    github_installations
    github_uid
    github_username
    created_at
    updated_at
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[].freeze

  # Attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
  ].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how authors are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(author)
    author.name
  end
end
