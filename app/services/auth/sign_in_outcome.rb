module Auth
  # What a sign-in step hands back: the verified user, and their new session,
  # or nil when a code was emailed instead and the user must confirm it first.
  SignInOutcome = Data.define(:user, :session)
end
