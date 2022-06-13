require 'spec_helper'
require 'request_spec_shared_examples'

RSpec.describe 'App Security Group Update Timestamp' do
  let(:user) { VCAP::CloudController::User.make(guid: 'user-guid') }
  let(:admin_header) { admin_headers_for(user) }

  describe 'GET /internal/v4/asg_latest_update' do
    let(:expected_time) { DateTime.new(2022) }

    it 'returns a timestamp' do
      VCAP::CloudController::AsgLatestUpdate.make(last_update: expected_time)
      get '/internal/v4/asg_latest_update', nil, admin_header

      expect(last_response).to have_status_code(200)
      parsed_response = MultiJson.load(last_response.body)
      expect(parsed_response['last_update']).to eq('2022-01-01T00:00:00Z')
    end
  end
end
