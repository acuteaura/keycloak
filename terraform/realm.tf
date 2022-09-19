resource "keycloak_realm" "this" {
  realm        = "internal"
  display_name = "sapphic.systems internal auth"

  reset_password_allowed   = false
  verify_email             = true
  remember_me              = false
  login_with_email_allowed = true
  duplicate_emails_allowed = false

  login_theme   = "keycloak"
  account_theme = "keycloak"
  admin_theme   = "keycloak"
  email_theme   = "keycloak"
}