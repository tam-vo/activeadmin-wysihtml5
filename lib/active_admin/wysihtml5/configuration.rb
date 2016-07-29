module ActiveAdmin
  module Wysihtml5
    include ActiveSupport::Configurable
    config_accessor :convert_options, :source_file_options, :base_path, :s3_credentials,
      :storage_path, :storage_url, :paperclip_storage, :s3_host_name
    self.convert_options = {
      :all => '-quality 75 -strip'
    }
    self.source_file_options = {
      :all => '-density 72'
    }
    self.base_path = 'asset_storages'
    self.paperclip_storage = :filesystem
    self.s3_credentials = "#{Rails.root}/config/s3.yml"
    self.s3_host_name =  's3.amazonaws.com'
    self.storage_path = ":rails_root/public/system/asset_storages/:id/:style/:basename.:extension"
    self.storage_url = "/system/asset_storages/:id/:style/:basename.:extension"
  end
end
