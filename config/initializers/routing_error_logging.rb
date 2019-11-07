# Overwriting log_error method from ActionDispatch::DebugExceptions to change
# the log level for ActionController::RoutingError from fatal to warning, also
# logging only the error message (excluding backtrace)

module ActionDispatch
  class DebugExceptions
    alias old_log_error log_error

    def log_error(request, wrapper)
      logger = logger(request)
      return unless logger

      exception = wrapper.exception
      if exception.is_a?(ActionController::RoutingError)
        logger.warn(exception.message)
      else
        old_log_error request, wrapper
      end
    end
  end
end
