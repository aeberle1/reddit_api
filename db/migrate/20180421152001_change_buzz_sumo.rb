class ChangeBuzzSumo < ActiveRecord::Migration[5.1]
  def change
    change_column :urls, :buzzsumo, :string
  end
end
