class FeatureFlag
  class << self
    def enable_new_user_registration?
      ENV.fetch("FEATURE_FLAG_ENABLE_NEW_USER_REGISTRATION", "false").downcase == "true"
    end

    def enable_user_mailer?
      ENV.fetch("FEATURE_FLAG_ENABLE_USER_MAILER", "false").downcase == "true"
    end
  end
end
