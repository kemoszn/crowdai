require 'spec_helper'

RSpec.describe SubmissionGradedNotificationMailer, type: :mailer do

  describe 'methods' do
    let(:challenge) { create :challenge }
    let(:participant) { create :participant }
    let(:submission) { create :submission, challenge: challenge, participant: participant }
    let!(:mailer) { create :mailer, mailer_classname: described_class.to_s }


    it 'successfully sends a message' do
      res = described_class.new.sendmail(participant.id,submission.id)
      man = MandrillSpecHelper.new(res)
      expect(man.status).to eq 'sent'
      expect(man.reject_reason).to eq nil
      expect(Email.count).to eq(1)
      expect(Email.last.participant_id).to eq(participant.id)
      expect(Email.last.mailer_classname).to eq(described_class.to_s)
    end

    it 'addresses the email to the participant' do
      res = described_class.new.sendmail(participant.id,submission.id)
      man = MandrillSpecHelper.new(res)
      expect(man.merge_var('NAME')).to eq(participant.name)
    end

    it 'produces a body which is correct HTML' do
      res = described_class.new.sendmail(participant.id,submission.id)
      man = MandrillSpecHelper.new(res)
      expect(man.merge_var('BODY')).to be_a_valid_html_fragment
    end

    it 'produces a valid unsubscribe link' do
      res = described_class.new.sendmail(participant.id,submission.id)
      man = MandrillSpecHelper.new(res)
      expect(man.merge_var('UNSUBSCRIBE_LINK')).to be_a_valid_html_fragment
    end
  end

end
