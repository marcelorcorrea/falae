require "open-uri"

namespace :pictograms do
  desc 'Populate pictograms table with images from a folder'
  task :populate_table, [:folder, :locale] => :environment do |task, args|
    unless valid?(args)
      msg = 'You need specify a valid folder and locale params (e.g. rails pictograms:populate_table[<folder>,<locale>]).'
      abort(msg)
    end
    folder = File.expand_path(args.folder)
    locale = args.locale
    populate_table(folder, locale)
  end

  desc 'Download some pictograms from araasac and populate db'
  task populate_with_samples: :environment do
    populate_with_samples()
  end


  # functions

  def valid?(params)
    folder = File.expand_path(params.folder)
    availables_locales = AVAILABLE_LOCALES.keys.to_s
    folder && Dir.exist?(folder) && availables_locales.include?(params.locale)
  end

  def populate_table(folder, locale)
    entries = Dir.entries(folder).reject { |entry| File.directory? entry }
    validated_filetypes = handle_file_types(folder, entries)
    normalized_filenames = normalize_filenames(validated_filetypes)
    unique_filenames = generate_unique_filenames(normalized_filenames)
    rename_files(folder, entries, unique_filenames)
    insert_into_pictogram_table(folder, locale)

  end

  def handle_file_types(folder, entries)
    puts 'Checking file types.'
    entries.map do |entry|
      ef_filename, ef_extension = entry.split(/\.(png|jpg|jpeg|bmp|tiff|gif)$/)
      entry_file = File.open File.join(folder, entry)
      ef_mime_type = MimeMagic.by_magic entry_file
      ef_mime_subtype = ef_mime_type&.subtype
      if ef_mime_subtype && ef_extension != ef_mime_subtype
        entry = if !ef_extension
          "#{entry}.#{ef_mime_subtype}"
        elsif ef_extension != 'jpg' || ef_mime_subtype != 'jpeg'
          entry.sub /#{ef_extension}$/, ef_mime_subtype
        end
      end
      entry
    end
  end

  def normalize_filenames(entries)
    puts 'Normalizing file names.'
    entries.map do |entry|
      entry.strip.sub(/^[^\p{L}]*/, '').gsub(' ', '_')
    end
  end

  def generate_unique_filenames(entries)
    puts 'Generating unique file names.'
    unique_filenames = []
    entries.each do |entry|
      unique_filenames << if unique_filenames.include? entry
        suffixed_entry = ''
        basename, extension = entry.split(/(\.[^.]*)$/)
        index = Integer(entry[/_(\d)*$/, 1] || 1)
        loop do
          suffix = "_#{index}"
          suffixed_entry = "#{basename}#{suffix}#{extension}"
          break unless unique_filenames.include? suffixed_entry
          index += 1
        end
        suffixed_entry
      else
        entry
      end
    end
    unique_filenames
  end

  def rename_files(folder, entries, filenames)
    puts 'Renaming files with unique names.'
    entries.zip(filenames) do |entry, filename|
      next if entry == filename
      File.rename File.join(folder, entry), File.join(folder, filename)
    end
  end

  def insert_into_pictogram_table(folder, locale)
    entries = Dir.entries(folder).reject {|f| File.directory? f}
    entries_size = entries.length
    entries.each_with_index do |file, idx|
      img = File.new File.join(folder, file)
      Pictogram.create! image: img, locale: locale rescue puts "Error in #{file}"
      print "\rInserting pictograms into database (#{idx}/#{entries_size})."
    end
    puts
  end

  def populate_with_samples()
    samples_folder_path = "#{Rails.root}/storage/samples"

    sample_files = [
      'oi.png',
      'tchau.png',
      'obrigado.png',
      'eu.png',
      'voce.png',
      'nos.png',
      'querer.png',
      'comer.png',
      'beber.png',
      'fruta.png',
      'bolo.png',
      'sorvete.png',
      'agua.png',
      'leite.png',
      'suco.png',
      'quente.png',
      'frio.png',
      'gostoso.png',
    ]

    sample_files.each do |file|
      img = File.new File.join(samples_folder_path, file)
      Pictogram.create! image: img, locale: 'pt'
    end
  end
end
