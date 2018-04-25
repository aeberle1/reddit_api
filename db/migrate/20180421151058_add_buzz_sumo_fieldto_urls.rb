class AddBuzzSumoFieldtoUrls < ActiveRecord::Migration[5.1]
  def change
    add_column :urls, :buzzsumo, :integer
  end
end
