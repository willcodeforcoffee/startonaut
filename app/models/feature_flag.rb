class FeatureFlag
  class << self
    def enable_new_user_registration?
      Rails.configuration.x.feature_flags.enable_new_user_registration
    end
  end
end
