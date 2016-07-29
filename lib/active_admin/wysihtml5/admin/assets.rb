ActiveAdmin.register Asset do
  menu false
  index as: :grid do |asset|
    link_to(image_tag(asset.storage.url(:small)), admin_asset_path(asset))
  end

  form do |f|
    f.inputs do
      f.input :storage
    end
    f.actions
  end

  show do
    attributes_table do
      row('Dimensions') do
        "#{asset.storage.width}px x #{asset.storage.height}px"
      end
      row('Thumbnail') do
        image_tag(asset.thumb_url)
      end
      row('small') do
        image_tag(asset.storage.url(:small))
      end
      row('medium') do
        image_tag(asset.storage.url(:medium))
      end
      row('large') do
        image_tag(asset.storage.url(:large))
      end
      row('Full Image') do
        image_tag(asset.storage.url)
      end
    end
  end

  controller do
    def permitted_params
      params.permit asset: [:storage, :retained_storage, :remove_storage, :storage_url]
    end
    def create
      # If an app is using Rack::RawUpload, it can just use
      # params['file'] and not worry with original_filename parsing.
      if params['file']
        @asset = Asset.new
        @asset.storage = params['file']

        if @asset.save!
          render json: { success: true }.to_json
        else
          render nothing: true, status: 500 and return
        end
      elsif params['qqfile']
        @asset = Asset.new
        io = request.env['rack.input']
        # throw io

        # def io.original_filename=(name) @original_filename = name; end
        # def io.original_filename() @original_filename; end

        # io.original_filename = params['qqfile']

        @asset.storage = io
        if @asset.save!
          render json: { success: true }.to_json
        else
          render nothing: true, status: 500 and return
        end
      else
        create!
      end
    end

  end
end

