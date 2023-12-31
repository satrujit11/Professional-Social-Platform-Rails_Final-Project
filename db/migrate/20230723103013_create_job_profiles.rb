# rubocop:disable all
# frozen_string_literal: true

class CreateJobProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :job_profiles do |t|
      t.string :title
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
