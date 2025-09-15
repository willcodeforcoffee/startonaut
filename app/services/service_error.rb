class ServiceError < StandardError
  attr_reader :original_exception

  def initialize(msg, e = nil)
    super(msg)
    @original_exception = e
    set_backtrace(e.backtrace) if e
  end
end
