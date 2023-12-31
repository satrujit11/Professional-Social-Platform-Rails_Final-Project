# rubocop:disable all
# frozen_string_literal: true

class AddReportToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :report, :integer, default: 0
  end
end
