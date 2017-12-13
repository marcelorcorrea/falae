json.extract! user, :name, :last_name, :email, :auth_token, :photo, :profile

json.spreadsheets user.spreadsheets do |spreadsheet|
  json.partial! 'spreadsheets/spreadsheet', spreadsheet: spreadsheet
end
