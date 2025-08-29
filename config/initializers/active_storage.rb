# https://guides.rubyonrails.org/active_storage_overview.html#proxy-mode
# Setup Rails to proxy active storage files
# Then you can do things like
# <%= image_tag rails_storage_proxy_path(@user.avatar) %>
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
