json.extract! user, :name, :last_name, :email

json.spreadsheets user.spreadsheets do |spreadsheet|
  json.partial! 'spreadsheets/spreadsheet', spreadsheet: spreadsheet
end
