require "spec_helper"

describe Purchasable do
  subject { Factory :plan }

  describe "#contact_msg_instead_of_price?" do
    it "returns true if needs_staff_approval?" do
      subject.stub(:needs_staff_approval?) { true }
      subject.contact_msg_instead_of_price?.should be_true
    end
  end

  describe "#price_for_display" do
    it "obeys contact_msg_instead_of_price?" do
      subject.stub(:contact_msg_instead_of_price?) { true }
      subject.price_for_display.should == "Contact the Registrar"
    end
  end

  context "when at least one attendee has selected it" do
    before do
      subject.attendees << Factory(:attendee)
    end

    describe "#destroy" do
      it "raises an error" do
        expect { subject.destroy }.to
          raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end

    describe "#valid?" do
      it "returns false if the price is changed" do
        subject.price += 50
        subject.valid?.should be_false
      end

      it "returns true if zero attributes have changed" do
        subject.valid?.should be_true
      end
    end
  end

end