require 'administrate/base_dashboard'

class RepositoryDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    branch: Field::String,
    description: Field::String,
    git_url: Field::String,
    last_pull_at: Field::DateTime,
    name: Field::String,
    title: Field::String,
    token: Field::Password,
    uuid: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    title
    branch
    last_pull_at
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    name
    title
    branch
    description
    last_pull_at
    updated_at
  ].freeze

  # Attributes that will be displayed on the model's form new page.
  FORM_ATTRIBUTES_NEW = %i[
    name
    title
    branch
    token
  ].freeze

  # Attributes that will be displayed on the model's form edit page.
  FORM_ATTRIBUTES_EDIT = %i[
    name
    title
    branch
  ].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how repositories are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(repository)
  #   "Repository ##{repository.id}"
  # end
end
