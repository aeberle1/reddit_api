class ChangeColumnNames < ActiveRecord::Migration[5.1]
  def change
    rename_column :urls, :reddit_engs, :reddit
    rename_column :urls, :eng_data, :reddit_data
  end
end
