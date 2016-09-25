if defined?(ActionMailer)
  class Track::Mailer < Devise::Mailer
    include Devise::Mailers::Helpers

    helper :application
    helper :subdomain
    include Devise::Controllers::UrlHelpers

  end
end
