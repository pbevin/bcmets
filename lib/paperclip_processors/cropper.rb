module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      if crop_command
        crop_command + super.join(' ').sub(/ -crop \S+/, '').split(' ')
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
      return unless target.cropping?

      w, h = target.crop_w.to_i, target.crop_h.to_i
      x, y = target.crop_x.to_i, target.crop_y.to_i
      [ "-crop", "#{w}x#{h}+#{x}+#{y}" ]
    end
  end
end
