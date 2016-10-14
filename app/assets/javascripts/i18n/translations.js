var I18n = I18n || {};
I18n.translations = {
    "ru": {
        "errors": {
            "messages": {
                "after_or_equal_to": "\u0434\u043e\u043b\u0436\u043d\u0430 \u0440\u0430\u0432\u043d\u044f\u0442\u044c\u0441\u044f \u0438\u043b\u0438 \u0431\u044b\u0442\u044c \u043f\u043e\u0437\u0434\u043d\u0435\u0435 \u0447\u0435\u043c %{date}",
                "not_a_date": "\u043d\u0435\u0432\u0435\u0440\u043d\u044b\u0439 \u0444\u043e\u0440\u043c\u0430\u0442",
                "after": "\u0434\u043e\u043b\u0436\u043d\u0430 \u0431\u044b\u0442\u044c \u043f\u043e\u0437\u0434\u043d\u0435\u0435 \u0447\u0435\u043c %{date}",
                "before_or_equal_to": "\u0434\u043e\u043b\u0436\u043d\u0430 \u0440\u0430\u0432\u043d\u044f\u0442\u044c\u0441\u044f \u0438\u043b\u0438 \u0431\u044b\u0442\u044c \u0440\u0430\u043d\u0435\u0435 \u0447\u0435\u043c %{date}",
                "before": "\u0434\u043e\u043b\u0436\u043d\u0430 \u0431\u044b\u0442\u044c \u0440\u0430\u043d\u0435\u0435 \u0447\u0435\u043c %{date}"
            }
        }
    },
    "es": {
        "errors": {
            "messages": {
                "after_or_equal_to": "tiene que ser posterior o igual a %{date}",
                "not_a_date": "no es una fecha",
                "after": "tiene que ser posterior a %{date}",
                "before_or_equal_to": "tiene que ser antes o igual a %{date}",
                "before": "tiene que ser antes de %{date}"
            }
        }
    },
    "nl": {
        "errors": {
            "messages": {
                "after_or_equal_to": "moet gelijk zijn aan of na %{date} liggen",
                "not_a_date": "is geen datum",
                "after": "moet na %{date} liggen",
                "before_or_equal_to": "moet gelijk zijn of voor %{date} liggen",
                "before": "moet voor %{date} liggen"
            }
        }
    },
    "ca": {
        "errors": {
            "messages": {
                "after_or_equal_to": "must be after or equal to %{date}",
                "not_a_date": "is not a date",
                "after": "must be after %{date}",
                "before_or_equal_to": "must be before or equal to %{date}",
                "before": "must be before %{date}"
            }
        }
    },
    "en": {
        "number": {
            "format": {
                "separator": ".",
                "precision": 3,
                "delimiter": ",",
                "significant": false,
                "strip_insignificant_zeros": false
            },
            "human": {
                "format": {
                    "precision": 3,
                    "delimiter": "",
                    "strip_insignificant_zeros": true,
                    "significant": true
                },
                "storage_units": {
                    "format": "%n %u",
                    "units": {"kb": "KB", "tb": "TB", "gb": "GB", "byte": {"one": "Byte", "other": "Bytes"}, "mb": "MB"}
                },
                "decimal_units": {
                    "format": "%n %u",
                    "units": {
                        "trillion": "Trillion",
                        "billion": "Billion",
                        "quadrillion": "Quadrillion",
                        "million": "Million",
                        "unit": "",
                        "thousand": "Thousand"
                    }
                }
            },
            "percentage": {"format": {"delimiter": ""}},
            "precision": {"format": {"delimiter": ""}},
            "currency": {
                "format": {
                    "format": "%u%n",
                    "unit": "$",
                    "separator": ".",
                    "precision": 2,
                    "delimiter": ",",
                    "strip_insignificant_zeros": false,
                    "significant": false
                }
            }
        },
        "activerecord": {
            "errors": {
                "messages": {
                    "record_invalid": "Validation failed: %{errors}",
                    "taken": "has already been taken"
                }
            }
        },
        "errors": {
            "messages": {
                "greater_than_or_equal_to": "must be greater than or equal to %{count}",
                "after_or_equal_to": "must be after or equal to %{date}",
                "not_found": "not found",
                "not_locked": "was not locked",
                "less_than_or_equal_to": "must be less than or equal to %{count}",
                "confirmation": "doesn't match confirmation",
                "not_a_date": "is not a date",
                "blank": "can't be blank",
                "not_an_integer": "must be an integer",
                "invalid": "is invalid",
                "exclusion": "is reserved",
                "odd": "must be odd",
                "before_or_equal_to": "must be before or equal to %{date}",
                "after": "must be after %{date}",
                "not_saved": {
                    "one": "1 error prohibited this %{resource} from being saved:",
                    "other": "%{count} errors prohibited this %{resource} from being saved:"
                },
                "already_confirmed": "was already confirmed, please try signing in",
                "even": "must be even",
                "empty": "can't be empty",
                "wrong_length": "is the wrong length (should be %{count} characters)",
                "too_short": "is too short (minimum is %{count} characters)",
                "less_than": "must be less than %{count}",
                "greater_than": "must be greater than %{count}",
                "equal_to": "must be equal to %{count}",
                "expired": "has expired, please request a new one",
                "before": "must be before %{date}",
                "too_long": "is too long (maximum is %{count} characters)",
                "accepted": "must be accepted",
                "inclusion": "is not included in the list",
                "not_a_number": "is not a number"
            }, "format": "%{attribute} %{message}"
        },
        "time": {
            "am": "am",
            "formats": {"default": "%a, %d %b %Y %H:%M:%S %z", "short": "%d %b %H:%M", "long": "%B %d, %Y %H:%M"},
            "pm": "pm"
        },
        "views": {
            "pagination": {
                "previous": "&lsaquo; Prev",
                "last": "Last &raquo;",
                "first": "&laquo; First",
                "next": "Next &rsaquo;",
                "truncate": "..."
            }
        },
        "date": {
            "month_names": [null, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
            "order": ["year", "month", "day"],
            "abbr_day_names": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
            "formats": {"default": "%Y-%m-%d", "short": "%b %d", "long": "%B %d, %Y"},
            "day_names": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
            "abbr_month_names": [null, "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        },
        "devise": {
            "failure": {
                "unauthenticated": "You need to sign in or sign up before continuing.",
                "timeout": "Your session expired, please sign in again to continue.",
                "invalid": "Invalid email or password.",
                "inactive": "Your account was not activated yet.",
                "unconfirmed": "You have to confirm your account before continuing.",
                "invalid_token": "Invalid authentication token.",
                "already_authenticated": "You are already signed in.",
                "locked": "Your account is locked."
            },
            "passwords": {
                "updated_not_active": "Your password was changed successfully.",
                "no_token": "You can't access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided.",
                "send_paranoid_instructions": "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.",
                "send_instructions": "You will receive an email with instructions about how to reset your password in a few minutes.",
                "updated": "Your password was changed successfully. You are now signed in."
            },
            "mailer": {
                "unlock_instructions": {"subject": "Unlock Instructions"},
                "reset_password_instructions": {"subject": "Reset password instructions"},
                "confirmation_instructions": {"subject": "Confirmation instructions"}
            },
            "unlocks": {
                "unlocked": "Your account has been unlocked successfully. Please sign in to continue.",
                "send_paranoid_instructions": "If your account exists, you will receive an email with instructions about how to unlock it in a few minutes.",
                "send_instructions": "You will receive an email with instructions about how to unlock your account in a few minutes."
            },
            "omniauth_callbacks": {
                "failure": "Could not authenticate you from %{kind} because \"%{reason}\".",
                "success": "Successfully authenticated from %{kind} account."
            },
            "registrations": {
                "signed_up_but_locked": "You have signed up successfully. However, we could not sign you in because your account is locked.",
                "signed_up_but_inactive": "You have signed up successfully. However, we could not sign you in because your account is not yet activated.",
                "update_needs_confirmation": "You updated your account successfully, but we need to verify your new email address. Please check your email and click on the confirm link to finalize confirming your new email address.",
                "destroyed": "Bye! Your account was successfully cancelled. We hope to see you again soon.",
                "signed_up_but_unconfirmed": "A message with a confirmation link has been sent to your email address. Please open the link to activate your account.",
                "updated": "You updated your account successfully.",
                "signed_up": "Welcome! You have signed up successfully."
            },
            "sessions": {"signed_out": "Signed out successfully.", "signed_in": "Signed in successfully."},
            "confirmations": {
                "confirmed": "Your account was successfully confirmed. You are now signed in.",
                "send_paranoid_instructions": "If your email address exists in our database, you will receive an email with instructions about how to confirm your account in a few minutes.",
                "send_instructions": "You will receive an email with instructions about how to confirm your account in a few minutes."
            }
        },
        "support": {
            "array": {
                "last_word_connector": ", and ",
                "words_connector": ", ",
                "two_words_connector": " and "
            }
        },
        "hello": "Hello world",
        "datetime": {
            "prompts": {
                "minute": "Minute",
                "month": "Month",
                "second": "Seconds",
                "hour": "Hour",
                "day": "Day",
                "year": "Year"
            },
            "distance_in_words": {
                "less_than_x_minutes": {
                    "one": "less than a minute",
                    "other": "less than %{count} minutes"
                },
                "x_days": {"one": "1 day", "other": "%{count} days"},
                "almost_x_years": {"one": "almost 1 year", "other": "almost %{count} years"},
                "x_seconds": {"one": "1 second", "other": "%{count} seconds"},
                "x_minutes": {"one": "1 minute", "other": "%{count} minutes"},
                "x_months": {"one": "1 month", "other": "%{count} months"},
                "less_than_x_seconds": {"one": "less than 1 second", "other": "less than %{count} seconds"},
                "about_x_hours": {"one": "about 1 hour", "other": "about %{count} hours"},
                "about_x_months": {"one": "about 1 month", "other": "about %{count} months"},
                "about_x_years": {"one": "about 1 year", "other": "about %{count} years"},
                "over_x_years": {"one": "over 1 year", "other": "over %{count} years"},
                "half_a_minute": "half a minute"
            }
        },
        "helpers": {
            "submit": {"submit": "Save %{model}", "create": "Create %{model}", "update": "Update %{model}"},
            "select": {"prompt": "Please select"}
        }
    }
};