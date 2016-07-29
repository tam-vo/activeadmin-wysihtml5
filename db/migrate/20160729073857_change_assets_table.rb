class ChangeAssetsTable < ActiveRecord::Migration
  def up
    drop_table :assets
    create_table :assets do |t|
      t.attachment :storage
      t.string :dimensions
      t.timestamps
    end
  end

  def down
    drop_table :assets
    create_table :assets do |t|
      t.string :storage_uid
      t.string :storage_name
      t.timestamps
    end
  end
end
