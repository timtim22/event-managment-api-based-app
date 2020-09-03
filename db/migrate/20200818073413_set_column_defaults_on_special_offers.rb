class SetColumnDefaultsOnSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    change_column_default :special_offers, :title, from: nil, to: ''
    change_column_default :special_offers, :sub_title, from: nil, to: ''
    change_column_default :special_offers, :description, from: nil, to: ''
    change_column_default :special_offers, :validity, from: nil, to: ''
    change_column_default :special_offers, :image, from: nil, to: ''
    change_column_default :special_offers, :created_at, from: nil, to: ''
    change_column_default :special_offers, :updated_at, from: nil, to: ''
    change_column_default :special_offers, :is_redeemed, from: nil, to: false
    change_column_default :special_offers, :redeem_code, from: nil, to: ''
    change_column_default :special_offers, :end_time, from: nil, to: ''
    change_column_default :special_offers, :location, from: nil, to: ''
    change_column_default :special_offers, :lat, from: nil, to: ''
    change_column_default :special_offers, :lng, from: nil, to: ''
    change_column_default :special_offers, :time, from: nil, to: ''
  
  end
end
