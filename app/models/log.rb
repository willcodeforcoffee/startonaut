class Log < ApplicationRecord
  belongs_to :loggable, polymorphic: true

  enum :severity, {
    debug: "debug",
    info: "info",
    warn: "warn",
    error: "error",
    fatal: "fatal"
  }, default: :info
end
