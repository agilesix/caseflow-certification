require "rails_helper"

RSpec.feature "Save Certification" do
  class FakePdfService
    def self.save_form!(form:, values:)
      @saved_form = form
      @saved_values = values
    end

    class << self
      attr_reader :saved_values
    end
  end

  scenario "Saving a certification generates PDF form" do
    Form8.pdf_service = FakePdfService
    Fakes::AppealRepository.records = {
      "1234C" => Fakes::AppealRepository.appeal_ready_to_certify
    }

    visit "certifications/new/1234C"

    fill_in "Name of Appellant", with: "Shane Bobby"
    fill_in "Relationship to Veteran", with: "Brother"
    expect(find("#file-number-2 input")["readonly"]).to be_truthy
    fill_in "Full Veteran Name", with: "Micah Bobby"
    fill_in "Insurance file number", with: "INSURANCE-NO"
    click_on "Preview Completed Form 8"

    expect(FakePdfService.saved_values["appellant"]).to eq("Shane Bobby")
    expect(FakePdfService.saved_values["appellant_relationship"]).to eq("Brother")
    expect(FakePdfService.saved_values["file_number"]).to eq("VBMS-ID")
    expect(FakePdfService.saved_values["veteran_name"]).to eq("Micah Bobby")
    expect(FakePdfService.saved_values["insurance_loan_number"]).to eq("INSURANCE-NO")
  end
end