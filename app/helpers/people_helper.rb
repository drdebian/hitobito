# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module PeopleHelper

  def format_gender(person)
    gender_label(person.gender)
  end

  def gender_label(gender)
    t("activerecord.attributes.person.genders.#{gender.presence || 'default'}")
  end

  def dropdown_people_export(details = false, emails = true)
    Dropdown::PeopleExport.new(self, current_user, params, details, emails).to_s
  end

  def format_birthday(person)
    if person.birthday?
      f(person.birthday) << ' ' <<  t('people.years_old', years: person.years)
    end
  end

  def sortable_grouped_person_attr(t, sortable_attrs, grouping_attr = nil, &block)
    list = sortable_attrs.map do |attr|
      t.sort_header(attr.to_sym, Person.human_attribute_name(attr.to_sym))
    end

    list.unshift(Person.human_attribute_name(grouping_attr.to_sym)) if grouping_attr

    t.col(safe_join(list, ' | '), &block)
  end

end
