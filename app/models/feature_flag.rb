class FeatureFlag < ApplicationRecord
  # Known flags. A stored row overrides the env var; without a row the env var is the default.
  DEFINITIONS = {
    enable_new_user_registration: {
      description: "Allow new users to sign up.",
      env: "FEATURE_FLAG_ENABLE_NEW_USER_REGISTRATION"
    },
    enable_user_mailer: {
      description: "Send emails to users (e.g. the welcome email).",
      env: "FEATURE_FLAG_ENABLE_USER_MAILER"
    }
  }.freeze

  validates :name, presence: true, uniqueness: true, inclusion: { in: DEFINITIONS.keys.map(&:to_s) }

  class << self
    def enabled?(name)
      stored = find_by(name: name.to_s)
      stored ? stored.enabled : env_default(name)
    end

    def set!(name, enabled)
      definition!(name)
      find_or_initialize_by(name: name.to_s).update!(enabled: enabled)
    end

    def env_default(name)
      env_value(name).to_s.downcase == "true"
    end

    # Raw env var value, or nil when unset
    def env_value(name)
      ENV[definition!(name)[:env]]
    end

    def stored?(name)
      exists?(name: name.to_s)
    end

    def definition!(name)
      DEFINITIONS.fetch(name.to_sym) { raise ArgumentError, "Unknown feature flag: #{name}" }
    end
  end

  # FeatureFlag.enable_new_user_registration?, FeatureFlag.enable_user_mailer?, ...
  DEFINITIONS.each_key do |flag_name|
    define_singleton_method(:"#{flag_name}?") { enabled?(flag_name) }
  end
end
