module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      crop = crop_command
      if crop
        crop + super.join(' ').sub(/ -crop \S+/, '').split(' ')
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      if target.cropping?
        commands = ["-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
        target.crop_w = target.crop_h = nil
        target.crop_x = target.crop_y = nil
        resize = options[:resize_image] || {}
        r_width, r_height = resize[:width], resize[:height]
        commands << "-resize" << "#{r_width}x#{r_height}" if r_width && r_height
        commands
      end
    end
  end
end
