# encoding: utf-8

class LocalidadeHoje < Sinatra::Base

  LOCALES = Marshal.load(File.read('./files/localidades.txt'))
  NORMALIZED_LOCALES = Marshal.load(File.read('./files/normalized_localidades.txt'))

  enable :static
  enable :sessions


  set :views,  File.join(File.dirname(__FILE__), 'views')
  set :public_folder, File.join(File.dirname(__FILE__), 'public')
  set :files,  File.join(settings.public_folder, 'files')

  helpers do
    def flash(message = '')
      session[:flash] = message
    end
  end

  not_found do
    haml '404'
  end

  error do
    haml "Error (#{request.env['sinatra.error']})"
  end

  get '/' do
    @flash = session[:flash]
    session[:flash] = nil

    haml :index
  end

  get '/procura' do
    @flash = session[:flash]
    session[:flash] = nil

    letters = params[:letras].to_s.gsub(' ', '').downcase
    todas = params[:todas]
    palavras = params[:palavras].to_i

    palavras = nil if palavras == 0

    letters_arr = letters.split(//)

    letters_count = {}
    letters_arr.uniq.each { |l| letters_count[l] = letters_arr.count(l) }

    solutions = []
    NORMALIZED_LOCALES.each_with_index do |locale, index|
      ok = letters_arr.uniq.all? do |letter|
        locale.split(//).count(letter) >= letters_count[letter]
      end
      if palavras && todas && ok
        solutions << LOCALES[index] if locale.length == letters_arr.size && palavras == LOCALES[index].split(' ').size
      elsif palavras && ok
        solutions << LOCALES[index] if palavras == LOCALES[index].split(' ').size
      elsif todas && ok
        solutions << LOCALES[index] if locale.length == letters_arr.size
      elsif ok
        solutions << LOCALES[index]
      end
    end

    @letters_tried = letters
    @todas = todas
    @palavras = palavras

    @solutions = solutions.uniq.sort

    @flash_m = "Talvez queira preencher melhor o formulário para conseguirmos descobrir a Localidade" if @solutions.size > 99

    haml :index
  end
end
