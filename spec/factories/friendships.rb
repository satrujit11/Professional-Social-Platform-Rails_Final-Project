# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    association :user, factory: :user
    association :friend, factory: :user
    association :requested_by_user, factory: :user
  end
end
