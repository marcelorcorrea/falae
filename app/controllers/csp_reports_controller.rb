class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    report = JSON.parse(request.body.read)['csp-report']
    CspReport.create!(
      user_agent: request.user_agent,
      blocked_uri: report['blocked-uri'],
      document_uri: report['document-uri'],
      effective_directive: report['effective-directive'],
      original_policy: report['original-policy'],
      referrer: report['referrer'],
      script_sample: report['script-sample'],
      source_file: report['source-file'],
      status_code: report['status-code'],
      violated_directive: report['violated-directive']
    )
  end
end
