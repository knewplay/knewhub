require "administrate/base_dashboard"

class AdministratorDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    permissions: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    permissions
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    permissions
    created_at
    updated_at
  ].freeze

  # Attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
    permissions
  ].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how administrators are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(administrator)
  #   "Administrator ##{administrator.id}"
  # end
end
