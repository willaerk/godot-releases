namespace = File.basename(File.expand_path('.', __FILE__.chomp('.rake')))

require 'uri'
require 'net/http'

releases_url = 'https://github.com/godotengine/godot/releases'

if (ENV['VERSION'].nil? or ENV['VERSION'].empty?)
  redirect_version_url = Net::HTTP.get_response(URI("#{releases_url}/latest/"))['Location']
  version = redirect_version_url.split('/')[-1]
else
  version = "#{ENV['VERSION']}-stable"
end

arch             = 'x86_64'
download_file    = "Godot_v#{version}_mono_linux_#{arch}.zip"
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
      FileUtils.mkdir_p('pkg/opt/godot-mono/bin')
      FileUtils.mkdir_p('pkg/usr/share/icons/hicolor')

      system("unzip #{download_file} -d pkg/opt/godot-mono/bin")
      FileUtils.mv("pkg/opt/godot-mono/bin/#{download_file.chomp('.zip')}", 'pkg/opt/godot-mono/bin/godot')

      #Create icons
      icon_resolutions.each { |res|
        FileUtils.mkdir_p("pkg/usr/share/icons/hicolor/#{res}x#{res}/apps")
        system("convert files/godot-mono.png -resize #{res}x#{res} pkg/usr/share/icons/hicolor/#{res}x#{res}/apps/godot-mono.png")
      }

      #Create desktop shortcut
      FileUtils.cp('files/godot-mono.desktop', 'pkg/usr/share/applications')
    }
  end

  desc 'Create a debian package from the binaries.'
  task :build_artifact => [:build] do |task|
    FileUtils.cd(ROOT_DIR) {
      system("fpm -s dir -t deb -a amd64 -v #{version} -n godot-mono --license MIT \
        --prefix / -C pkg -m 'Kristof Willaert <kristof.willaert@gmail.com>' \
        --after-install files/postinst.godot-mono --after-remove files/postrm.godot-mono \
        --url 'https://godotengine.org' --vendor 'Godot Foundation' \
        --description 'Full 2D and 3D game engine with editor (with C# support)' ."
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

