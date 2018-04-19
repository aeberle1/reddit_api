class AddEngDataToUrls < ActiveRecord::Migration[5.1]
  def change
    add_column :urls, :eng_data, :string
  end
end
