require 'administrate/base_dashboard'

class LogDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    build: Field::BelongsTo,
    content: Field::Text.with_options(
      truncate: 150
    ),
    failure: Field::Boolean,
    step: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    step
    content
    failure
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[].freeze

  # Attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how logs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(log)
  #   "Log ##{log.id}"
  # end
end
