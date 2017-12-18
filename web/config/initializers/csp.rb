SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      lax: true
    }
  }

  # Add "; preload" and submit the site to hstspreload.org for best protection.
  config.hsts = "max-age=#{1.year.to_i}; includeSubdomains"
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = "strict-origin-when-cross-origin"

  config.clear_site_data = [
    "cache",
    "cookies",
    "storage",
    "executionContexts"
  ]

  config.csp = {
    preserve_schemes: true,
    base_uri: %w('self'),
    #default_src: %w('self' https:),
    default_src: %w('self'),
    frame_ancestors: %w('none'),
    child_src: %w('none'),
    plugin_types: %w('none'),
    media_src: %w('none'),
    object_src: %w('none'),
    #font_src: %w('self' https: data:),
    font_src: %w('self' data:),
    #img_src: %w('self' www.arasaac.org https: data:),
    img_src: %w('self' www.arasaac.org data:),
    #script_src: %w('self' 'unsafe-inline' https:),
    script_src: %w('self' 'unsafe-inline'),
    #style_src: %w('self' https:),
    style_src: %w('self'),
    #upgrade_insecure_requests: true,
    block_all_mixed_content: true,
  }

  # This is available only from 3.5.0; use the `report_only: true` setting for 3.4.1 and below.
  #config.csp_report_only = config.csp.merge({
  #  img_src: %w(somewhereelse.com),
  #  report_uri: %w(https://report-uri.io/example-csp-report-only)
  #})

  #config.hpkp = {
  #  report_only: false,
  #  max_age: 60.days.to_i,
  #  include_subdomains: true,
  #  report_uri: "https://report-uri.io/example-hpkp",
  #  pins: [
  #    {sha256: "abc"},
  #    {sha256: "123"}
  #  ]
  #}
end