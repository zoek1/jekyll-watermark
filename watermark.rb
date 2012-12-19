require 'mini_magick'
require 'fileutils'

module Jekyll
    class WatermarkGenerator < Generator
        safe true
        priority :low
        
        def generate(site)
            Dir.glob('_photos/**/*').each do |file|
                path = destination_path(file)
                if(File.file?(file))
                    watermark_image(site, file, path)
                    create_thumb(site, path)
                end
            end
        end
        
        private
        
        def add_to_static_file(site, path)
            name = File.basename(path)
            destination = File.dirname(path).sub(site.source, '')
            site.static_files << StaticFile.new(site, site.source, destination, name)
        end
        
        def destination_path(file)
            new_file = String.new(file)
            new_file["_photos"] = "photos"
            FileUtils.mkdir_p(File.dirname(new_file))
            new_file
        end
        
        def watermark_image(site, file, new_file)
            if(File.exist?(new_file))
                return
            end
            image = MiniMagick::Image.open(file)
            result = image.composite(MiniMagick::Image.open('img/watermark-large.png')) do |c|
                c.gravity "southeast"
            end
            result.write new_file
            add_to_static_file(site, new_file)
        end
        
        def create_thumb(site, file)
            thumb_file = File.join(File.join(File.dirname(file), "thumbs"), File.basename(file))
            if(File.exist?(thumb_file))
                return
            end
            
            width = 140
            height = width * 0.6
            FileUtils.mkdir_p(File.dirname(thumb_file))
            image = MiniMagick::Image.open(file)
            image.resize "#{width}x#{nil}"
            woffset = (image["width"] - width) / 2
            hoffset = (image["height"] - height) / 2
            image.gravity('NorthWest')
            image.crop "#{width}x#{height}+#{woffset}+#{hoffset}"
            result = image.composite(MiniMagick::Image.open('img/watermark-small.png')) do |c|
                c.gravity "southeast"
            end
            result.write thumb_file
            add_to_static_file(site, thumb_file)
        end
    end
end