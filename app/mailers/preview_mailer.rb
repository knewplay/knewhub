# Remove database records created to preview the mailer
class PreviewMailer < ActionMailer::Preview
  def self.call(...)
    message = nil
    ActiveRecord::Base.transaction do
      message = super(...)
      raise ActiveRecord::Rollback
    end
    message
  end
end
