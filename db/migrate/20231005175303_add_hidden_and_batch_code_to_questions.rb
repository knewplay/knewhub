class AddHiddenAndBatchCodeToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :hidden, :boolean, default: false
    add_column :questions, :batch_code, :uuid
  end
end
