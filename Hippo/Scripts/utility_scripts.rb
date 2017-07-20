require 'rubygems'
require 'bundler/setup'

desc 'Generate asset'
task :asset do

  FILE_NAME   = "Hippo.sketch"
  FILE_URL    = "https://dl.dropbox.com/s/oai479dnr1wvbau/#{FILE_NAME}"
  SKETCH_ROOT = "Sketch"

  sh "mkdir -p #{SKETCH_ROOT}"
  sh "cd #{SKETCH_ROOT} && curl -O -L #{FILE_URL}"

  XCASSETS_PATH     = "Hippo/Resources/Assets.xcassets"
  SLIDE_SCRIPT_ROOT = "Scripts"

  sh "python '#{SLIDE_SCRIPT_ROOT}/importFromSketch.py' '#{SKETCH_ROOT}/#{FILE_NAME}' '#{XCASSETS_PATH}' 'MyAsset'"

end
