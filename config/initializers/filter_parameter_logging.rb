# Keeps credentials and personal data out of logs and error reports. A client
# can type secrets straight into the GraphQL query text, so the whole query,
# its variables and multipart operations are filtered; operationName stays.
Rails.application.config.filter_parameters += %i[
  query variables operations
  passw email secret token _key crypt salt certificate otp ssn cvv cvc
]
