json.extract! user, :name, :last_name, :email, :auth_token, :photo

json.spreadsheets user.spreadsheets do |spreadsheet|
  json.partial! 'spreadsheets/spreadsheet', spreadsheet: spreadsheet
end
