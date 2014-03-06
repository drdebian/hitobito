# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  group_id   :integer          not null
#  type       :string(255)      not null
#  label      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require 'spec_helper'

describe Event::Role do

  [Event, Event::Course].each do |event_type|
    event_type.role_types.each do |part|
      context part do
        it 'must have valid permissions' do
          # although it looks like, this example is about participation.permissions and not about Participation::Permissions
          Event::Role::Permissions.should include(*part.permissions)
        end
      end
    end
  end

  describe 'destroying roles' do
    before do
      @role = Event::Role::Participant.new
      @role.participation = participation
      @role.save!
    end

    let(:event) { events(:top_event) }
    let(:role)  { @role.reload }
    let(:participation) { Fabricate(:event_participation, event: event) }

    it 'decrements event#participant_count' do
      expect { role.destroy }.to change {  event.reload.participant_count }.by(-1)
    end

    it 'decrements event#participant_count if participations has other non participant roles' do
      treasurer = Event::Role::Treasurer.new
      treasurer.participation = Fabricate(:event_participation, event: event)
      treasurer.save!

      expect { role.destroy }.to change {  event.reload.participant_count }.by(-1)
    end

  end
end
