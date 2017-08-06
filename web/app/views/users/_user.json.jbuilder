json.extract! user, :name, :last_name, :email, :photo

json.spreadsheets user.spreadsheets do |spreadsheet|
  json.partial! 'spreadsheets/spreadsheet', spreadsheet: spreadsheet
end
