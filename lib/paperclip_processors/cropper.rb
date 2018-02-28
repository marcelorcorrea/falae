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
      ret = nil
      if target.cropping?
        ret = ["-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
        target.crop_w = target.crop_h = nil
        target.crop_x = target.crop_y = nil
        ret
      end
    end
  end
end

