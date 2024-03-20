require 'administrate/base_dashboard'

class QuestionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    answers: Field::HasMany,
    batch_code: Field::String,
    body: Field::Text,
    hidden: Field::Boolean,
    page_path: Field::String,
    repository: Field::BelongsTo,
    tag: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # Attributes that will be displayed on the model's index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    repository
    page_path
    tag
    answers
  ].freeze

  # Attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    repository
    page_path
    tag
    body
    answers
    batch_code
    hidden
    created_at
    updated_at
  ].freeze

  # Attributes that will be displayed on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[].freeze

  # Filters that can be used while searching via the search field of the dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how questions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(question)
  #   "Question ##{question.id}"
  # end
end
