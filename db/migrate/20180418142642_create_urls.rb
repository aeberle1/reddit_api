class CreateUrls < ActiveRecord::Migration[5.1]
  def change
    create_table :urls do |t|
      t.string :url
      t.integer :reddit_engs

      t.timestamps
    end
  end
end
