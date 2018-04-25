class ChangeReddEngDefault < ActiveRecord::Migration[5.1]
  def change
    change_column :urls, :reddit_engs, :integer, :default => 0
  end
end
