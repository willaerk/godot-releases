# Godot releases

This repository contains rake tasks and a GitHub actions workflow that
create Debian (and Ubuntu) package artifacts of recent stable Godot releases.
The resulting artifacts are added as GitHub releases.

Apart from merely providing the binaries, the artifact also takes care
of the desktop integration.

If you want to build your own artifact, just clone this repository, install the
necessary dependencies and run the relevant rake task.

```
$ git clone https://github.com/willaerk/godot-releases
Cloning into 'godot-releases'...
remote: Enumerating objects: 97, done.
remote: Counting objects: 100% (97/97), done.
remote: Compressing objects: 100% (55/55), done.
remote: Total 97 (delta 36), reused 79 (delta 18), pack-reused 0
Unpacking objects: 100% (97/97), 18.50 KiB | 1.16 MiB/s, done.
```
```
$ cd godot-releases
$ bundle install
Fetching gem metadata from https://rubygems.org/...............
Fetching rake 13.0.6
Installing rake 13.0.6
Fetching arr-pm 0.0.12
Installing arr-pm 0.0.12
Fetching backports 3.24.1
Installing backports 3.24.1
Using bundler 2.1.2
Fetching cabin 0.9.0
Installing cabin 0.9.0
Fetching clamp 1.0.1
Installing clamp 1.0.1
Fetching dotenv 2.8.1
Installing dotenv 2.8.1
Fetching insist 1.0.0
Installing insist 1.0.0
Fetching mustache 0.99.8
Installing mustache 0.99.8
Fetching stud 0.0.23
Installing stud 0.0.23
Fetching pleaserun 0.0.32
Installing pleaserun 0.0.32
Fetching rexml 3.2.6
Installing rexml 3.2.6
Fetching fpm 1.15.1
Installing fpm 1.15.1
Bundle complete! 2 Gemfile dependencies, 13 gems now installed.
Bundled gems are installed into `./vendor/bundle`
```
```
$ bundle exec rake
bundle exec rake
rake clean                      # Remove any temporary products
rake clobber                    # Remove any generated files
rake default                    # Default task prints the available targets
rake godot-mono:build           # Create binaries from the source code
rake godot-mono:build_artifact  # Create a debian package from the binaries
rake godot-mono:clean           # Remove generated files
rake godot-mono:download        # Download the necessary sources for the version specified
rake godot:build                # Create binaries from the source code
rake godot:build_artifact       # Create a debian package from the binaries
rake godot:clean                # Remove generated files
rake godot:download             # Download the necessary sources for the version specified
```
