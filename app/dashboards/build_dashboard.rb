require 'administrate/base_dashboard'

class BuildDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    repository_name: Field::String,
    aasm_state: Field::String,
    action: Field::String,
    completed_at: Field::DateTime,
    logs: Field::HasMany,
    repository: Field::BelongsTo.with_options(
      searchable: true,
      searchable_fields: %w[id name]
    ),
    status: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    repository
    repository_name
    aasm_state
    action
    completed_at
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    repository
    repository_name
    aasm_state
    action
    created_at
    completed_at
    status
    logs
  ].freeze

  # Attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how builds are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(build)
  #   "Build ##{build.id}"
  # end
end
