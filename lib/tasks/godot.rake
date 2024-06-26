namespace = File.basename(File.expand_path('.', __FILE__.chomp('.rake')))

require 'uri'
require 'net/http'

releases_url = 'https://github.com/godotengine/godot-builds/releases'

if (ENV['VERSION'].nil? or ENV['VERSION'].empty?)
  redirect_version_url = Net::HTTP.get_response(URI("#{releases_url}/latest/"))['Location']
  version = redirect_version_url.split('/')[-1]
else
  version = "#{ENV['VERSION']}"
end

arch             = 'x86_64'
download_file    = "Godot_v#{version}_linux.#{arch}.zip"
download_url     = "#{releases_url}/download/#{version}/#{download_file}"
icon_resolutions = [16, 32, 48, 64, 128, 256, 512]

namespace "#{namespace}" do
  desc 'Download the necessary sources for the version specified.'
  task :download => [:clean] do |task|
    FileUtils.cd(ROOT_DIR) {
      system("wget #{download_url}")
    }
  end

  desc 'Create binaries from the source code.'
  task :build => [:download] do |task|
    FileUtils.cd(ROOT_DIR) {
      FileUtils.mkdir('pkg')
      FileUtils.mkdir_p('pkg/usr/share/applications')
      FileUtils.mkdir_p('pkg/opt/godot')
      FileUtils.mkdir_p('pkg/usr/share/icons/hicolor')

      # Create icons
      icon_resolutions.each { |res|
        FileUtils.mkdir_p("pkg/usr/share/icons/hicolor/#{res}x#{res}/apps")
        system("convert files/godot/godot.png -resize #{res}x#{res} pkg/usr/share/icons/hicolor/#{res}x#{res}/apps/godot.png")
      }

      # Create desktop shortcut
      FileUtils.cp('files/godot/godot.desktop', 'pkg/usr/share/applications')

      # Uncompress application
      system("unzip #{download_file} -d pkg")
      FileUtils.mv("pkg/#{download_file.chomp('.zip')}", 'pkg/opt/godot/godot')
      FileUtils.rm_r("pkg/#{download_file.chomp('.zip')}", :force => true)
    }
  end

  desc 'Create a debian package from the binaries.'
  task :build_artifact => [:build] do |task|
    FileUtils.cd(ROOT_DIR) {
      system("fpm -s dir -t deb -a amd64 -v #{version} -n godot --license MIT \
        --prefix / -C pkg -m 'Kristof Willaert <kristof.willaert@gmail.com>' \
        --after-install files/godot/postinst \
        --before-remove files/godot/prerm \
        --url 'https://godotengine.org' --vendor 'Godot Foundation' \
        --description 'Full 2D and 3D game engine with editor' ."
      )
    }
  end

  desc 'Remove generated files.'
  task :clean do |task|
    FileUtils.cd(ROOT_DIR) {
      FileUtils.rm(Dir.glob('Godot*.zip*'))
      FileUtils.rm(Dir.glob('Godot*.tpz'))
      FileUtils.rm_r('pkg', :force => true)
      FileUtils.rm(Dir.glob('*.deb'))
    }
  end
end
