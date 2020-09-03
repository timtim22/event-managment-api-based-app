class AddColumDefaultToEventAttachments < ActiveRecord::Migration[5.2]
  def change
    change_column_default :event_attachments, :media_type, from: '0', to: 'image'
  end
end
