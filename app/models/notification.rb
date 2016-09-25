# == Schema Information
#
# Table name: notifications
#
#  notification_id :string(32)       primary key
#  sender_id       :string(32)
#  recipient_id    :string(32)
#  body            :string(255)
#  type_of         :string(255)
#  state           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Notification < ApplicationRecord

  ## IDENTIFIER (start) ======================================================
  self.primary_key = 'notification_id'
  ## IDENTIFIER (end)

  ## ASSOCIATIONS (start) ====================================================
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
  ## ASSOCIATIONS (end)

  ## DEFAULTS (start) ========================================================
  before_validation :set_defaults
  after_save :send_broadcast, if: :original?
  # after_save :notify_tenant, if: :alert?
  ## DEFAULTS (end)

  ## SCOPES (start) ========================================================
  scope :unread, -> { where(state: 'new') }
  scope :sorted, -> { order(created_at: :desc) }
  scope :broadcast, -> { where(type_of: 'broadcast') }
  ## SCOPES (end)

  # Helper sets all defaults on the current model prior to validation.
  def set_defaults
    self.notification_id ||= Track::Util::Uuid.generate
    self.state = 'new' unless state
  end # def set_defaults

  def summary
    self.body.truncate 30, :separator => /\w/
  end

  def read?
    state != 'new'
  end

  def alert?
    type_of != 'alert'
  end

  def broadcast?
    type_of == 'broadcast'
  end

  def journal?
    type_of == 'journal'
  end

  def original?
    state == 'original'
  end

  def mark_as_read
    self.update_attribute(:state,'read')
  end

  def self.mark_all_as_read(user)
    user.notifications.each {|n| n.mark_as_read }
  end

  def today?
    created_at.to_date == Date.today
  end

  def received
    today? ? created_at.strftime('%R %p') : created_at.strftime('%D')
  end

  def sender_display
    self.sender ? self.sender.full_name : 'System Notification'
  end

  def recipient_display
    self.recipient ? self.recipient.full_name : 'System Notification'
  end

  def notify_tenant
    Tenant.current.admins.each do |ta|
      Notification.create(recipient: ta, body: "you have a thriver in distress")
    end
  end

  def send_broadcast
    sender.tenant.users.each do |u|
      Notification.create(sender: sender, recipient: u, type_of: 'broadcast', body: body) unless u == sender
    end
    update_attributes(state: 'read')
  end

end
