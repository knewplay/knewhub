require 'administrate/base_dashboard'

class RepositoryDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    author: Field::BelongsTo,
    branch: Field::String,
    description: Field::String,
    git_url: Field::String,
    last_pull_at: Field::DateTime,
    name: Field::String,
    title: Field::String,
    token: Field::Password,
    uuid: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    last_build_created_at: Field::DateTime,
    last_build_status: Field::String
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    author
    id
    name
    title
    branch
    last_build_created_at
    last_build_status
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[].freeze

  # Attributes that will be displayed on the model's form new page.
  FORM_ATTRIBUTES_NEW = %i[].freeze

  # Attributes that will be displayed on the model's form edit page.
  FORM_ATTRIBUTES_EDIT = %i[].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how repositories are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(repository)
  #   "Repository ##{repository.id}"
  # end
end
