namespace :pictograms do
  desc 'Download some pictograms from araasac and populate db'
  task download_samples: :environment do
    require "open-uri"

    TMP_FOLDER = '/tmp/pictograms'

    PICTOGRAMS = [
      { name: 'oi', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6522.png' },
      { name: 'tchau', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6028.png' },
      { name: 'obrigado', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/8/8129.png' },
      { name: 'eu', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6632.png' },
      { name: 'voce', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6625.png' },
      { name: 'nos', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/7/7186.png' },
      { name: 'querer', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/3/31141.png' },
      { name: 'comer', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/28413.png' },
      { name: 'beber', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/6/6061.png' },
      { name: 'fruta', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/4/4653.png' },
      { name: 'bolo', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/8/8042.png' },
      { name: 'sorvete', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/1/11382.png' },
      { name: 'agua', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/2248.png' },
      { name: 'leite', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/2445.png' },
      { name: 'suco', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/1/11463.png' },
      { name: 'quente', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/26716.png' },
      { name: 'frio', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/2/26865.png' },
      { name: 'gostoso', url: 'http://www.arasaac.org/repositorio/thumbs/10/200/7/7124.png' },
    ]

    Dir.mkdir TMP_FOLDER unless Dir.exist? TMP_FOLDER

    puts "Saving samples in #{TMP_FOLDER}"

    PICTOGRAMS.each do |pictogram|
      file_path = "#{TMP_FOLDER}/#{pictogram[:name]}"
      File.open(file_path, 'wb') do |file|
        puts "Downloading: #{pictogram[:url]}"
        file.write open(pictogram[:url]).read
      end
      file_type = MimeMagic.by_magic(File.open(file_path)).subtype
      File.rename file_path, "#{file_path}.#{file_type}"
    end

    Dir.entries(TMP_FOLDER).reject {|f| File.directory? f}.each do |entry|
      img = File.new "#{TMP_FOLDER}/#{entry}"
      Pictogram.create! image: img
    end
  end
end
