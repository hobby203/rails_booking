A2Mk2::Application.routes.draw do
  get "home/index"

  get "room/view"

  get "room/new"

  post "room/process_new"

  get "room/edit"

  put "room/process_edit"

  get "room/delete"

  get "room/process_delete"

  get "booking/view"

  get "booking/new"

  post "booking/process_new"

  get "booking/edit"

  put "booking/process_edit"

  get "booking/delete"

  get "booking/process_delete"

  get "user/login"

  post "user/process_login"

  get "user/edit"

  put "user/process_edit"

  get "user/new"

  post "user/process_new"

  get "user/account"

  get "user/process_logout"

  get "user/view"

  get "user/delete"

  get "user/process_delete"

  get "user/password"

  post "user/process_password"

  get "user/reset"

  post "user/process_reset"

  root :to => "home#index" ##sets "index" page to be the index function, in the home controller
end
