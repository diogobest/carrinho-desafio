# # Configurations
# session_url = "#{ENV.fetch('REDIS_URL')}/session"
# secure = Rails.env.production?
# key = Rails.env.production? ? "_app_session" : "_app_session_#{Rails.env}"
# p key
#
# Rails.application.config.session_store :redis_store,
#                                        url: session_url,
#                                        expire_after: 180.days,
#                                        key: key,
#                                        secure: secure,
#                                        same_site: :lax
#
