Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'
  get "user/index"
  get "user/edit"
  get "user/new"
  post "user/edit"
  get "user/delete"

  get "user/change_password"
  post "user/change_password"

  post "user/new"
  get "user/view"
  get "/logout" => 'user#logout'
  get "/login" => "user#login"
  post "/login" => "user#login"

  get "user/roles"
  get "user/permissions"

  get "home/aggregates"
  get "home/aggregates_by_period"

  get "user/new_role"
  get "user/edit_role"
  get "user/edit_role"
  post "user/edit_role"
  post "user/new_role"
  get "user/delete_role"
  get "user/view_role"

  get "user/new_permission"
  get "user/edit_permission"
  get "user/edit_permission"
  post "user/edit_permission"
  post "user/new_permission"
  get "user/delete_permission"
  get "user/view_permission"

  get "user/role_permissions"
  post "user/role_permissions"

  get "user/user_roles"
  post "user/user_roles"

  get "location/index"
  get "location/tags"

  get "location/new_tag"
  post "location/new_tag"

  get "location/view_tag"
  get  "location/edit_tag"
  post "location/edit_tag"
  get "location/delete_tag"

  get "location/new"
  post "location/new"
  get "location/view"
  get "location/delete"

  get  "location/edit"
  post "location/edit"

  get "location/ajax_locations"
  get "client/client_types"
  get "client/new_type"
  post "client/new_type"

  get "client/edit_type"
  post "client/edit_type"

  get "client/view_type"
  get "client/delete_type"

  get "client/index"
  get "client/ajax_clients"

  get "fridge/index"
  get "fridge/ajax_fridges"

  get "client/new"
  post "client/new"

  get "client/edit"
  post "client/edit"

  get "client/view"

  get "fridge/new"
  post "fridge/new"

  get "fridge/edit"
  post "fridge/edit"

  get "fridge/helpdesk_token"
  post "fridge/helpdesk_token"

  get "fridge/selected_pending_services"
  get "fridge/selected_active_tokens"
  get "fridge/selected_recorded_fridges"
  get "fridge/selected_services_done"

  get "fridge/service"
  post "fridge/service"

  get "fridge/view"

  get "module/view_module"

  get "client/client_suggestions"
  get "fridge/fridge_suggestions"

  get "/complaints/:client_id" => "encounter#complaints"
  post "/create/:client_id" => "encounter#create"

  get "/diagnosis/:client_id" => "encounter#diagnosis"
  get "/vitals/:client_id" => "encounter#vitals"
  get "/prescribe/:client_id" => "drug#prescribe"
  get "/dispense/:client_id" => "drug#dispense"
  get "/outcomes/:client_id"  => "encounter#outcomes"

  get "/configs/:module" => "configuration#index"

  get "/lab_departments" => "configuration#lab_departments"
  get "/new_department" => "configuration#new_department"
  get "/edit_department" => "configuration#edit_department"

  post "/new_department" => "configuration#new_department"
  post "/edit_department" => "configuration#edit_department"
end
