require 'administrate/base_dashboard'

class AutodeskFileDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    filepath: Field::String,
    repository: Field::BelongsTo,
    urn: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    repository
    filepath
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    repository
    filepath
    urn
  ].freeze

  # Attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how autodesk files are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(autodesk_file)
  #   "AutodeskFile ##{autodesk_file.id}"
  # end
end
