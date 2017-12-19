# This enables print out which file/line generated a db query log
# To enable uncomment the last line with "QueryTrace.enable!"

module QueryTrace
  def self.enable!
    ::ActiveRecord::LogSubscriber.send(:include, self)
  end

  def self.append_features(klass)
    super
    klass.class_eval do
      unless method_defined?(:log_info_without_trace)
        alias_method :log_info_without_trace, :sql
        alias_method :sql, :log_info_with_trace
      end
    end
  end

  def log_info_with_trace(event)
    log_info_without_trace(event)
    trace_log = Rails.backtrace_cleaner.clean(caller).first
    if trace_log && event.payload[:name] != 'SCHEMA'
      logger.debug("   \\_ \e[33mCalled from:\e[0m " + trace_log)
    end
  end
end

# QueryTrace.enable!
