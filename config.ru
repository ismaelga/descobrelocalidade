$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'bundler'

Bundler.require


require 'localidade_hoje'

run LocalidadeHoje

