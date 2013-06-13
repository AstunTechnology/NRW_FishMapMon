from flaskext.babel import lazy_gettext

SECURITY_DEFAULT_HTTP_AUTH_REALM = lazy_gettext('You must sign in')
SECURITY_EMAIL_SUBJECT_REGISTER = lazy_gettext('Welcome')
SECURITY_EMAIL_SUBJECT_CONFIRM = lazy_gettext('Please confirm your email')
SECURITY_EMAIL_SUBJECT_PASSWORDLESS = lazy_gettext('Login instructions')
SECURITY_EMAIL_SUBJECT_PASSWORD_NOTICE = lazy_gettext(
    'Your password has been reset')
SECURITY_EMAIL_SUBJECT_PASSWORD_CHANGE_NOTICE = lazy_gettext(
    'Your password has been changed')
SECURITY_EMAIL_SUBJECT_PASSWORD_RESET = lazy_gettext(
    'Password reset instructions')
SECURITY_MSG_UNAUTHORIZED = (lazy_gettext(
    'You do not have permission to view this resource.'), 'error')
SECURITY_MSG_CONFIRM_REGISTRATION = (lazy_gettext(
    'Thank you. Confirmation instructions have been sent to %(email)s.'),
    'success')
SECURITY_MSG_EMAIL_CONFIRMED = (lazy_gettext(
    'Thank you. Your email has been confirmed.'), 'success')
SECURITY_MSG_ALREADY_CONFIRMED = (lazy_gettext(
    'Your email has already been confirmed.'), 'info')
SECURITY_MSG_INVALID_CONFIRMATION_TOKEN = (lazy_gettext(
    'Invalid confirmation token.'), 'error')
SECURITY_MSG_EMAIL_ALREADY_ASSOCIATED = (lazy_gettext(
    '%(email)s is already associated with an account.'), 'error')
SECURITY_MSG_PASSWORD_MISMATCH = (lazy_gettext('Password does not match'),
                                  'error')
SECURITY_MSG_RETYPE_PASSWORD_MISMATCH = (lazy_gettext(
    'Passwords do not match'), 'error')
SECURITY_MSG_INVALID_REDIRECT = (lazy_gettext(
    'Redirections outside the domain are forbidden'), 'error')
SECURITY_MSG_PASSWORD_RESET_REQUEST = (lazy_gettext(
    'Instructions to reset your password have been sent to %(email)s.'),
    'info')
SECURITY_MSG_PASSWORD_RESET_EXPIRED = (lazy_gettext(
    'You did not reset your password within %(within)s. '
    'New instructions have been sent to %(email)s.'), 'error')
SECURITY_MSG_INVALID_RESET_PASSWORD_TOKEN = (lazy_gettext(
    'Invalid reset password token.'), 'error')
SECURITY_MSG_CONFIRMATION_REQUIRED = (lazy_gettext(
    'Email requires confirmation.'), 'error')
SECURITY_MSG_CONFIRMATION_REQUEST = (lazy_gettext(
    'Confirmation instructions have been sent to %(email)s.'), 'info')
SECURITY_MSG_CONFIRMATION_EXPIRED = (lazy_gettext(
    'You did not confirm your email within %(within)s. '
    'New instructions to confirm your email have been sent to %(email)s.'),
    'error')
SECURITY_MSG_LOGIN_EXPIRED = (lazy_gettext(
    'You did not login within %(within)s. '
    'New instructions to login have been sent to %(email)s.'), 'error')
SECURITY_MSG_LOGIN_EMAIL_SENT = (lazy_gettext(
    'Instructions to login have been sent to %(email)s.'), 'success')
SECURITY_MSG_INVALID_LOGIN_TOKEN = (lazy_gettext('Invalid login token.'),
                                    'error')
SECURITY_MSG_DISABLED_ACCOUNT = (lazy_gettext('Account is disabled.'),
                                 'error')
SECURITY_MSG_EMAIL_NOT_PROVIDED = (lazy_gettext('Email not provided'),
                                   'error')
SECURITY_MSG_INVALID_EMAIL_ADDRESS = (lazy_gettext('Invalid email address'),
                                      'error')
SECURITY_MSG_PASSWORD_NOT_PROVIDED = (lazy_gettext('No password entered'),
                                      'error')
SECURITY_MSG_USER_DOES_NOT_EXIST = (lazy_gettext(
    'Specified user does not exist'), 'error')
SECURITY_MSG_INVALID_PASSWORD = (lazy_gettext('Invalid password'), 'error')
SECURITY_MSG_PASSWORDLESS_LOGIN_SUCCESSFUL = (lazy_gettext(
    'You have successfuly logged in.'), 'success')
SECURITY_MSG_PASSWORD_RESET = (lazy_gettext(
    'You successfully reset your password and '
    'you have been logged in automatically.'), 'success')
SECURITY_MSG_PASSWORD_CHANGE = (lazy_gettext(
    'You successfully changed your password.'), 'success')
SECURITY_MSG_LOGIN = (lazy_gettext('Please log in to access this page.'),
                      'info')
SECURITY_MSG_REFRESH = (lazy_gettext(
    'Please reauthenticate to access this page.'), 'info')
