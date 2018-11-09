require 'rails_helper'

RSpec.describe CspReportsController, type: :controller do
  describe 'POST #create' do
    let(:csp_report) {
      {
        'csp-report' => {
          'blocked-uri' => 'blocked-uri',
          'document-uri' => 'document-uri',
          'effective-directive' => 'effective-directive',
          'original-policy' => 'original-policy',
          'referrer' => 'referrer',
          'script-sample' => 'script-sample',
          'source-file' => 'source-file',
          'status-code' => 'status-code',
          'violated-directive' => 'violated-directive'
        }
      }
    }
    let(:csp_report_hash) { csp_report['csp-report'] }

    let(:csp_report_create_params) {
      {
        user_agent: request.user_agent,
        blocked_uri: csp_report_hash['blocked-uri'],
        document_uri: csp_report_hash['document-uri'],
        effective_directive: csp_report_hash['effective-directive'],
        original_policy: csp_report_hash['original-policy'],
        referrer: csp_report_hash['referrer'],
        script_sample: csp_report_hash['script-sample'],
        source_file: csp_report_hash['source-file'],
        status_code: csp_report_hash['status-code'],
        violated_directive: csp_report_hash['violated-directive']
      }
    }

    before do
      allow(controller).to receive(:set_locale)
      allow(JSON).to receive(:parse).and_return(csp_report)
      allow(CspReport).to receive(:create!)
      post :create
    end

    it 'creates an entry in csp reports' do
      expect(CspReport).to have_received(:create!)
        .with(csp_report_create_params)
    end
  end
end
