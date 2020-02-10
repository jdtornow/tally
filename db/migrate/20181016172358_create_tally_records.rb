class CreateTallyRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :tally_records do |t|
      t.date :day
      t.bigint :recordable_id
      t.string :recordable_type
      t.string :key
      t.integer :value, default: 0

      t.timestamps
    end

    add_index :tally_records, [ :day, :key, :recordable_id, :recordable_type ], name: "index_tally_records_on_day", unique: true
  end
end
