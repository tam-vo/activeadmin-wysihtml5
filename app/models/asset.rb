class Asset < ActiveRecord::Base
  before_save :extract_dimensions
  serialize :dimensions

  has_attached_file :storage,
    styles: {
      small: '100x100#',
      medium: '320x320#',
      large: '640x640#'
    },
    source_file_options: ActiveAdmin::Wysihtml5.config.source_file_options,
    convert_options: ActiveAdmin::Wysihtml5.config.convert_options,
    storage: ActiveAdmin::Wysihtml5.paperclip_storage,
    s3_credentials: ActiveAdmin::Wysihtml5.s3_credentials,
    s3_host_name: ActiveAdmin::Wysihtml5.s3_host_name,
    url: ActiveAdmin::Wysihtml5.storage_url,
    path: ActiveAdmin::Wysihtml5.storage_path

  validates_attachment_presence :storage
  validates_attachment_size     :storage, :less_than => 20.megabytes
  validates_attachment_content_type :storage, :content_type => ["image/jpeg", "image/jpg", "image/png", "image/gif"]

  def thumb_url
    storage_url(:small)
  end

  def storage_url(size=nil)
    if ActiveAdmin::Wysihtml5.paperclip_storage.to_s == "s3"
      "#{ENV["ASSET_PROTOCOL"]}://#{ENV["ASSET_HOST"]}#{storage.path(size)}"
    else
      storage.url(size)
    end
  end

  def as_json(options = {})
    width, height = self.dimensions.try(:split, "x")
    {
      dimensions: {
        width: width,
        height: height
      },
      thumb_url: thumb_url,
      source_url: {
        full: storage_url,
        three_quarters: storage_url(:large),
        half: storage_url(:medium),
        one_quarter: storage_url(:small)
      }
    }
  end

  # Helper method to determine whether or not an attachment is an image.
  # @note Use only if you have a generic asset-type model that can handle different file types.
  def image?
    storage_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
  end

  private

  # Retrieves dimensions for image assets
  # @note Do this after resize operations to account for auto-orientation.
  def extract_dimensions
    return unless image?
    tempfile = storage.queued_for_write[:original]
    unless tempfile.nil?
      geometry = Paperclip::Geometry.from_file(tempfile)
      self.dimensions = [geometry.width.to_i, geometry.height.to_i].join('x')
    end
  end
end

