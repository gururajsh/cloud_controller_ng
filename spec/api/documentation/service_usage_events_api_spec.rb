require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Service Usage Events (experimental)", :type => :api do
  let(:admin_auth_header) { admin_headers["HTTP_AUTHORIZATION"] }
  authenticated_request
  let(:guid) { VCAP::CloudController::ServiceUsageEvent.first.guid }
  let!(:event1) { VCAP::CloudController::ServiceUsageEvent.make }
  let!(:event2) { VCAP::CloudController::ServiceUsageEvent.make }
  let!(:event3) { VCAP::CloudController::ServiceUsageEvent.make }

  around do |example|
    admin_user
    example.run
    admin_user.destroy
  end

  standard_model_get :service_usage_event

  get "/v2/service_usage_events" do
    standard_list_parameters VCAP::CloudController::ServiceUsageEventsController
    request_parameter :after_guid, "Restrict results to Service Usage Events after the one with the given guid"

    example "List service usage events" do
      explanation <<-DOC
        Events are sorted by internal database IDs. This order may differ from created_at.

        Events close to the current time should not be processed because other events may still have open
        transactions that will change their order in the results.
      DOC

      client.get "/v2/service_usage_events?results-per-page=1&after_guid=#{event1.guid}", {}, headers
      status.should == 200
      standard_list_response parsed_response, :service_usage_event
    end
  end

  post "/v2/service_usage_events/destructively_purge_all_and_reseed_existing_instances" do
    example "Purge and reseed service usage events" do
      explanation <<-DOC
        Destroys all existing events. Populates new usage events, one for each existing service instance.
        All populated events will have a created_at value of current time.

        There is the potential race condition if service instances are currently being created or deleted.

        The seeded usage events will have the same guid as the service instance.
      DOC

      client.post "/v2/service_usage_events/destructively_purge_all_and_reseed_existing_instances", {}, headers
      status.should == 204
    end
  end
end
