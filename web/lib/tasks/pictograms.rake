require "open-uri"

namespace :pictograms do
  desc 'Populate pictograms table with images from a folder'
  task :populate_table, [:folder] => :environment do |task, args|
    folder = args.folder
    unless folder
      msg = 'You need specify a folder param (e.g. rails pictograms:populate_table[<folder>]).'
      abort(msg)
    end
    populate_table(folder)
  end

  desc 'Download some pictograms from araasac and populate db'
  task download_samples: :environment do
    download_samples()
  end


  # functions

  def populate_table(folder)
    entries = Dir.entries(folder).reject { |entry| File.directory? entry }
    validated_filetypes = check_file_type(folder, entries)
    normalized_filenames = validated_filetypes.map do |entry|
      normalize_filename(entries, folder, entry)
    end
    rename_files(folder, entries, normalized_filenames)
    insert_into_pictogram_table(folder)
  end

  def check_file_type(folder, entries)
    entries.map do |entry|
      ef_filename, ef_extension = entry.split(/\.([^.]*)$/)
      entry_file = File.open File.join(folder, entry)
      ef_mime_type = MimeMagic.by_magic entry_file
      ef_mime_subtype = ef_mime_type&.subtype
      if ef_mime_subtype && ef_extension != ef_mime_subtype
        if !ef_extension
          possible_name = "#{entry}.#{ef_mime_subtype}"
          entry = generate_suffixed_filename_if_neessary(entries, possible_name)
        elsif ef_extension != 'jpg' || ef_mime_subtype != 'jpeg'
          entry = entry.sub /#{ef_extension}$/, ef_mime_subtype
        end
      end
      entry
    end
  end

  def normalize_filename(entries, folder, entry)
    normalized_filename = entry.strip.sub(/^[^\p{L}]*/, '').gsub(' ', '_')
    return normalized_filename if normalized_filename == entry
    generate_suffixed_filename_if_neessary(entries, normalized_filename)
  end

  def rename_files(folder, entries, filenames)
    entries.zip(filenames) do |entry, filename|
      next if entry == filename
      File.rename File.join(folder, entry), File.join(folder, filename)
    end
  end

  def insert_into_pictogram_table(folder)
    Dir.entries(folder).reject {|f| File.directory? f}.each do |file|
      img = File.new File.join(folder, file)
      Pictogram.create! image: img
    end
  end

  def generate_suffixed_filename_if_neessary(entries, filename)
    return filename unless entries.include? filename
    basename, extension = filename.split(/(\.[^.]*)$/)
    index = Integer(filename[/_(\d)*$/, 1] || 1)
    loop do
      suffix = "_#{index}"
      suffixed_filename = "#{basename}#{suffix}#{extension}"
      return suffixed_filename unless entries.include? suffixed_filename
      index += 1
    end
  end

  def download_samples()
    tmp_load_folder = '/tmp/pictograms'

    pictograms = [
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

    Dir.mkdir tmp_load_folder unless Dir.exist? tmp_load_folder

    puts "Saving samples in #{tmp_load_folder}"

    pictograms.each do |pictogram|
      file_path = File.join tmp_load_folder, pictogram[:name]
      File.open(file_path, 'wb') do |file|
        puts "Downloading: #{pictogram[:url]}"
        file.write open(pictogram[:url]).read
      end
      file_type = MimeMagic.by_magic(File.open(file_path)).subtype
      File.rename file_path, "#{file_path}.#{file_type}"
    end

    Dir.entries(tmp_load_folder).reject {|f| File.directory? f}.each do |entry|
      img = File.new File.join(tmp_load_folder, entry)
      Pictogram.create! image: img
    end
  end
end
