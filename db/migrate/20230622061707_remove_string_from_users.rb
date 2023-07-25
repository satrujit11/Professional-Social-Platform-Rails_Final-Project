# frozen_string_literal: true

class RemoveStringFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :string
  end
end
