class CreateSolidusMolliePaymentSource < ActiveRecord::Migration[6.0]
  def change
    create_table :solidus_mollie_payment_sources do |t|
      t.string :payment_id
      t.string :payment_method_name
      t.string :issuer
      t.string :status
      t.string :payment_url
      t.integer :payment_method_id
      t.integer :user_id
      
      t.timestamps
    end
  end
end
